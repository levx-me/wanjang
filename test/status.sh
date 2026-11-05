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

# --- --eta: fixed clock, history of finished agents, running agents, a PM with a run log
NOW=$(date +%s); export WANJANG_NOW=$NOW
isoN() { date -u -r "$(( NOW - $1 ))" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "@$(( NOW - $1 ))" +%Y-%m-%dT%H:%M:%SZ; }
span() { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"text","text":"a"}]}}\n{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"text","text":"b"}]}}\n' "$(isoN "$1")" "$(isoN "$2")"; }
U=$(mktemp -d); trap 'rm -rf "${T:?}" "${U:?}"' EXIT
git init -q "$U/repo"; RL=$U/repo/.git/wanjang/run1; mkdir -p "$RL"
Q=$U/projects/-y; E=$Q/s2/subagents; H=$Q/s0/subagents; mkdir -p "$E" "$H"
echo "{\"type\":\"user\",\"cwd\":\"$U/repo\",\"timestamp\":\"$(isoN 9000)\"}" > "$Q/s2.jsonl"
hist() { # type model minutes...: finished agents, each took that many minutes
  local ty=$1 mo=$2; shift 2; local m i=0
  for m in "$@"; do i=$((i+1)); local id=h-${ty#wanjang:}-${mo//\"/}-$i
    echo "{\"agentType\":\"$ty\",\"model\":$mo,\"finished\":true,\"spawnDepth\":1}" > "$H/agent-$id.meta.json"
    span $((20000 - i)) $((20000 - i - m * 60)) > "$H/agent-$id.jsonl"
  done; }
hist wanjang:builder '"sonnet"' 4 5 6 7 8 9     # median 6.5, p80 8
hist wanjang:pm null 10 10 10 10 10
hist wanjang:checker '"opus"' 2 3; hist wanjang:checker '"sonnet"' 1 2 3   # 5 by type, 2 and 3 by model
hist wanjang:scout '"sonnet"' 2 3
run() { echo "{\"agentType\":\"$2\",\"model\":$3,\"description\":\"$4\",\"spawnDepth\":1}" > "$E/agent-$1.meta.json"
  { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"text","text":"start"}]}}\n' "$(isoN "$5")"
    printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","id":"u%s","name":"Bash","input":{"command":"ls"}}]}}\n' "$(isoN 5)" "$1"; } > "$E/agent-$1.jsonl"; }
