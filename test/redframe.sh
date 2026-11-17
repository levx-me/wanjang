#!/usr/bin/env bash
# redframe: `off` with no binary exits 0; `on` without swiftc exits 0 with a notice; bad usage exits 2.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT; fail=0
CLAUDE_CONFIG_DIR="$T" bin/redframe off || { echo "FAIL off"; fail=1; }
e=$(CLAUDE_CONFIG_DIR="$T" PATH=/usr/bin:/bin:$T/none bin/redframe on 2>&1 >/dev/null); rc=$?
if command -v swiftc >/dev/null 2>&1 && [ "$(uname)" = Darwin ]; then
  # swiftc lives outside the pruned PATH only if it is not in /usr/bin; skip the check when it is.
  [ "$(command -v swiftc)" = /usr/bin/swiftc ] || { [ $rc = 0 ] && grep -q redframe <<<"$e" || { echo "FAIL on w/o swiftc ($rc)"; fail=1; }; }
else
  [ $rc = 0 ] && grep -q redframe <<<"$e" || { echo "FAIL on unsupported ($rc)"; fail=1; }
fi
bin/redframe bogus 2>/dev/null; [ $? = 2 ] || { echo "FAIL usage"; fail=1; }
# lease cap: default 60, N>60 capped to 60 with a notice, small N kept
[ "$(bin/redframe secs 2>&1)" = 60 ] || { echo "FAIL default"; fail=1; }
[ "$(bin/redframe secs 30 2>&1)" = 30 ] || { echo "FAIL 30"; fail=1; }
o=$(bin/redframe secs 600 2>/dev/null); e=$(bin/redframe secs 600 2>&1 >/dev/null)
{ [ "$o" = 60 ] && grep -q capped <<<"$e"; } || { echo "FAIL cap"; fail=1; }
[ "$(bin/redframe secs abc 2>&1)" = 60 ] || { echo "FAIL nonnumeric"; fail=1; }
[ $fail = 0 ] && echo "redframe: all passed"
exit $fail
