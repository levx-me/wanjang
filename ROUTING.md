Wanjang routing:
- Multi-step work (feature, cross-file refactor, fix to investigate) goes to `wanjang:pm`: it plans, splits by layer, sends UI to its designer, has QA and the checker verify. No model (Sonnet) if the request or a spec says what to build; `model: "opus"` only if something must be found out before any plan (unknown codebase, open design, unknown bug).
- Small, fully specified changes: `wanjang:builder` (`model: "haiku"` mechanical, `"sonnet"` standard) or do directly. A fork (`subagent_type: "fork"`) carries the whole conversation each turn: only for a non-code job with a 1-2 line brief while the conversation is short (under ~100K tokens).
- Briefing workers yourself, over three files: cut into groups sharing none, one worker each, started in one message (five at most; the next as one returns). Settle shared names, ids, interfaces first, in every brief; a file two groups would edit goes to one. Parts to be written in order stay with one worker.
- Verify once: never rerun checks a worker reported with commands and results. The independent pass is a fresh `wanjang:checker`, never a fork.
- Lookups: `wanjang:scout`, several at once if split. Document-answer research goes to `wanjang:pm` as a research run (scouts split it, parts written in parallel, the checker verifies numbers). A vague idea to spec: `wanjang:planner`; trying a running product as a user: `wanjang:qa`.
- Playbooks: `.claude/playbooks/INDEX.md`, `~/.claude/playbooks/INDEX.md`. The PM picks them; in your own briefs, name the fitting ones.
- Merge and check results; pass a PM's completion report on as is (what to use, how to see it, what was decided).
- Defaults a PM decided for the user are never left in a file or buried in a reply. Never ask mid-run; when the final report lists "Decided for you", ask all at once with AskUserQuestion: one question per default (choice, why), options "keep <X>" first (recommended), then alternatives and their effect; four per call. Add pending task "you: review N defaults from <run>" until answered (kept if wizard closed). Send changes to `wanjang:pm` ("Resume the run in <folder>: change <topic> to <Y>").
- Crew size: one or two files, no PM; one lookup, one scout; comparing options, two to four scouts; the PM only for multi-step work.

Keeping main-session context:
- Every brief says what to return: conclusion first, path:line evidence, a length (~300 words; one summary per run); no file contents or logs.
- Main session: grep or read the range needed, not big files or logs whole.
- For .md/.txt/.html, run `docindex search "<query>" <dir>` (or `docindex outline <file>`) first, read only those lines; workers too.
- A repeated job (tuning loop, benchmark, migration) keeps each round's state in a file (run log or scratchpad notes); take only what changed.
- Progress still reaches the user (task list, short status); the saving is in what agents return.
- At compaction keep: the user's requests in their words, decisions and why, paths of run folders and files in play, what waits on the user, what is next; drop output a file or log holds.
