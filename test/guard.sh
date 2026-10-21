#!/usr/bin/env bash
# Runs bin/guard on commands the wanjang might send; fails on any wrong verdict.
cd "$(dirname "$0")/.." || exit 2
fail=0
check() {  # expect(deny|allow) agent_type command
  out=$(jq -n --arg t "$2" --arg c "$3" '{agent_type: $t, tool_input: {command: $c}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $3"; fail=1; }
}
F=wanjang:wanjang
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
check allow "" "echo hi > lib/a.ts"
checkw() {  # expect tool file
  out=$(jq -n --arg t "$2" --arg f "$3" '{agent_type: "wanjang:wanjang", tool_name: $t, tool_input: {file_path: $f}}' | bin/guard)
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
checkr allow wanjang:checker Write "/x/repo/.git/wanjang/2026-10-21-auth/checker-tests.log"
checkr allow wanjang:scout   Write "/private/var/folders/ab/T/notes.md"
checkr deny  wanjang:planner Write "/x/repo/docs/spec.md"
checkr deny  wanjang:qa      Edit  "/x/repo/app/page.tsx"
checkr allow wanjang:builder Write "/x/repo/app/page.tsx"
check  allow wanjang:checker "git diff main..HEAD > /x/repo/.git/wanjang/r/review.diff"
[ $fail = 0 ] && echo "guard: all cases pass"
exit $fail
