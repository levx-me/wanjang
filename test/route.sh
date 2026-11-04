#!/usr/bin/env bash
# Feeds made-up SessionStart input to bin/route with a fake HOME; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
run() { jq -nc --arg c "$2" '{cwd:$c}' | HOME="$1" CLAUDE_CONFIG_DIR="$1/.claude" bin/route | jq -r .hookSpecificOutput.additionalContext; }
mkdir -p "$T/home" "$T/proj" "$T/projB"
base=$(run "$T/home" "$T/proj")
grep -q "Main-session rule" <<<"$base" && { echo "FAIL empty dirs should add nothing"; fail=1; }
[ "$base" = "$(sed "s|<bin>|$PWD/bin|g" ROUTING.md)" ] || { echo "FAIL output differs from ROUTING.md"; fail=1; }
grep -q "^- When you or the user commit to something later.*\`$PWD/bin/next promise add\`" <<<"$base" || { echo "FAIL capture rule lacks the real bin path"; fail=1; }
# a promise due in projB shows there at session start, and nowhere else
WANJANG_NOW=1800000000 CLAUDE_CONFIG_DIR="$T/home/.claude" bin/next promise add "check the release" --at +1m --cwd "$T/projB" >/dev/null
export WANJANG_NOW=1800000100
b=$(run "$T/home" "$T/projB")
{ grep -q '^Promises due here' <<<"$b" && grep -q 'check the release; due: time passed' <<<"$b"; } || { echo "FAIL no due notice: $b"; fail=1; }
[ "$(run "$T/home" "$T/proj")" = "$base" ] || { echo "FAIL due notice in a project without promises"; fail=1; }
[ $fail = 0 ] && echo "route: all passed"
exit $fail
