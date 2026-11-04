#!/usr/bin/env bash
# Runs bin/next on made-up Stop events, a temp git repo and a temp config dir; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
N=$PWD/bin/next
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
export CLAUDE_CONFIG_DIR=$T/cfg CLAUDE_CODE_SESSION_ID=s1
R=$T/repo; mkdir "$R"; git -C "$R" init -q
git -C "$R" -c user.email=a@b -c user.name=t commit -q --allow-empty -m init
fail=0
bad() { echo "FAIL $*"; fail=1; }

# ---- stop
TR=$T/tr.jsonl
user() { jq -nc --arg t "$1" --arg ts "$2" '{type:"user",timestamp:$ts,message:{role:"user",content:$t}}' >> "$TR"; }
tool() { jq -nc --arg n "$1" '{type:"assistant",timestamp:"2026-11-04T10:00:05Z",message:{role:"assistant",content:[{type:"tool_use",id:"x",name:$n,input:{}}]}}' >> "$TR"; }
at() { date -u -r $(($(date +%s) + $1)) +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "$1 sec" +%Y-%m-%dT%H:%M:%SZ; }  # offset seconds from now
CRONS='[{"id":"c","schedule":"*/30 * * * *","recurring":true,"prompt":"/wanjang:next check"}]'
stop() {  # want(fire|none) label [jq filter over the input]
  out=$(jq -nc --arg t "$TR" --argjson c "$CRONS" '{session_id:"s1",transcript_path:$t,stop_hook_active:false,session_crons:$c,background_tasks:[]}' \
        | jq -c "${3:-.}" | "$N" stop); rc=$?
  OUT=$out; got=none; [ -n "$out" ] && got=fire
  [ $rc = 0 ] || bad "$2: exit $rc"
  [ "$got" = "$1" ] || bad "$2: want $1 got $got"
  if [ "$got" = fire ]; then
    echo "$out" | jq -e '.hookSpecificOutput.hookEventName=="Stop" and (.hookSpecificOutput.additionalContext|contains("wanjang:next"))' >/dev/null || bad "$2: wrong JSON: $out"
  fi
}
rm -f "$T"/cfg/wanjang/next/*; : > "$TR"
user "fix the bug" "$(at -100)"; tool Edit
CRONS='[]';                       stop none "no cron"
CRONS='[{"prompt":" /wanjang:next check "}]'
stop none "stop_hook_active" '.stop_hook_active=true'
stop none "agent_id" '.agent_id="a1"'
stop none "background task running" '.background_tasks=[{"id":"b","status":"Running"}]'
stop fire "work done"
stop none "same prompt twice"
user "now the docs" "$(at 3600)"; tool Write
stop fire "newer prompt fires again"
: > "$TR"; user "what is this" "$(at -50)"; tool Read; tool Grep
stop none "only Read/Grep"
: > "$TR"; user "/wanjang:next check" "$(at -50)"; tool Bash
stop none "check turn"
rm -f "$T"/cfg/wanjang/next/*; : > "$TR"; user "run it" "$(at -50)"; tool Bash
jq -nc '{type:"assistant",isSidechain:true,message:{role:"assistant",content:[{type:"tool_use",name:"Bash"}]}}' >> "$TR"
echo 'not json' >> "$TR"
stop fire "sidechain and bad lines skipped"
out=$(echo 'garbage' | "$N" stop 2>&1); [ -z "$out" ] || bad "garbage stdin printed: $out"
out=$(echo '{"session_crons":"x","background_tasks":5}' | "$N" stop 2>&1); [ -z "$out" ] || bad "odd fields printed: $out"

# on-switch in state
st() { echo "$1" > "$T/cfg/wanjang/next/s1.json"; }
fresh() { rm -f "$T"/cfg/wanjang/next/*; : > "$TR"; user "go" "$(at -50)"; tool Bash; }
text() { jq -r .hookSpecificOutput.additionalContext <<<"$OUT"; }
mkdir -p "$T/cfg/wanjang/next"
fresh; CRONS='[]'; "$N" on
stop fire "on in state, no cron in list"
text | grep -q '`create`' || bad "hook text should name create"
fresh; CRONS='[{"prompt":"/wanjang:next check"}]'; "$N" on
stop fire "on, cron present"
text | grep -q 'verdict' && bad "keep should add no renew sentence"
fresh; "$N" on; "$N" off
stop none "off in state, cron present"
fresh; st '{"on":true,"cron_created":1}'
stop fire "on, old cron"; text | grep -q '`recreate`' || bad "hook text should name recreate"
fresh
stop fire "legacy: no on key, cron present"
# cron verdicts
rm -f "$T"/cfg/wanjang/next/*
cron() { "$N" cron "$@"; }
[ "$(cron)" = recreate ] || bad "cron: no state, cron present is legacy (recreate)"
[ "$(cron --exists no)" = off ] || bad "cron: off with exists=no"
st '{"asked":[]}'; [ "$(cron)" = recreate ] || bad "cron: legacy should be recreate"
[ "$(cron --exists no)" = off ] || bad "cron: legacy exists=no should be off"
"$N" on
[ "$(cron --exists no)" = create ] || bad "cron: on, no cron should be create"
[ "$(cron)" = keep ] || bad "cron: on, fresh should be keep"
st "{\"on\":true,\"cron_created\":$(( $(date +%s) - 561600 ))}"; [ "$(cron)" = recreate ] || bad "cron: 6.5 days old should be recreate"
st "{\"on\":true,\"cron_created\":$(( $(date +%s) - 500000 ))}"; [ "$(cron)" = keep ] || bad "cron: 5.8 days old should be keep"
st '{"on":true}'; [ "$(cron)" = recreate ] || bad "cron: missing cron_created should be recreate"
st '{"on":true,"cron_created":"x"}'; [ "$(cron)" = recreate ] || bad "cron: bad cron_created should be recreate"
"$N" on; "$N" off
[ "$(cron)" = off ] && [ "$(cron --exists no)" = off ] || bad "cron: after off should be off"
"$N" on; "$N" status | grep -q '^on, schedule made' || bad "status should show on"
"$N" off; "$N" status | grep -q '^off, last check' || bad "status should show off without a schedule age"
env -u CLAUDE_CODE_SESSION_ID "$N" on 2>/dev/null; [ $? = 2 ] || bad "on without session should exit 2"

# no timestamp on the prompt: skip
rm -f "$T"/cfg/wanjang/next/*; : > "$TR"; CRONS='[{"prompt":"/wanjang:next check"}]'
jq -nc '{type:"user",message:{role:"user",content:"go"}}' >> "$TR"; tool Bash
stop none "prompt without timestamp"
# HOME unset, odd input: nothing on stderr, exit 0
err=$(echo '{"session_crons":[{"prompt":"/wanjang:next check"}],"transcript_path":"/nonexistent","session_id":"s1"}' | env -u HOME "$N" stop 2>&1 >/dev/null); rc=$?
{ [ -z "$err" ] && [ $rc = 0 ]; } || bad "HOME unset / odd input: rc=$rc stderr=$err"
err=$(echo 'garbage' | env -u HOME "$N" stop 2>&1 >/dev/null); [ -z "$err" ] || bad "garbage stderr: $err"

# ---- prompt (UserPromptSubmit): block checks that would find nothing
rm -f "$T"/cfg/wanjang/next/*
pr() {  # want(block|pass) label prompt
  out=$(jq -nc --arg p "$3" '{session_id:"s1",prompt:$p}' | "$N" prompt); rc=$?
  got=pass; [ -n "$out" ] && got=block
  [ $rc = 0 ] || bad "$2: exit $rc"
  [ "$got" = "$1" ] || bad "$2: want $1 got $got"
  [ "$got" = pass ] || jq -e '.decision=="block" and (.reason|startswith("·"))' <<<"$out" >/dev/null || bad "$2: wrong JSON: $out"
}
C='/wanjang:next check'
pr pass "no state" "$C"
"$N" on
pr pass "on, never checked" "$C"
pr pass "on, non-check prompt" "fix the bug"
"$N" scan --periodic --cwd "$R" >/dev/null
pr block "on, checked just now" "$C"
pr block "padded prompt" " $C "
pr pass "recent but another prompt" "/wanjang:next check now"
pr pass "recent but status" "/wanjang:next status"
st "{\"on\":true,\"last_check\":$(( $(date +%s) - 1600 ))}"
pr pass "on, checked 26 min ago" "$C"
st "{\"on\":true,\"last_check\":$(( $(date +%s) - 1400 ))}"
pr block "on, checked 23 min ago" "$C"
"$N" off
pr pass "off, first fire reaches the model (leftover cron sweep)" "$C"
pr block "off, second fire" "$C"
pr pass "off, other prompt" "hello"
"$N" on; "$N" off
pr pass "off again resets the sweep" "$C"
echo '{"on":false' > "$T/cfg/wanjang/next/s1.json"
pr pass "corrupt state" "$C"
out=$(echo 'garbage' | "$N" prompt 2>&1); [ -z "$out" ] || bad "garbage stdin printed: $out"
out=$(echo '{"session_id":"s1","prompt":5}' | "$N" prompt 2>&1); [ -z "$out" ] || bad "odd prompt printed: $out"
jq -e '.hooks.UserPromptSubmit[0].hooks[0].command|endswith("bin/next\" prompt")' hooks/hooks.json >/dev/null || bad "hooks.json lacks the UserPromptSubmit prompt hook"
rm -f "$T"/cfg/wanjang/next/*

# ---- scan
fp() { "$N" scan --cwd "$R" | awk -F'\t' -v k="$1" '$1==k{print $2}'; }
[ -z "$(fp uncommitted)" ] || bad "clean repo shows uncommitted"
echo one > "$R/a.txt"; git -C "$R" add a.txt
f1=$(fp uncommitted); [ -n "$f1" ] || bad "dirty repo: no uncommitted line"
"$N" ask uncommitted "$f1"
[ -z "$(fp uncommitted)" ] || bad "asked candidate still shown"
echo two >> "$R/a.txt"
f2=$(fp uncommitted); { [ -n "$f2" ] && [ "$f2" != "$f1" ]; } || bad "edit did not give a new fp ($f1 -> $f2)"
echo "x = 1  # TODO later" >> "$R/a.txt"
[ -n "$(fp todo)" ] || bad "no todo line"
printf '# Notes\n## Next\n- ship it\n## Other\nx\n' > "$R/MEMORY.md"
[ -n "$(fp memory-next)" ] || bad "no memory-next line"
mkdir -p "$R/.git/wanjang/r1"; printf 'Status: in progress\n## Goal\nbuild x\n' > "$R/.git/wanjang/r1/log.md"
"$N" scan --cwd "$R" | grep -q $'^run:r1\t.*build x' || bad "no run:r1 line"
touch -t 202601010000 "$R/.git/wanjang/r1/log.md"
[ -z "$(fp run:r1)" ] || bad "old run log shown"
"$N" scan --cwd "$T" >/dev/null || bad "non-repo scan failed"
"$N" scan --periodic --cwd "$R" >/dev/null; rc=$?; [ $rc = 3 ] || bad "periodic after scan: exit $rc"
[ -z "$("$N" scan --periodic --cwd "$R")" ] || bad "periodic printed output"
env -u CLAUDE_CODE_SESSION_ID "$N" scan 2>/dev/null; [ $? = 2 ] || bad "no session should exit 2"

# corrupt numbers in the state file
mkdir -p "$T/cfg/wanjang/next"; echo '{"last_check":"abc","last_hook":"x","asked":"y"}' > "$T/cfg/wanjang/next/s1.json"
"$N" scan --periodic --cwd "$R" >/dev/null 2>&1; [ $? = 0 ] || bad "corrupt last_check crashed scan"
"$N" status >/dev/null 2>&1 || bad "status crashed on corrupt state"
echo '{"last_hook":"x"}' > "$T/cfg/wanjang/next/s1.json"; : > "$TR"; user "go" "$(at -50)"; tool Bash
stop fire "corrupt last_hook"
# read-only state dir: scan still prints, one line on stderr, exit 0
RO=$T/ro; mkdir -p "$RO/wanjang/next"; chmod 555 "$RO/wanjang/next"
out=$(CLAUDE_CONFIG_DIR=$RO "$N" scan --cwd "$R" 2>"$T/err"); rc=$?
{ [ $rc = 0 ] && grep -q '^uncommitted' <<<"$out" && grep -q '^next: cannot save state' "$T/err" && [ "$(wc -l <"$T/err")" -eq 1 ]; } || bad "read-only state dir: rc=$rc out=$out err=$(cat "$T/err")"
chmod 755 "$RO/wanjang/next"
rm -f "$T"/cfg/wanjang/next/*

# ---- asked
"$N" asked k1 v1; [ $? = 1 ] || bad "asked before ask should be 1"
"$N" ask k1 v1; "$N" ask k1 v1
"$N" asked k1 v1 || bad "asked after ask should be 0"
for i in $(seq 1 60); do "$N" ask cap "$i"; done
n=$(jq '.asked|length' "$T/cfg/wanjang/next/s1.json"); [ "$n" = 50 ] || bad "asked cap: $n"
"$N" status | grep -q "50 asked" || bad "status line"
"$N" status --json | jq -e '.asked==50' >/dev/null || bad "status --json"

[ $fail = 0 ] && echo "next: all passed"
exit $fail
