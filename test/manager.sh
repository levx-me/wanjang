#!/usr/bin/env bash
# Runs bin/manager on a fake session registry (live sleep processes), temp git repos and a temp config dir;
# fails on any wrong result. The clock is WANJANG_NOW (epoch seconds), so nothing sleeps.
cd "$(dirname "$0")/.." || exit 2
M=$PWD/bin/manager N=$PWD/bin/next
T=$(mktemp -d); T=$(cd "$T" && pwd -P)
PIDS=()
trap 'kill "${PIDS[@]}" 2>/dev/null; rm -rf "${T:?}"' EXIT
export CLAUDE_CONFIG_DIR=$T/cfg WANJANG_SESSIONS_DIR=$T/sess CLAUDE_CODE_SESSION_ID=own-0000
mkdir -p "$CLAUDE_CONFIG_DIR" "$WANJANG_SESSIONS_DIR" "$T/home"
fail=0
bad() { echo "FAIL $*"; fail=1; }
B0=1800000000; export WANJANG_NOW=$B0
clk() { export WANJANG_NOW=$((B0 + $1)); }
# a live pid: a detached sleep (a bash background job would run the EXIT trap when killed, under bash 3.2)
live() { P=$(python3 -c 'import subprocess as s;print(s.Popen(["sleep","100000"],stdout=s.DEVNULL,stderr=s.DEVNULL,start_new_session=True).pid)'); PIDS+=($P); }
dead() { P=$(sh -c 'echo $$'); }  # a pid that has exited
reg() {  # PID SID NAME CWD STATUS [SECONDS-AGO] [KIND]
  jq -nc --argjson p "$1" --arg s "$2" --arg n "$3" --arg c "$4" --arg st "$5" --argjson u $(( (WANJANG_NOW - ${6:-0}) * 1000 )) \
    --arg k "${7:-interactive}" '{pid:$p,sessionId:$s,name:$n,cwd:$c,status:$st,statusUpdatedAt:$u,kind:$k}' > "$WANJANG_SESSIONS_DIR/$1.json"
}
gl() { git -C "$R" -c user.email=a@b -c user.name=t "$@"; }
tick() { jq -nc --arg s "${1:-own-0000}" --arg p "${2:-wanjang manager tick}" '{session_id:$s,prompt:$p}' | "$M" prompt; }
blocked() { jq -e --arg r "$1" '.decision=="block" and .reason==$r and .hookSpecificOutput.suppressOriginalPrompt==true' >/dev/null; }
ctx() { jq -r '.hookSpecificOutput.additionalContext // empty'; }
LG=$CLAUDE_CONFIG_DIR/wanjang/manager/ledger.jsonl ST=$CLAUDE_CONFIG_DIR/wanjang/manager/state.json
DG=$CLAUDE_CONFIG_DIR/wanjang/manager/digest.txt PG=$CLAUDE_CONFIG_DIR/wanjang/manager/page.html
ev() { jq -c "select(.id==\"$1\")" "$LG"; }
fpnow() { "$N" scan --cwd "$R" | awk -F'\t' -v k="$1" '$1==k{print $2}'; }
judged() { grep -E '^- [^ ]+ [^ ]+ \| ' "$DG" | while read -r _ k f _; do "$M" item drop "$k" "$f" --why test >/dev/null; done; }  # the inspector drops every new finding

R=$T/repo; mkdir "$R"; git -C "$R" init -q; echo a > "$R/a.txt"; gl add a.txt; gl commit -qm init
live; OWN=$P; live; A=$P
reg "$OWN" own-0000 boss "$R" waiting            # the manager: in the same repo, waiting; never a finding
reg "$A" aaaa1111-x repo-a "$R" busy
dead; reg "$P" dddd1111-x deadone "$R" waiting     # dead pid: skipped
live; reg "$P" nnnn1111-x bg "$R" waiting 0 background   # not interactive: skipped
mkdir -p "$CLAUDE_CONFIG_DIR/tasks/session-own-0000"
jq -nc '{id:"1",subject:"you: pick a name",status:"pending"}' > "$CLAUDE_CONFIG_DIR/tasks/session-own-0000/1.json"

