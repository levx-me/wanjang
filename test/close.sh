#!/usr/bin/env bash
# Runs bin/close on made-up SubagentStop events; fails on any wrong verdict.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
git -C "$T" init -q && mkdir -p "$T/.git/wanjang/run1"
fail=0
check() {  # want(block|pass) agent_type stop_hook_active
  out=$(jq -n --arg t "$2" --argjson a "$3" --arg c "$T" '{agent_type: $t, stop_hook_active: $a, cwd: $c}' | bin/close)
  got=pass; [ -n "$out" ] && got=block
  [ "$got" = "$1" ] || { echo "FAIL want $1 got $got: $2 active=$3 ($(head -1 "$T/.git/wanjang/run1/log.md"))"; fail=1; }
}
printf 'Status: in progress\n' > "$T/.git/wanjang/run1/log.md"
check block wanjang:pm false   # still open: sent back once
check pass  wanjang:pm true    # the second stop goes through
check pass  wanjang:builder false   # not the PM
check block wanjang:wanjang false   # old name: still the PM
printf 'Status: done\n' > "$T/.git/wanjang/run1/log.md"
check pass  wanjang:pm false   # closed
printf 'Status: in progress\n' > "$T/.git/wanjang/run1/log.md"; touch -t 202601010000 "$T/.git/wanjang/run1/log.md"
check pass  wanjang:pm false   # an old log is not this run's
[ $fail = 0 ] && echo "close: all cases pass"
exit $fail
