---
name: optimize
description: Check where this session's tokens go (the main context, running agents, background commands, Wanjang runs) and offer the fixes that apply, without stopping agents at work. Only when the user types /wanjang:optimize.
disable-model-invocation: true
---
Make this session cheaper without losing work. Agents and commands keep running throughout; never stop anything without the user's yes.

1. Run the report (it reads transcripts on disk; it does not load them into this context):
   `"<this skill's base directory>/../../bin/usage"` with the Bash tool. Read its output; do not open the transcripts yourself.
2. From the report, pick only the fixes that apply, then ask once with AskUserQuestion (multiSelect), each option saying what it saves and what it costs. Recommend the first.
   - **Checkpoint, then compact** — the main context is past about 50%, or a few tool results take a large share. Write a checkpoint file (in the scratchpad, or the Wanjang run folder when one is in progress): the user's open requests in their words, decisions and why, paths of files and run folders in play, what is waiting on the user, what comes next. Then give the user one ready line to type, e.g. `/compact keep the checkpoint at <path>; drop tool output already saved in files`. You cannot run /compact yourself; say so.
   - **Tell a running PM to economise** — a Wanjang run is in progress. SendMessage to it: the remaining mechanical tasks on haiku, workers return status lines only, re-checks cover only what fixes changed, no new scouts for what the run log already answers.
   - **Wind down a runaway agent** — an agent repeats the same error, or spends far more in the last 5 minutes than the others with no new result. SendMessage to it: write what it has so far to its report file and stop. If it keeps going, ask the user before stopping it with TaskStop.
   - **Stop a noisy background command** — a background command still running with a large or growing output, or one no one is waiting for. Ask before stopping it with TaskStop; never stop a dev server the user started.
   - **Stop re-reading** — files read three or more times: say which, and from now on grep or read the range needed.
   - **For the next session** — only if the report or this conversation shows them: a big CLAUDE.md or MEMORY.md, unused skills or MCP servers (point to /doctor).
3. Do what the user picked, then reply in a few lines: what changed, what is still running, and the one line to type for /compact if that was picked.

If the report shows nothing worth doing, say so in one line and stop.
