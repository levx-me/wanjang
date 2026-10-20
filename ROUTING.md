Foreman routing (from the foreman plugin):
- Multi-step work (a feature, a refactor across files, a fix that needs investigating) goes to the `foreman:foreman` agent. It has a vague request planned, splits the work by layer, picks each worker's model, sends UI to its designer, and has QA and its checker verify. Dispatch it as is (Sonnet) when the scope is clear; pass `model: "opus"` when there is something to find out first (unknown structure, a design choice, a bug with no known cause).
- Small, fully specified changes go straight to `foreman:builder` (`model: "haiku"` for mechanical, `"sonnet"` for standard) or are done directly.
- A job that only finds things out (reading docs, querying data, checking status) is a lookup, however big: it goes to `foreman:scout` (several at once if it splits), never to `foreman:foreman`.
- Turning a vague idea into a spec, on its own, goes to `foreman:planner`; trying a running product as a user goes to `foreman:qa`.
- Specialist know-how lives in playbooks: `.claude/playbooks/INDEX.md` in the project and `~/.claude/playbooks/INDEX.md`. The foreman picks them per task; when you brief a worker yourself, name the playbooks that fit.
- Check and merge the crew's results yourself before reporting.
