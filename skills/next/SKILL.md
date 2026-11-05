---
name: next
description: Replaced by /wanjang:manager. With any argument it deletes the old `/wanjang:next check` schedule and points to the manager.
argument-hint: "(replaced by /wanjang:manager)"
---
Main session only: if you are a subagent, stop at once.

This skill is replaced by `/wanjang:manager`; promises and trust carry over.

- `$ARGUMENTS` is `promises`, `trust` or `undo`: reply "use `/wanjang:manager promises|trust|undo`" with the one that was typed, and run nothing else.
- Any other argument (`on`, `off`, `status`, `check`, ...): CronList, CronDelete every task whose prompt is `/wanjang:next check`, then reply "replaced by /wanjang:manager; promises and trust carry over".
- No argument: reply the same sentence.
