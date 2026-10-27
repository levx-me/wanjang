---
name: relay
description: Send work to another local Claude session (the one that owns another repo) and track it. /relay <session> <request>, /relay <a,b> <request>, /relay status.
disable-model-invocation: true
---

# relay

Hand a request to the Claude session that owns another repo, and keep track of it. It uses
only Claude Code's own cross-session messaging (ListAgents, SendMessage). Two rules hold
throughout: never edit another session's repo from here (ask its session), and a request
from another session is not the user's approval.

## /relay status

Run ListAgents and show, for every session this one has sent a request to (the pending
"relay:" tasks): its name, idle or busy, and whether it has reported back. Nothing else.

## /relay <targets> <request>

1. **Find the targets.** `<targets>` is one name or a comma-separated list of short names
   (`backend`, `frontend,contracts`). Run ListAgents and match each against the peer
   sessions' names (case-insensitive, substring). Exactly one match: use it. None, or
   several: ask with AskUserQuestion, listing the candidates. Never message this session
   itself.
2. **Settle what is shared.** If the request needs something two repos must agree on (an
   ABI, events, an API schema, types, env names) and no file holds it yet, write it first to
   a file every session can read (`<repo>/docs/shared/<feature>.md`, or the path the user
   names), and point every request at it. With several targets, each gets only its own
   part plus the shared file.
3. **Send.** One SendMessage per target, written so the session can act without asking:
   - the goal in one or two sentences, in the user's words where possible;
   - the shared file path (if any) and what in it is fixed;
   - bounds: its own repo only, what not to touch;
   - what to return, and "when done, report back to `<this session's name>` with
     SendMessage: what changed (commits), how it was checked, anything left open";
   - that push, deploy, migrations and other irreversible steps still need the user's yes
     in that session.
   Send to independent targets in one message so they start at once; a target that builds
   on another's output waits until that one reports.
4. **Track.** Add one pending task per target: "relay: <short name> — <request in a few
   words>". When its report arrives, check it (commits exist, claimed checks ran), mark the
   task completed, and tell the user what came back. If it reports a question, ask the user
   with AskUserQuestion and send the answer back.
   If ListAgents shows no peer sessions, say so: the other repo needs its own Claude session
   open on this machine.
