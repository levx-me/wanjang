#!/usr/bin/env bash
# Feeds made-up hook input to bin/read-warn; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
fail=0
seq 300 > "$T/big"; seq 20 > "$T/small"; printf 'x' > "$T/img.png"
out() { printf '%s' "$1" | bin/read-warn; }
warns() { o=$(out "$1"); case $o in *additionalContext*"is 300 lines"*) ;; *) echo "FAIL should warn: $2"; fail=1 ;; esac
  case $o in *permissionDecision*) echo "FAIL permissionDecision: $2"; fail=1 ;; esac; }
quiet() { [ -z "$(out "$1")" ] || { echo "FAIL should be silent: $2"; fail=1; }; }
r() { jq -nc --arg f "$1" --arg a "$2" --argjson x "$3" '{tool_name:"Read",cwd:"/",tool_input:({file_path:$f}+$x)}+(if $a=="" then {} else {agent_id:$a} end)'; }
b() { jq -nc --arg c "$1" --arg d "$T" '{tool_name:"Bash",cwd:$d,tool_input:{command:$c}}'; }
warns "$(r "$T/big" "" '{}')" "main Read big"
quiet "$(r "$T/big" "" '{"limit":50}')" "Read limit"
quiet "$(r "$T/big" "" '{"offset":10}')" "Read offset"
warns "$(r "$T/big" "agent-1" '{}')" "subagent Read"
quiet "$(r "$T/small" "" '{}')" "Read small"
quiet "$(r "$T/img.png" "" '{}')" "Read image"
quiet "$(r "$T/nope" "" '{}')" "Read missing"
warns "$(b "cat $T/big")" "cat big"
warns "$(b "cat big")" "cat relative"
warns "$(b "head -n 250 big")" "head -n 250"
warns "$(b "tail -300 big")" "tail -300"
warns "$(b "sed -n '1,280p' big")" "sed range"
quiet "$(b "cat $T/small")" "cat small"
quiet "$(b "cat <<EOF
x
EOF")" "heredoc"
quiet "$(b "cat > $T/f")" "cat >"
quiet "$(b "cat <<'EOF' > $T/f")" "cat <<'EOF' >"
quiet "$(b "grep x big | cat")" "pipe to cat"
quiet "$(b "cat big | head")" "cat big |"
quiet "$(b "head -n 50 big")" "head 50"
quiet "$(b "sed -n '1,100p' big")" "sed short"
sub=$(jq -c '. + {agent_id:"a1",agent_type:"wanjang:builder"}' <<<"$(b "cat $T/big")")
warns "$sub" "subagent cat"
warns "$(b "less big")" "less big"
warns "$(b "more $T/big")" "more big"
warns "$(b "sed -n '1,9999p' big")" "sed huge"
quiet "$(jq -c '. + {agent_id:"a1"}' <<<"$(b "head -n 50 big")")" "subagent head 50"
quiet "$(b "less small")" "less small"
[ $fail = 0 ] && echo "read-warn: all passed"
exit $fail
