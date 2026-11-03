# Claude Code plugins, hooks, subagents

> Sources: [Plugins](https://code.claude.com/docs/en/plugins), [Hooks](https://code.claude.com/docs/en/hooks), [Subagents](https://code.claude.com/docs/en/sub-agents), [Memory and rules](https://code.claude.com/docs/en/memory), [Output styles](https://code.claude.com/docs/en/output-styles), [Skills](https://code.claude.com/docs/en/skills); building the wanjang and Steading plugins · Written 2026-10-27 · Applies to: Claude Code plugins, hooks, skills, subagents, MCP servers

**Use when:** writing or changing a plugin, a hook, a subagent definition, a skill, or the rules and context that every session loads. Tags: **[doc]** = confirmed on the official page on 2026-10-27; **[obs]** = observed in transcripts or by running it, not in the docs; recheck after a Claude Code upgrade.

## Before you start
- Read the plugin's `.claude-plugin/plugin.json` and its `hooks/hooks.json`; match their layout, script language and naming.
- Decide which layer the behaviour belongs to: something that must happen every time is a hook; something Claude should know is a rule or file read on demand; a focused task is a subagent. Instructions are not enforcement [doc].
- Check the hook event names and input fields on the hooks page before writing code; they change between versions.

## Rules

### Hook output
1. Each hook's `additionalContext`, `systemMessage` and plain stdout is capped at 10,000 characters, each string measured on its own (so two hook commands, or two fields, each get their own 10,000). Over it, Claude Code saves the text to a file and gives Claude only the path plus the first 2,000 characters, and does not ask Claude to read it [doc]. Anything Claude must always see goes in a command of its own, under the cap; split big injections into several hook commands.
2. A hook must never break session start. Always exit 0, write nothing to stderr, print valid JSON (or nothing). Treat `HOME` as possibly unset and every file as possibly missing; wrap the body in a catch-all that prints `{}`.
3. Hooks run as you with your privileges [doc]. Never put secrets in the output; it lands in the transcript.
4. `additionalContext` on `PreToolUse` is documented only next to `permissionDecision`; it is ignored when the decision is `defer` [doc]. Returning context with no `permissionDecision` left other hooks' decisions alone when tried [obs]. Never emit `allow` just to carry context.

### Which event reaches whom
5. `SessionStart` fires on `startup`, `resume`, `clear`, `compact` (and `fork`) [doc]. Its context reaches the main session. A subagent gets its own `SubagentStart` context, shown in the subagent's transcript, not the parent's [doc]. So a rule you want in subagents needs a `SubagentStart` hook (or a file the agent definition tells it to read).
6. `/reload-plugins` does not re-run `SessionStart` [obs]. To test a SessionStart change use `/restart` or a new session.
7. A `/restart` that kills the process mid-turn skips `Stop` [obs]. Clear per-turn marks (flags, counters, "agent running" files) on `SessionStart`, not only on `Stop`.
8. `SubagentStop` with `decision: "block"` and a `reason` keeps the subagent running and delivers the reason to the subagent as its next instruction [doc]. It does not tell the parent. To inject context into the parent after a subagent returns, use `PostToolUse` on the `Agent` tool (`additionalContext`) [doc].
9. Guard every blocking Stop-style hook against loops: read `stop_hook_active` from the input (the field exists on `SubagentStop` input [doc]; its meaning is not explained there) and allow the stop when it is true.
10. A background subagent returns `status: "async_launched"` to `PostToolUse` [doc], so that hook cannot see the end of the work. Only `SubagentStop` sees it end.
11. Count running subagents with `SubagentStart`/`SubagentStop` markers (one file per `agent_id`, removed on stop), never transcript mtimes: one long tool call writes nothing for minutes and looks dead.
12. `StopFailure` fires when a turn ends on an API error; the matcher is the error type (`rate_limit`, `authentication_failed`, ...). It has no decision control and its JSON output is ignored, except side-effect fields [doc]. Use it to log or notify only.
13. `UserPromptExpansion` runs when a typed command expands into a prompt; exit 2 blocks the expansion, stdout is added as context [doc]. Handling a slash command with no model call at all by this route worked [obs]; check the input schema first.

### Subagent definitions
14. Frontmatter: `tools` (allowlist, inherits all if omitted) and `disallowedTools` (removed from that list), `model`, `skills`, `omitClaudeMd` [doc]. Give read-only agents a short `tools` list.
15. `skills:` injects the full text of each listed skill at startup, not just the description, up to the first 32 names [doc]. List only skills the agent always needs.
16. `omitClaudeMd: true` starts the agent without user, project and local CLAUDE.md [doc] (managed policy instructions still load). Use it for narrow workers.
17. Plugin subagents ignore `hooks`, `mcpServers` and `permissionMode` [doc]. Put those in settings or the plugin's own `hooks.json`/`.mcp.json`, not in the agent file.
17a. Claude Code refuses a subagent's write to a file whose name starts REPORT, SUMMARY, FINDINGS or ANALYSIS and ends .md ("Subagents should return findings as text") [obs: from the binary, 2026-10-29]. Workers return reports as reply text; a parent that wants a copy saves it under another name (e.g. `return-<n>-<worker>.md`). Never put such a file on a Deliverables line.
18. A subagent can spawn subagents up to three layers below the main conversation; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` changes it, `1` turns nesting off [doc]. Set it explicitly if a worker should not delegate further.
19. A fork inherits the parent's whole conversation and system prompt [doc], so every fork turn pays for that history. Use a fresh subagent with a written brief when the task does not need the history.

### Rules and styles
20. `~/.claude/rules/*.md` and CLAUDE.md load into every session, and (unless `omitClaudeMd`) into subagents. Keep what only the main session needs out of them, or scope it with `paths:` frontmatter, which loads a rule only when matching files are touched [doc].
21. Output styles apply to the main session and to forks only; other subagents use their own system prompt. One style is active at a time [doc]. Do not use a style to steer workers.

### Packaging
22. The plugin cache is keyed by version [obs]: bump `version` in `plugin.json` on every release, or `claude plugin update` will not pick the change up.
23. A plugin's `bin/` directory is on the Bash tool's PATH inside sessions [obs]. Ship helper CLIs there and call them by bare name from hooks, skills and rules.
24. Plugins load at startup or on reload [doc]. For manual testing run with `--plugin-dir <folder>` instead of installing.

### Cost
25. Name and description of every skill and agent Claude can invoke sit in context on every turn, in every session, even when unused; the full text loads on use [doc]. Write one-line descriptions, merge near-duplicates, and set manual-only for rarely used skills.
26. Prefer a playbook or reference file read on demand over a rule or skill description. A rule costs its full length in every session and every subagent.
27. Measure before and after: `claude -p "hi" --output-format json` and read the usage fields; repeat with the plugin disabled and with tool variants. `/context` shows the same split interactively.

### Testing
28. Test each hook as a plain command: a shell test pipes fake hook JSON into stdin and asserts on stdout, exit code (always 0) and empty stderr. Cover the unset-`HOME`, missing-file and malformed-input cases.
29. Then run one live `claude -p` session with the plugin loaded and read the transcript to confirm the context really arrived, in the right session (main vs subagent), and under the 10,000 cap. Shell tests prove the script, not the wiring.

## Example
```sh
# test: SessionStart hook survives no HOME and prints JSON
out=$(echo '{"hook_event_name":"SessionStart"}' | env -u HOME ./hooks/session-start 2>err)
[ $? -eq 0 ] && [ ! -s err ] && echo "$out" | jq -e . >/dev/null && echo ok
```
