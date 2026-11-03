# Deploy and Config for Web Apps and Services

> Sources: [The Twelve-Factor App](https://12factor.net) (CC-BY-4.0, repo heroku/12factor), [vercel-labs/agent-skills deploy-to-vercel](https://github.com/vercel-labs/agent-skills) (MIT), [Vercel docs](https://vercel.com/docs) (proprietary, linked only) · Written 2026-10-20 · Applies to: any host; Vercel details marked "check current docs"

**Use when:** setting up env vars and secrets, separating dev/preview/prod, deciding what runs at build vs run time, wiring a deploy pipeline, health checks, rollbacks. Schema changes themselves: `postgres-migration.md`.

## Before you start
- Read the project's `.env.example`, `.gitignore`, hosting config (`vercel.json`, Dockerfile, CI workflow) and how env vars are read in code.
- Confirm which environment you are deploying to and that you chose the target. Default to a preview/staging deploy; production only on explicit request. Ask before pushing.
- Vercel (check current docs first): https://vercel.com/docs/environment-variables , https://vercel.com/docs/instant-rollback , https://vercel.com/llms.txt .

## Rules

### Config and secrets
1. Anything that differs per deploy (URLs, credentials, hostnames, feature flags) is config: read it from environment variables, one variable per setting, not a committed per-environment file. Internal wiring that never varies stays in code.
2. Litmus test: the repo could be made public right now without leaking a credential. If not, move the value out and rotate it.
3. Commit `.env.example` with every name and a fake value (`example.com`); `.env*` real files are git-ignored. Check with `git check-ignore -v .env.local`.
4. Validate config at startup (a schema check) and fail fast with the variable name, not the value. Never provide a silent production default for a secret.
5. Never log secrets, full connection strings, tokens or request headers. Redact `Authorization` and cookies in logs and error reports.
6. Rotate on exposure: a secret that touched git history, a log, a chat or a client bundle is burned even if later deleted. Revoke first, then replace.
7. Least privilege: separate credentials per environment and per service (read-only where possible). Production credentials never go to local dev or preview.

### Client-side exposure
- Frameworks inline some variables into browser JS: Next.js `NEXT_PUBLIC_*`, Vite `VITE_*`, Expo `EXPO_PUBLIC_*`, Create React App `REACT_APP_*` (CRA is deprecated, but old apps still ship it; check each framework's current docs). Anything with these prefixes is public to every visitor and stays in old builds.
- Put only public identifiers there (Supabase URL and anon/publishable key, analytics id). Never service-role keys, DB URLs, private API keys, JWT secrets.
- Bad: `NEXT_PUBLIC_STRIPE_SECRET_KEY`. Good: `STRIPE_SECRET_KEY` read only in server code (route handlers, server actions), the browser calls your endpoint.
- Public values are baked at build time: changing them needs a rebuild/redeploy.
- Grep the built output for secrets before shipping: `grep -r "sk_live\|service_role" .next/static dist 2>/dev/null`.

### Environments and parity
- Keep dev, preview/staging and prod as similar as possible: same Postgres major version, same runtime version (pin Node in `engines`/`.nvmrc`), same backing-service types. No SQLite in dev with Postgres in prod.
- Preview deployments use their own database/project and third-party sandbox keys, never production data.
- Name variables by meaning, not by environment (`DATABASE_URL`, not `PROD_DATABASE_URL`). The environment decides the value.
- Do not branch behavior on `NODE_ENV`-style names for config; use explicit variables.

### Build, release, run
- Build produces an artifact from a commit; release = artifact + that environment's config; run starts it. Do not edit code or install things at run time.
- Releases are immutable and have an id; rollback means re-pointing to a previous release, not rebuilding.
- Build must not need production secrets or a live production database. If a build needs data, give it a read-only or fixture source.
- Lockfile committed, installs reproducible (`npm ci`, `pnpm install --frozen-lockfile`). Run lint, typecheck and tests in CI before deploy.

### Processes and logs
- Run stateless, share-nothing processes. Anything that must survive a restart (sessions, uploads, queues, caches) goes to a backing service (Postgres, Redis, object storage), not local disk or memory. On serverless, local disk is ephemeral and instances are not sticky.
- Write logs to stdout/stderr as lines (JSON is fine); never manage log files in the app. The platform collects them.
- Handle SIGTERM: stop accepting work, finish in-flight requests, exit. Bind to the `PORT` the platform gives.
- Run one-off tasks (migrations, console, seed scripts) as separate processes from the same release and config, not inside web start-up.

### Migrations in the release
- Migration is its own release step, not part of app start. Order: expand migration, deploy new code, contract migration later. Old and new app versions must both work with the schema during the rollout.
- A failed migration blocks the deploy; do not auto-roll-forward code against a half-migrated schema.
- Code rollback does not undo a migration. Design migrations to be backward compatible so rollback of code is safe.

### Health checks and rollback
- Provide a cheap liveness endpoint (process up) and a readiness endpoint (can reach DB and required services) that returns non-200 on failure. Do not put slow or auth-gated checks in liveness.
- After deploy, smoke-test the real URL: health endpoint, one authenticated page, one write path. Do this with the deploy tool's own URL output, not guesses.
- Know the rollback command before deploying and note the previous release id. Verify in CI/CD logs that a deploy is "ready", not just "queued", before claiming success.

### Vercel specifics (check current docs first)
- Git push to a linked project is the preferred path: non-production branches get preview deployments, the production branch gets production. Ask the user before committing/pushing.
- Env var changes apply only to new deployments; redeploy after changing them. Scope each variable to Production / Preview / Development; pull dev values with `vercel env pull`. Store credentials as the Secret type (formerly "Sensitive"), which cannot be read back after saving; Config type stays readable.
- Total env size limit is 64 KB per deployment (5 KB per variable on the edge runtime), per the docs at time of writing.
- CLI deploy of a linked project: `vercel deploy -y --no-wait` (preview), then `vercel inspect <url>`. `--prod` only when explicitly asked. Do not run `vercel link`, `vercel ls` or `vercel project inspect` in an unlinked directory; they prompt or link as a side effect. `vercel whoami` is safe anywhere. With several teams, pass `--scope <team>`.
- Instant Rollback (`vercel rollback [url]` or dashboard) re-points production domains to an earlier production deployment; it does not revert env vars or the database. Hobby can only roll back to the immediately previous deployment. Afterwards new pushes to the production branch do not go live until you promote a deployment (`vercel promote <url>`).
- Preview deployments can be protected (deployment protection / SSO); do not assume a preview URL is public to testers or webhooks.

## Pitfalls
- Secret in `NEXT_PUBLIC_*` or any prefix the bundler inlines.
- `.env` committed once then "removed": it lives in history. Rotate.
- Preview deployment pointing at the production database, or sending real emails/payments.
- Env var edited in the dashboard but not redeployed: running deployment still has the old value.
- Build step that queries the DB, so builds fail when the DB is down or leak data into static pages.
- Migration run on app boot with N instances starting at once.
- Logging whole `process.env`, config objects, or request bodies containing tokens.
- Different Node/Postgres versions between local and prod.
- Treating rollback as undo for data changes.

## Verify
- `git diff` and `git log -p` (or `git show HEAD`) contain no keys, tokens, real hostnames or connection strings before any push.
- `git check-ignore -v .env .env.local` shows they are ignored; `.env.example` lists every variable the code reads (`grep -rn "process.env\." src`).
- Production build output contains no secret strings (grep above).
- App starts with only the documented variables and fails with a clear message when one is missing.
- Deploy status is ready, health/readiness endpoint returns 200 on the new release, a smoke path works, and the rollback target is known.
