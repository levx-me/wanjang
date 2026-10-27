#!/usr/bin/env bash
# Feeds made-up SessionStart input to bin/route with a fake HOME; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
run() { jq -nc --arg c "$2" '{cwd:$c}' | HOME="$1" bin/route | jq -r .hookSpecificOutput.additionalContext; }
mkdir -p "$T/home" "$T/proj"
base=$(run "$T/home" "$T/proj")
grep -q "Main-session rule" <<<"$base" && { echo "FAIL empty dirs should add nothing"; fail=1; }
[ "$base" = "$(cat ROUTING.md)" ] || { echo "FAIL output differs from ROUTING.md"; fail=1; }
[ $fail = 0 ] && echo "route: all passed"
exit $fail
