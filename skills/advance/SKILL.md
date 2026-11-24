---
name: advance
description: Pick the work back up after a compaction, or after the user read the last reply without answering it. Finds what is left to do from this conversation; one item is done at once, several are put to the user in the wizard to choose which comes first. /wanjang:advance [hint]
argument-hint: "[what to focus on]"
---
Main session only: if you are a subagent, stop at once.

1. Gather what is left, from what this session already holds, with no new reads beyond these:
   - the user's last requests and the last reply: a question it asked, a step it said comes next, a wizard the user closed or left unanswered;
   - TaskList: pending and in_progress tasks (a "you:" task is the user's to do, not a candidate; mention it at the end);
   - `${CLAUDE_PLUGIN_ROOT}/bin/next promise list` (promises due in this repo);
   - unfinished run folders the session-start hook named (`.git/wanjang/<run>/log.md` with no report);
   - `git status --short` and unpushed commits (`git log @{u}..` when there is an upstream): uncommitted work of this session is a candidate (commit), unpushed commits are a push decision.
   With `$ARGUMENTS`, keep only the items it names.
2. Drop what is done (a later message settled it, a task is completed), what the user declined ("not now", "later"), and duplicates (the same work as a task and in the reply).
3. Nothing left: say so in one line and stop.
4. One item: do it now, as if the user had typed it, with normal routing. Say in one line what you are picking up and why it is the only one.
5. Several: AskUserQuestion, one question "Which do I pick up first?" with up to 4 options, the most likely wanted first and marked "(Recommended)": finishing what was in progress beats a new item, a promise that is due beats both. Each option says what will be done, from what evidence (task #, the reply that left it, the commit), and its rough cost. More than 4: the top 4, and the rest named in the question. Do the chosen one; the rest stay pending tasks (create any that are not tasks yet).
6. Push, deploy, deletes and anything outward still get their own yes in the wizard; picking such an item here is the user's choice to look at it, not that yes. A run folder resumes through `wanjang:pm` ("Resume the run in <folder>").
