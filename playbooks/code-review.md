# Code Review

> Sources: [Google Engineering Practices: code review](https://google.github.io/eng-practices/review/) (CC-BY-3.0), [awesome-copilot code review instructions](https://github.com/github/awesome-copilot) (MIT), [agency-agents minimal-change engineer](https://github.com/msitarzewski/agency-agents) (MIT, paraphrased) · Written 2026-10-20 · Applies to: any language

**Use when:** reviewing a PR or a worker's diff for quality and correctness. For vulnerabilities in depth use `security-review.md`; for endpoint shape `api-design.md`.

## Before you start
- Read the task or PR description first: what was asked, what is out of scope. Judge the diff against that.
- Get the whole change: `git diff main...HEAD --stat`, then the full diff. Read every changed line, plus the surrounding function and its callers, not only the hunks.
- Check project rules (CLAUDE.md, lint config, style guide). The project's style guide decides style questions, not your taste.
- Run the project's tests, type-check and linter yourself (see Verify).

## Rules
**1. The standard: better than before, not perfect.**
- Approve when the change clearly improves overall code health, even if you would have done it differently. Do not block on preference.
- Block when it makes code health worse (bugs, broken behaviour, needless complexity, missing tests for new logic), except true emergencies.
- Facts and data beat opinion. When two designs are both sound, keep the author's. Argue from principle (correctness, readability, consistency), not "I prefer".

**2. What to look for, in this order** (stop and report big problems before polishing small ones)
1. **Design.** Does it belong here? Does it fit existing structure and reuse existing helpers, or reinvent them (`grep` for similar code)? Is it the right layer? Will it integrate with the rest of the system?
2. **Behaviour.** Does it do what the task asked, including edge cases: empty, null, huge, duplicate, concurrent, failure halfway through? Trace one real input end to end. Error paths handled, resources closed, no silent catch.
3. **Complexity.** Could a reader understand each function quickly? Flag over-engineering: abstractions, options or generality nobody asked for, code for hypothetical futures. Prefer the simpler version.
4. **Tests.** New logic has tests; they assert behaviour, would fail if the code broke (break the code and see), and are not flaky. Bug fixes have a regression test.
5. **Naming.** Names say what a thing is or does, no need for a comment to decode them.
6. **Comments.** Explain why, not what. Delete stale and commented-out code. Public behaviour changes update docs/README.
7. **Consistency.** Matches surrounding code, formatting by the formatter, same patterns for the same problem.
- Also scan: security-sensitive code (auth, input, secrets, money) triggers `security-review.md`; performance only when it is obviously bad (N+1 queries, unbounded loops or memory), not micro-optimisation.

**3. Scope.**
- Flag unrelated changes (drive-by refactors, reformatting, renamed files, new dependencies) that the task did not ask for. They hide bugs and make review and revert hard. Ask to split them out or justify them.
- Flag the opposite too: the task asked for X and part of X is missing.

**4. Verify claims, do not trust them.**
- "Tests pass", "fixed", "no behaviour change": run it. `git stash`/checkout the branch and run the test command; for a bug fix, confirm the new test fails without the fix.
- For UI changes, run the app or request a screenshot; for API changes, call the endpoint.
- A worker's report is a claim. Compare it to the diff: did it touch the files it says, and only those?

**5. Writing comments.**
- Every comment: location (`path:line`), the problem, why it matters, a concrete fix. "This is confusing" is not actionable; "rename `d` to `retryDelayMs`" is.
- Label each: **Blocking** (must change: bug, security, broken test, regression, hard-to-maintain), **Question** (need an answer before deciding), **Nit:** (optional polish, author may ignore). Make the label the first word.
- Comment on the code, not the person. Ask questions instead of asserting when unsure of intent.
- Say what is good when it is: a clean test, a smart simplification.
- Group repeated issues into one comment ("same in 4 places: ...").
- Do not bury the one blocking comment among twenty nits; if there are many nits, mention a few and say "similar elsewhere".

**6. Disagreement.**
- Try to settle it with the standard above. If the author shows the alternative is equally sound, accept it. If stuck, escalate to the user with both options; do not stall the change on taste.

**7. Minimal change.**
- The diff does only what the task needs. Expect the smallest change that fixes the root cause, made at the shared place (one fix in the helper beats a patch in each caller); `grep` the callers to check the author did not patch only the reported path.
- Reject drive-by renames, reformatting, moved code and "while I was here" refactors mixed into the same commit. Say so as scope creep and ask for a split.
- Unrelated cleanups are welcome in their own commit or PR, so the fix can be reviewed and reverted alone.

## Pitfalls
- Reviewing only the diff hunks: the bug is often in the unchanged caller or in a deleted line.
- Rubber-stamping because the author is a capable agent or the diff is large. Large diffs get the most skim-reading; request a split.
- Approving on "tests pass" when no test touches the changed lines.
- Perfectionism: holding a clear improvement hostage for style or personal design preference.
- Treating nits as blockers, or blockers as nits (a missing auth check labelled "Nit").
- Reviewing your own work in the same pass that wrote it; use a separate reviewer context.
- Scope creep accepted silently because each piece "looks fine".

## Verify
- `git diff main...HEAD --stat` matches the stated scope.
- Run the project's test command, type-checker and linter; read the whole output, including failures and warnings. If none are configured, say so.
- For a fix, reproduce the bug before and confirm it is gone after.
- End the review with a verdict: **Approve**, **Approve with nits**, or **Changes requested** plus the list of blocking items, and what you ran to check.
