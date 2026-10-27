---
name: status
description: Say what the running agents are doing now, for how long, what is done and what looks stuck. /wanjang:status [--session id]
argument-hint: "[--session <id|path>]"
---
Answer "how is it going?" from a compact snapshot, not from transcripts.

1. Run `status $ARGUMENTS` with the Bash tool (a plugin `bin/`, so on PATH). If `status` is not found, run `${CLAUDE_PLUGIN_ROOT}/bin/status`.
2. Reply briefly in the user's language: for each running agent what it is doing now and for how long (a command it waits on counts as working), what has finished, the Wanjang run's current step, and open tasks. Nested workers go under their parent.
3. Anything marked `MAY BE STUCK`: say so and what to do: SendMessage to that agent asking for status, or stop it and re-brief. A long command ("running `forge test` for 4 min") is not stuck; say to wait.
4. Do not read transcripts beyond the script's output, unless something looks stuck and the output does not explain it.
