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
# SubagentStop: the brief is the first user line of the worker's transcript
tr() { jq -nc --arg p "$1" '{type:"user",message:{role:"user",content:[{type:"text",text:$p}]}}' > "$T/t.jsonl"; }
stop() { jq -nc --arg d "$T" --arg a "$1" --arg t "$2" '{hook_event_name:"SubagentStop",cwd:$d,stop_hook_active:($a=="true"),agent_transcript_path:$t}' | bin/deliverables; }
tr "Deliverables: a.txt, nope.txt"
o=$(stop false "$T/t.jsonl"); case $o in *'"decision": "block"'*"nope.txt (missing)"*"Create them"*) ;; *) echo "FAIL stop block: $o"; fail=1 ;; esac
[ -z "$(stop true "$T/t.jsonl")" ] || { echo "FAIL stop_hook_active"; fail=1; }
[ -z "$(stop false "$T/none.jsonl")" ] || { echo "FAIL transcript missing"; fail=1; }
tr "Deliverables: a.txt, b.txt"
[ -z "$(stop false "$T/t.jsonl")" ] || { echo "FAIL stop all present"; fail=1; }
tr "Read $T/brief.md"
o=$(stop false "$T/t.jsonl"); case $o in *gone.txt*) ;; *) echo "FAIL stop brief file: $o"; fail=1 ;; esac
[ $fail = 0 ] && echo "deliverables: all passed"
exit $fail
