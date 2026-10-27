---
name: slim
description: Move rules that only the main session needs out of what every subagent loads.
---
Every subagent loads `~/.claude/CLAUDE.md`, `~/.claude/rules/*.md` and the project's `.claude/rules/*.md`. Rules only the main session needs can live in `main-rules/` instead: wanjang's SessionStart hook injects those into the main session only. Follow the steps in order; never move anything before the user answers.

1. List sizes in characters (`wc -m`) of `~/.claude/CLAUDE.md`, each `~/.claude/rules/*.md` and each `<project>/.claude/rules/*.md` (project = the git root, else the cwd), and the total every subagent receives. Say that skill listings and other plugins' hooks are outside this skill's reach.
2. Classify each rules file (never CLAUDE.md, which stays put):
   - **main only**: talking to the user: reply language, status or report format, asking decisions, offering wiki notes, how to split or delegate requests.
   - **workers need it**: anything about code, files, git, secrets, tests, data safety, project conventions.
   - When unsure, "workers need it". A file with `paths:` frontmatter stays.
3. Show a table: file, size, verdict, one-line reason. Then ask with AskUserQuestion (multiSelect) which "main only" files to move (put them all in the options, up to 4 per question; split across questions if more). Nothing moves without the answer. Before asking, add up the sizes of the files already in `main-rules/` (both places) plus the candidates: the hook injects at most ~9.5K chars in total and skips the rest, so warn the user when the total would pass that and suggest moving fewer files.
4. For each approved file: `mkdir -p` the target and `mv` it to `~/.claude/main-rules/` (project rules: `<project>/.claude/main-rules/`). Print the undo, one `mv` per file back to where it came from, and say to run `/restart` so the main session and new subagents both pick the change up.
