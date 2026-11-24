---
name: humanize
description: Rewrite text that sounds machine-made (English or Korean: notice, README, blog, product copy, report) so it reads like a person wrote it, keeping every claim and detail. /wanjang:humanize <text or file>
---
Fix the voice of a text without changing what it says. The rules live in one place, the playbook; read it first and follow it.

1. Read `${CLAUDE_PLUGIN_ROOT}/playbooks/humanize.md` (Rules, Steps, Patterns for the text's language).
2. Take the text from the arguments, the conversation, or a file path the user gives. Without any of these, ask for the text.
3. Rewrite following the playbook's Steps. Keep every claim; do not invent; keep the register; flag unsourced praise instead of dropping it.
4. Reply with the rewrite, then 2-4 lines on the main changes, then the playbook's "Return" items that apply (needs a source, thin spots, not checked). If the user gave a file, write the result next to it only when asked.
5. For a long document or copy that ships, hand the rewrite to a builder and the claim check to a fresh checker, as the playbook says.
