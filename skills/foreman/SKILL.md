---
name: foreman
description: Hand a piece of work to the Foreman crew instead of doing it in this session, or resume a Foreman run that stopped. Only when the user types /foreman.
disable-model-invocation: true
argument-hint: <the work to hand over> | resume [run]
---
Arguments: $ARGUMENTS

**`resume`** (optionally followed by a run log's name): pick up a Foreman run that stopped (a crash, a lost connection, a restart).
- Each run has a folder in `$(git rev-parse --git-common-dir)/foreman/` (outside a git repository, `~/.claude/foreman/runs/`) with its `log.md`. Take the run named, else the newest whose `log.md` says `Status: in progress`. None: say so and stop. Several and none named: ask which with AskUserQuestion.
- Hand it to the `foreman:foreman` agent with the Agent tool: "Resume the run in <folder>", plus anything this conversation adds. Do not redo its work yourself.

**Anything else**: hand this work to the `foreman:foreman` agent with the Agent tool, and do not do it yourself.
- If nothing follows /foreman, hand over the request the user made last in this conversation.
- Write the brief so it stands alone: the goal in the user's words, the repository and the paths that matter, what is already known from this conversation, constraints (what not to touch, commit, deploy and push rules), and what to return.
- Pass `model: "opus"` when something must be found out first (unknown structure, a design choice, a bug with no known cause); otherwise leave the model as is.

Either way, run it in the background when the user may want to keep talking meanwhile. When it reports, check its summary and relay what matters.