# ---- on, and a tick with nothing new: blocked with `·`, ledger unchanged
"$M" on --name boss | grep -q '^manager on in boss$' || bad "on: $("$M" on)"
[ "$(jq -r '.owner|[.sessionId,.pid,.name,.cwd]|@tsv' "$ST")" = "$(printf 'own-0000\t%s\tboss\t%s' "$OWN" "$R")" ] || bad "on: owner $(jq -c .owner "$ST")"
out=$(tick); blocked "·" <<<"$out" || bad "1: nothing new should block with ·: $out"
[ ! -s "$LG" ] || bad "1: ledger written on a nothing-new tick"
"$M" scan >/dev/null; [ $? = 3 ] || bad "1: scan with nothing new should exit 3"
# 2, 3: the owner's entry, a dead pid and a non-interactive entry never show
"$M" scan --force >/dev/null
grep -q 'own-0000\|waiting:own\|you:own\|deadone\|dddd1111\|nnnn1111\|bg |' "$DG" && bad "2/3: owner, dead or background session in the digest: $(cat "$DG")"
grep -q '^- repo-a | busy' "$DG" || bad "digest lacks the live session: $(cat "$DG")"
# a non-tick prompt from another session passes untouched
[ -z "$(tick aaaa1111-x "hello")" ] || bad "other session's prompt printed something"

