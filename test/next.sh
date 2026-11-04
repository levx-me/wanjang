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
"$N" ask uncommitted "$f1" >/dev/null
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
"$N" ask k1 v1 >/dev/null; "$N" ask k1 v1 >/dev/null
"$N" asked k1 v1 || bad "asked after ask should be 0"
for i in $(seq 1 60); do "$N" ask cap "$i" >/dev/null; done
n=$(jq '.asked|length' "$T/cfg/wanjang/next/s1.json"); [ "$n" = 50 ] || bad "asked cap: $n"
"$N" status | grep -q "50 asked" || bad "status line"
"$N" status --json | jq -e '.asked==50' >/dev/null || bad "status --json"

# ---- promise (the clock is WANJANG_NOW, so nothing sleeps)
PF=$T/cfg/wanjang/promises.json
B0=1800000000; export WANJANG_NOW=$B0
clk() { export WANJANG_NOW=$((B0 + $1)); }
pl() { "$N" scan --cwd "${1:-$R}" | grep '^promise:' ; }
pj() { jq -r "$1" "$PF"; }
reset() { rm -rf "$T"/cfg/wanjang/next/* "$PF"; clk 0; }
git -C "$R" checkout -q -- . 2>/dev/null; git -C "$R" reset -q; rm -f "$R/a.txt" "$R/MEMORY.md"; rm -rf "$R/.git/wanjang"
reset
# 1, 2
id=$("$N" promise add "check release page" --words "once CI is green, check it" --fp c1 --at +2h --cwd "$R" | cut -f1); [ $? = 0 ] && [ -n "$id" ] || bad "add: no id"
[ "$(pj '.promises|length')" = 1 ] && [ "$(pj '.promises[0]|[.status,.session,.by,.words,.fp,.at,.project]|@tsv')" = "$(printf 'open\ts1\tuser\tonce CI is green, check it\tc1\t%s\t%s' $((B0+7200)) "$(cd "$R" && pwd -P)")" ] || bad "add: fields: $(pj '.promises[0]')"
"$N" promise add "x" --cwd "$R" 2>"$T/err"; [ $? = 2 ] && grep -q '^usage' "$T/err" || bad "add without at/when should exit 2 with usage"
"$N" promise add "x" --at nonsense --cwd "$R" 2>/dev/null; [ $? = 2 ] || bad "add with a bad time should exit 2"
# 3
cp "$PF" "$T/before"; out=$("$N" promise add "  Check   RELEASE page" --fp c1 --at +5h --cwd "$R"); rc=$?
{ [ $rc = 4 ] && [ "$out" = "$id" ] && cmp -s "$PF" "$T/before"; } || bad "duplicate: rc=$rc out=$out"
"$N" promise add "check release page" --fp c2 --at +5h --cwd "$R" >/dev/null || bad "other fp is not a duplicate"
# off: confirmation names the way to turn it on
"$N" promise add "off one" --at +1h --cwd "$R" | grep -q 'next is off here.*session start.*/wanjang:next on' || bad "add while off: no hint"
[ "$("$N" status --json | jq .on)" = false ] || bad "add turned next on"
# 4
[ -z "$(pl)" ] || bad "promise shown before at"
clk 7300; l=$(pl | head -1)
[ "${l%%$'\t'*}" = "promise:$id" ] && grep -q "once CI is green, check it; due: time passed" <<<"$l" || bad "due promise line: $l"
echo one > "$R/a.txt"; git -C "$R" add a.txt
[ "$("$N" scan --cwd "$R" | head -1 | cut -f1)" = "promise:$id" ] || bad "promise not first"
git -C "$R" rm -q -f a.txt
# 9
fp9=$(pl | grep "^promise:$id" | cut -f2); "$N" ask "promise:$id" "$fp9" >/dev/null
[ -z "$(pl | grep "^promise:$id")" ] || bad "asked promise shown again the same day"
clk $((7300 + 86400)); [ -n "$(pl | grep "^promise:$id")" ] || bad "asked promise not shown on a later day"
# 10
clk 7300; "$N" promise set "$id" --at +1d; [ "$(pj ".promises[]|select(.id==\"$id\")|.snoozes")" = 1 ] || bad "set: snoozes"
[ -z "$(pl | grep "^promise:$id")" ] || bad "snoozed promise shown"
clk $((7300 + 86400)); l=$(pl | grep "^promise:$id"); [ -n "$l" ] && [ "$(cut -f2 <<<"$l")" != "$fp9" ] || bad "snooze: due again with a new fp"
# 11
"$N" promise done "$id" --note ok; "$N" promise list | grep -q "$id" && bad "list shows a done promise"
"$N" promise list --all | grep -q "$id" || bad "list --all hides a done promise"
[ -z "$(pl | grep "^promise:$id")" ] || bad "done promise shown"
"$N" promise drop pffff 2>/dev/null; [ $? = 1 ] || bad "unknown id should exit 1"
"$N" promise done "$id" 2>/dev/null; [ $? = 1 ] || bad "closed id should exit 1"
d2=$("$N" promise add "drop me" --at +1m --cwd "$R" | cut -f1); "$N" promise drop "$d2"; [ "$(pj ".promises[]|select(.id==\"$d2\")|.status")" = dropped ] || bad "drop"
# 5, 6, 7, 8
reset; W=$T/flag
c=$("$N" promise add "wait for flag" --when "test -f $W" --every 30m --cwd "$R" | cut -f1)
[ -z "$(pl)" ] || bad "condition not met shown"
touch "$W"; clk 600; [ -z "$(pl)" ] || bad "condition re-run within every"
clk 1800; pl | grep -q "^promise:$c.*test -f $W. exits 0" || bad "met condition not shown"
reset; M=$T/ran; for i in 1 2 3 4 5; do "$N" promise add "cond $i" --when "echo x >> $M; false" --cwd "$R" >/dev/null; done
"$N" scan --cwd "$R" >/dev/null; [ $(wc -l < "$M") -eq 3 ] || bad "at most 3 conditions per scan: $(wc -l < "$M")"
reset; "$N" promise add "slow" --when "sleep 30" --cwd "$R" >/dev/null
s0=$(date +%s); [ -z "$(pl)" ] || bad "timed out condition shown"; [ $(( $(date +%s) - s0 )) -lt 20 ] || bad "condition not killed at 10 s"
reset; "$N" promise add "nocmd" --when "nonexistent-cmd-xyz" --cwd "$R" >/dev/null
pl | grep -q 'its check cannot run' || bad "127 should say the check cannot run"
reset; "$N" promise add "later and true" --at +1d --when true --cwd "$R" >/dev/null
[ -z "$(pl)" ] || bad "at in the future with true condition shown"
clk 86500; [ -n "$(pl)" ] || bad "not due after at"
# 12
reset; "$N" promise add "short" --at +1m --for 1d --cwd "$R" >/dev/null; clk $((60 + 86400 + 5))
pl | grep -q 'gave up after' || bad "expired not printed"
[ "$(pj '.promises[0].status')" = expired ] || bad "status expired"
[ -z "$(pl)" ] || bad "expired printed twice"
# 13
reset; RB=$T/repoB; mkdir "$RB"; git -C "$RB" init -q; git -C "$RB" -c user.email=a@b -c user.name=t commit -q --allow-empty -m i
git -C "$RB" worktree add -q "$T/wtB" -b wt 2>/dev/null; mkdir -p "$RB/.git/wanjang/r1"
"$N" promise add "in B" --at +1m --cwd "$RB" >/dev/null; "$N" promise add "from wt" --at +1m --cwd "$T/wtB" >/dev/null
"$N" promise add "from run" --at +1m --cwd "$RB/.git/wanjang/r1" >/dev/null
[ "$(pj '.promises|map(.project)|unique|length')" = 1 ] || bad "worktree/run folder did not resolve to the repo: $(pj '.promises|map(.project)')"
clk 100; [ -z "$(pl "$R")" ] || bad "promise for B shown in A"
[ "$(pl "$RB" | wc -l | tr -d " ")" -ge 1 ] || bad "promise for B not shown in B"
"$N" promise list | grep -q "in B" && bad "list in A shows B"
# 14
rm -rf "$T"/cfg/wanjang/next; [ -n "$(CLAUDE_CODE_SESSION_ID=other pl "$RB")" ] || bad "promise lost with the session state"
# 15
reset; for i in 1 2 3 4 5 6; do "$N" promise add "par $i" --at +1m --cwd "$R" >/dev/null & done; wait
[ "$(pj '.promises|length')" = 6 ] || bad "concurrent adds: $(pj '.promises|length') landed"
# 16
reset; Z=$T/touched; "$N" promise add "t" --at +1m --cwd "$RB" >/dev/null; "$N" promise add "c" --when "touch $Z" --cwd "$RB" >/dev/null
for i in 3 4 5 6; do "$N" promise add "t$i" --at +1m --cwd "$RB" >/dev/null; done
clk 100; out=$("$N" promise due --cwd "$RB")
{ [ "$(grep -c '^- p' <<<"$out")" = 3 ] && grep -q 'and 2 more' <<<"$out" && [ ! -e "$Z" ]; } || bad "due: $out"
[ -z "$("$N" promise due --cwd "$R")" ] || bad "due printed for a project without promises"
# 18
reset; echo '{"promises":[' > "$PF"; echo one > "$R/a.txt"; git -C "$R" add a.txt
"$N" scan --cwd "$R" | grep -q '^uncommitted' || bad "corrupt promises.json broke scan"
[ -z "$("$N" promise list)" ] && [ $? = 0 ] || bad "corrupt list"
rm -f "$PF"; "$N" scan --cwd "$R" >/dev/null && [ -z "$("$N" promise list)" ] || bad "missing promises.json"
RO=$T/ro2; mkdir -p "$RO/wanjang"; chmod 555 "$RO/wanjang"
CLAUDE_CONFIG_DIR=$RO "$N" promise add "ro" --at +1m --cwd "$R" 2>"$T/err" >/dev/null
[ "$(wc -l <"$T/err")" -eq 1 ] && grep -q '^next: cannot save' "$T/err" || bad "read-only promises dir: $(cat "$T/err")"
chmod 755 "$RO/wanjang"; git -C "$R" rm -q -f a.txt
# 19
reset; for i in 1 2 3; do "$N" promise add "q$i" --at +1m --cwd "$R" >/dev/null; done
clk 100; for k in $(pl | cut -f1 | head -2); do "$N" ask "$k" "$("$N" scan --cwd "$R" | awk -F'\t' -v k="$k" '$1==k{print $2}')" >/dev/null; done
[ -z "$(pl)" ] || bad "third promise question offered in one idle stretch"
jq -nc '{session_id:"s1",prompt:"carry on"}' | "$N" prompt; clk 101
[ "$(pl | wc -l | tr -d " ")" = 1 ] || bad "a real prompt should reset the cap: $(pl | wc -l | tr -d ' ')"
jq -nc '{session_id:"s1",prompt:"/wanjang:next check"}' | "$N" prompt; clk 102
[ "$(pl | wc -l | tr -d " ")" = 1 ] || bad "a check prompt should not reset anything"
unset WANJANG_NOW

# ---- trust ladder (WANJANG_NOW clock: yeses are answers given at earlier fake times)
L=$T/lad; mkdir "$L"; gl() { git -C "$L" -c user.email=a@b -c user.name=t "$@"; }; gl init -q; gl commit -q --allow-empty -m init
H=3600; D=86400; SF=$T/cfg/wanjang/next/s1.json
lreset() { rm -rf "$T"/cfg/wanjang/next; clk 0; "$N" on; }
tf() { ls "$T"/cfg/wanjang/next/trust/*.json; }
ak() { "$N" ask "$1" "$2" --what "${3:-run the tests}" --cwd "$L"; }  # KEY FP [WHAT]: prints ask|auto
yes_at() { clk "$1"; ak "$2" "y$1" >/dev/null; "$N" answer "$2" "y$1" yes --cwd "$L"; }  # SECONDS KEY
yeses() { "$N" trust --json --cwd "$L" | jq -r --arg k "$1" '.kinds[]|select(.kind==$k)|.yeses'; }
three() { yes_at 0 "$1:a" >/dev/null; yes_at $D "$1:b" >/dev/null; yes_at $((2*D)) "$1:c"; }  # over 2 days
# kind mapping, kept on each asked entry
lreset
for kv in verify:a=verify test:a=test docs:a=docs commit:a=commit uncommitted=commit relay:s=relay task:1=resume \
          run:r1=resume promise:p1=promise todo=other memory-next=other foo:bar=other verify=other; do
  ak "${kv%%=*}" m1 "update the notes" >/dev/null
  [ "$(jq -r '.asked[-1].kind' "$SF")" = "${kv#*=}" ] || bad "kind of ${kv%%=*}: $(jq -r '.asked[-1].kind' "$SF")"
done
for w in "git push origin main" "Deploy to prod" "publish 1.2" "run the migration" "delete old logs" "rm -rf build" \
         "npm install x" "send the summary by email" "post a PR comment" "pay the invoice"; do
  ak commit:o "$RANDOM" "$w" >/dev/null; [ "$(jq -r '.asked[-1].kind' "$SF")" = outward ] || bad "outward not forced for: $w"
done
for w in "confirm the fix works" "update the form docs"; do
  ak commit:o "$RANDOM" "$w" >/dev/null; [ "$(jq -r '.asked[-1].kind' "$SF")" = commit ] || bad "not outward: $w"
done
# 1: 3 yeses over 2 days -> auto, with a notice on promotion
lreset; out=$(three commit); grep -q '^commit is trusted now (3 yeses): from now' <<<"$out" || bad "1: promotion notice: $out"
[ -f "$(tf)" ] && [ "$(dirname "$(tf)")" = "$T/cfg/wanjang/next/trust" ] || bad "1: trust file path"
clk $((2*D + 60)); [ "$(ak commit:x c1 "commit the verified work")" = auto ] || bad "1: 3 yeses over 2 days should be auto"
echo a > "$L/f1"; gl add f1; gl commit -qm "auto c"
out=$("$N" did commit:x c1 ok --commit HEAD --note 'abc "auto c" (1 file)' --cwd "$L")
grep -q '^Done without asking (commit, trusted after 3 yeses): commit the verified work, abc "auto c" (1 file). Undo: /wanjang:next undo · always ask: /wanjang:next trust commit ask$' <<<"$out" || bad "1: report: $out"
"$N" did commit:x c1 ok --commit HEAD --cwd "$L" 2>/dev/null; [ $? = 1 ] || bad "did twice should exit 1"
# 10: undo the auto commit (HEAD, unpushed): soft reset, commit reset
out=$("$N" undo --cwd "$L"); rc=$?
{ [ $rc = 0 ] && [ "$(gl log -1 --format=%s)" = init ] && [ "$(gl diff --cached --name-only)" = f1 ] && [ "$(yeses commit)" = 0 ]; } || bad "10: undo commit: rc=$rc $out"
grep -q 'commit is asked again' <<<"$out" || bad "10: undo line: $out"
[ "$("$N" undo --cwd "$L")" ] && [ "$(gl diff --cached --name-only)" = f1 ] || bad "10: second undo should do nothing"
gl commit -qm "user c"
undo_refused() {  # label setup: an auto commit, then the setup; undo must exit 4 and change nothing
  lreset; three commit >/dev/null; clk $((2*D + 60)); ak commit:y c2 "commit the verified work" >/dev/null
  echo "$RANDOM" >> "$L/f1"; gl commit -qam "auto"; "$N" did commit:y c2 ok --commit HEAD --cwd "$L" >/dev/null
  eval "$2"; h=$(gl rev-parse HEAD)
  out=$("$N" undo --cwd "$L"); rc=$?
  { [ $rc = 4 ] && [ "$(gl rev-parse HEAD)" = "$h" ] && [ "$(yeses commit)" = 3 ]; } || bad "10: $1: rc=$rc $out"
}
undo_refused "HEAD moved" 'echo b >> "$L/f1"; gl commit -qam user'
undo_refused "pushed" 'gl update-ref refs/remotes/origin/main HEAD'
gl update-ref -d refs/remotes/origin/main
# 12: an auto commit the user dropped resets commit at the next ask
lreset; three commit >/dev/null; clk $((2*D + 60)); ak commit:z c3 "commit it" >/dev/null
echo z >> "$L/f1"; gl commit -qam "auto z"; "$N" did commit:z c3 ok --commit HEAD --cwd "$L" >/dev/null
gl reset -q --hard HEAD^; clk $((2*D + 120)); "$N" answer x x yes --cwd "$L" >/dev/null
[ "$(yeses commit)" = 3 ] || bad "12: answer should not check for dropped commits"
[ "$(ak commit:w c4 "commit it")" = ask ] && [ "$(yeses commit)" = 0 ] || bad "12: dropped auto commit should reset commit"
# 2, 4: 3 yeses within 24 h, or 2 yeses, stay ask
lreset; yes_at 0 test:a >/dev/null; yes_at $H test:b >/dev/null; out=$(yes_at $((2*H)) test:c)
grep -q "from $(date -r $((B0 + D)) '+%a %d %H:%M')" <<<"$out" || bad "2: notice should name when: $out"
clk $((3*H)); [ "$(ak test:x t1)" = ask ] || bad "2: 3 yeses within 24 h should be ask"
"$N" trust --cwd "$L" | grep -q $'^test\tauto from' || bad "2: table should say auto from"
clk $((D + 1)); [ "$(ak test:x t2)" = auto ] || bad "2: once the first yes is 24 h old it should be auto"
lreset; yes_at 0 test:a >/dev/null; yes_at $D test:b >/dev/null; clk $((3*D)); [ "$(ak test:x t1)" = ask ] || bad "4: 2 yeses should be ask"
# 14 days: yeses older than that no longer count
lreset; three test >/dev/null; clk $((15*D)); [ "$(ak test:x t1)" = ask ] || bad "yeses older than 14 days should not count"
# 3: a Not now resets
lreset; three test >/dev/null; clk $((2*D + 60)); "$N" answer test:n n1 no --cwd "$L"
[ "$(ak test:x t1)" = ask ] && [ "$(yeses test)" = 0 ] || bad "3: not now should reset"
# 5: never auto, whatever the count (outward checked in code)
lreset; three commit >/dev/null; clk $((3*D))
for w in "commit and git push" "deploy the build" "commit, then post a comment"; do
  [ "$(ak commit:p "$RANDOM" "$w")" = ask ] || bad "5: outward '$w' came back auto"
done
[ "$("$N" ask commit:q q1 --what "" --cwd "$L")" = ask ] || bad "5: no --what should be ask"
yl=$(jq -c '.kinds.commit.yes' "$(tf)")
jq --argjson y "$yl" '.kinds += {resume:{yes:$y},other:{yes:$y},promise:{yes:$y},outward:{yes:$y}}' "$(tf)" > "$T/tf" && mv "$T/tf" "$(tf)"
for k in task:1 run:r1 promise:p1 foo:bar todo; do [ "$(ak "$k" "$RANDOM" "look at it")" = ask ] || bad "5: $k came back auto"; done
[ "$(ak commit:ok o1 "commit the verified work")" = auto ] || bad "5: commit itself should still be auto"
"$N" did commit:ok o1 ask --cwd "$L"
# 6: pin and reset
"$N" trust commit ask --cwd "$L" >/dev/null; clk $((3*D + 1)); [ "$(ak commit:x p1 "commit it")" = ask ] || bad "6: pinned should be ask"
"$N" trust --cwd "$L" | grep -q $'^commit\task\t3/3\tpinned' || bad "6: table should show the pin"
"$N" trust commit reset --cwd "$L" >/dev/null
[ "$(yeses commit)" = 0 ] && [ "$("$N" trust --json --cwd "$L" | jq '.kinds[]|select(.kind=="commit")|.pin')" = false ] || bad "6: reset should unpin and zero"
"$N" trust bogus ask --cwd "$L" 2>/dev/null; [ $? = 2 ] || bad "trust with a bad kind should exit 2"
# 7: trust off keeps counts; on restores
lreset; three test >/dev/null; clk $((3*D)); "$N" trust off --cwd "$L" >/dev/null
[ "$(ak test:x o1)" = ask ] && [ "$(yeses test)" = 3 ] || bad "7: off should ask and keep counts"
"$N" trust on --cwd "$L" >/dev/null; [ "$(ak test:x o2)" = auto ] || bad "7: on should restore auto"
"$N" did test:x o2 ok --cwd "$L" >/dev/null
"$N" off; clk $((3*D + 5)); [ "$(ak test:x o3)" = ask ] || bad "next off should mean ask"
# 8: one at a time, 2 per idle stretch, 6 per 24 h; a real prompt starts a new stretch
lreset; three test >/dev/null; s=$((3*D)); got=""
step() { s=$((s + 10)); clk $s; r=$(ak test:x "s$s"); got="$got$r "; [ "$r" = auto ] && [ "$1" != keep ] && "$N" did test:x "s$s" ok --cwd "$L" >/dev/null; }
prompt() { s=$((s + 10)); clk $s; jq -nc '{session_id:"s1",prompt:"carry on"}' | "$N" prompt; }
step keep; step; [ "$got" = "auto ask " ] || bad "8: a running auto action should block another: $got"
"$N" did test:x "s$((s - 10))" ask --cwd "$L"; got=""
step; step; step; prompt; step; step; step; prompt; step; step; prompt; step
[ "$got" = "auto auto ask auto auto ask auto auto ask " ] || bad "8: limits: $got"
"$N" status --cwd "$L" | grep -q ', 6 auto today$' || bad "15: status should count auto today: $("$N" status --cwd "$L")"
clk $((5*D)); jq -nc '{session_id:"s1",prompt:"next day"}' | "$N" prompt; clk $((5*D + 1))
[ "$(ak test:x nd)" = auto ] || bad "8: next day should be auto again"
# 9: a failed auto action resets its kind and says so
out=$("$N" did test:x nd failed --note "tests timed out" --cwd "$L")
[ "$out" = "Tried run the tests without asking; it failed: tests timed out. test is asked again from now." ] && [ "$(yeses test)" = 0 ] || bad "9: failed: $out"
# 11: undo an auto docs edit; a file edited since is restored by none
printf 'v1\n' > "$L/doc.md"; gl add doc.md; gl commit -qm doc
docs_auto() { lreset; three docs >/dev/null; clk $((3*D)); ak "docs:$1" d1 "update doc.md" >/dev/null; printf 'v2\n' > "$L/doc.md"; "$N" did "docs:$1" d1 ok --files doc.md --cwd "$L" >/dev/null; }
docs_auto a; out=$("$N" undo --cwd "$L"); rc=$?
{ [ $rc = 0 ] && [ "$(cat "$L/doc.md")" = v1 ] && [ "$(yeses docs)" = 0 ]; } || bad "11: docs undo: rc=$rc $out"
docs_auto b; printf 'v3\n' > "$L/doc.md"; out=$("$N" undo --cwd "$L"); rc=$?
{ [ $rc = 4 ] && [ "$(cat "$L/doc.md")" = v3 ] && grep -q 'doc.md' <<<"$out"; } || bad "11: edited since: rc=$rc $out"
gl checkout -q -- doc.md
"$N" did docs:c zz ok --cwd "$L" 2>/dev/null; [ $? = 1 ] || bad "did without a running action should exit 1"
# 15: table lists every kind
lreset; out=$("$N" trust --cwd "$L"); [ "$(grep -c $'\t[0-9]/3\t' <<<"$out")" = 5 ] && grep -q '^trust ladder on' <<<"$out" || bad "15: table: $out"
# 13: survives a new session and the 7-day prune; worktrees share it
lreset; three relay >/dev/null; echo '{}' > "$T/cfg/wanjang/next/old.json"; touch -t 202001010000 "$T/cfg/wanjang/next/old.json"
clk $((3*D)); CLAUDE_CODE_SESSION_ID=s2 "$N" on
[ ! -e "$T/cfg/wanjang/next/old.json" ] && [ -f "$(tf)" ] || bad "13: prune should drop old sessions and keep trust/"
[ "$(CLAUDE_CODE_SESSION_ID=s2 "$N" ask relay:x r1 --what "report back to s9" --cwd "$L")" = auto ] || bad "13: new session should see the trust"
gl worktree add -q "$T/wtL" -b wtl 2>/dev/null
[ "$("$N" trust --json --cwd "$T/wtL" | jq '.kinds[]|select(.kind=="relay")|.yeses')" = 3 ] || bad "13: worktree should share the counts"
# 14: corrupt trust file asks, no stderr; read-only trust dir asks with one line
echo '{"kinds":' > "$(tf)"; clk $((3*D + 99))
out=$(ak relay:y r2 "report back" 2>"$T/err"); [ "$out" = ask ] && [ ! -s "$T/err" ] || bad "14: corrupt: $out $(cat "$T/err")"
lreset; three test >/dev/null; clk $((3*D)); chmod 555 "$(dirname "$(tf)")"
out=$(ak test:x ro 2>"$T/err"); [ "$out" = ask ] && [ "$(wc -l <"$T/err")" -le 1 ] || bad "14: read-only: $out $(cat "$T/err")"
chmod 755 "$(dirname "$(tf)")"
unset WANJANG_NOW

[ $fail = 0 ] && echo "next: all passed"
exit $fail
