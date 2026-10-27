#!/usr/bin/env bash
# Feeds made-up SessionStart input to bin/route with a fake HOME; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
run() { jq -nc --arg c "$2" '{cwd:$c}' | HOME="$1" bin/route | jq -r .hookSpecificOutput.additionalContext; }
mkdir -p "$T/home" "$T/proj/.claude/main-rules"
base=$(run "$T/home" "$T/proj")
grep -q "Main-session rule" <<<"$base" && { echo "FAIL empty dirs should add nothing"; fail=1; }
[ "$base" = "$(cat ROUTING.md)" ] || { echo "FAIL output differs from ROUTING.md"; fail=1; }
mkdir -p "$T/home/.claude/main-rules"
echo "HOMERULE" > "$T/home/.claude/main-rules/b.md"; echo "HOMEA" > "$T/home/.claude/main-rules/a.md"
echo "PROJRULE" > "$T/proj/.claude/main-rules/p.md"
o=$(run "$T/home" "$T/proj")
for w in HOMERULE HOMEA PROJRULE "Main-session rule (from $T/home/.claude/main-rules/a.md):"; do
  grep -qF "$w" <<<"$o" || { echo "FAIL missing: $w"; fail=1; }
done
[ "$(grep -n HOMEA <<<"$o" | cut -d: -f1)" -lt "$(grep -n HOMERULE <<<"$o" | cut -d: -f1)" ] || { echo "FAIL order"; fail=1; }
head -c 50000 /dev/zero | tr '\0' x > "$T/home/.claude/main-rules/big.md"
run "$T/home" "$T/proj" | grep -q "exceed 40 KB" || { echo "FAIL cap"; fail=1; }
[ $fail = 0 ] && echo "route: all passed"
exit $fail
