---
name: crew-console
description: Bill every wanjang agent (the PM, its workers, and the builder, scout, checker the main session calls) to the Anthropic Console API key instead of the subscription. Use when the user types /wanjang:crew-console on, off or status, or asks to run the wanjang crew on the API key.
argument-hint: "on [--budget USD] | off | status"
---
Run `"<this skill's base directory>/../../bin/crew-console" $ARGUMENTS` with the Bash tool (no arguments: `status`) and report its output.

While it is on in this project, a hook (`bin/crew-console-hook`) refuses a `wanjang:*` Agent call from the main session and gives the command to run instead: `crew-run <type> --model M --effort E` (brief on stdin) in a Bash call with `run_in_background: true`. Then end the turn and report the result when woken; its last line is the cost. The main conversation itself stays on the subscription.

- The switch is per project (git toplevel of the cwd, else the cwd): other projects stay off. State: `${CLAUDE_CONFIG_DIR:-~/.claude}/wanjang/crew-console.json`, keyed by project path; each run's full JSON is logged in `.../wanjang/crew-console/`. Default budget per run: $10 (`--budget`).
- `on` needs a stored Console key: `/wanjang:provider key console`.
- Limits: no SendMessage to an agent running this way; it is its own session in `/wanjang:now` and the deck; a PM's "Bad news" lines arrive with its final report. The Console promotional credit may cover `claude -p` but not interactive Claude Code.
