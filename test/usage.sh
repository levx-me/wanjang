#!/usr/bin/env bash
# Runs bin/usage on a made-up session; fails on any wrong number.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
P=$T/projects/-x; S=sess1; mkdir -p "$P/$S/subagents"
now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
py() { python3 -c "import json,sys; print(json.dumps(json.loads(sys.argv[1])))" "$1"; }
{
  py '{"type":"assistant","message":{"model":"claude-opus-5-5","usage":{"input_tokens":10,"cache_read_input_tokens":100000,"cache_creation_input_tokens":0},"content":[{"type":"tool_use","id":"t0","name":"Read","input":{"file_path":"/old.md"}}]}}'
  py '{"type":"system","subtype":"compact_boundary"}'
  for i in 1 2 3; do
    py "{\"type\":\"assistant\",\"message\":{\"content\":[{\"type\":\"tool_use\",\"id\":\"r$i\",\"name\":\"Read\",\"input\":{\"file_path\":\"/big.ts\"}}]}}"
    py "{\"type\":\"user\",\"message\":{\"content\":[{\"type\":\"tool_result\",\"tool_use_id\":\"r$i\",\"content\":\"$(printf 'x%.0s' $(seq 400))\"}]}}"
  done
  py '{"type":"assistant","message":{"model":"claude-opus-5-5","usage":{"input_tokens":5,"cache_read_input_tokens":500000,"cache_creation_input_tokens":0},"content":[{"type":"tool_use","id":"b1","name":"Bash","input":{"command":"npm run watch","description":"Watch the build"}}]}}'
  py '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"b1","content":"Command running in background with ID: bg1. Output is being written to: x"}]}}'
} > "$P/$S.jsonl"
mkdir -p "$T/tmp"; out=/private/tmp/claude-$(id -u)/usage-test-$$/$S/tasks; mkdir -p "$out"; head -c 3000 /dev/zero > "$out/bg1.output"
echo '{"agentType":"wanjang:builder","description":"Fix the login"}' > "$P/$S/subagents/agent-a1.meta.json"
for i in 1 2 3; do
  py "{\"type\":\"assistant\",\"timestamp\":\"$now\",\"message\":{\"model\":\"claude-sonnet-5-5\",\"usage\":{\"input_tokens\":100,\"output_tokens\":50,\"cache_creation_input_tokens\":1000,\"cache_read_input_tokens\":0}}}"
  py '{"type":"user","message":{"content":[{"type":"tool_result","is_error":true,"content":"Error: cannot find module x"}]}}'
done > "$P/$S/subagents/agent-a1.jsonl"
json=$(CLAUDE_CONFIG_DIR=$T bin/usage --session $S --cwd "$T" --json); rm -rf "/private/tmp/claude-$(id -u)/usage-test-$$"
fail=0
want() { got=$(printf '%s' "$json" | jq -r "$1"); [ "$got" = "$2" ] || { echo "FAIL $1: want $2 got $got"; fail=1; }; }
want '.main.context' 500005
want '.main.reread[0] | "\(.[0]) \(.[1])"' '/big.ts 3'
want '[.main.reread[][0]] | index("/old.md")' null   # before the compaction: not counted
want '.agents[0].name' wanjang:builder
want '.agents[0].last_5min' 3450
want '.agents[0].repeated_error' 'Error: cannot find module x'
want '.background[0].id' bg1
want '.background[0].output_kb' 2
CLAUDE_CONFIG_DIR=$T bin/usage --session none >/dev/null 2>&1; [ $? = 2 ] || { echo "FAIL exit code for a missing session"; fail=1; }
[ $fail = 0 ] && echo "usage: all cases pass"
exit $fail
