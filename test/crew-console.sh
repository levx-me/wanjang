#!/usr/bin/env bash
# crew-run, crew-console and crew-console-hook with a stub `claude` on PATH; no network, no real key.
cd "$(dirname "$0")/.." || exit 2
ROOT=$PWD
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
bad() { echo "FAIL $1"; fail=1; }
unset WANJANG_CREW_CONSOLE  # (run from inside a crew-run child, the hook would pass everything)
export CLAUDE_CONFIG_DIR=$T/cfg USER=wanjang-test-nobody HOME=$T/home XDG_CONFIG_HOME= ANTHROPIC_CONSOLE_API_KEY=sk-ant-testsecret
mkdir -p "$T/home" "$T/shim" "$T/projA" "$T/projB"; A=$T/projA; B=$T/projB
printf '#!/bin/sh\n[ "$1" = find-generic-password ] && exit 44\nexit 1\n' > "$T/shim/security"
printf '#!/bin/sh\nexit 1\n' > "$T/shim/secret-tool"
# stub claude: records argv and env marker; STUB_OUT is the JSON it prints
cat > "$T/shim/claude" <<SH
#!/bin/sh
printf '%s\n' "\$*" > "$T/argv"; printf '%s' "\${WANJANG_CREW_CONSOLE:-}" > "$T/marker"
cat > /dev/null
printf '%s' "\${STUB_OUT:-}"
exit "\${STUB_RC:-0}"
SH
chmod +x "$T/shim/"*
export PATH="$T/shim:$PATH"
OK='[{"type":"system"},{"type":"result","subtype":"success","is_error":false,"result":"hello","total_cost_usd":0.0123,"duration_ms":2000,"session_id":"abc"}]'

# crew-run: ok path, marker, flags, key never in argv or log
out=$(echo brief | STUB_OUT=$OK bin/crew-run scout --model haiku --effort low 2>&1); rc=$?
[ $rc = 0 ] || bad "ok: exit $rc"
case $out in *hello*"crew-console: scout haiku \$0.0123 2s session abc"*) ;; *) bad "ok: output: $out" ;; esac
[ "$(cat "$T/marker")" = 1 ] || bad "marker not set"
grep -q -- '--agent wanjang:scout' "$T/argv" && grep -q -- '--model haiku' "$T/argv" && grep -q -- '--effort low' "$T/argv" || bad "flags missing: $(cat "$T/argv")"
grep -q -- '--max-budget-usd 10 ' "$T/argv" || bad "default budget not 10"
grep -q 'apiKeyHelper' "$T/argv" && grep -q 'ANTHROPIC_API_KEY' "$T/argv" || bad "settings shape"
grep -rq testsecret "$T/argv" "$T/cfg" && bad "key leaked into argv or logs"
[ "$(ls "$T"/cfg/wanjang/crew-console/*.json 2>/dev/null | wc -l)" -eq 1 ] || bad "log not kept"
# budget: flag, then the switch's value
echo b | STUB_OUT=$OK bin/crew-run scout --budget 2.5 >/dev/null 2>&1; grep -q -- '--max-budget-usd 2.5 ' "$T/argv" || bad "budget flag"
(cd "$T/projA" && "$ROOT/bin/crew-console" on --budget 4 >/dev/null) || bad "on: exit $?"
echo b | STUB_OUT=$OK bin/crew-run scout --cwd "$T/projA" >/dev/null 2>&1; grep -q -- '--max-budget-usd 4 ' "$T/argv" || bad "switch budget"
# exit codes
echo b | bin/crew-run nosuch >/dev/null 2>&1; [ $? = 2 ] || bad "unknown agent should exit 2"
echo b | bin/crew-run scout --effort wild >/dev/null 2>&1; [ $? = 2 ] || bad "bad effort should exit 2"
echo b | bin/crew-run scout --budget 0 >/dev/null 2>&1; [ $? = 2 ] || bad "zero budget should exit 2"
echo b | STUB_OUT='{"type":"result","subtype":"error_max_budget_usd","is_error":true,"result":"","total_cost_usd":1}' bin/crew-run scout >/dev/null 2>&1; [ $? = 4 ] || bad "budget hit should exit 4"
echo b | STUB_OUT='{"type":"result","subtype":"success","is_error":true,"result":"Credit balance is too low"}' bin/crew-run scout >/dev/null 2>&1; [ $? = 5 ] || bad "credit error should exit 5"
echo b | STUB_OUT='{"type":"result","subtype":"error_during_execution","is_error":true,"result":"boom"}' bin/crew-run scout >/dev/null 2>&1; [ $? = 6 ] || bad "agent error should exit 6"
echo b | ANTHROPIC_CONSOLE_API_KEY= bin/crew-run scout >/dev/null 2>&1; [ $? = 3 ] || bad "no key should exit 3"
bin/crew-run scout --dry-run | grep -q testsecret && bad "dry-run shows the key"

# switch: on refuses without a key; off; status
ANTHROPIC_CONSOLE_API_KEY= bin/crew-console on >/dev/null 2>&1; [ $? = 3 ] || bad "on without key should exit 3"
cd "$T/projA"; "$ROOT/bin/crew-console" status | grep -q '^crew-console: on for .*, budget \$4' || bad "status on keeps budget"
"$ROOT/bin/crew-console" off >/dev/null; "$ROOT/bin/crew-console" status | grep -q '^crew-console: off' || bad "status off"
"$ROOT/bin/crew-console" on >/dev/null; cd "$ROOT"

# hook matrix
h() { printf '%s' "$1" | bin/crew-console-hook; }

MAIN='{"cwd":"'$A'","tool_name":"Agent","tool_input":{"subagent_type":"wanjang:builder","model":"sonnet","effort":"high"}}'
SUB='{"agent_id":"a1","agent_type":"wanjang:pm","tool_name":"Agent","tool_input":{"subagent_type":"wanjang:builder"}}'
OTHER='{"tool_name":"Agent","tool_input":{"subagent_type":"Explore"}}'
d=$(h "$MAIN" | jq -r .hookSpecificOutput.permissionDecision+.hookSpecificOutput.permissionDecisionReason); case $d in deny*"crew-run\" builder --model sonnet --effort high"*) ;; *) bad "main+wanjang should deny: $d" ;; esac
[ -z "$(h "${MAIN/$A/$B}")" ] || bad "project B should pass while A is on"
[ -z "$(h "$SUB")" ] || bad "subagent call should pass"
[ -z "$(h "$OTHER")" ] || bad "non-wanjang type should pass"
[ "$(WANJANG_CREW_CONSOLE=1 bin/crew-console-hook <<<"$MAIN" | jq -r .hookSpecificOutput.updatedInput.run_in_background)" = false ] || bad "crew-run child: an Agent call with run_in_background omitted runs in the foreground"
[ -z "$(WANJANG_CREW_CONSOLE=1 bin/crew-console-hook <<<"$(jq -c '.tool_input.run_in_background=false' <<<"$MAIN")")" ] || bad "crew-run child: explicit foreground passes untouched"
(cd "$A" && "$ROOT/bin/crew-console" off >/dev/null)
[ -z "$(h "$MAIN")" ] || bad "switch off should pass"
exit $fail
