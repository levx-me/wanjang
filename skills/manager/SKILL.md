---
name: manager
description: Make this session the manager of your other open sessions: every hour it looks at them, shows what was missed on one page, asks about up to 4 items one at a time, and sends each approved item to the session that owns it. Only when the user types /wanjang:manager on|off|status|promises|trust|undo|approve ID|reject ID, or bare for a check now, or when the hourly prompt `wanjang manager tick` arrives with the hook's steps. Main session only.
argument-hint: "on | off | status | promises | trust | undo | approve ID | reject ID | (bare: check now)"
---
Main session only: if you are a subagent, stop at once.

Below, `manager` means `"<this skill's base directory>/../../bin/manager"` and `next` means `"<this skill's base directory>/../../bin/next"` (not a `manager` or a Next.js `next` on PATH). It prints one-line reasons and exits 0 when there is nothing to do; read them, do not retry.

A reply of only `·` is the whole reply: no status, no explanation. (Claude Code refuses an empty reply and would add its own line.)

The manager is a role an open session takes (the user's general assistant session, say). It never edits a repository or does the work; it tells the user what can be done, asks, and sends. Its memory is the ledger under `~/.claude/wanjang/manager/`, so a compaction or a restart loses nothing: `manager resume` prints it in at most 15 lines.

Run the part of `$ARGUMENTS` that matches:

**on** (add `--take` only if the user said to move it)
1. `manager on [--take]`. If it refuses (exit 4, "manager already on in <name>"), say that and that `--take` moves it; stop.
2. CronList, CronDelete every task whose prompt is `wanjang manager tick` or `/wanjang:next check`, then CronCreate cron `7 * * * *`, recurring, prompt `wanjang manager tick` (plain text, not a slash command).
3. `manager resume` and show it. Reply in two lines: on in this session, checks at minute 7 of every hour, asks at most 4 things at a time; `/wanjang:manager` checks now, `off` stops it.

**off**
CronList, CronDelete every task whose prompt is `wanjang manager tick`, then `manager off`. Say it is off (or was not on).

**status**
CronList (on or off, next run), then `manager resume`. Reply in two lines.

**promises**, **trust**, **undo**
Promises, trust and undo live in `next`, which the manager keeps as its library. **promises**: `next promise list` as a short table (id, due, condition, what was asked); "drop 2" or "later 2" afterwards: `next promise drop 2`, or `next promise set 2 --at <tomorrow 09:00 local, ISO 8601>`; `list --all` shows every project. **trust** (a kind of work the user said yes to 3 times, the first at least a day before, within 14 days, is done without asking and reported; push, deploy and anything outward or irreversible is always asked): `next trust` with the rest of `$ARGUMENTS` (`off`, `on`, `<kind> ask`, `<kind> reset`); bare, show its table and that sentence. **undo**: `next undo` and its one line (exit 4: it changed nothing; say why).

**approve ID**, **reject ID**
The user answers an item from the page. `manager answer ID approve|reject --words "<the user's words>"`; after approve go to Dispatch.

**bare** (a check now)
Run the tick below with `manager scan --force`. If nothing is new, reply "nothing new since HH:MM; N open · <page>" (from `manager resume`).

**The tick** (the prompt `wanjang manager tick`; the hook has already run `manager scan` and passed only because something is new. Its context repeats these steps.)
1. If a wizard is open or you are mid-turn on the user's work, reply `·`; the findings stay new for the next tick.
2. Start one `wanjang:inspector`, telling it the path of `manager`, `next` and the digest (`manager/digest.txt`, printed by the scan). It records the items, renders the page (`manager page`, in the brief skill's plain language, up to 4 decision blocks) and returns `TICK`, up to 4 `ASK`, `AUTO` and up to 2 `NOTE` lines.
3. **Asking.** One AskUserQuestion per tick, one question per `ASK` line (header = its label, question = "<action>? <why>. Cost: <cost>", options Approve / Reject; Other is a comment). Ask them one at a time in the wizard, never as a list in chat. For each answer: `manager answer ID approve|reject|comment --words "<verbatim>"`. A comment is not approval: send it back to a fresh `wanjang:inspector` to revise the item, which asks again only once its evidence changes. No answer: leave it; it waits on the page, where `/wanjang:manager approve|reject ID` answers it.
4. **Dispatch** right after each approve, and for every `AUTO` line (trusted kinds, local only; dispatch them without asking): `manager dispatch --id ID` prints `SEND <session-name>` and the message (or `WAIT` / `NOT SENT`: nothing to send now, the item stays; `CHANGED`: see below). SendMessage that text to that session (it queues if the session is busy), then `manager sent ID`; if SendMessage fails, `manager sent ID --failed` (retried next tick). Do not wait for the session. If dispatch prints `CHANGED`, the evidence changed and the item is asked again, not sent. The message always tells the owning session that push, deploy, migrations, deletes, installs and anything outward still need the user's yes there, even though it carries an approval.
5. Reply with one line: `Manager HH:MM · n new, n asked, n sent · <page path>`, plus each `NOTE` line (stuck, gone, no reply). Nothing else.

**Replies from sessions.** They arrive as `manager reply ID done|failed|question --note ...`, written to the ledger by the owning session at no cost to you. If a session messages you anyway, record it with `manager reply ID <word> --note "<its words>"` and reply `·`. A `question` becomes a new ASK on the next tick.
