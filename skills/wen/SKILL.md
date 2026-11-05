---
name: wen
description: Say roughly when the running work will be done, estimated from how long past agents took. /wanjang:wen [--session id]
argument-hint: "[--session <id|path>]"
---
Answer "when will it be done?" from a compact estimate, not from transcripts.

1. Run `status --bars $ARGUMENTS` with the Bash tool (a plugin `bin/`, so on PATH). If `status` is not found, run `${CLAUDE_PLUGIN_ROOT}/bin/status --bars $ARGUMENTS`. It prints English labels: `Overall HH:MM · about N min left`, then one bar per running piece of work (elapsed against the likely total, `N min  HH:MM` = minutes left and likely finish; `longer than usual`, `may be stuck`, `no estimate`), nested workers indented, and `└ k/n tasks done` under a Wanjang PM.
2. Show that output unchanged in a code block, with the labels translated into the user's language (keep the bars, numbers and times). Under it, one line: the overall finish time and that it is an estimate from past runs, not a promise. Use `status --eta $ARGUMENTS` only if the user asks for the basis ("from 369 past builders") or the latest time.
3. An agent marked `longer than usual` or `may be stuck`: say so in that line and point to `/wanjang:now`.
4. Nothing running: one line saying so, no code block.
5. Do not read transcripts beyond the script's output.
