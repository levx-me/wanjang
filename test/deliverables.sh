#!/usr/bin/env bash
# Feeds made-up hook input to bin/deliverables; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
echo hi > "$T/a.txt"; echo hi > "$T/b.txt"; : > "$T/empty.txt"
out() { jq -nc --arg p "$1" --arg d "$T" --arg s "${2:-completed}" '{tool_name:"Agent",cwd:$d,tool_input:{prompt:$p},tool_response:{status:$s}}' | bin/deliverables; }
warns() { o=$(out "$1" "${3:-}"); case $o in *additionalContext*"$2"*) ;; *) echo "FAIL should warn ($2): $o"; fail=1 ;; esac; }
quiet() { [ -z "$(out "$1" "${2:-}")" ] || { echo "FAIL should be silent: $1"; fail=1; }; }
quiet "Build it.
Deliverables: $T/a.txt, b.txt"
warns "Deliverables: $T/a.txt, nope.txt" "nope.txt (missing)"
warns "Deliverables: a.txt, empty.txt" "empty.txt (empty)"
printf 'Goal\nDeliverables: a.txt, gone.txt\n' > "$T/brief.md"
warns "Read $T/brief.md and do it" "gone.txt (missing)"
quiet "Just research, no files."
quiet "Deliverables: nope.txt" async_launched
[ $fail = 0 ] && echo "deliverables: all passed"
exit $fail
