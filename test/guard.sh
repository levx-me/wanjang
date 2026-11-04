#!/usr/bin/env bash
# Runs bin/guard on commands the PM might send; fails on any wrong verdict.
cd "$(dirname "$0")/.." || exit 2
fail=0
check() {  # expect(deny|allow) agent_type command
  out=$(jq -n --arg t "$2" --arg c "$3" '{agent_type: $t, tool_input: {command: $c}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $3"; fail=1; }
}
F=wanjang:pm
check deny  $F "cd /x; python3 - <<'EOF'
open('lib/a.ts','w').write(s)
EOF"
check deny  $F "sed -i '' 's/a/b/' lib/a.ts"
check deny  $F "echo hi > lib/a.ts"
check deny  $F "cat > app/x.tsx <<'EOF'
x
EOF"
check deny  $F "printf x | tee lib/a.ts"
check deny  $F "cd /x && git add -A && git commit -m fix"
check deny  $F "git -C /x commit -m fix"
check deny  $F "rm -rf lib/old"
check allow $F "cd /x; npm test 2>&1 | tail -5"
check allow $F "grep -rn foo lib > /dev/null && echo yes"
check allow $F "git status --short; git log --oneline -5; git diff --stat"
check allow $F "S=/private/tmp/claude-501/p/s; npx eslint a.ts > \$S/lint.txt 2>&1"
check allow $F "curl -s localhost:3000/api | jq '.items[] | select(.n >= 2)'"
check allow $F "node -e 'const f = (a) => a + 1; console.log(f(1))'"
check allow "wanjang:builder" "echo hi > lib/a.ts"
check deny  wanjang:wanjang "echo hi > lib/a.ts"  # old name is still the PM
check allow "" "echo hi > lib/a.ts"
checkw() {  # expect tool file
  out=$(jq -n --arg t "$2" --arg f "$3" '{agent_type: "wanjang:pm", tool_name: $t, tool_input: {file_path: $f}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $2 $3"; fail=1; }
}
checkw allow Write "/x/repo/.git/wanjang/2026-10-21-auth/log.md"
checkw allow Write "/x/repo/.git/wanjang/2026-10-21-auth/brief-1-builder.md"
checkw deny  Write "/tmp/scratch.md"
checkw allow Edit  "$HOME/.claude/wanjang/runs/2026-10-21-notes.md"
checkw deny  Write "/x/repo/lib/auth.ts"
checkw deny  Edit  "/x/repo/.git/config"
checkw deny  Write "/x/repo/wanjang/plan.md"
checkr() {  # expect agent_type tool file
  out=$(jq -n --arg a "$2" --arg t "$3" --arg f "$4" '{agent_type: $a, tool_name: $t, tool_input: {file_path: $f}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $2 $3 $4"; fail=1; }
}
checkr allow wanjang:checker Write "/x/repo/.git/wanjang/2026-10-21-auth/return-3-checker.md"
checkr allow wanjang:scout   Write "/private/var/folders/ab/T/notes.md"
checkr deny  wanjang:planner Write "/x/repo/docs/spec.md"
checkr deny  wanjang:qa      Edit  "/x/repo/app/page.tsx"
checkr allow wanjang:builder Write "/x/repo/app/page.tsx"
check  allow wanjang:checker "git diff main..HEAD > /x/repo/.git/wanjang/r/review.diff"

# Locked goal check: a temp repo whose run log locks test/goal.sh.
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
git -C "$T" init -q && git -C "$T" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init
mkdir -p "$T/.git/wanjang/run1" "$T/test" && echo ok > "$T/test/goal.sh"
LOG="$T/.git/wanjang/run1/log.md"
B=0123456789abcdef0123456789abcdef01234567
lock() {  # the log's text; fresh by default
  printf '%s\n' "$1" > "$LOG"
}
open() { lock "Status: in progress
Goal check: bash test/goal.sh | tail -3 | locked: test/goal.sh@$B, test/b.spec.ts@$B"; }
checkl() {  # expect agent tool file-or-command [cwd]
  if [ "$3" = Bash ]; then in=$(jq -n --arg a "$2" --arg c "$4" --arg d "${5:-$T}" '{agent_type: $a, cwd: $d, tool_name: "Bash", tool_input: {command: $c}}')
  else in=$(jq -n --arg a "$2" --arg t "$3" --arg f "$4" '{agent_type: $a, tool_name: $t, tool_input: {file_path: $f}}'); fi
  out=$(printf '%s' "$in" | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $2 $3 $4"; fail=1; }
  [ "$1" = deny ] && [ "$2" != wanjang:pm ] && { case "$out" in *"Locked goal check"*|*"Only the PM edits a run log"*) ;; *) echo "FAIL reason: $4"; fail=1 ;; esac; }
}
open
checkl deny  wanjang:builder  Edit  "$T/test/goal.sh"                    # L1
checkl deny  wanjang:designer Write "$T/test/b.spec.ts"
out=$(jq -n --arg f "$T/test/goal.sh" '{agent_type: "wanjang:builder", tool_name: "Edit", tool_input: {file_path: $f}}' | bin/guard)
case "$out" in *"Locked goal check: test/goal.sh defines done for run run1."*) ;; *) echo "FAIL reason text: $out"; fail=1 ;; esac
checkl allow wanjang:builder  Edit  "$T/src/app.ts"                      # L2
checkl allow wanjang:builder  Edit  "$T/test/other.sh"
checkl allow wanjang:builder  Bash  "cat test/goal.sh; grep -n x test/goal.sh | head"
checkl deny  wanjang:builder  Bash  "sed -i '' 's/a/b/' test/goal.sh"    # L3
checkl deny  wanjang:builder  Bash  "echo exit 0 > test/goal.sh"
checkl deny  wanjang:builder  Bash  "echo exit 0 >> test/goal.sh"
checkl deny  wanjang:builder  Bash  "printf x | tee test/goal.sh"
checkl deny  wanjang:builder  Bash  "cp /tmp/x test/goal.sh"
checkl deny  wanjang:builder  Bash  "mv /tmp/x test/goal.sh"
checkl deny  wanjang:builder  Bash  "git checkout -- test/goal.sh"
checkl deny  wanjang:builder  Bash  "git restore test/goal.sh"
checkl deny  wanjang:builder  Bash  "python3 -c \"open('test/goal.sh','w').write('')\""
checkl deny  wanjang:builder  Bash  "node -e \"require('fs').writeFileSync('test/goal.sh','')\""
checkl deny  wanjang:builder  Bash  "dd if=/dev/null of=test/goal.sh"
checkl allow wanjang:builder  Bash  "echo x > src/a.ts; sed -i '' s/a/b/ src/a.ts"
checkl allow wanjang:builder  Bash  "bash test/goal.sh > /tmp/out.txt 2>&1"
checkl deny  wanjang:checker  Bash  "sed -i '' 's/a/b/' test/goal.sh"
mkdir -p "$T/wt" && git -C "$T" worktree add -q "$T/wt/b" -b wtb
checkl deny  wanjang:builder  Edit  "$T/wt/b/test/goal.sh"               # L7
checkl deny  wanjang:builder  Write "$T/wt/b/test/b.spec.ts"
checkl allow wanjang:builder  Edit  "$T/wt/b/test/other.sh"
checkl deny  wanjang:builder  Bash  "sed -i '' s/a/b/ test/goal.sh" "$T/wt/b"
checkl allow ""               Edit  "$T/test/goal.sh"                    # L5
checkl allow ""               Bash  "sed -i '' s/a/b/ test/goal.sh"
checkl deny  wanjang:builder  Edit  "$LOG"                               # L6
checkl deny  wanjang:builder  Write "$T/.git/wanjang/run2/log.md"
checkl deny  wanjang:checker  Edit  "$LOG"
checkl deny  wanjang:builder  Bash  "echo 'Status: done' > .git/wanjang/run1/log.md"
checkl deny  wanjang:builder  Bash  "sed -i '' 's/in progress/done/' .git/wanjang/run1/log.md"
checkl allow wanjang:builder  Bash  "cat .git/wanjang/run1/log.md"
checkl allow wanjang:builder  Write "$T/.git/wanjang/run1/return-1-builder.md"
checkl allow wanjang:pm       Write "$LOG"
checkl allow wanjang:wanjang  Edit  "$LOG"
checkl deny  wanjang:pm       Edit  "$T/test/goal.sh"                    # the PM still may not build
# L4: no lock in force
lock "Status: done
Goal check: bash test/goal.sh | locked: test/goal.sh@$B"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
checkl allow wanjang:builder  Bash  "sed -i '' s/a/b/ test/goal.sh"
open; touch -t 202601010000 "$LOG"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
lock "Status: in progress
Goal check: bash test/goal.sh | locked: test/goal.sh@open"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
lock "Status: in progress
Goal: ship the thing"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
lock "Status: in progress
Goal check: bash test/goal.sh | locked test/goal.sh"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
lock "Status: in progress
Goal check: QA steps 2-4 of the spec"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
lock "Status: in progress
Goal check: bash x | locked: test/goal.sh@zzz, @$B, test/a.sh"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"
rm -rf "$T/.git/wanjang"
checkl allow wanjang:builder  Edit  "$T/test/goal.sh"                    # no log at all
checkl allow wanjang:builder  Edit  "$T/nonexistent/dir/x.ts"
checkl allow wanjang:builder  Edit  "relative/path.ts"
[ $fail = 0 ] && echo "guard: all cases pass"
exit $fail
