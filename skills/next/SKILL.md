---
name: next
description: Find the next useful piece of work and offer it with one question. Only when the user types /wanjang:next on|off|status, or when its schedule or the wanjang Stop hook says to run `check`. Main session only.
argument-hint: "on | off | status | check"
---
Main session only: if you are a subagent, stop at once.

Below, `next` means `"<this skill's base directory>/../../bin/next"` (not a `next` on PATH, which may be Next.js).

Run the part of `$ARGUMENTS` that matches:

**on**
CronList, CronDelete every task whose prompt is `/wanjang:next check`, CronCreate a fresh one (cron `*/30 * * * *`, recurring, prompt `/wanjang:next check`), then run `next on` (turning it on again resets the 7 days). Reply in one or two lines: on for this session; it checks after each finished piece of work and every 30 minutes while idle; it renews its own schedule and runs until `/wanjang:next off` or the session ends.

**off**
CronList, CronDelete every task whose prompt is `/wanjang:next check`, then run `next off`. Say it is off (or was not on).

**status**
CronList (on or off, next run), then `next status`. Reply in one or two lines.

**check** (from the cron or the Stop hook; also when typed)
1. If you are a subagent, or work of your own is still running (a background agent, a task you are doing): end the turn with no text.
2. Renew. From the cron (the turn started with the prompt `/wanjang:next check`): CronList, then run `next cron --exists yes` if a task with prompt `/wanjang:next check` exists, else `next cron --exists no`. While it is off the verdict is `off`, so a typed or stray `check` does nothing. From the hook: use the verdict named in the hook text (none named means `keep`). Then: `keep`, go on; `create`, CronCreate (cron `*/30 * * * *`, recurring, prompt `/wanjang:next check`), run `next on`, go on; `recreate`, CronList, CronDelete the tasks whose prompt is `/wanjang:next check`, CronCreate, run `next on`, go on; `off`, CronList, CronDelete those tasks and end the turn with no text. Renewing never adds a message to the user and never runs a check by itself.
3. Run `next scan`. When the turn started with the prompt `/wanjang:next check` (the cron, not the hook's feedback), run `next scan --periodic` instead; exit 3 means end the turn with no text.
4. Add candidates only this session can see, with no new tool calls beyond ListAgents: follow-ups to the work just done (verify with the checker, docs, commit); pending tasks that stalled; subagent results not yet reported to the user; another session's request with no report sent back, or a session waiting on this one (ListAgents only if a relay task or such a message exists). Failing tests or lint seen in this conversation, or code changed since the tests last ran: "run the tests/lint". Never run the tests to find out.
5. Pick the ONE most likely wanted next; finishing what was just done beats older items. Its key: the scan's key, or a short slug (`verify:<what>`, `relay:<session>`, `task:<id>`). Its fp: the scan's fp, or a string naming the evidence (the commit hash, the message or result it rests on). `next asked KEY FP` exit 0 means already asked: take the next candidate. None left: end the turn with no text at all (no "nothing found").
6. `next ask KEY FP` BEFORE asking, so a closed or unanswered question is not repeated. Then AskUserQuestion, one standalone question: what to do, why now (the evidence), what it costs (time, agents). Options: "Do it (Recommended)" and "Not now". Never more than one question per check.
7. Yes: handle it exactly as if the user had typed the request, with normal wanjang routing (do it directly, a builder, or the PM). Push, deploy and anything irreversible still get their own yes. "Not now" or no answer: end the turn with no text.
