# Writing tests: unit, integration, e2e

> Sources: [mattpocock/skills tdd](https://github.com/mattpocock/skills) (MIT), [anthropics/skills webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) (Apache-2.0), [Playwright docs](https://playwright.dev/docs/locators) (Apache-2.0, link only), Google [Testing Blog](https://testing.googleblog.com/) "Testing on the Toilet" series (link only) · Written 2026-10-20 · Applies to: any (examples use JS/TS/Python)

**Use when:** adding or fixing tests, doing test-first work, or hardening flaky ones. For finding a bug's cause use `debugging.md`; this file covers the test you leave behind.

## Before you start
- Find the project's runner and commands (`package.json` scripts, `pytest.ini`, `bun test`) and run the existing suite once to see the baseline and speed.
- Read two neighbouring tests and match their layout, naming, helpers and fixtures.
- For Playwright/Cypress/Vitest API details check the current official docs first: https://playwright.dev/docs/intro , https://vitest.dev/guide/ .

## Rules

### Seams and behaviour
1. Agree the seams before writing anything: the public boundaries (function, HTTP route, CLI command, component) you will test at. Write each seam down with one line: what it catches, what it misses. If the caller named seams, use those only.
2. Test behaviour through the public interface, never internals. A good test reads like a spec ("rejects a cart with no items") and survives a refactor. The smell: the test breaks on a rename or reshuffle with no behaviour change.
3. Verify through the interface, not a side channel. Bad: call `save()` then query the table directly. Good: call `save()` then `get()`.
4. Name tests by the behaviour and condition, not the method: `test_expired_token_is_rejected`, not `test_validate_2`.

### Values and assertions
5. Compute expected values independently of the code: a literal, a hand-worked example, the spec, a known-good fixture. Bad: `expect(total(items)).toBe(items.reduce((s,i)=>s+i.price,0))` (the same logic twice, it cannot disagree). Good: `expect(total([{price:300},{price:450}])).toBe(750)`.
6. Choose inputs that matter: boundaries, empty, one, many, unicode, negative, the case from the bug report. Use values distinct from each other so a swapped argument shows up (not `1, 1, 1`).
7. One reason to fail per test. Several asserts are fine if they describe one behaviour; two behaviours means two tests.
8. Assert the specific outcome, not "no error" or "truthy". Assert error type and message, not just that something threw.

### The loop
9. Red before green: write the failing test, watch it fail for the expected reason (read the failure message), then write the least code that passes. A test never seen red proves nothing.
10. Work in vertical slices: one test, one implementation, repeat. Writing all tests first tests imagined behaviour and locks in shape.
11. Refactor only with the suite green, as a separate step.

### Determinism
12. Inject or fake the clock (`vi.useFakeTimers()`, `freezegun`, a `now()` parameter), seed randomness, pin timezone and locale (`TZ=UTC`), generate unique ids rather than sharing them.
13. No real network in unit and integration tests; stub at the HTTP boundary or use a local fake server. No dependence on test order, shared files or leftover DB rows; each test creates and cleans its own state (per-test transaction or temp dir).
14. Never `sleep(n)` to wait. Wait for a condition: poll with a timeout, await the event, use the runner's auto-waiting.

### Fixtures and factories
15. Use a factory with sensible defaults and per-test overrides: `makeUser({role:'admin'})`. Keep the data that matters to the test visible in the test body; hide the rest in the factory. Prefer a little repetition to a clever shared fixture that hides what a test depends on.

### Mocking
16. Mock at system boundaries you do not own or cannot run cheaply: payment API, email, clock, other teams' services. Do not mock your own modules or the thing under test.
17. Prefer a real or in-memory implementation (SQLite/Postgres container, fake repository) over a mock that records calls. Asserting "called with X" tests wiring, not behaviour; use it only when the call is the behaviour (an email was sent).
18. A mock must match the real contract; check against a recorded real response or a contract test.

### Levels
19. Many fast unit tests for logic, fewer integration tests for wiring (DB, HTTP, queue), a handful of e2e for critical user journeys. Cover each risk at the cheapest level that catches it.

### e2e / browser
20. Select by role, label or test id, not CSS paths or text that marketing changes: `page.getByRole('button', {name:'Save'})`, `page.getByTestId('cart-total')`. Add a `data-testid` when no accessible handle exists.
21. Rely on auto-waiting and web-first assertions (`await expect(locator).toBeVisible()`). When driving a dynamic page by script, wait for a known element of the ready app before reading the DOM; `networkidle` is a fallback only (Playwright docs mark it discouraged, and it never settles on pages that poll).
22. Start servers through the runner's `webServer` config or a wrapper (e.g. the `scripts/with_server.py --server "npm run dev" --port 5173 -- python test.py` helper in anthropics/skills webapp-testing), headless, and always close the browser.
23. Seed data through API or DB, not through the UI; log in once and reuse the saved session state.
24. Capture screenshots, trace and console logs on failure only.

### Flaky tests
25. Reproduce first: run it 50-200 times (Playwright `--repeat-each=100`; pytest `--count=100` from the `pytest-repeat` plugin), in parallel and in a loaded shell. Then find the nondeterminism: time, ordering, shared state, async not awaited, port clashes, animations.
26. Fix the cause. Do not add retries or longer timeouts as the fix; a quarantine (skip with ticket link) is a stop-gap and must be reported.

### What not to test
Language and framework behaviour, trivial getters, private helpers directly (test them via the public path), generated code, exact log wording, pixel styling (unless visual regression is set up), and anything where the test would just restate the implementation.

## Pitfalls
- **Tautology:** expected value built by the same formula or copied from current output. Spot it by asking whether a bug in the code could make this test fail.
- **Over-mocking:** more mock setup than assertions; refactors break tests.
- **Shared mutable fixtures:** passes alone, fails in suite (or reverse). Run a single test and the full suite.
- **Snapshot dumping:** huge snapshots approved blindly. Snapshot small, meaningful output only and review diffs.
- **`.only` / `.skip` left in.**
- **Assertions in unawaited promises:** the test passes before the assertion runs. Await everything; in Jest/Vitest use `expect.assertions(n)` for async error paths.
- **Date/timezone bugs** appearing only near midnight, month ends, or on CI in another TZ.

## Verify
- Run the new tests alone, then the whole suite; read the full summary including skipped counts.
- Temporarily break the code (or revert the fix) and confirm the test fails with a clear message; `git diff` afterwards to confirm the break is gone.
- Run the new tests repeatedly (20+) and in random order if the runner supports it.
- Type-check and lint pass. No `.only`, no `console.log`, no sleeps.
- Further reading: the Google Testing Blog TotT series (https://testing.googleblog.com/) on test values, collaborators and prefactoring.

## Skeleton
```ts
test('rejects an expired token', () => {
  const token = makeToken({ expiresAt: '2026-01-01T00:00:00Z' }); // arrange: only what matters
  const result = verify(token, { now: new Date('2026-06-01T00:00:00Z') }); // act via public API
  expect(result).toEqual({ ok: false, reason: 'expired' }); // literal expectation
});
```
