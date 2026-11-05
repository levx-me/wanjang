#!/usr/bin/env bash
# Runs bin/next (scan, promises, trust ladder) on temp git repos and a temp config dir; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
N=$PWD/bin/next
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
export CLAUDE_CONFIG_DIR=$T/cfg CLAUDE_CODE_SESSION_ID=s1
R=$T/repo; mkdir "$R"; git -C "$R" init -q
git -C "$R" -c user.email=a@b -c user.name=t commit -q --allow-empty -m init
fail=0
bad() { echo "FAIL $*"; fail=1; }

# ---- old hooks (before 0.13.0) still call `next prompt` and `next stop`: silent no-ops, never a block
for h in prompt stop; do
  out=$(jq -nc '{session_id:"s1",prompt:"fix the bug",transcript_path:"/nonexistent"}' | "$N" $h 2>&1); rc=$?
  [ $rc = 0 ] && [ -z "$out" ] || bad "old hook $h: rc=$rc out=$out"
done

# ---- scan
fp() { "$N" scan --cwd "$R" | awk -F'\t' -v k="$1" '$1==k{print $2}'; }
[ -z "$(fp uncommitted)" ] || bad "clean repo shows uncommitted"
echo one > "$R/a.txt"; git -C "$R" add a.txt
f1=$(fp uncommitted); [ -n "$f1" ] || bad "dirty repo: no uncommitted line"
[ "$(fp uncommitted)" = "$f1" ] || bad "same tree should give the same fp"
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
# unpushed: commits ahead of the upstream
UP=$T/up.git; git init -q --bare "$UP"; git -C "$R" remote add origin "$UP"; git -C "$R" push -q -u origin HEAD 2>/dev/null
[ -z "$(fp unpushed)" ] || bad "pushed branch shows unpushed"
git -C "$R" update-ref HEAD "$(git -C "$R" -c user.email=a@b -c user.name=t commit-tree "HEAD^{tree}" -p HEAD -m two)"  # index untouched
"$N" scan --cwd "$R" | grep -q $'^unpushed\t[0-9a-f]\{8\}\t1 commit not pushed to origin/' || bad "no unpushed line: $("$N" scan --cwd "$R")"
[ "$("$N" kind unpushed)" = outward ] || bad "unpushed should be outward"
git -C "$R" push -q 2>/dev/null; [ -z "$(fp unpushed)" ] || bad "unpushed after push"
# read-only config dir: scan still prints, exit 0
RO=$T/ro; mkdir -p "$RO/wanjang"; chmod 555 "$RO/wanjang"
out=$(CLAUDE_CONFIG_DIR=$RO "$N" scan --cwd "$R" 2>"$T/err"); rc=$?
{ [ $rc = 0 ] && grep -q '^uncommitted' <<<"$out"; } || bad "read-only config dir: rc=$rc out=$out err=$(cat "$T/err")"
chmod 755 "$RO/wanjang"

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
"$N" promise add "off one" --at +1h --cwd "$R" | grep -q "the next session start in .*manager's next check" || bad "add: no hint where it comes up"
# 4
[ -z "$(pl)" ] || bad "promise shown before at"
clk 7300; l=$(pl | head -1)
[ "${l%%$'\t'*}" = "promise:$id" ] && grep -q "once CI is green, check it; due: time passed" <<<"$l" || bad "due promise line: $l"
echo one > "$R/a.txt"; git -C "$R" add a.txt
[ "$("$N" scan --cwd "$R" | head -1 | cut -f1)" = "promise:$id" ] || bad "promise not first"
git -C "$R" rm -q -f a.txt
# 9
fp9=$(pl | grep "^promise:$id" | cut -f2); [ "$(pl | grep "^promise:$id" | cut -f2)" = "$fp9" ] || bad "same day should keep the fp"
[ "$("$N" ask "promise:$id" "$fp9" --cwd "$R")" = ask ] || bad "a promise should always be asked"
clk $((7300 + 86400)); [ "$(pl | grep "^promise:$id" | cut -f2)" != "$fp9" ] || bad "a later day should give a new fp"
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
grep -qF "then \`\"$N\" promise done ID\`" <<<"$out" && grep -q 'not a `next` on PATH, which may be Next.js' <<<"$out" || bad "due: should name bin/next by path: $out"
for e in 0m 30s; do "$N" promise add "fast $e" --when true --every "$e" --cwd "$R" >/dev/null 2>&1; [ $? = 2 ] || bad "--every $e should be refused (at least 1m)"; done
# 18
reset; echo '{"promises":[' > "$PF"; echo one > "$R/a.txt"; git -C "$R" add a.txt
"$N" scan --cwd "$R" | grep -q '^uncommitted' || bad "corrupt promises.json broke scan"
[ -z "$("$N" promise list)" ] && [ $? = 0 ] || bad "corrupt list"
rm -f "$PF"; "$N" scan --cwd "$R" >/dev/null && [ -z "$("$N" promise list)" ] || bad "missing promises.json"
RO=$T/ro2; mkdir -p "$RO/wanjang"; chmod 555 "$RO/wanjang"
CLAUDE_CONFIG_DIR=$RO "$N" promise add "ro" --at +1m --cwd "$R" 2>"$T/err" >/dev/null
[ "$(wc -l <"$T/err")" -eq 1 ] && grep -q '^next: cannot save' "$T/err" || bad "read-only promises dir: $(cat "$T/err")"
chmod 755 "$RO/wanjang"; git -C "$R" rm -q -f a.txt
unset WANJANG_NOW

