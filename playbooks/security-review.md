# Security Review

> Sources: [Trail of Bits skills: differential-review, audit-context-building](https://github.com/trailofbits/skills) (CC-BY-SA-4.0, paraphrased), [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org) (CC-BY-SA, paraphrased), [OWASP ASVS](https://github.com/OWASP/ASVS) (CC-BY-SA, paraphrased), [awesome-copilot security-and-owasp](https://github.com/github/awesome-copilot) (MIT), agency-agents security-ai-generated-code-auditor (MIT, paraphrased) · Written 2026-10-20 · Applies to: any web/API stack · This file is CC BY-SA 4.0 (it adapts CC BY-SA material)

**Use when:** reviewing a diff or feature for security (checker in "security review" mode), or building anything that touches auth, payments, permissions, secrets or user data. For general quality review use `code-review.md`; for endpoint shape use `api-design.md`.

## Before you start
- Build context before judging lines. Write down: entry points (routes, handlers, jobs, webhooks, CLI), trust boundaries (browser, server, DB, third-party), and who may call each one (anonymous, user, admin, service).
- Read the whole function and its callers, not only the changed hunk. Trace one request from entry to storage and back.
- Rank each changed file by what it can break, not by diff size. Top tier: login, sessions, tokens, crypto, payments or balances, permission checks, outbound calls, any deleted validation. Middle: domain rules, writes to stored state, newly reachable endpoints. Bottom: docs, tests, styling. A two-line change or a "pure refactor" in the top tier still gets the full read.
- Count callers of any changed shared helper (`grep -rn name`): that is the blast radius.
- If code was removed, check why (`git log -S`, `git blame`). Deleted checks and deleted tests of security code are findings until explained.
- Cheat sheets to open for the area at hand: [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html), [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html), [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html), [IDOR](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html), [SQL Injection](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html), [SSRF](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html), [XSS](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html), [CSRF](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html), [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html), [Logging](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html).

## Rules
**1. Authentication and sessions**
- Passwords hashed with Argon2id or bcrypt; never a fast hash. Login, reset and OTP endpoints are rate limited.
- Session or token is rotated at login and privilege change, invalidated at logout, and has an expiry. Cookies: `HttpOnly; Secure; SameSite=Lax` (or Strict). No tokens in localStorage or URLs.
- JWT: verify with a pinned algorithm list, check `exp`, `aud`, `iss`. Never accept `alg: none`.
- Reset/magic links: single use, short-lived, random (CSPRNG), and the response must not reveal whether the account exists.

**2. Authorisation on every route and action**
- Every handler checks identity AND permission server-side. A hidden button or client guard is not a control.
- Every object lookup by id is scoped to the caller: `WHERE id = $1 AND owner_id = $2`, or a policy check after fetch. Bad: `db.order.findUnique({where:{id}})` then return it. Good: scope by `session.userId` or check ownership before returning.
- Check list/search/export/bulk/GraphQL/background-job paths too, not just the main read. Check each HTTP method separately.
- Mass assignment: whitelist writable fields; never spread the request body into a model update (`role`, `isAdmin`, `ownerId`, `price`).
- Roles and tenant ids come from the session, never from the request.
- Return 404 vs 403 consistently so existence does not leak where that matters.

**3. Input validation and injection**
- Validate at the trust boundary with a schema (type, length, range, enum). Reject, do not "clean".
- SQL: parameterised queries or the ORM's bound params only. Bad: `` `... WHERE name='${q}'` ``. Dynamic identifiers (column, sort order) come from an allow-list.
- Commands: no shell with user data; use `execFile`/argument arrays. Better: no subprocess.
- Paths: resolve, then verify the result stays inside the base directory; reject `..` and absolute paths after normalising.
- SSRF: for any server-side fetch of a user-supplied URL, allow-list hosts, resolve DNS and block private, loopback and link-local ranges (169.254.169.254), re-check after redirects, restrict schemes.
- XSS: rely on framework escaping; flag `dangerouslySetInnerHTML`, `innerHTML`, `v-html`, unescaped template output. Sanitise HTML with a maintained library if HTML must be accepted. Never put user data in `<script>` or `href="javascript:"`.
- Uploads: check size, type by content, store outside web root, random names.

**4. Secrets**
- No keys, tokens, connection strings or private hostnames in code, tests, fixtures, logs or client bundles. `NEXT_PUBLIC_*`/`VITE_*` variables are public.
- `.env` is git-ignored (`git check-ignore -v .env`). Scan the diff: `git diff origin/main..HEAD | grep -iE 'key|secret|token|passw|BEGIN .*PRIVATE'`.
- A secret that was ever committed is leaked: rotate it, do not just delete it.

**5. Errors, logging, headers**
- Clients get a generic message plus a correlation id; no stack traces, SQL errors, file paths or "user not found" vs "wrong password".
- Logs record security events (login failure, permission denied, money moves) but never passwords, tokens, full card numbers, or PII beyond ids.
- CORS: never `*` with credentials; origins from an allow-list. Set CSP, `X-Content-Type-Options: nosniff`, HSTS, frame protection.

**6. CSRF**
- State-changing requests authenticated by cookie need SameSite plus a CSRF token or origin check. GET must not change state. Bearer-header APIs are not CSRF-prone, cookie APIs are.

**7. Rate limiting and abuse**
- Limit auth, password reset, OTP, signup, search, expensive queries and anything that sends email/SMS. Cap request body size and page size.

**8. Races and replay on money and permission changes**
- Balance, stock, credit and role changes: do the check and the write in one transaction (`SELECT ... FOR UPDATE`, or one atomic `UPDATE ... WHERE balance >= $x`). Check-then-write in app code is a race.
- Payments and webhooks: idempotency key or unique constraint, verify the webhook signature on the raw body, check timestamp, ignore duplicates. Amounts and prices come from the server, never the client.

**9. Dependencies and supply chain**
- For each new or bumped package: need it at all, maintainer and age, typosquat check, install scripts, size. Lockfile committed and changed only as expected. No `latest` or `*`.
- Run `npm audit` / `pip-audit` / `cargo audit` and read results touching changed packages.

**10. AI-written code** (models often get these wrong; read it as untrusted)
- Checks that look present but never run: dead branches, validation or auth after the side effect, a result that is computed and ignored.
- Hard-coded secrets, test keys, example hosts or default passwords left in.
- Swallowed errors: empty `catch`, `|| true`, `except: pass`, a failure treated as success.
- Invented APIs, flags or config options that do not exist (check the docs or run it); a silently ignored option is no control.
- "Make it work" shortcuts: CORS `*`, disabled TLS verification, `chmod 777`, auth turned off.
- SQL or shell built by string concatenation; copy-pasted crypto (ECB, fixed IV, `Math.random` for tokens, home-made hashing).
- Tests that assert nothing or mock the thing under test: they pass while the control is missing.

## Pitfalls (rationalisations to reject)
- "It's behind login." Logged-in users attack each other (IDOR).
- "It's an internal endpoint." Internal becomes reachable via SSRF, misconfig, or a later refactor.
- "The frontend validates it." The attacker does not use your frontend.
- "The ORM prevents injection." Not in raw queries, `orderBy` from input, or JSON operators.
- "It's only a refactor / only a few lines." Refactors drop checks; read the removed lines.
- "Tests pass." Tests rarely cover the other user's id.
- "Low traffic, so a race won't happen." Attackers fire 50 parallel requests.
- Reporting what looks wrong without a path from attacker input to impact. Build the exploit story or lower the severity.
- Stating "no issues" without listing what was and was not examined.

## Verify
- State coverage: files read, files skipped, assumptions, confidence.
- Try the exploit where cheap, against a local or staging instance you control, never production: request another user's id, drop the auth header, replay a request, send two concurrent requests (`xargs -P`, `curl &`).
- Run the project's tests, type-check, linter and dependency audit.

## Output format
List findings highest first; one block each:
```
[HIGH] path/to/file.ts:42  Short title
Exploit: who does what, with which input, and what they gain.
Fix: the concrete change (code or approach).
```
Severity: CRITICAL (remote, no auth, data/money loss) · HIGH (auth'd user crosses a boundary) · MEDIUM (needs unusual conditions) · LOW (hardening). End with: coverage, what was not reviewed, and "no findings" only if the coverage list supports it.