run bnew wanjang:builder '"sonnet"' "Fresh build" 180        # 3 min in: likely +3.5, latest +5
run bold wanjang:builder '"sonnet"' "Slow build" 1500        # 25 min in: past p80
run chk wanjang:checker '"opus"' "Check it" 60               # model has 2, type has 5
run scx wanjang:scout '"sonnet"' "Look around" 60            # 2 samples only: no estimate
run pm1 wanjang:pm null "Lead" 120                           # history +8 min, run log says more
run pmw wanjang:builder '"sonnet"' "Task 2" 180
sed -i.bak 's/"spawnDepth":1/"spawnDepth":2,"parentAgentId":"pm1"/' "$E/agent-pmw.meta.json"; rm -f "$E"/*.bak
printf 'Status: in progress\n\n## Tasks\n| task | worker | files | status |\n| one | builder sonnet | a | done |\n| two pmw | builder sonnet | b | running |\n| three | builder sonnet | c | todo |\n' > "$RL/log.md"
ej=$(CLAUDE_CONFIG_DIR=$U bin/status --session s2 --cwd "$U/repo" --json --eta)
et=$(CLAUDE_CONFIG_DIR=$U bin/status --session s2 --cwd "$U/repo" --eta)
json=$ej
want '.agents[] | select(.id=="bnew") | .eta | [.likely - '"$NOW"', .latest - '"$NOW"', .left_min, .basis_n, .basis, .over] | @csv' '210,300,4,6,"wanjang:builder sonnet",false'
want '.agents[] | select(.id=="bold") | .eta | [.likely, .latest, .over] | @csv' ',,true'
want '.agents[] | select(.id=="chk") | .eta | [.basis_n, .basis] | @csv' '5,"wanjang:checker"'
want '.agents[] | select(.id=="scx") | .eta | [.likely, .basis_n, .over] | @csv' ',,false'
want '.agents[] | select(.id=="pm1") | .eta | .tasks_done' 1
want '.agents[] | select(.id=="pm1") | .eta | .basis | endswith("1 of 3 tasks done")' true
# pm: history gives start+10 min (8 left); the table gives the worker 3.5 left plus the todo row 6.5 = 10 left
want '.agents[] | select(.id=="pm1") | .eta | .likely - '"$NOW" 600
want '.eta_all' "$(printf '%s' "$ej" | jq '.agents[] | select(.id=="pm1") | .eta.likely')"   # latest likely among top-level
echo "$et" | grep -q 'all running work should be done by' || { echo "FAIL eta overall line"; fail=1; }
echo "$et" | grep -q 'taking longer than usual (most finish within 8 min)' || { echo "FAIL overdue wording"; fail=1; }
echo "$et" | grep -q 'eta: no estimate' || { echo "FAIL no-estimate wording"; fail=1; }
echo "$et" | grep -q '1 of 3 tasks done' || { echo "FAIL tasks done text"; fail=1; }
echo "$et" | grep -q 'eta: likely [0-9: -]* (~4 min left), latest' || { echo "FAIL likely wording"; fail=1; }
# without --eta nothing changes: no eta keys, no eta text
CLAUDE_CONFIG_DIR=$U bin/status --session s2 --cwd "$U/repo" --json | jq -e 'has("eta_all") or ([.agents[] | has("eta")] | any)' >/dev/null && { echo "FAIL eta leaked into --json"; fail=1; }
CLAUDE_CONFIG_DIR=$U bin/status --session s2 --cwd "$U/repo" | grep -q 'eta' && { echo "FAIL eta leaked into text"; fail=1; }
# two running PMs, each with its own run log (named in its transcript); a worker with no history takes builder sonnet's median; bad clock
R2=$U/repo/.git/wanjang/run2; R3=$U/repo/.git/wanjang/run3; mkdir -p "$R2" "$R3"
printf '## Tasks\n| task | worker | files | status |\n| one | builder sonnet | a | done |\n| two | builder sonnet | b | todo |\n| three | builder sonnet | c | todo |\n| four | builder sonnet | d | todo |\n' > "$R2/log.md"
printf '## Tasks\n| task | worker | files | status |\n| one | builder sonnet | a | done |\n| two | qa opus | b | todo |\n| three | builder sonnet | c | todo |\n' > "$R3/log.md"
echo "{\"type\":\"user\",\"cwd\":\"$U/repo\",\"timestamp\":\"$(isoN 9000)\"}" > "$Q/s3.jsonl"
E3=$Q/s3/subagents; mkdir -p "$E3"
pmrun() { echo '{"agentType":"wanjang:pm","model":null,"description":"Lead","spawnDepth":1}' > "$E3/agent-$1.meta.json"
  { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"text","text":"start"}]}}\n' "$(isoN 120)"
    printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","id":"u%s","name":"%s","input":%s}]}}\n' "$(isoN 5)" "$1" "$2" "$3"; } > "$E3/agent-$1.jsonl"; }
pmrun pmA Write "{\"file_path\":\"$R2/log.md\",\"content\":\"x\"}"
pmrun pmB Bash "{\"command\":\"echo hi >> $R3/log.md\"}"
json=$(CLAUDE_CONFIG_DIR=$U bin/status --session s3 --cwd "$U/repo" --json --eta)
want '.agents[] | select(.id=="pmA") | .eta | [.likely - '"$NOW"', .tasks_done, .tasks_total] | @csv' '1170,1,4'
want '.agents[] | select(.id=="pmB") | .eta | [.likely - '"$NOW"', .tasks_done, .tasks_total] | @csv' '780,1,3'   # qa opus has no history: 6.5 + 6.5
WANJANG_NOW=abc CLAUDE_CONFIG_DIR=$U bin/status --session s3 --cwd "$U/repo" --eta >/dev/null 2>"$T/err"; [ $? = 0 ] && ! grep -q Traceback "$T/err" || { echo "FAIL bad WANJANG_NOW"; fail=1; }
unset WANJANG_NOW
[ $fail = 0 ] && echo "status.sh ok"; exit $fail
