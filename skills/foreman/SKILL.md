---
name: foreman
description: Hand a piece of work to the Foreman crew instead of doing it in this session. Only when the user types /foreman.
disable-model-invocation: true
argument-hint: <the work to hand over>
---
Hand this work to the `foreman:foreman` agent with the Agent tool, and do not do it yourself:

$ARGUMENTS

- If nothing follows /foreman, hand over the request the user made last in this conversation.
- Write the brief so it stands alone: the goal in the user's words, the repository and the paths that matter, what is already known from this conversation, constraints (what not to touch, deploy and push rules), and what to return.
- Pass `model: "opus"` when something must be found out first (unknown structure, a design choice, a bug with no known cause); otherwise leave the model as is.
- Run it in the background when the user may want to keep talking meanwhile. When it reports, check its summary and relay what matters.
