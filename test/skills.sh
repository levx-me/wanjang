#!/usr/bin/env bash
# Checks skills/: frontmatter name matches the folder, a description exists, ${CLAUDE_PLUGIN_ROOT} paths exist,
# and the visual-doc and brief skills are generic (no own-product names, no Korea-only wording).
cd "$(dirname "$0")/.." || exit 2
fail=0
for s in skills/*/SKILL.md; do
  d=${s%/SKILL.md}; d=${d#skills/}
  fm=$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1' "$s")
  [ "$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')" = "$d" ] || { echo "FAIL $s: frontmatter name is not $d"; fail=1; }
  printf '%s\n' "$fm" | grep -q '^description: *[^ ]' || { echo "FAIL $s: no description"; fail=1; }
  while IFS= read -r p; do
    ls -d "${p/\$\{CLAUDE_PLUGIN_ROOT\}/.}" >/dev/null 2>&1 || { echo "FAIL $s names $p, which does not exist"; fail=1; }
  done < <(grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' "$s" | sed 's/[.]$//' | sort -u)
done
for d in skills/visual-doc skills/brief; do
  [ -d "$d" ] || { echo "FAIL $d is missing"; fail=1; continue; }
  # private names live outside the repo, one regex per line; no file, no check
  names=$(grep -v '^#' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/wanjang/private-names" 2>/dev/null | paste -sd'|' -)
  hit=$([ -n "$names" ] && grep -rniE "$names" "$d" | head -3)
  [ -z "$hit" ] || { echo "FAIL $d names a product or person:"; echo "$hit"; fail=1; }
  hit=$(grep -niE '원화|한국어 페이지' "$d/SKILL.md" | head -3)
  [ -z "$hit" ] || { echo "FAIL $d/SKILL.md has Korea-only wording:"; echo "$hit"; fail=1; }
done
[ $fail = 0 ] && echo "skills: all passed"
exit $fail
