#!/usr/bin/env bash
# Runs bin/ghwatch against a local bare remote and a fake gh; fails on a wrong line or exit code.
cd "$(dirname "$0")/.." || exit 2
W=$PWD; T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
git init -q --bare "$T/remote.git"
git clone -q "$T/remote.git" "$T/repo" 2>/dev/null
git clone -q "$T/remote.git" "$T/other" 2>/dev/null
c() { git -C "$1" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m "$2"; }
c "$T/repo" init && git -C "$T/repo" push -q origin HEAD:main 2>/dev/null && git -C "$T/repo" branch -q -u origin/main
git -C "$T/repo" push -q origin HEAD:feat 2>/dev/null && git -C "$T/repo" branch -q feat origin/feat
mkdir "$T/bin"; cat > "$T/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
  "repo view") echo '{"nameWithOwner":"o/r"}' ;;
  "api user") echo '{"login":"me"}' ;;
  "pr list") case "$*" in *search*) echo '[]' ;; *) cat "$FAKE_PRS" ;; esac ;;
  "issue list") case "$*" in *assignee*) cat "$FAKE_ISSUES" ;; *) echo '[]' ;; esac ;;
esac
EOF
chmod +x "$T/bin/gh"
export PATH="$T/bin:$PATH" FAKE_PRS="$T/prs.json" FAKE_ISSUES="$T/issues.json"
pr() { echo "{\"number\":$1,\"title\":\"$2\",\"author\":{\"login\":\"al\"},\"isDraft\":false,\"headRefOid\":\"$3\",\"updatedAt\":\"$4\",\"reviewDecision\":\"\",\"statusCheckRollup\":[{\"status\":\"COMPLETED\",\"conclusion\":\"$5\"}],\"reviewRequests\":[$6],\"url\":\"u\"}"; }
run() { out=$(cd "$T/repo" && "$W/bin/ghwatch" --state "$T/state"); rc=$?; }
want() {  # rc grep-pattern label
  [ "$rc" = "$1" ] || { echo "FAIL $3: exit $rc, want $1"; fail=1; }
  [ -z "$2" ] || grep -qE "$2" <<<"$out" || { echo "FAIL $3: no line matching $2 in:"; echo "$out"; fail=1; }
}
echo "[$(pr 1 Add a1 t1 SUCCESS)]" > "$T/prs.json"; echo '[]' > "$T/issues.json"
run; want 0 '^\s+\* #1 Add .*CI pass · new$' "first check marks all new"
run; want 3 '^\s+  #1 Add' "second check: nothing changed"
echo "[$(pr 1 Add a2 t2 FAILURE), $(pr 2 Fix b1 t1 SUCCESS '{"login":"me"}')]" > "$T/prs.json"
run; want 0 '\* #1 Add .*new commits, CI fail \(was pass\)' "commits and CI"
grep -q 'review  asking for your review: #2' <<<"$out" || { echo "FAIL review line"; echo "$out"; fail=1; }
echo "[$(pr 2 Fix b1 t1 SUCCESS '{"login":"me"}')]" > "$T/prs.json"
echo '[{"number":9,"title":"Bug","updatedAt":"t1"}]' > "$T/issues.json"
run; want 0 '^\* closed .*#1 Add' "closed PR"
grep -q '^\* issue   #9 Bug (assigned to you, new)' <<<"$out" || { echo "FAIL issue line"; echo "$out"; fail=1; }
git -C "$T/other" fetch -q && git -C "$T/other" checkout -q -b main origin/main && c "$T/other" "Upstream change" \
  && git -C "$T/other" push -q origin main 2>/dev/null && git -C "$T/other" push -q origin :feat 2>/dev/null
run; want 0 'is 1 behind origin/main' "behind"
grep -q 'Upstream change' <<<"$out" || { echo "FAIL commit title"; fail=1; }
grep -q '^\* gone    1 local branches.*: feat' <<<"$out" || { echo "FAIL gone"; echo "$out"; fail=1; }
[ "$(git -C "$T/repo" rev-list --count HEAD..origin/main)" = 1 ] || { echo "FAIL it merged"; fail=1; }
run; want 3 '' "same state again"
sed -i '' 's/^  "pr list")/  "pr list") exit 1;;  "x")/' "$T/bin/gh"
run; want 3 'PRs and issues not checked' "gh outage: no false closed"
sed -i '' 's/^  "pr list") exit 1;;  "x")/  "pr list")/' "$T/bin/gh"
run; want 3 '' "back online: nothing new"
(cd "$T" && "$W/bin/ghwatch" --state "$T/state" 2>/dev/null); [ $? = 2 ] || { echo "FAIL not a repo: want exit 2"; fail=1; }
[ $fail = 0 ] && echo "ghwatch: all cases pass"
exit $fail
