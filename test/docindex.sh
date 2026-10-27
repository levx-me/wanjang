#!/usr/bin/env bash
# Runnable check for docindex: temp HOME (so temp DB) and temp docs dir.
set -u
D=$(cd "$(dirname "$0")/.." && pwd)/bin/docindex
T=$(cd "$(mktemp -d)" && pwd -P); export HOME=$T/home; mkdir -p "$HOME" "$T/docs"
trap 'rm -rf "$T"' EXIT
fail=0
ok() { if (eval "$2"); then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
S() { python3 "$D" search "$@"; }

cat > "$T/docs/a.md" <<'EOF'
# Alpha
intro line

## Pricing
The oracle updates prices every block.

```
# not a heading
## still code

more code
```

## Fees
수수료 정산은 매일 이루어진다.
EOF
printf 'first paragraph about gardening\n\nsecond paragraph about welding\n' > "$T/docs/b.txt"

printf '<html><head><style>\n.x{color:red}\n</style></head>\n<body>\n<h1>Guide</h1>\n<p>intro</p>\n<script>var hidden="jsmarker";</script>\n<h2 class="a">Setup &amp; Run</h2>\n<p>install the <b>zebrafish</b> tool</p>\n</body></html>\n' > "$T/docs/c.html"
ok "html: tags/script stripped, original line range" '[ "$(S zebrafish "$T/docs" 2>/dev/null | head -1)" = "$T/docs/c.html:8-9  Guide > Setup & Run" ] && ! S jsmarker "$T/docs" >/dev/null 2>&1'
ok "heading chunk line range" '[ "$(S oracle "$T/docs" 2>/dev/null | head -1)" = "$T/docs/a.md:4-12  Alpha > Pricing" ]'
ok "code fence not split" 'python3 "$D" outline "$T/docs/a.md" | grep -q "^ *4-1[0-9]" && ! python3 "$D" outline "$T/docs/a.md" | grep -q "not a heading"'
ok "outline has 3 headed chunks" '[ "$(python3 "$D" outline "$T/docs/a.md" --json | python3 -c "import json,sys;print(len(json.load(sys.stdin)))")" = 3 ]'
ok "english stemming (price -> prices)" 'S price "$T/docs" | grep -q "Pricing"'
ok "korean partial word (정산 in 정산은)" 'S 정산 "$T/docs" | grep -q "Fees"'
ok "korean 2-char word" 'S 수수 "$T/docs" | grep -q "Fees"'
ok "no results exits 1" 'S zzzqqq "$T/docs" >/dev/null 2>&1; [ $? = 1 ]'
ok "special chars do not crash" 'for q in "\"" "a AND" "foo*(" "NEAR(" "x-y" "c++ \"unterminated" ":"; do S "$q" "$T/docs" >/dev/null 2>&1; r=$?; [ $r = 0 -o $r = 1 ] || exit 1; done'
ok "txt paragraphs searchable" 'S welding "$T/docs" | grep -q "b.txt"'
sleep 1; echo "## Extra
unicornmarker here" >> "$T/docs/a.md"
ok "re-index after edit" 'S unicornmarker "$T/docs" | grep -q "a.md"'
rm "$T/docs/b.txt"
ok "deleted file dropped" '! S welding "$T/docs" >/dev/null 2>&1 && python3 "$D" stats --json | grep -q "\"files\": 2"'
ok "bad args exit 2" 'python3 "$D" search >/dev/null 2>&1; [ $? = 2 ]'
ok "purge" 'python3 "$D" purge >/dev/null && python3 "$D" stats --json | grep -q "\"chunks\": 0"'
[ $fail = 0 ] && echo "all passed" || { echo "FAILED"; exit 1; }
