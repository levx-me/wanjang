#!/usr/bin/env bash
# Runs bin/guard on commands the foreman might send; fails on any wrong verdict.
cd "$(dirname "$0")/.." || exit 2
fail=0
check() {  # expect(deny|allow) agent_type command
  out=$(jq -n --arg t "$2" --arg c "$3" '{agent_type: $t, tool_input: {command: $c}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $3"; fail=1; }
}
F=foreman:foreman
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
check allow "foreman:builder" "echo hi > lib/a.ts"
check allow "" "echo hi > lib/a.ts"
checkw() {  # expect tool file
  out=$(jq -n --arg t "$2" --arg f "$3" '{agent_type: "foreman:foreman", tool_name: $t, tool_input: {file_path: $f}}' | bin/guard)
  got=allow; [ -n "$out" ] && got=deny
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $2 $3"; fail=1; }
}
checkw allow Write "/x/repo/.git/foreman/2026-10-21-auth.md"
checkw allow Edit  "$HOME/.claude/foreman/runs/2026-10-21-notes.md"
checkw deny  Write "/x/repo/lib/auth.ts"
checkw deny  Edit  "/x/repo/.git/config"
checkw deny  Write "/x/repo/foreman/plan.md"
[ $fail = 0 ] && echo "guard: all cases pass"
exit $fail
