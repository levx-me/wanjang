#!/usr/bin/env bash
# Checks playbooks/: every INDEX entry has its file, every playbook is indexed, sourced and in NOTICE.md.
cd "$(dirname "$0")/.." || exit 2
fail=0
P=playbooks
while IFS= read -r f; do
  [ -f "$P/$f" ] || { echo "FAIL INDEX.md lists $f but the file is missing"; fail=1; }
done < <(grep -oE '^- \[[^]]+\]\([^)]+\.md\)' $P/INDEX.md | sed -E 's/.*\(([^)]+)\)/\1/')
for p in $P/*.md; do
  f=${p##*/}; n=${f%.md}
  [ "$f" = INDEX.md ] || [ "$f" = NOTICE.md ] || {
    grep -q "^- \[$n\]($f)" $P/INDEX.md || { echo "FAIL $f is not in INDEX.md"; fail=1; }
    grep -q '^> Sources:' "$p" || { echo "FAIL $f has no '> Sources:' line"; fail=1; }
    grep -q "$n" $P/NOTICE.md || { echo "FAIL NOTICE.md does not mention $n"; fail=1; }
  }
done
[ $fail = 0 ] && echo "playbooks: all passed"
exit $fail
