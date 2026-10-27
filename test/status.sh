#!/usr/bin/env bash
# Runs bin/status on a made-up projects dir: waiting, finished, stuck and nested agents.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
P=$T/projects/-x; S=sess1; D=$P/$S/subagents; mkdir -p "$D"
echo '{"type":"user","cwd":"/nonexistent","timestamp":"2026-01-01T00:00:00Z"}' > "$P/$S.jsonl"
iso() { date -u -r "$(( $(date +%s) - $1 ))" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "-$1 sec" +%Y-%m-%dT%H:%M:%SZ; }
use() { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","id":"%s","name":"Bash","input":{"command":"%s"}}]}}\n' "$(iso "$1")" "$2" "$3"; }
res() { printf '{"type":"user","timestamp":"%s","message":{"content":[{"type":"tool_result","tool_use_id":"%s","content":"ok"}]}}\n' "$(iso "$1")" "$2"; }
txt() { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"text","text":"%s"}]}}\n' "$(iso "$1")" "$2"; }
mk() { echo "{\"agentType\":\"$2\",\"description\":\"$3\",\"spawnDepth\":$4$5}" > "$D/agent-$1.meta.json"; }
touch_ago() { touch -t "$(date -r "$(( $(date +%s) - $2 ))" +%Y%m%d%H%M.%S 2>/dev/null || date -d "-$2 sec" +%Y%m%d%H%M.%S)" "$1"; }
# pm (depth 1) running; worker (depth 2, parent recorded) waiting on forge test for 4 min
mk pm wanjang:pm "Lead the build" 1; { txt 3000 "Planning"; use 20 p1 "ls"; } > "$D/agent-pm.jsonl"
mk w1 wanjang:builder "Write the tests" 2 ',"parentAgentId":"pm"'; { txt 3000 "Starting"; use 240 w1 "forge test"; } > "$D/agent-w1.jsonl"
# finished (meta flag)
mk fin wanjang:scout "Look up docs" 1 ',"finished":true'; { use 900 f1 "ls"; res 890 f1; txt 880 "Found it"; } > "$D/agent-fin.jsonl"
# stuck: 30 min silent, nothing pending
mk stk wanjang:builder "Fix the login" 1; { txt 2500 "Working on it"; use 2400 s1 "ls"; res 2300 s1; } > "$D/agent-stk.jsonl"
touch_ago "$D/agent-stk.jsonl" 1800
json=$(CLAUDE_CONFIG_DIR=$T bin/status --session $S --cwd /nonexistent --json); rc=$?
fail=0
want() { got=$(printf '%s' "$json" | jq -r "$1"); [ "$got" = "$2" ] || { echo "FAIL $1: want $2 got $got"; fail=1; }; }
[ $rc = 0 ] || { echo "FAIL exit $rc"; fail=1; }
want '[.agents[] | select(.running)] | length' 3
want '.agents[] | select(.id=="fin") | .running' false
want '.agents[] | select(.id=="w1") | .waiting.what' 'forge test'
want '.agents[] | select(.id=="w1") | .waiting.secs >= 240' true
want '.agents[] | select(.id=="w1") | .stuck' false
want '.agents[] | select(.id=="stk") | .stuck' true
want '[.agents[].id] | index("w1") - index("pm")' 1   # nested worker follows its parent
CLAUDE_CONFIG_DIR=$T bin/status --session $S --cwd /nonexistent | grep -q 'MAY BE STUCK' || { echo "FAIL text output"; fail=1; }
CLAUDE_CONFIG_DIR=$T bin/status --bogus 2>/dev/null; [ $? = 2 ] || { echo "FAIL bad args exit"; fail=1; }
[ $fail = 0 ] && echo "status.sh ok"; exit $fail
