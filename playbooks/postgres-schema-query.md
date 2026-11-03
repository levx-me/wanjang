# Postgres Schema and Query Design

> Sources: [supabase/agent-skills postgres references](https://github.com/supabase/agent-skills) (MIT), [wshobson/agents postgresql-table-design](https://github.com/wshobson/agents) (MIT), [Postgres wiki "Don't Do This"](https://wiki.postgresql.org/wiki/Don%27t_Do_This) (no licence stated, paraphrased only), [PostgreSQL docs and release notes](https://www.postgresql.org/docs/current/) (PostgreSQL Licence), [Supabase RLS docs](https://supabase.com/docs/guides/database/postgres/row-level-security) · Written 2026-10-20 · Applies to: PostgreSQL 14+ (notes for 15/17/18)

**Use when:** designing new tables, choosing types/keys/indexes/constraints, writing or tuning queries, setting up RLS policies, queues or connection pooling. For changing a live schema safely use `postgres-migration.md`.

## Before you start
- Read the existing schema (`\d+ table`, the migrations folder) and match its naming and key style before adding anything.
- Check the Postgres version (`select version()`): `NULLS NOT DISTINCT` is PG15+, `uuidv7()` is PG18+, `MERGE` PG15+.
- Know the real query shapes (which columns are filtered, joined, sorted). Index for those, not in the abstract.
- Postgres docs entry points: https://www.postgresql.org/docs/current/datatype.html, /indexes.html, /ddl-rowsecurity.html.

## Rules

### Types
| Use | Not | Why |
|---|---|---|
| `timestamptz` | `timestamp`, `timetz` | plain `timestamp` has no zone, so arithmetic across DST/zones is wrong; store instants |
| `text` (+ `CHECK (length(c) <= n)` if a limit is real) | `varchar(n)`, `char(n)` | no speed benefit, limits cause later insert errors, `char` pads |
| `numeric(p,s)` (or integer minor units) | `money`, `float` | exact arithmetic, no locale dependence |
| `bigint generated always as identity` | `serial`, `int` ids | identity is standard and has cleaner ownership/permissions; `int` overflows at 2.1B |
| `boolean not null` | `varchar` flags | |
| `jsonb` | `json` | `json` has no equality, breaks `DISTINCT`; use jsonb only for optional attributes |
| `timestamptz` without precision arg | `timestamptz(0)` | a precision argument rounds, so stored time can land in the future |
- UUID keys: only when ids are exposed or generated across systems. Prefer time-ordered (`uuidv7()` on PG18+, or the pg_uuidv7 extension); random v4 keys scatter inserts across the index on big tables.
- Enums: only for small stable sets. Otherwise `text` + `CHECK`, or a lookup table (enum values cannot be dropped).
- Names: lower_snake_case, unquoted. Mixed case forces quoting everywhere.
- Time ranges: use `>= start AND < end`, not `BETWEEN` (inclusive end double-counts boundaries). Use `now()` for transaction time, `clock_timestamp()` for wall clock.
- Anti-joins: `NOT EXISTS`, not `NOT IN` (a NULL in the list returns no rows).

### Constraints
- Put integrity in the database: `NOT NULL` wherever semantically required, `CHECK`, `UNIQUE`, FKs with explicit `ON DELETE`.
- `UNIQUE` allows many NULLs; use `UNIQUE NULLS NOT DISTINCT` (PG15+) if one NULL is the rule.
- `CHECK` passes on NULL; pair it with `NOT NULL`.
- No overlapping bookings: `EXCLUDE USING gist (room_id WITH =, during WITH &&)` (needs `btree_gist`).
- Case-insensitive unique email: `CREATE UNIQUE INDEX ON users (lower(email))`, queries must use `lower(email)`.
- Normalize to 3NF first; denormalize only for a measured read problem.

### Indexes
- Postgres does NOT index foreign key columns. Add an index on every FK column you join or delete through.
- Composite: equality columns first, range/sort column last; the index serves only a leftmost prefix. `(status, created_at)` serves `status=`, and `status= AND created_at>`, not `created_at>` alone.
- Partial for hot subsets: `CREATE INDEX ON jobs (created_at) WHERE status = 'pending'` (query must repeat the predicate).
- Covering: `CREATE INDEX ON t (a) INCLUDE (b, c)` for index-only scans.
- Expression: `(lower(email))`, `((attrs->>'theme'))`; the query must use the identical expression.
- GIN for jsonb containment/arrays/full-text, GiST for ranges/exclusion, BRIN for huge append-ordered tables.
- Each index slows writes and takes space: drop unused ones (`pg_stat_user_indexes.idx_scan = 0` over a long window). Counters are per server and reset with stats: check every replica, and never drop an index that backs a UNIQUE/PK constraint.
- Build on live tables with `CONCURRENTLY` (see migration playbook).

### Queries
- Diagnose with `EXPLAIN (ANALYZE, BUFFERS)` on realistic data. Read: Seq Scan on a big table, `Rows Removed by Filter` large, estimated vs actual rows far apart (run `ANALYZE`), `Sort Method: external merge` (work_mem). `EXPLAIN ANALYZE` executes the statement: wrap writes in `BEGIN; ... ROLLBACK;`.
- N+1: replace per-row queries with one `WHERE user_id = ANY($1::bigint[])` or a join. In ORMs use eager loading/`include`, and check the query log count per request.
- Pagination: keyset, not OFFSET.
```sql
SELECT * FROM products
WHERE (created_at, id) > ($1, $2)   -- last row of previous page
ORDER BY created_at, id LIMIT 20;   -- index on (created_at, id)
```
The sort must be total (add `id` as tie-break). Use OFFSET only for small bounded sets.
- Bulk work: multi-row `INSERT ... VALUES`, `INSERT ... ON CONFLICT DO UPDATE` for upserts, `COPY` for loads. Select only needed columns, not `select *`, in hot paths.
- Queues: claim with `FOR UPDATE SKIP LOCKED` in one statement.
```sql
UPDATE jobs SET status='processing', started_at=now()
WHERE id = (SELECT id FROM jobs WHERE status='pending'
            ORDER BY created_at LIMIT 1 FOR UPDATE SKIP LOCKED)
RETURNING *;
```
Add a partial index on pending rows, and a reaper for rows stuck in `processing`.
- Keep transactions short; never hold one open across an HTTP call or user wait. Lock rows in a consistent order to avoid deadlocks. Use advisory locks for app-level mutual exclusion.
- Avoid inheritance and rules: use native partitioning (consider only past ~100M rows with queries filtering on the key; unique keys must include the partition key) and triggers.

### Row-level security and privileges (Supabase and similar)
- Enable RLS on every table in an exposed schema; a table without policies and RLS off is readable by any API role with grants.
- Wrap auth functions in a scalar subquery so they are evaluated once, not per row:
```sql
-- bad:  using (auth.uid() = user_id)
-- good: using ((select auth.uid()) = user_id)
```
- Index every column a policy filters on (`user_id`, `tenant_id`). Specify `to authenticated` on policies; do not rely on defaults.
- `SECURITY DEFINER` runs with the owner's rights and bypasses RLS. If you must: put it in a non-exposed schema (e.g. `private`), `SET search_path = ''`, schema-qualify every object, check the caller's identity inside, and `REVOKE EXECUTE ... FROM PUBLIC, anon, authenticated` unless callers need it.
- Test policies with at least two different users and with `anon`; `service_role` and table owners bypass RLS, so tests as them prove nothing.
- Least privilege: the app connects as a role with only needed grants, never superuser; never `GRANT ALL`. Views run with owner rights unless `security_invoker = true` (PG15+).

### Connections
- Always use a pooler (PgBouncer, Supavisor, or the driver's pool) in front of Postgres; each connection costs memory. Size the app pool small; serverless functions need the pooler's transaction-mode URL.
- Transaction mode breaks session state: prepared statements (disable them or use protocol-level support), `SET` without `LOCAL`, temp tables, advisory session locks, `LISTEN`. Migrations use the direct/session connection.
- Set `statement_timeout`, `idle_in_transaction_session_timeout` on the app role.

## Pitfalls
- Missing FK index: slow joins and slow `DELETE` on the parent (full scan of children per row).
- Function call in an index/RLS expression that is not immutable or not matched by the query: index silently unused.
- `OFFSET 100000` pages that get slower each page.
- Gaps in identity values are normal; do not "fix" them or use them for counting.
- `timestamp` columns filled with UTC by convention: nothing enforces it.
- `NOT IN (subquery)` returning nothing because of one NULL.
- Leaving `EXPLAIN ANALYZE` on an `UPDATE/DELETE` outside a rolled-back transaction.
- RLS policy that joins other RLS-protected tables per row: move the lookup into a `security definer` function in a non-exposed schema and call it as `(select private.fn())` so it runs once per statement.

## Verify
- `EXPLAIN (ANALYZE, BUFFERS)` of each new hot query shows an index scan on the intended index with row estimates near actual.
- `\d+ table` shows FK indexes, constraints and RLS flag as intended.
- Supabase: run the security and performance advisors (`supabase db advisors`, or the dashboard Advisors page) and fix RLS and unindexed-FK findings.
- Policy tests pass for owner, other user, and anon.
- Type/lint checks of the app pass after regenerating DB types.