# ---- trust ladder (WANJANG_NOW clock: yeses are answers given at earlier fake times)
L=$T/lad; mkdir "$L"; gl() { git -C "$L" -c user.email=a@b -c user.name=t "$@"; }; gl init -q; gl commit -q --allow-empty -m init
H=3600; D=86400
lreset() { rm -rf "$T"/cfg/wanjang/next; clk 0; }
tf() { ls "$T"/cfg/wanjang/next/trust/*.json; }
ak() { "$N" ask "$1" "$2" --what "${3:-run the tests}" --cwd "$L"; }  # KEY FP [WHAT]: prints ask|auto
yes_at() { clk "$1"; ak "$2" "y$1" >/dev/null; "$N" answer "$2" "y$1" yes --cwd "$L"; }  # SECONDS KEY
yeses() { "$N" trust --json --cwd "$L" | jq -r --arg k "$1" '.kinds[]|select(.kind==$k)|.yeses'; }
three() { yes_at 0 "$1:a" >/dev/null; yes_at $D "$1:b" >/dev/null; yes_at $((2*D)) "$1:c"; }  # over 2 days
# kind mapping
lreset
for kv in verify:a=verify test:a=test docs:a=docs commit:a=commit uncommitted=commit relay:s=relay task:1=resume \
          run:r1=resume promise:p1=promise todo=other memory-next=other foo:bar=other verify=other; do
  k=$("$N" kind "${kv%%=*}" --what "update the notes"); [ "$k" = "${kv#*=}" ] || bad "kind of ${kv%%=*}: $k"
done
for w in "git push origin main" "Deploy to prod" "publish 1.2" "run the migration" "delete old logs" "rm -rf build" \
         "npm install x" "send the summary by email" "post a PR comment" "pay the invoice"; do
  [ "$("$N" kind commit:o --what "$w")" = outward ] || bad "outward not forced for: $w"
done
for w in "confirm the fix works" "update the form docs"; do
  [ "$("$N" kind commit:o --what "$w")" = commit ] || bad "not outward: $w"
done
# 1: 3 yeses over 2 days -> auto, with a notice on promotion
lreset; out=$(three commit); grep -q '^commit is trusted now (3 yeses): from now' <<<"$out" || bad "1: promotion notice: $out"
[ -f "$(tf)" ] && [ "$(dirname "$(tf)")" = "$T/cfg/wanjang/next/trust" ] || bad "1: trust file path"
clk $((2*D + 60)); [ "$(ak commit:x c1 "commit the verified work")" = auto ] || bad "1: 3 yeses over 2 days should be auto"
echo a > "$L/f1"; gl add f1; gl commit -qm "auto c"
out=$("$N" did commit:x c1 ok --commit HEAD --note 'abc "auto c" (1 file)' --cwd "$L")
grep -q '^Done without asking (commit, trusted after 3 yeses): commit the verified work, abc "auto c" (1 file). Undo: /wanjang:manager undo · always ask: /wanjang:manager trust commit ask$' <<<"$out" || bad "1: report: $out"
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
# 5b: auto needs the kind's own wording and nothing outward, spelled any way; a denylist is never complete
lreset; for k in test docs commit verify relay; do three $k >/dev/null; done; clk $((3*D))
while IFS= read -r w; do
  [ "$("$N" kind commit:g --what "$w")" = outward ] || bad "5b: not outward: $w"
  for kp in "test:g=run the tests, then " "docs:g=update the README, then " "commit:g=commit the files, then "; do
    [ "$(ak "${kp%%=*}" "$RANDOM$RANDOM" "${kp#*=}$w")" = ask ] || bad "5b: '${kp#*=}$w' came back auto"
  done
done <<'EOP'
remove old build dirs
rmdir build
unlink the cache file
truncate the log table
purge the cache
wipe the tmp dir
erase the old builds
rm build
npm i x
pip add requests
brew install jq
apt-get install jq
yarn
go get example.com/x
update the dependencies
terraform apply
kubectl apply -f x.yaml
ship it to production
go live
rollout the new version
promote to prod
sync with remote
git remote update
git reset --hard origin/main
merge to main
open a PR
gh pr create
gh pr merge 12
upload the build
scp build host:
rsync dist/ host:
message Alice
notify the team
ping Bob
tell the customer
mail the report
e-mail the report
post it on slack
tweet the release
DM Carol
text Dan
reply to the thread
buy a paid plan
charge the card
bill the customer
subscribe to the pro plan
transfer funds
alter table users
schema change
p-u-s-h it
pu sh it
EOP
for w in "look at the tests" "please run the tests" "tidy up" "do the usual"; do
  [ "$(ak test:g "$RANDOM" "$w")" = ask ] || bad "5b: unrecognised '$w' came back auto"
done
# compounds whose outward verb no denylist names: one clause of the kind's own words only
while IFS='=' read -r k w; do
  fp="x$RANDOM"; [ "$(ak "$k" "$fp" "$w")" = ask ] || { bad "5b: compound '$w' ($k) came back auto"; "$N" did "$k" "$fp" ask --cwd "$L"; }
done <<'EOX'
commit:g=commit the files and let Bob know
verify:g=verify the build, then launch the site
test:g=run the tests and sign up for the service
commit:g=commit the files and make it public
commit:g=commit and announce it
commit:g=commit the files and add the package x
docs:g=update the README and put it on the server
verify:g=check the site and then order a domain
commit:g=commit the files, then publicize
test:g=run the tests and bump the version
verify:g=verify then kill the process
commit:g=commit the files and chmod 777 /
docs:g=update the README then whatsapp Bob
relay:s9=relay a note then sign up
verify:g=check and restart the service
commit:g=commit the files and ｐｕｓｈ
commit:g=commit the files ｐｕｓｈ
commit:g=commit the files I changed to prod
test:g=run the tests; curl x
relay:s9=report back to s8
test:g=run the tests 并推送
test:g=run the tests 그리고 푸시해
commit:g=commit it 그리고 배포해
commit:g=commit it и запушь
commit:g=commit it 公開して
test:g=run the tests 🚀
verify:g=verify the fix 并推送
docs:g=update the README 그리고 배포해
relay:s9=report back to s9 并推送
test:g=run the​ tests
EOX
while IFS='=' read -r k w; do
  fp="c$RANDOM"; r=$(ak "$k" "$fp" "$w"); [ "$r" = auto ] || bad "5b: control '$w' ($k) should be auto: $r"
  "$N" did "$k" "$fp" ask --cwd "$L"
done <<'EOC'
test:g=run the unit tests
test:g=run tests
docs:g=update the README
commit:g=commit the files I changed
verify:g=verify the fix
relay:s9=report back to s9
EOC
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
# 8: one at a time, 6 per 24 h (2 per tick is bin/manager's); the same running action asked again stays auto
lreset; three test >/dev/null; s=$((3*D)); got=""
step() { s=$((s + 10)); clk $s; r=$(ak test:x "s$s"); got="$got$r "; [ "$r" = auto ] && [ "$1" != keep ] && "$N" did test:x "s$s" ok --cwd "$L" >/dev/null; }
step keep; [ "$(ak test:x "s$s")" = auto ] || bad "8: the running action asked again should stay auto"
step; [ "$got" = "auto ask " ] || bad "8: a running auto action should block another: $got"
"$N" did test:x "s$((s - 10))" ask --cwd "$L"; got=""
for i in 1 2 3 4 5 6 7; do step; done
[ "$got" = "auto auto auto auto auto auto ask " ] || bad "8: limits: $got"
clk $((5*D + 1))
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
# 13: survives a new session; worktrees share it
lreset; three relay >/dev/null; clk $((3*D))
[ "$(CLAUDE_CODE_SESSION_ID=s2 "$N" ask relay:s9 r1 --what "report back to s9" --cwd "$L")" = auto ] || bad "13: new session should see the trust"
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
