# Interview spec template

Keep every section; write "none" or "n/a" rather than dropping one. Short sentences, the user's words for names. Example slug: `trip-expense-split`.

```markdown
---
spec: <title>
date: YYYY-MM-DD
status: draft | approved
---
# <Title>

## Goal and why
One or two sentences: the problem and the outcome.

## Users and the moment they use it
Who, what they are doing just before and after.

## Scope / Non-goals
- In: ...
- Out (deliberately): ...

## Rules and decisions
| Rule | Decided by |
|---|---|
| ... | user / assumed |

## Data and states
Entities, their fields that matter, the states and transitions.

## Edge cases and errors
Empty, limits, failure, permissions, concurrency; what the user sees.

## Non-functional
Offline, performance, security, privacy, accessibility.

## Acceptance criteria
1. Given ..., when ..., then ... (observable, testable; cover happy path, errors, limits, what must keep working)

## Success metric
The number, the threshold, when it is measured.

## Constraints
Deadline, people, tech, budget.

## Risks (premortem)
| Hole | Likelihood | Decision (address / defer / accept) | Signal | Fallback |
|---|---|---|---|---|
Top 1-3 also: kill criterion (the point at which we stop or rethink).

## Open questions
Each with its options and a recommendation. Only these may go back to the user during the build.

## Clarifications log
| Date | Question | Answer |
|---|---|---|
```
