#!/usr/bin/env bash
# Runs bin/ledger on made-up SubagentStop events and run logs; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
L=$PWD/bin/ledger
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
export CLAUDE_CONFIG_DIR=$T/cfg HOME=$T/home; mkdir -p "$HOME"
R=$T/proj; git -C "$T" init -q proj; mkdir -p "$R/.git/wanjang/run1"
LEDGER=$CLAUDE_CONFIG_DIR/wanjang/ledger.md
fail=0
ok() { [ "$2" = "$3" ] || { echo "FAIL $1: want [$2] got [$3]"; fail=1; }; }
hook() { jq -n --arg t "${1:-wanjang:pm}" --arg c "${2:-$R}" '{agent_type: $t, cwd: $c}' | "$L" hook; }
log() { printf 'Status: %s\n\n## Goal\nlists overflow\nwithout a hint\n\n## Decisions\n%s\n' "$1" "${2-Shipped: Scrollbar on every list | where: a1..b2, PR #41}" > "$R/.git/wanjang/run1/log.md"; }
count() { [ -f "$LEDGER" ] && grep -c '^- ' "$LEDGER" || echo 0; }

# S6: no ledger yet
ok S6 "nothing shipped" "$("$L" show)"; "$L" show >/dev/null; ok S6-exit 0 $?
# S3: nothing for these
log "in progress"; hook; log stopped; hook; log done ""; hook; log done; hook wanjang:builder
touch -t 202601010000 "$R/.git/wanjang/run1/log.md"; hook
ok S3 0 "$(count)"
# S1
touch "$R/.git/wanjang/run1/log.md"; out=$(hook); ok S1-silent "" "$out"
ok S1 "$(date +%F) · proj · Scrollbar on every list · why: lists overflow · a1..b2, PR #41 · .git/wanjang/run1" "$("$L" show)"
# S2
hook; hook; ok S2 1 "$(count)"
# S4
printf -- '- 2020-01-01 · other · Old thing · why: g · none · .git/wanjang/x\n' >> "$LEDGER"
ok S4-all 2 "$("$L" show | wc -l | tr -d ' ')"
ok S4-since 1 "$("$L" show --since 7d | wc -l | tr -d ' ')"
ok S4-week 1 "$("$L" show --week | wc -l | tr -d ' ')"
ok S4-date 2 "$("$L" show --since 2019-12-31 | wc -l | tr -d ' ')"
ok S4-repo "other" "$("$L" show --repo other | awk -F' · ' '{print $2}')"
ok S4-here proj "$(cd "$R" && "$L" show --here | awk -F' · ' '{print $2}')"
ok S4-json '["date","repo","run","shipped","where","why"]' "$("$L" show --repo other --json | jq -c '.[0] | keys')"
ok S4-json-run ".git/wanjang/x" "$("$L" show --repo other --json | jq -r '.[0].run')"
# S5: a run outside git
mkdir -p "$CLAUDE_CONFIG_DIR/wanjang/runs/r9"; N=$T/nogit; mkdir "$N"
printf 'Status: done\n## Goal\nresearch it\nShipped: A report | where: /x/report.md\n' > "$CLAUDE_CONFIG_DIR/wanjang/runs/r9/log.md"
hook wanjang:pm "$N"; hook wanjang:pm "$N"
ok S5 1 "$("$L" show --repo - | wc -l | tr -d ' ')"
ok S5-where "/x/report.md" "$("$L" show --repo - --json | jq -r '.[0].where')"
# fix round: " · " in text, same slug in two repos, bulleted lines, ~/.claude runs under another config dir, missing values
mkdir -p "$R/.git/wanjang/run2"; printf 'Status: done\n- Shipped: A · B | where: x · y\n' > "$R/.git/wanjang/run2/log.md"
hook; ok F1 "A - B" "$("$L" show --repo proj --json | jq -r '.[] | select(.run | endswith("run2")) | .shipped')"
ok F1-where "x - y" "$("$L" show --repo proj --json | jq -r '.[] | select(.run | endswith("run2")) | .where')"
git -C "$T" init -q proj2; mkdir -p "$T/proj2/.git/wanjang/run1"; cp "$R/.git/wanjang/run1/log.md" "$T/proj2/.git/wanjang/run1/"
hook wanjang:pm "$T/proj2"; ok F2 1 "$("$L" show --repo proj2 | wc -l | tr -d ' ')"
ok F3-goal "lists overflow" "$("$L" show --repo proj2 --json | jq -r '.[0].why')"
mkdir -p "$HOME/.claude/wanjang/runs/h1"; printf 'Status: done\n- Shipped: H | where: none\n' > "$HOME/.claude/wanjang/runs/h1/log.md"
hook wanjang:pm "$N"; ok F4 1 "$("$L" show --json | jq '[.[] | select(.shipped == "H")] | length')"
"$L" show --repo 2>/dev/null; ok F5-repo 2 $?; "$L" show --since 2>/dev/null; ok F5-since 2 $?
[ $fail = 0 ] && echo "ledger: all cases pass"
exit $fail