# ---- a new uncommitted change: the tick passes with the steps, at most 800 chars
clk 3600; echo b >> "$R/a.txt"
out=$(tick); c=$(ctx <<<"$out")
{ [ -n "$c" ] && [ ${#c} -le 800 ] && grep -q 'wanjang:inspector' <<<"$c" && grep -q 'manager dispatch --id' <<<"$c"; } || bad "4: pass context (${#c} chars): $out"
grep -q '^- uncommitted [0-9a-f]\{8\} | '"$R"' | repo-a | 1 file changed: a.txt' "$DG" || bad "4: digest: $(cat "$DG")"
F1=$(awk '/^- uncommitted /{print $3}' "$DG")
# installed under a long plugin path, the steps still fit
LB=$T/plugins/cache/wanjang/wanjang/0.13.0/bin; mkdir -p "$LB"; cp bin/manager bin/next bin/status bin/manager-page "$LB"/
c=$(cp "$ST" "$T/st"; jq -nc '{session_id:"own-0000",prompt:"wanjang manager tick"}' | "$LB/manager" prompt | ctx); cp "$T/st" "$ST"
[ -n "$c" ] && [ ${#c} -le 800 ] || bad "4: steps under a long path are ${#c} chars"

# ---- items, page
out=$("$M" item add uncommitted "$F1" --project "$R" --session repo-a --kind commit --text "Save the work in repo as a commit" \
      --why "1 file changed: a.txt" --cost "1 min"); [ "$out" = "m-1 ask" ] || bad "item add: $out"
[ "$("$M" item add uncommitted "$F1" --project "$R" --text x)" = "m-1 ask" ] || bad "item add twice should give the same id"
p1=$("$M" page); grep -q "^$PG changed=yes$" <<<"$p1" || bad "5: first page: $p1"
grep -q 'Save the work in repo as a commit' "$PG" || bad "5: page lacks the item"
m1=$(stat -f %m "$PG" 2>/dev/null || stat -c %Y "$PG"); touch -t 202001010000 "$PG"
grep -q 'changed=no$' <<<"$("$M" page)" || bad "5: same ledger should not rewrite the page"
[ "$(stat -f %m "$PG" 2>/dev/null || stat -c %Y "$PG")" != "$m1" ] || bad "5: page rewritten"
clk 7200; out=$(tick); blocked "·" <<<"$out" || bad "5: same findings on the next tick should block: $out"
echo "x = 1  # TODO later" >> "$R/a.txt"
clk 10800; out=$(tick); [ -n "$(ctx <<<"$out")" ] || bad "5: new finding should pass: $out"
F2=$(awk '/^- uncommitted /{print $3}' "$DG"); FT=$(awk '/^- todo /{print $3}' "$DG")
[ -n "$FT" ] && [ -n "$F2" ] && [ "$F2" != "$F1" ] || bad "5: digest should list the new uncommitted fp and the todo: $(cat "$DG")"
[ "$("$M" item add todo "$FT" --project "$R" --session repo-a --kind other --text "Finish the TODO" --why "new TODO in a.txt")" = "m-2 ask" ] || bad "item add todo"
"$M" item add uncommitted "$F2" --project "$R" --session repo-a --kind commit --text "Save the work as a commit" --why "a.txt changed" >/dev/null
[ "$(ev m-1 | tail -1 | jq -r .ev)" = closed ] || bad "a revised item should close the older one with the same key"
[ "$("$M" item add uncommitted "$F1" --project "$R" --text x)" = "m-1 closed" ] || bad "item add on a closed item should say closed"
grep -q 'changed=yes$' <<<"$("$M" page)" || bad "5: new finding should change the page"
[ "$(grep -o 'class="tag on">new<' "$PG" | wc -l | tr -d ' ')" = 2 ] || bad "5: new chip count: $(grep -o 'class="tag on">new<' "$PG" | wc -l)"
out=$("$M" ask-list); [ "$(grep -c '^ASK m-' <<<"$out")" = 2 ] && grep -q '^ASK m-2 | other | Finish the TODO | new TODO in a.txt | not stated$' <<<"$out" || bad "ask-list: $out"
[ -z "$("$M" ask-list)" ] || bad "ask-list should not list an asked item twice"

# ---- 6: answered items are not asked again until the fp changes
"$M" answer m-2 reject --words "not now" | grep -q 'm-2 rejected' || bad "6: reject"
[ "$("$M" item add todo "$FT" --project "$R" --text x)" = "m-2 rejected" ] || bad "6: item add on a rejected item should not say ask"
clk 14400; out=$(tick); blocked "·" <<<"$out" || bad "6: answered items should not come back: $out"
# a comment is not approval: it is news for the inspector, once
"$M" answer m-3 comment --words "only the docs part" >/dev/null
[ "$(ev m-3 | tail -1 | jq -r '[.ev,.ans,.words]|@tsv')" = "$(printf 'answered\tcomment\tonly the docs part')" ] || bad "6: comment event"
clk 18000; out=$(tick); [ -n "$(ctx <<<"$out")" ] && grep -q '^COMMENT on m-3 .*only the docs part' "$DG" || bad "6: comment should be news: $(cat "$DG")"
clk 21600; out=$(tick); blocked "·" <<<"$out" || bad "6: a comment is news once"
echo "y = 2  # TODO again" >> "$R/a.txt"
clk 25200; tick >/dev/null; FT2=$(awk '/^- todo /{print $3}' "$DG"); [ -n "$FT2" ] && [ "$FT2" != "$FT" ] || bad "6: new todo fp should be asked once more"

# ---- 7, dispatch format: approve, dispatch at once (busy target still SEND), sent
F3=$(awk '/^- uncommitted /{print $3}' "$DG")
"$M" item add uncommitted "$F3" --project "$R" --session repo-a --kind commit --text "Save the work as a commit" --why "a.txt changed" >/dev/null
id=$("$M" item add uncommitted "$F3" --project "$R" --text x | cut -d' ' -f1)
"$M" answer "$id" approve --words 'yes, "commit" it' | grep -q "$id approved" || bad "7: approve"
out=$("$M" dispatch --id "$id")
{ [ "$(head -1 <<<"$out")" = "SEND repo-a" ] \
  && grep -q "^wanjang manager · item $id · the user approved this in the manager session at 20[0-9-]*T[0-9:]*[+-][0-9:]*$" <<<"$out" \
  && grep -qF "User's words: \"yes, \"commit\" it\"" <<<"$out" \
  && grep -qF 'Do: Save the work as a commit. Evidence: a.txt changed.' <<<"$out" \
  && grep -qF "Bounds: this repository only. Push, deploy, migrations, deletes, installs and anything outward still need the user's yes here, even though this message carries an approval: ask the user again before doing them." <<<"$out" \
  && grep -qF "When done: run \`\"$M\" reply $id done|failed|question --note \"<one line>\"\`. Do not message the manager." <<<"$out"; } \
  || bad "7: dispatch message (busy target): $out"
"$M" sent "$id" | grep -q "$id sent to repo-a" || bad "7: sent"
[ "$(ev "$id" | tail -1 | jq -r '[.ev,.to,.tsid]|@tsv')" = "$(printf 'sent\trepo-a\taaaa1111-x')" ] || bad "7: sent event: $(ev "$id" | tail -1)"
"$M" sent "$id" 2>/dev/null; [ $? = 1 ] || bad "sent twice should exit 1"
# 9: a reply from the owning session: one locked line; the page lists it under Done
CLAUDE_CODE_SESSION_ID=aaaa1111-x "$M" reply "$id" done --note "committed abc123" | grep -q 'recorded' || bad "9: reply"
[ "$(ev "$id" | tail -1 | jq -r '[.ev,.ans,.note,.by]|@tsv')" = "$(printf 'reply\tdone\tcommitted abc123\taaaa1111-x')" ] || bad "9: reply event"
"$M" page >/dev/null; python3 - "$PG" <<'EOF' || bad "9: page Done section"
import re, sys
h = open(sys.argv[1]).read()
i = h.find("· Done<"); j = h.find("committed abc123")
sys.exit(0 if 0 <= i < j else 1)
EOF
clk 28800; out=$(tick); [ -n "$(ctx <<<"$out")" ] && grep -q "^REPLY $id done from repo-a: committed abc123" "$DG" || bad "9: a reply should be news"
W=(); for i in 1 2 3 4; do CLAUDE_CODE_SESSION_ID=aaaa1111-x "$M" reply "$id" question --note "q$i" >/dev/null & W+=($!); done; wait "${W[@]}"
[ "$(grep -c '"ev": *"reply"' "$LG")" = 5 ] || bad "9: concurrent replies: $(grep -c '"ev": *"reply"' "$LG") lines"
"$M" reply m-999 done 2>/dev/null; [ $? = 1 ] || bad "reply to an unknown item should exit 1"

# ---- 8: the evidence changed after approval: not sent, re-asked as a new fp
clk 32400; tick >/dev/null; F4=$(fpnow uncommitted)
id8=$("$M" item add uncommitted "$F4" --project "$R" --session repo-a --text "Save the work as a commit" --why "changed" | cut -d' ' -f1)
"$M" answer "$id8" approve --words "go" >/dev/null; echo c >> "$R/a.txt"
out=$("$M" dispatch --id "$id8"); { grep -q "^CHANGED $id8" <<<"$out" && ! grep -q '^SEND' <<<"$out"; } || bad "8: changed evidence sent: $out"
[ "$(ev "$id8" | tail -1 | jq -r .ev)" = changed ] || bad "8: changed event"
clk 36000; tick >/dev/null; grep -q '^- uncommitted ' "$DG" && [ "$(awk '/^- uncommitted /{print $3}' "$DG")" != "$F4" ] || bad "8: changed evidence should be a new finding"

# ---- 10: sent, then 2 idle ticks of the target with no reply: Problems
F5=$(fpnow uncommitted)
id10=$("$M" item add uncommitted "$F5" --project "$R" --session repo-a --text "Save the work as a commit" --why "x" | cut -d' ' -f1)
"$M" answer "$id10" approve --words ok >/dev/null; "$M" dispatch --id "$id10" | grep -q '^SEND repo-a' || bad "10: send"
"$M" sent "$id10" >/dev/null
reg "$A" aaaa1111-x repo-a "$R" idle 60
clk 39600; tick >/dev/null; "$M" page >/dev/null; grep -q 'no reply' "$PG" && bad "10: no reply after one idle tick"
clk 43200; out=$(tick); [ -n "$(ctx <<<"$out")" ] && grep -q "^NO REPLY $id10 " "$DG" || bad "10: 2 idle ticks should be news: $out $(cat "$DG")"
"$M" page >/dev/null; python3 - "$PG" <<'EOF' || bad "10: page Problems section"
import sys
h = open(sys.argv[1]).read()
i = h.find("· Problems<"); j = h.find("no reply", i)
sys.exit(0 if 0 <= i < j else 1)
EOF
reg "$A" aaaa1111-x repo-a "$R" busy

# ---- 11: a trusted local kind is sent without asking; an outward action is always asked
for d in 3 2 1; do WANJANG_NOW=$((WANJANG_NOW - d * 86400)) "$N" answer "commit:t$d" "y$d" yes --cwd "$R" >/dev/null; done
[ "$("$N" trust --json --cwd "$R" | jq '.kinds[]|select(.kind=="commit")|.level' -r)" = auto ] || bad "11: commit should be trusted"
clk 46800; "$M" scan --force >/dev/null
out=$("$M" item add commit:x c1 --project "$R" --session repo-a --kind commit --text "commit the files" --why "tests passed")
id11=${out% *}; [ "${out#* }" = auto ] || bad "11: trusted kind should be auto: $out"
out=$("$M" dispatch --id "$id11"); grep -q "^wanjang manager · item $id11 · under your standing yes for commit; for docs/commit only if every dirty file is yours, else reply question$" <<<"$out" || bad "11: auto message: $out"
"$M" sent "$id11" >/dev/null
out=$("$M" item add commit:y c2 --project "$R" --session repo-a --kind commit --text "commit the files and push them" --why "x")
[ "${out#* }" = ask ] || bad "11: outward text should be asked: $out"
out=$("$M" item add unpushed u1 --project "$R" --session repo-a --kind commit --text "commit the files" --why "x")
[ "${out#* }" = ask ] || bad "11: outward key should be asked: $out"
"$M" dispatch --id "${out% *}" | grep -q '^NOT SENT' || bad "11: dispatching an unasked outward item should be refused"
# the inspector asked bin/next first (a running action): an outward action text still is not sent
"$N" ask commit:z z1 --what "commit the files" --cwd "$R" >/dev/null 2>&1
out=$("$M" item add commit:z z1 --project "$R" --session repo-a --text "commit the files, then deploy" --why "x"); [ "${out#* }" = ask ] || bad "11: outward with a running action: $out"
# a reply closes the trust ladder's running action
CLAUDE_CODE_SESSION_ID=aaaa1111-x "$M" reply "$id11" failed --note "hook failed" >/dev/null
[ "$("$N" trust --json --cwd "$R" | jq '.kinds[]|select(.kind=="commit")|.yeses')" = 0 ] || bad "11: a failed auto reply should reset the kind"

# ---- the trust check reads the action sent (--what, else --text), also when bin/next already runs one
R3=$T/r3; mkdir "$R3"; git -C "$R3" init -q; echo a > "$R3/a.txt"
git -C "$R3" -c user.email=a@b -c user.name=t add a.txt; git -C "$R3" -c user.email=a@b -c user.name=t commit -qm init
live; C=$P; reg "$C" cccc3333-x repo-c "$R3" busy
for d in 3 2 1; do WANJANG_NOW=$((WANJANG_NOW - d * 86400)) "$N" answer "commit:t$d" "y$d" yes --cwd "$R3" >/dev/null; done
clk 50400; "$M" scan --force >/dev/null; clk 50460
i=0
for txt in "commit the files, then git checkout -- . to discard the rest" "commit the files and d$(printf '\xd0\xb5')ploy the site" \
           "commit the files and ssh server1 to restart nginx"; do
  i=$((i + 1))
  [ "$("$N" ask "commit:b$i" "b$i" --what "commit the files" --cwd "$R3" 2>/dev/null)" = auto ] || bad "bypass $i: next ask should be auto"
  out=$("$M" item add "commit:b$i" "b$i" --project "$R3" --session repo-c --text "$txt" --why x)
  [ "${out#* }" = ask ] || bad "bypass $i: a running action must not pass other text: $txt -> $out"
  "$N" did "commit:b$i" "b$i" ask --cwd "$R3" >/dev/null
done
out=$("$M" item add commit:v v1 --project "$R3" --session repo-c --text "Save the finished work in repo-c as a commit" --why x)
[ "${out#* }" = ask ] || bad "--what: free text alone is not the kind's short wording: $out"
out=$("$M" item add commit:w w1 --project "$R3" --session repo-c --kind tidy --text "Save the finished work in repo-c as a commit" \
      --what "commit the files" --why "tests passed"); idw2=${out% *}
[ "${out#* }" = auto ] || bad "--what: the short action should be auto: $out"
out=$("$M" dispatch --id "$idw2")
{ grep -q "^wanjang manager · item $idw2 · under your standing yes for commit;" <<<"$out" && grep -qx "Do: commit the files. Evidence: tests passed." <<<"$out"; } \
  || bad "--what: the auto message sends the short action and the derived kind: $out"
"$M" sent "$idw2" >/dev/null
[ "$("$M" item add commit:w w1 --project "$R3" --text x)" = "$idw2 sent" ] || bad "item add on a sent item should give its status"
# a ledger line cut short (a crash mid-write) does not swallow the next event
printf '{"ev":"cut' >> "$LG"
out=$("$M" item add other:nl n1 --project "$R3" --session repo-c --text "Look at it" --why x)
[ "$(tail -1 "$LG" | jq -r .id)" = "${out% *}" ] || bad "ledger: the event after a cut line was lost: $(tail -2 "$LG")"
grep -vx '{"ev":"cut' "$LG" > "$T/lg"; cat "$T/lg" > "$LG"  # jq below reads the whole file
# past the time budget the scan skips promise conditions and says so; the next scan runs them
pid=$("$N" promise add "check x" --when "touch '$T/ran'; false" --cwd "$R3" | cut -f1)
WANJANG_SCAN_BUDGET=0 "$M" scan --force >/dev/null
{ head -1 "$DG" | grep -q ' · partial: promise conditions skipped after 0 s, next tick$' && [ ! -e "$T/ran" ]; } || bad "budget: $(head -1 "$DG"); ran: $(ls "$T/ran" 2>&1)"
"$M" scan --force >/dev/null; { [ -e "$T/ran" ] && ! head -1 "$DG" | grep -q partial; } || bad "budget: the next scan should run the condition: $(head -1 "$DG")"
"$N" promise drop "$pid" >/dev/null
rm -f "$WANJANG_SESSIONS_DIR/$C.json"

# ---- 7 (no live session): waiting, then expired after 7 days
P2=$T/p2; mkdir "$P2"; git -C "$P2" init -q
idw=$("$M" item add other:w w1 --project "$P2" --session gone --text "Look at p2" --why "x" | cut -d' ' -f1)
"$M" answer "$idw" approve --words ok >/dev/null
out=$("$M" dispatch --id "$idw"); grep -q "^WAIT $idw: waiting for a session in $P2" <<<"$out" || bad "7: waiting: $out"
"$M" page >/dev/null; grep -q 'waiting for a session' "$PG" || bad "7: page should say waiting"
clk $((46800 + 8 * 86400)); "$M" scan >/dev/null; [ "$(ev "$idw" | tail -1 | jq -r .ev)" = expired ] || bad "7: waiting should expire after 7 days"

# ---- 13: the owner typed within 10 minutes: deferred; the findings come next tick
echo d >> "$R/a.txt"; clk $((47000 + 8 * 86400))
[ -z "$(tick own-0000 "what's next?")" ] || bad "13: owner prompt printed something"
out=$(tick); blocked "· manager: deferred, you typed in the last 10 min" <<<"$out" || bad "13: should defer: $out"
clk $((47000 + 8 * 86400 + 660)); out=$(tick); [ -n "$(ctx <<<"$out")" ] || bad "13: next tick should pass: $out"
judged

# ---- the schedule is renewed before Claude Code's 7-day limit, even when nothing is new
clk $((47000 + 8 * 86400 + 4000)); out=$(tick); c=$(ctx <<<"$out")
grep -q 'First renew the schedule' <<<"$c" && grep -q 'reply only `·`' <<<"$c" || bad "renew: $out"
"$M" on >/dev/null; out=$(tick); blocked "·" <<<"$out" || bad "renew: after on it should block again: $out"

# ---- 12: a second owner is refused while the first lives; a dead owner is taken over; resume keeps the items
live; B=$P; reg "$B" bbbb2222-x other "$T/home" idle
before=$("$M" resume | grep '^- ')
out=$(CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" on); [ $? = 4 ] && [ "$out" = 'manager already on in boss; `--take` to move it' ] || bad "12: refusal: $out"
kill "$OWN"; while kill -0 "$OWN" 2>/dev/null; do :; done
out=$(CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" on) && grep -q 'manager on in other (moved from boss)' <<<"$out" || bad "12: takeover: $out"
after=$(CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" resume)
[ "$(grep '^- ' <<<"$after")" = "$before" ] && [ -n "$before" ] && [ "$(wc -l <<<"$after")" -le 15 ] || bad "12: resume after takeover: $after / $before"
grep -q '^manager on · owner other' <<<"$after" || bad "12: resume owner line: $after"
# the old owner's leftover tick reaches the model once (to delete its schedule), then is blocked
out=$(tick own-0000); grep -q 'not on in this session (it is on in other)' <<<"$(ctx <<<"$out")" || bad "leftover tick: $out"
out=$(tick own-0000); blocked "· manager is not on here" <<<"$out" || bad "leftover tick twice: $out"
# self-exclusion follows the owner: the new owner's own session is never inspected
mkdir -p "$CLAUDE_CONFIG_DIR/tasks/session-bbbb2222"; jq -nc '{id:"7",subject:"you: answer me",status:"pending"}' > "$CLAUDE_CONFIG_DIR/tasks/session-bbbb2222/7.json"
CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" scan --force >/dev/null; grep -q 'you:bbbb2222\|^- other |' "$DG" && bad "self-exclusion after takeover: $(cat "$DG")"
mkdir -p "$CLAUDE_CONFIG_DIR/tasks/session-aaaa1111"; jq -nc '{id:"3",subject:"you: pick a colour",status:"pending"}' > "$CLAUDE_CONFIG_DIR/tasks/session-aaaa1111/3.json"
CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" scan --force >/dev/null; grep -q '^- you:aaaa1111:3 ' "$DG" || bad "a you: task of another session should be found: $(cat "$DG")"
# an idle session's last reply (its last 600 chars) is flagged for the inspector to judge, once per reply
mkdir -p "$CLAUDE_CONFIG_DIR/projects/p"; xs=$(printf 'x%.0s' $(seq 1 700))
jq -nc --arg t "Done. $xs Shall I push it?" '{type:"assistant",message:{role:"assistant",content:[{type:"text",text:$t}]}}' > "$CLAUDE_CONFIG_DIR/projects/p/aaaa1111-x.jsonl"
reg "$A" aaaa1111-x repo-a "$R" idle 2400
CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" scan --force >/dev/null
{ grep -q '^- idle:aaaa1111 [0-9a-f]\{8\} | .* | repo-a | repo-a idle 40 min after its reply: x' "$DG" && grep -q '^    x* Shall I push it?$' "$DG" \
  && [ "$(awk '/^    x/{print length}' "$DG")" = 604 ]; } || bad "idle reply tail: $(grep -A1 "^- idle" "$DG")"
reg "$A" aaaa1111-x repo-a "$R" busy
# off, and the leftover old next state is gone
mkdir -p "$CLAUDE_CONFIG_DIR/wanjang/next/trust"; echo '{}' > "$CLAUDE_CONFIG_DIR/wanjang/next/s1.json"
CLAUDE_CODE_SESSION_ID=bbbb2222-x "$M" on >/dev/null; [ ! -e "$CLAUDE_CONFIG_DIR/wanjang/next/s1.json" ] && [ -d "$CLAUDE_CONFIG_DIR/wanjang/next/trust" ] || bad "on should delete next/<sid>.json and keep trust/"
"$M" off | grep -q '^manager off (was on in other)$' || bad "off"
out=$(tick bbbb2222-x); grep -q 'it is off' <<<"$(ctx <<<"$out")" || bad "tick after off: $out"

# ---- the ledger prune on `on`: closed items older than 30 days go, open ones stay
n0=$(wc -l < "$LG"); clk $((60 * 86400)); "$M" on >/dev/null
[ "$(wc -l < "$LG")" -lt "$n0" ] && [ -n "$(ev "$id10")" ] && [ -z "$(ev m-1)" ] || bad "prune: $(wc -l < "$LG") of $n0 lines; sent item kept? $(ev "$id10" | head -1)"

# ---- 15: no registry, no config dir: every command exits 0 with one line
for c in "on" "off" "status" "resume" "scan" "page" "ask-list" "dispatch"; do
  out=$(CLAUDE_CONFIG_DIR=$T/none "$M" $c 2>&1); rc=$?
  [ $rc = 0 ] && [ "$(wc -l <<<"$out" | tr -d ' ')" = 1 ] && grep -q 'no config dir' <<<"$out" || bad "15: no config dir, $c: rc=$rc $out"
done
[ ! -e "$T/none" ] || bad "15: the missing config dir was created"
for c in "scan" "dispatch"; do
  out=$(WANJANG_SESSIONS_DIR=$T/nosess "$M" $c 2>&1); rc=$?
  [ $rc = 0 ] && [ "$(wc -l <<<"$out" | tr -d ' ')" = 1 ] && grep -q 'no session registry' <<<"$out" || bad "15: no registry, $c: rc=$rc $out"
done
"$M" on >/dev/null
out=$(WANJANG_SESSIONS_DIR=$T/nosess tick); grep -q 'scan --sessions -' <<<"$(ctx <<<"$out")" || bad "15: tick without registry should ask for ListAgents: $out"
out=$(echo '[{"sessionId":"aaaa1111-x","name":"repo-a","cwd":"'"$R"'","status":"busy"},{"sessionId":"own-0000","name":"boss","cwd":"'"$R"'","status":"waiting"}]' \
      | WANJANG_SESSIONS_DIR=$T/nosess "$M" scan --force --sessions -); grep -q '^new=' <<<"$out" && grep -q '^- repo-a | busy' "$DG" && ! grep -q '^- boss' "$DG" || bad "15: --sessions -: $out"
[ -z "$(echo garbage | "$M" prompt 2>&1)" ] || bad "garbage hook input printed"
[ -z "$(echo '{"session_id":"own-0000","prompt":5}' | "$M" prompt 2>&1)" ] || bad "odd hook input printed"

# ---- promises, trust, undo go to bin/next
"$M" promises | grep -q . && bad "promises: none expected"
"$M" trust --cwd "$R" | grep -q '^trust ladder on' || bad "trust passthrough"
"$M" undo --cwd "$R" | grep -q 'Nothing to undo' || bad "undo passthrough"

# ---- hooks.json: no Stop hook; the tick hook waits up to 45 s
jq -e '(.hooks|has("Stop")|not) and (.hooks.UserPromptSubmit[0].hooks[0]|(.command|endswith("bin/manager\" prompt")) and .timeout==45)' hooks/hooks.json >/dev/null \
  || bad "hooks.json: Stop hook left or prompt hook wrong"

[ $fail = 0 ] && echo "manager: all passed"
exit $fail
