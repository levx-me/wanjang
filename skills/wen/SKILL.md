---
name: wen
description: Say roughly when the running work will be done, estimated from how long past agents took. /wanjang:wen [--session id]
argument-hint: "[--session <id|path>]"
---
Answer "when will it be done?" from a compact estimate, not from transcripts.

1. Run `status --eta $ARGUMENTS` with the Bash tool (a plugin `bin/`, so on PATH). If `status` is not found, run `${CLAUDE_PLUGIN_ROOT}/bin/status --eta $ARGUMENTS`.
2. Reply briefly in the user's language: for each running piece of work its likely finish time and its latest time, with minutes left and the basis in a few words ("from 369 past builders"); a Wanjang PM with a task table adds "k of n tasks done". Nested workers go under their parent. End with the time all of it should be done.
3. Always say it is an estimate from past runs, not a promise.
4. An agent past its usual time ("taking longer than usual") or marked `MAY BE STUCK`: say so, give no time, and point to `/wanjang:now`.
5. Nothing running: one line saying so.
6. Do not read transcripts beyond the script's output.
