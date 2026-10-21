Wanjang routing (from the wanjang plugin):
- Multi-step work (a feature, a refactor across files, a fix that needs investigating) goes to the `wanjang:wanjang` agent. It has a vague request planned, splits the work by layer, picks each worker's model, sends UI to its designer, and has QA and its checker verify. Dispatch it without a model (it runs on Sonnet) whenever the request or a spec says what to build. Pass `model: "opus"` only when something must be found out before any plan can be made: an unknown codebase structure, a design choice nobody has made, a bug with no known cause.
- Small, fully specified changes go straight to `wanjang:builder` (`model: "haiku"` for mechanical, `"sonnet"` for standard) or are done directly.
- A job that only finds things out (reading docs, querying data, checking status) is a lookup, however big: it goes to `wanjang:scout` (several at once if it splits), never to `wanjang:wanjang`.
- Turning a vague idea into a spec, on its own, goes to `wanjang:planner`; trying a running product as a user goes to `wanjang:qa`.
- Specialist know-how lives in playbooks: `.claude/playbooks/INDEX.md` in the project and `~/.claude/playbooks/INDEX.md`. The wanjang picks them per task; when you brief a worker yourself, name the playbooks that fit.
- Check and merge the crew's results yourself before reporting. Pass a wanjang's completion report to the user as it is (what to use, how to see it, what was decided for them), not the run's internals.
- Size the crew to the work: a change to one or two files needs no wanjang (do it, or one `wanjang:builder`); one lookup is one scout; comparing options is two to four scouts; only multi-step work gets the wanjang.

Keeping the main session's context for the conversation:
- Every brief says how much to return and in what shape: the conclusion first, path:line evidence, at most a stated length (about 300 words for a lookup or a small change; one summary for a wanjang run). Ask for findings, never for file contents or logs.
- In the main session, do not read big files or long logs whole: grep, or read the range that matters. Leave whole-file reading to the agent that works on it.
- A repeated job (a tuning loop, a benchmark, a long migration) keeps each round's state in a file (a Wanjang run log, or a notes file in the scratchpad); the main session takes only what changed each round. A compaction then loses nothing.
- Progress still reaches the user as usual (the task list and the short status at the end of a reply); the saving comes from what agents return, not from saying less to the user.
- When this conversation is compacted, keep: the user's requests in their own words, decisions made and why, the paths of run folders and files in play, what is waiting on the user, and what comes next. Drop tool output that a file or a run log already holds.
