#!/usr/bin/env bash
# Feeds made-up SessionStart input to bin/main-rules with a fake HOME; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
run() { jq -nc --arg c "$2" '{cwd:$c}' | HOME="$1" bin/main-rules | jq -r '.hookSpecificOutput.additionalContext // empty'; }
mkdir -p "$T/home" "$T/proj/.claude/main-rules"
[ -z "$(jq -nc --arg c "$T/proj" '{cwd:$c}' | HOME="$T/home" bin/main-rules)" ] || { echo "FAIL empty dirs should print nothing"; fail=1; }
mkdir -p "$T/home/.claude/main-rules"
echo HOMERULE > "$T/home/.claude/main-rules/b.md"; echo HOMEA > "$T/home/.claude/main-rules/a.md"; echo PROJRULE > "$T/proj/.claude/main-rules/p.md"
o=$(run "$T/home" "$T/proj")
for w in HOMERULE HOMEA PROJRULE "Main-session rule (from $T/home/.claude/main-rules/a.md):"; do
  grep -qF "$w" <<<"$o" || { echo "FAIL missing: $w"; fail=1; }
done
[ "$(grep -n HOMEA <<<"$o" | cut -d: -f1)" -lt "$(grep -n HOMERULE <<<"$o" | cut -d: -f1)" ] || { echo "FAIL order"; fail=1; }
head -c 12000 /dev/zero | tr '\0' x > "$T/home/.claude/main-rules/z.md"
o=$(run "$T/home" "$T/proj")
[ "${#o}" -le 9700 ] && grep -q "skipped, over the limit.*z.md" <<<"$o" || { echo "FAIL cap (${#o})"; fail=1; }
[ $fail = 0 ] && echo "main-rules: all passed"
exit $fail
