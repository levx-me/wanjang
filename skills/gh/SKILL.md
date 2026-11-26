---
name: gh
description: Watch this repository's GitHub every hour. Fetches (never merges or pulls), says how far the branch is behind and which commits came in, lists local branches whose remote was deleted, and summarizes open pull requests, issues assigned to you and mentions of you that changed since the last check; offers to review a PR that asks for your review. /wanjang:gh on|off|status, or bare for a check now.
argument-hint: "on | off | status | (bare: check now)"
---
Main session only: if you are a subagent, stop at once.

Below, `ghwatch` means `"<this skill's base directory>/../../bin/ghwatch"`. Run it from the session's working folder; give the Bash call the description `git: git fetch --all --prune`. It never merges, pulls, deletes a branch or writes to GitHub. Exit codes: 0 something changed, 3 nothing changed, 2 not a git repository or the fetch failed.

A reply of only `·` is the whole reply: no status, no explanation.

Run the part of `$ARGUMENTS` that matches:

**on**
CronList, CronDelete every task whose prompt is `/wanjang:gh tick`, then CronCreate cron `23 * * * *`, recurring, prompt `/wanjang:gh tick`. Then run a check now (bare, below). End with one line: on for this session, checks at minute 23 of every hour and speaks only when something changed; `/wanjang:gh off` stops it.

**off**
CronList, CronDelete every task whose prompt is `/wanjang:gh tick`. Say it is off (or was not on).

**status**
CronList: on or off, and the next run. One line.

**tick** (the hourly cron)
1. If you are mid-turn on the user's work or a wizard is open, reply `·`; the changes stay for the next check (it compares with what it last saw).
2. Run `ghwatch`. Exit 3 or 2 (nothing new, or offline): reply `·`.
3. Exit 0: summarize as in **bare**, but only the lines marked `*`.

**bare** (a check now)
Run `ghwatch` and reply briefly, in the user's language:
- what came in: the branch is N behind, with the commit titles it printed, and that nothing was merged (`git pull` takes them when the user wants).
- pull requests: those marked `*` first, one line each (number, title, author, CI, review, what changed), then a count of the unchanged ones. Merged or closed ones in one line.
- issues assigned to the user or mentioning them that are new or updated.
- branches whose remote branch is gone: list them, and say `git branch -d <name>` removes one. Never delete them yourself.
- if a pull request asks for the user's review (listed on the `review` line) and its PR row is marked `*`: ask with AskUserQuestion, one question for all of them: "#N <title> asks for your review. Review it now?", options "Review #N (Recommended)" for each (at most 3) and "Not now". On a pick, run `/code-review <N>`; it reads the PR and posts nothing unless the user asks.
Exit 3 on a bare check: say nothing changed since the last check and give the count of open PRs from the output.
