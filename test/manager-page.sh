#!/usr/bin/env bash
# bin/manager-page: sections, new chip, escaping, determinism, empty ledger, bad input.
cd "$(dirname "$0")/.." || exit 2
P=bin/manager-page; fail=0
ck() { grep -q -- "$2" <<<"$1" || { echo "FAIL: missing $2"; fail=1; }; }
no() { grep -q -- "$2" <<<"$1" && { echo "FAIL: unexpected $2"; fail=1; }; }
IN='{"now":"2026-11-05T10:00","state":{"owner":"s1","last_tick":"2026-11-05T09:58"},"items":[
{"id":"1","kind":"verify","text":"run <b>tests</b> & more","why":"w","cost":"low","status":"asked","new":true,"project":"p","t":"1"},
{"id":"2","kind":"docs","text":"t2","status":"sent","t":"2"},
{"id":"3","kind":"test","text":"t3","status":"done","t":"3"},
{"id":"4","kind":"commit","text":"t4","status":"failed","note":"n","t":"4"},
{"id":"5","kind":"x","text":"t5","status":"mystery","t":"5"},
{"id":"6","kind":"x","text":"gone","status":"dropped","t":"6"}]}'
out=$($P <<<"$IN"); [ $? = 0 ] || { echo "FAIL: exit"; fail=1; }
for h in "Decisions needed" "Sent, waiting" "Done" "Problems" "Also open"; do ck "$out" "$h</p>"; done
ck "$out" 'tag on">new'; ck "$out" "answer\|Answer in the manager session"
ck "$out" "run &lt;b&gt;tests&lt;/b&gt; &amp; more"; no "$out" "<b>tests</b>"; no "$out" ">gone<"
ck "$out" '<b>Project</b> p</p>'; no "$out" ' · </p>'
[ "$out" = "$($P <<<"$IN")" ] || { echo "FAIL: not deterministic"; fail=1; }
many=$(python3 -c 'import json;print(json.dumps({"now":"n","items":[{"id":str(i),"kind":"k","text":"t%d"%i,"status":"found","t":str(i)} for i in range(6)]}))')
[ "$($P <<<"$many" | grep -o 'class="decide"' | wc -l | tr -d ' ')" = 4 ] || { echo "FAIL: more than 4 decide blocks"; fail=1; }
ck "$($P <<<"$many")" "Also open</p>"
no "$($P <<<"$many")" 'class="decide-meta"'  # no project: no Project line
empty=$($P <<<'{"now":"n","state":{},"items":[]}'); ck "$empty" "Nothing open"; no "$empty" "Decisions needed"
$P <<<'nope' 2>/dev/null && { echo "FAIL: bad input accepted"; fail=1; }
command -v xmllint >/dev/null && xmllint --html --noout - <<<"$out" 2>&1 | grep 'parser error' | grep -v 'invalid' | grep -q . && { echo "FAIL: xmllint"; fail=1; }
[ $fail = 0 ] && echo "manager-page: all passed"
exit $fail
