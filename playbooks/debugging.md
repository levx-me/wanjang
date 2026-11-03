# Debugging: finding the root cause

> Sources: [mattpocock/skills diagnosing-bugs](https://github.com/mattpocock/skills) (MIT), [obra/superpowers systematic-debugging](https://github.com/obra/superpowers) (MIT) · Written 2026-10-20 · Applies to: any

**Use when:** a bug, failing test, crash, wrong output, build failure or slowdown whose cause is not already known. For writing the regression test itself, also read `test-writing.md`.

## Before you start
- Get the user's exact symptom: error text, wrong value, steps, environment, first bad version or date. Quote it; later you must prove that this symptom is gone.
- Read `git log -p` / `git diff` for the area, recent dependency or config changes, and any project glossary or ADRs touching the module.
- Never paste secrets into your notes or output (see Rules, redaction).

## Rules

### 1. Build the feedback loop first
A fast command that goes red on this bug is worth more than any amount of code reading. Do not form theories before you have one. Pick the cheapest that reaches the bug:
1. A failing test at the seam that reaches it (unit, integration, e2e).
2. A `curl` script against a running dev server.
3. A CLI call with a fixture input, diffed against a known-good output.
4. A headless browser script asserting on DOM, console or network.
5. Replay of a captured request, payload or event log through the code path in isolation.
6. A throwaway harness: one service or function with dependencies stubbed.
7. A fuzz or property loop (1000 random inputs) for "sometimes wrong".
8. A bisect harness: "build at state X, check, report" so `git bisect run` can drive it.
9. A differential run: same input through old vs new version (or two configs), diff the outputs.
10. A scripted human step, last resort; make the human's output feed back to you.

Then tighten it: faster (narrow scope, cache setup), sharper (assert the specific symptom, not "did not crash"), more deterministic (pin time, seed RNG, freeze network, isolate the filesystem).

Intermittent bugs: aim for a higher reproduction rate, not a clean repro. Loop the trigger 100 times, add parallel load, widen the race with sleeps. 50% is debuggable; 1% is not.

If you truly cannot build a loop, stop and report what you tried, and ask for access to the failing environment, a redacted artifact (HAR, log, core dump) or permission for temporary instrumentation. Do not guess.

Loop is done when one named command: has been run once (show the output), asserts the user's exact symptom, gives the same verdict every run, and finishes in seconds without a human.

### 2. Reproduce, then minimise
- Confirm the loop shows the user's failure, not a neighbouring one. Wrong bug means wrong fix.
- Cut inputs, callers, config and steps one at a time, re-running after each cut. Stop when removing any remaining element turns it green. This is also your regression test.

### 3. Read the evidence
- Read the full error and stack trace: file, line, code, the first error rather than the last cascade. Read the logs around the timestamp.
- Check what changed: `git log --since`, lockfile diff, env/config diff, deploy time.
- `git bisect` when it worked at a known commit: `git bisect start BAD GOOD && git bisect run ./loop.sh` (script exit codes: 0 good; 1-127 except 125 bad; 125 skip this commit, e.g. it does not build; 128+ aborts the bisect, so make crashes exit 1, not via a signal). Finish with `git bisect reset`.

### 4. Hypothesise, one at a time
- Write 3-5 ranked, falsifiable guesses: "if X is the cause, changing Y makes it vanish". If you cannot state the prediction, sharpen or drop it. Show the list to the user when they are around; they often know which are already ruled out.
- Compare with similar working code in the repo; list every difference, however small.
- Test the top one with the smallest change. Change one variable per run. If it fails, revert it before trying the next; do not stack fixes.

### 5. Instrument at component boundaries
When data crosses layers (CI to build to script, API to service to DB), log what enters and leaves each layer in one run and see which hop is wrong, then dig only there.
- Prefer a debugger or REPL (one breakpoint beats ten logs); otherwise targeted logs. Never "log everything and grep".
- Tag every temporary log with a unique prefix such as `[DEBUG-a4f2]` so cleanup is one grep.
- For env/secrets, log SET/UNSET or length, not the value.
- Performance: measure a baseline first (profiler, query plan, timing harness), then bisect the cost. Logs mislead here.
- Deep in a call stack: trace the bad value backwards, caller by caller, to where it first went wrong.

### 6. Fix the cause, then lock it
- Before editing, grep every caller of the function you will touch. If the defect is in shared code, fix it there once; patching only the reported call site leaves siblings broken.
- No bundled refactors or "while I'm here" edits.
- Turn the minimised repro into a failing test at a seam that exercises the real bug pattern (not a shallower unit that cannot fail the same way). Watch it fail for the right reason, fix, watch it pass, re-run the original loop on the un-minimised scenario. If no honest seam exists, say so: that is a finding about the design.
- Put the confirmed hypothesis in the commit message.

### 7. Redact
Any command output, HAR, log or header you quote may carry tokens, cookies, connection strings or PII. Replace with `<REDACTED>`, drive loops from env vars, and quote only the signal lines.

### 8. Know when to stop
After three failed fix attempts, or when each fix exposes new coupling elsewhere, stop patching. The design may be wrong; report the evidence and options to the caller rather than trying a fourth. Likewise stop and report when the cause is external (vendor, infra) with what you proved. Say "I do not understand X yet" rather than guessing.

## Pitfalls
- **Wrong bug reproduced:** the repro fails, but with a different message. Compare it to the report literally.
- **Loop that cannot go red:** passes before and after. Prove it fails on the broken code (revert the fix and run it).
- **Forced red by mutation:** if you broke code to see red, `diff` against a pristine copy to be sure the mutation landed.
- **Symptom guards:** a null check or retry at the crash site hides a bad value produced upstream.
- **Stacked changes:** three edits at once, bug disappears, nobody knows which one worked.
- **Leftover instrumentation:** tagged logs, sleeps, committed `.only`.
- **Heisenbugs vanishing under logging:** suspect timing or races; use a debugger, a counter or a ring buffer instead of I/O.

## Verify
- The Phase 1 loop (original scenario) passes now, and failed before.
- The regression test passes, and fails when the fix is reverted.
- Full relevant test suite, type-check and lint pass.
- `grep -rn "DEBUG-" .` finds no tagged leftovers; throwaway scripts removed.
- Callers of the changed shared function checked.
- Report: root cause, evidence, fix, test, anything not verified.
