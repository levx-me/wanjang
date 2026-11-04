---
name: next
description: Find the next useful piece of work and offer it with one question. Only when the user types /wanjang:next on|off|status|promises, or when its schedule or the wanjang Stop hook says to run `check`. Main session only.
argument-hint: "on | off | status | promises | check"
---
Main session only: if you are a subagent, stop at once.

Whenever a step below says to reply with only `·`, the whole reply is that one middle dot: no status, no explanation. (Claude Code refuses an empty reply and would add its own line.) A hook may already have skipped a cron check that would find nothing.

Below, `next` means `"<this skill's base directory>/../../bin/next"` (not a `next` on PATH, which may be Next.js).

Run the part of `$ARGUMENTS` that matches:

**on**
CronList, CronDelete every task whose prompt is `/wanjang:next check`, CronCreate a fresh one (cron `*/30 * * * *`, recurring, prompt `/wanjang:next check`), then run `next on` (turning it on again resets the 7 days). Reply in one or two lines: on for this session; it checks after each finished piece of work and every 30 minutes while idle; it renews its own schedule and runs until `/wanjang:next off` or the session ends.

**off**
CronList, CronDelete every task whose prompt is `/wanjang:next check`, then run `next off`. Say it is off (or was not on).

**status**
CronList (on or off, next run), then `next status`. Reply in one or two lines.

**promises**
Run `next promise list` and show it as a short table (id, due, condition, what was asked). "drop 2" or "later 2" afterwards: `next promise drop ID`, or `next promise set ID --at <tomorrow 09:00 local, ISO 8601>`. `next promise list --all` shows every project.

**check** (from the cron or the Stop hook; also when typed)
1. If you are a subagent, or work of your own is still running (a background agent, a task you are doing): reply with only `·`.
2. Renew. From the cron (the turn started with the prompt `/wanjang:next check`): CronList, then run `next cron --exists yes` if a task with prompt `/wanjang:next check` exists, else `next cron --exists no`. While it is off the verdict is `off`, so a typed or stray `check` does nothing. From the hook: use the verdict named in the hook text (none named means `keep`). Then: `keep`, go on; `create`, CronCreate (cron `*/30 * * * *`, recurring, prompt `/wanjang:next check`), run `next on`, go on; `recreate`, CronList, CronDelete the tasks whose prompt is `/wanjang:next check`, CronCreate, run `next on`, go on; `off`, CronList, CronDelete those tasks and reply with only `·`. Renewing never adds a message to the user and never runs a check by itself.
3. Run `next scan`. When the turn started with the prompt `/wanjang:next check` (the cron, not the hook's feedback), run `next scan --periodic` instead; exit 3 means reply with only `·`.
4. Add candidates only this session can see, with no new tool calls beyond ListAgents: follow-ups to the work just done (verify with the checker, docs, commit); pending tasks that stalled; subagent results not yet reported to the user; another session's request with no report sent back, or a session waiting on this one (ListAgents only if a relay task or such a message exists). Failing tests or lint seen in this conversation, or code changed since the tests last ran: "run the tests/lint". Never run the tests to find out.
5. A `promise:<id>` line from the scan beats every other candidate: it is something the user was told would come back. Otherwise pick the ONE most likely wanted next; finishing what was just done beats older items. Its key: the scan's key, or a short slug (`verify:<what>`, `relay:<session>`, `task:<id>`). Its fp: the scan's fp, or a string naming the evidence (the commit hash, the message or result it rests on). `next asked KEY FP` exit 0 means already asked: take the next candidate. None left: reply with only `·` (no "nothing found").
6. `next ask KEY FP` BEFORE asking, so a closed or unanswered question is not repeated. Then AskUserQuestion, one standalone question: what to do, why now (the evidence), what it costs (time, agents). Options: "Do it (Recommended)" and "Not now". Never more than one question per check. For a `promise:` candidate the question is: "You asked me to: '<words>' (<created, local>). Due because <reason>. <cost>." with options "Do it (Recommended)", "Later (tomorrow 09:00)" and "Drop it"; a time typed in Other means snooze to it.
7. Yes: handle it exactly as if the user had typed the request, with normal wanjang routing (do it directly, a builder, or the PM). Push, deploy and anything irreversible still get their own yes. "Not now" or no answer: reply with only `·`. For a promise: yes means do it as if typed, then `next promise done ID --note "<result>"` and report the result; Later means `next promise set ID --at <time, ISO 8601>`; Drop means `next promise drop ID`.

**Recording a promise** (any turn, not only a check): when you or the user commit to something later (a check after an event, "in a few days", "remind me", "once X, do Y"), run `next promise add "<what>" --words "<user's words>" --fp <evidence> --at <time> --when "<shell test>"` at once (`--cwd` for another repo; `--at` and/or `--when`, "tomorrow" is 09:00 local; events become `--when` checks such as `gh run view ID --json status -q .status | grep -qx completed`). Conditions run later inside `next scan`, with a 10 s timeout and never from a hook. Confirm in one line with the id. Exit 4 means it is already recorded.
