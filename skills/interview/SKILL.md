---
name: interview
description: Planning interview before building a big, new or vague feature. Asks the decisions through the AskUserQuestion wizard in short rounds, plays back what is settled, runs a premortem on how it could fail, and writes one normalized spec file the PM and planner build from. Main session only (a subagent cannot use the wizard). Use on "interview me", "기획 인터뷰", "/wanjang:interview <idea>"; never for small, fully specified work.
argument-hint: "<the idea or request>"
---
Turn a vague request into one approved spec by asking, never by guessing. Ask every question in the user's language; this file is English. Request: $ARGUMENTS

## 0. Understand first
- Read the request, then what bears on it: code, docs, existing specs. Send lookups to `wanjang:scout`. Never ask the user what code or docs can answer.
- Write a one-paragraph understanding (goal, who, what exists today). Show it with the first round.

## 1. Grill rounds
Each round is one `AskUserQuestion` call. Every decision goes through the wizard, never chat text.
- At most 4 questions per call, the most important first (the ones that unlock others). More rounds, not bigger ones.
- Work through the coverage areas, frontier by frontier (a question whose answer does not depend on an unanswered one): scope, users and flow, data and states, rules, edge cases and errors, non-functional (offline, performance, security, privacy), integrations, constraints (deadline, people, tech), terminology, completion signals.
- Each question stands alone: one line of context, what the answer changes, 2-4 options. The recommended option is first. When it is a guess, say "my guess" in its label; when the code or docs back it, cite where. Always include a real alternative, not a strawman. "Other" stays free text.
- Skip areas that do not apply; never ask what a recommended default settles cheaply and reversibly. Record those as assumed.

## 2. Play-back after each round
3-5 lines: what is now decided, what was assumed (mark "assumed"), and the coverage table, one line per area: settled / assumed / open. The user can correct it in the next round's "Other", or say so in chat.

## 3. Premortem round
Once the main areas are settled or assumed, run it once. Frame: "Imagine this shipped and failed. Why?" Details in `${CLAUDE_PLUGIN_ROOT}/skills/interview/references/premortem.md`: helper agents (scouts, different angles) find the likely holes, ask about the top ones (address / defer / accept the risk), record signal, kill criterion and fallback for the top 1-3, finish with a bias check.

## 4. Stop rule
Stop asking when no frontier is left. Soft cap: about 5 rounds or 20 questions, then ask whether to continue (continue / write the spec with what we have). Questions left unanswered become "Open questions", not blockers.

## 5. Write the spec
- Fill `${CLAUDE_PLUGIN_ROOT}/skills/interview/references/spec-template.md` and save it as `docs/specs/YYYY-MM-DD-<slug>.md` in the project (create the folder; say that this is the default location and that the user can name another). Show the path.
- Final wizard, one question: approve / change something / keep asking. "Change" or "keep asking" goes back to step 1 for just that part, then rewrites the file.
- Every rule in the spec says who decided it: `user` or `assumed`. Never present an assumption as a decision.

## 6. Handoff
Build from the file, not from the chat. Pass its path to `wanjang:pm` (or `wanjang:planner` when only a plan is wanted): "Interview spec: <path>. Its decisions are settled; ask only about its Open questions." Do not start building before the spec is approved.

## Rules
- Main session only: a subagent has no wizard. If you are a subagent, say so and stop.
- Do not interview small, fully specified work.
- Do not pad: skip a question when its answer would not change the spec.
