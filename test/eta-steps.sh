#!/usr/bin/env bash
# bin/status --eta from an agent's own steps (TaskCreate "[tag] ..." + TaskUpdate), the phase fallback, the history
# fallback, the hold until step counts change, and the steps table of wanjang.db. Fixed clock, made-up transcripts.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
NOW=$(date +%s); export WANJANG_NOW=$NOW CLAUDE_CONFIG_DIR=$T
P=$T/projects/-z; mkdir -p "$P/s/subagents" "$P/h/subagents"
echo "{\"type\":\"user\",\"cwd\":\"/nonexistent\",\"timestamp\":\"2026-01-01T00:00:00Z\"}" > "$P/s.jsonl"
fail=0; DB=$T/wanjang/wanjang.db
want() { got=$(printf '%s' "$json" | jq -r "$1"); [ "$got" = "$2" ] || { echo "FAIL $1: want $2 got $got"; fail=1; }; }
# fx DIR ID TYPE MODEL FINISHED SPEC: SPEC = lines "t_ago kind arg" kind: text, tool (Bash cmd), tool:Name, create N tag, start N, done N (N = task number)
fx() { python3 - "$@" <<'PY'
import json, sys, datetime
d, aid, typ, model, fin, spec = sys.argv[1:7]; now = int(sys.argv[7])
iso = lambda a: datetime.datetime.fromtimestamp(now - int(a), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
json.dump(dict(agentType=typ, model=model, spawnDepth=1, **({"finished": True} if fin == "1" else {})), open(f"{d}/agent-{aid}.meta.json", "w"))
out, n = [], 0
def line(a, role, blocks): out.append(json.dumps(dict(type=role, timestamp=iso(a), message=dict(content=blocks))))
for l in spec.strip().splitlines():
    a, kind, *arg = l.split(None, 2)
    if kind == "text": line(a, "assistant", [dict(type="text", text="x")])
    elif kind == "tool": line(a, "assistant", [dict(type="tool_use", id=f"t{len(out)}", name="Bash", input=dict(command=arg[0]))])
    elif kind.startswith("tool:"): line(a, "assistant", [dict(type="tool_use", id=f"t{len(out)}", name=kind[5:], input=dict(file_path="f"))])
    elif kind == "create":
        num, tag = arg[0].split()
        line(a, "assistant", [dict(type="tool_use", id=f"c{num}", name="TaskCreate", input=dict(subject=f"{tag} step {num}"))])
        line(a, "user", [dict(type="tool_result", tool_use_id=f"c{num}", content=f"Task #{num} created successfully: {tag} step {num}")])
    else:
        line(a, "assistant", [dict(type="tool_use", id=f"u{len(out)}", name="TaskUpdate", input=dict(taskId=arg[0], status="in_progress" if kind == "start" else "completed"))])
open(f"{d}/agent-{aid}.jsonl", "w").write("\n".join(out) + "\n")
PY
}
# history: six finished builders (sonnet), each [read] 2 min, [edit] 4 min, [test] 2 min; 8 min in all
for i in 1 2 3 4 5 6; do
  fx "$P/h/subagents" "hist$i" wanjang:builder sonnet 1 "
$((20000+i+480)) text
$((20000+i+480)) create 1 [read]
$((20000+i+480)) create 2 [edit]
$((20000+i+480)) create 3 [test]
$((20000+i+480)) start 1
$((20000+i+360)) done 1
$((20000+i+360)) start 2
$((20000+i+120)) done 2
$((20000+i+120)) start 3
$((20000+i)) done 3" "$NOW"
done
run() { fx "$P/s/subagents" "$@" "$NOW"; }
# A: [read] finished in 4 min (twice the median), [edit] running 1 min, [test] to come: scale 2 -> 8-1 + 4 = 11 min
run A wanjang:builder sonnet 0 "
300 text
300 create 1 [read]
300 create 2 [edit]
300 create 3 [test]
300 start 1
60 done 1
60 start 2
5 tool ls"
# B: [read] running 30 s, nothing finished: scale 1 -> 2-0.5 + 4 + 2 = 7.5 min
run B wanjang:builder sonnet 0 "
30 text
30 create 1 [read]
30 create 2 [edit]
30 create 3 [test]
30 start 1
5 tool ls"
# C: no steps, reads then edits then a test command, 6 min in: phase late (0.85) blended with the 8 min history median
run C wanjang:builder sonnet 0 "
360 text
300 tool:Read
240 tool:Edit
200 tool:Edit
5 tool bun test"
# D: no steps, one tool call: history alone (8 min from its start)
run D wanjang:builder sonnet 0 "
120 text
5 tool ls"
# E: a step whose tag has no history ([docs]) : the history estimate
run E wanjang:builder sonnet 0 "
120 text
120 create 1 [docs]
120 start 1
5 tool ls"
est() { CLAUDE_CONFIG_DIR=$T WANJANG_NOW=${1:-$NOW} bin/status --session s --cwd /nonexistent --json --eta; }
json=$(est)
want '.agents[] | select(.id=="A") | .eta | [.likely - '"$NOW"', .method, .steps_done, .steps_total, .basis] | @csv' '660,"progress",1,3,"progress: 1 of 3 steps done"'
want '.agents[] | select(.id=="B") | .eta | [.likely - '"$NOW"', .method, .steps_done, .steps_total] | @csv' '450,"progress",0,3'
want '.agents[] | select(.id=="A") | .eta | .latest >= .likely and .over == false' true
# C: started 360 s ago: (360 / 0.85 + 480) / 2 = 451.8 s after its start, i.e. 91.8 s from now
want '.agents[] | select(.id=="C") | .eta | [((.likely - '"$NOW"') | floor), .method, (.basis | startswith("phase: late"))] | @csv' '91,"phase",true'
want '.agents[] | select(.id=="D") | .eta | [.likely - '"$NOW"', .method, .basis] | @csv' '360,"history","wanjang:builder sonnet"'
want '.agents[] | select(.id=="E") | .eta | [.method, .steps_done] | @csv' '"history",'
# the text line names the method
CLAUDE_CONFIG_DIR=$T bin/status --session s --cwd /nonexistent --eta | grep -q 'from progress: 1 of 3 steps done' || { echo "FAIL progress wording"; fail=1; }
# --- hold: same likely while the counts stay; B's [read] done at +60 s changes them and re-estimates (scale 90 / 120 s)
L1=$(printf '%s' "$json" | jq '.agents[] | select(.id=="B") | .eta.likely'); L2=$(est $((NOW + 60)) | jq '.agents[] | select(.id=="B") | .eta.likely')
[ "$L1" = "$L2" ] || { echo "FAIL held likely moved ($L1 | $L2)"; fail=1; }
python3 - "$P/s/subagents/agent-B.jsonl" "$NOW" <<'PY'
import sys, json, datetime
t = datetime.datetime.fromtimestamp(int(sys.argv[2]) + 60 - 0, datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
# the [read] began 30 s before NOW, so it ends 90 s after its start at NOW + 60
u = lambda tid, st: json.dumps(dict(type="assistant", timestamp=t, message=dict(content=[dict(type="tool_use", id=tid, name="TaskUpdate", input=dict(taskId=st[0], status=st[1]))])))
open(sys.argv[1], "a").write(u("u1", ("1", "completed")) + "\n" + u("u2", ("2", "in_progress")) + "\n" + json.dumps(dict(type="assistant", timestamp=t, message=dict(content=[dict(type="tool_use", id="z", name="Bash", input=dict(command="ls"))]))) + "\n")
PY
L3=$(est $((NOW + 60)) | jq '.agents[] | select(.id=="B") | .eta | "\(.likely - '"$NOW"' - 60) \(.steps_done)"')
[ "$L3" = '"270 1"' ] || { echo "FAIL steps change did not re-estimate ($L3)"; fail=1; }   # 0.75 x (4 + 2) min = 270 s
# --- steps table: path + mtime tracked, index on (agent_type, model, tag), WAL, each finished step once
[ "$(sqlite3 "$DB" 'PRAGMA journal_mode')" = wal ] || { echo "FAIL not WAL"; fail=1; }
sqlite3 "$DB" "SELECT sql FROM sqlite_master WHERE type='index'" | grep -q 'steps(agent_type, model, tag)' || { echo "FAIL no group index"; fail=1; }
[ "$(sqlite3 "$DB" "SELECT count(*) FROM steps WHERE path LIKE '%hist1.jsonl'")" = 3 ] || { echo "FAIL steps of hist1"; fail=1; }
[ "$(sqlite3 "$DB" "SELECT count(*) FROM transcripts WHERE path LIKE '%hist1.jsonl'")" = 1 ] || { echo "FAIL transcript not tracked"; fail=1; }
[ "$(sqlite3 "$DB" "SELECT CAST(round(minutes) AS INT) FROM steps WHERE path LIKE '%hist1.jsonl' AND tag='edit'")" = 4 ] || { echo "FAIL edit minutes"; fail=1; }
N1=$(sqlite3 "$DB" 'SELECT count(*) FROM steps'); est >/dev/null; est $((NOW + 60)) >/dev/null
[ "$N1" = "$(sqlite3 "$DB" 'SELECT count(*) FROM steps')" ] || { echo "FAIL steps inserted twice"; fail=1; }
# an unchanged transcript is not rescanned: a marker row for it survives a call, a changed one is rescanned and gains only the new step
sqlite3 "$DB" "UPDATE steps SET minutes = 99 WHERE path LIKE '%hist1.jsonl' AND tag='read'"
est >/dev/null; [ "$(sqlite3 "$DB" "SELECT minutes FROM steps WHERE path LIKE '%hist1.jsonl' AND tag='read'")" = 99.0 ] || { echo "FAIL unchanged transcript rescanned"; fail=1; }
# --- migration: old eta-held.json / eta-cache.json are imported once and renamed, never deleted
M=$(mktemp -d); trap 'rm -rf "${T:?}" "${M:?}"' EXIT; mkdir -p "$M/wanjang" "$M/projects/-z"; cp "$P/s.jsonl" "$M/projects/-z/s.jsonl"
echo '{"gone":{"likely":9,"key":null,"seen":1,"e":{}}}' > "$M/wanjang/eta-held.json"; echo '{"hist":[["wanjang:scout","sonnet",[1,2]]]}' > "$M/wanjang/eta-cache.json"
CLAUDE_CONFIG_DIR=$M bin/status --session s --cwd /nonexistent --eta >/dev/null 2>&1
[ -f "$M/wanjang/eta-held.json.migrated" ] && [ -f "$M/wanjang/eta-cache.json.migrated" ] && [ ! -e "$M/wanjang/eta-held.json" ] || { echo "FAIL old files not renamed"; fail=1; }
[ "$(sqlite3 "$M/wanjang/wanjang.db" "SELECT count(*) FROM eta_cache WHERE agent_type='wanjang:scout'")" = 2 ] || { echo "FAIL cache not imported"; fail=1; }
[ $fail = 0 ] && echo "eta-steps.sh ok"; exit $fail
