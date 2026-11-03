# Postgres Migration (zero-downtime schema changes)

> Sources: [strong_migrations](https://github.com/ankane/strong_migrations) (MIT), [Squawk rules](https://squawkhq.com/docs/rules) (Apache-2.0), [supabase/agent-skills postgres references](https://github.com/supabase/agent-skills) (MIT), [PostgreSQL docs: explicit locking, ALTER TABLE, release notes](https://www.postgresql.org/docs/current/explicit-locking.html) (PostgreSQL Licence), [supabase/cli#2898](https://github.com/supabase/cli/issues/2898) (MIT repo) · Written 2026-10-20 · Applies to: PostgreSQL 11+ (notes where 12/15+ matter)

**Use when:** changing the schema of a Postgres database that serves live traffic (add/alter/drop columns, indexes, constraints, renames, backfills). For designing tables or queries from scratch use `postgres-schema-query.md`; for the release order of code vs migration use `deploy-config.md`.

## Before you start
- Find the migration tool and its folder (`supabase/migrations/`, `prisma/migrations`, `db/migrate`, Flyway, etc.) and whether it wraps each file in a transaction. This decides how you write concurrent index builds.
- Find the table size and write rate (`select reltuples::bigint from pg_class where relname='t'`). A change that is fine on 1k rows can lock a 100M-row table for minutes.
- Confirm the target database URL yourself. Never run a migration against a database you did not choose.
- Check the Postgres major version (`select version()`); several fast paths below depend on it.
- Run the migration on a copy with production-like data size first, with `\timing` on.

## Rules

### 1. Locks and timeouts (every migration)
The danger is not only a long lock but a lock that waits: an `ACCESS EXCLUSIVE` request queues behind a long-running query, and every later query on the table queues behind it. Reads stop too.
```sql
SET lock_timeout = '5s';          -- give up quickly instead of queueing the app
SET statement_timeout = '15min';  -- generous; migrations may legitimately run long
```
- Set `lock_timeout` low on every migration session. On a pooler in transaction mode, session `SET` may not stick: set it on the migration role instead (`ALTER ROLE migrator SET lock_timeout = '5s'`).
- On a lock timeout, retry later (or retry in a loop outside any transaction). Do not raise the timeout.
- Check for long transactions before an `ACCESS EXCLUSIVE` change: `select pid, now()-xact_start, query from pg_stat_activity where state <> 'idle' order by 2 desc`.
- Keep the migration transaction short: do the DDL, commit. Never mix DDL and a long backfill in one transaction.

### 2. Lock level cheat-sheet
| Statement | Lock | Effect |
|---|---|---|
| `CREATE INDEX` | SHARE | blocks writes |
| `CREATE INDEX CONCURRENTLY`, `REINDEX CONCURRENTLY` | SHARE UPDATE EXCLUSIVE | reads and writes continue |
| `ADD FOREIGN KEY` (validating) | SHARE ROW EXCLUSIVE on both tables, scans table | blocks writes to both tables |
| `ADD CHECK` (validating) | ACCESS EXCLUSIVE, scans table | blocks reads and writes |
| `... NOT VALID` then `VALIDATE CONSTRAINT` | brief lock, then SHARE UPDATE EXCLUSIVE (for validate) | writes continue during the scan |
| `ALTER COLUMN TYPE` (rewrite) | ACCESS EXCLUSIVE | blocks reads and writes for the rewrite |
| `SET NOT NULL` | ACCESS EXCLUSIVE, full scan | blocks everything during the scan |
| `DROP COLUMN`, `RENAME` | ACCESS EXCLUSIVE (instant) | instant, but breaks running app code |

Look up unlisted statements in the "Explicit Locking" page; the docs do not list every `ALTER TABLE` form, so test on a copy.

### 3. Indexes
- Always `CREATE INDEX CONCURRENTLY` (and `DROP INDEX CONCURRENTLY`) on tables that already exist and have traffic.
- It cannot run inside a transaction block. If your tool wraps migrations in a transaction, use the tool's opt-out (Rails `disable_ddl_transaction!`, Flyway `executeInTransaction=false`, a separate non-transactional step) and keep that statement alone in its file.
- A failed or timed-out concurrent build leaves an INVALID index. Find it (`select indexrelid::regclass from pg_index where not indisvalid`), drop it, rerun. Use `IF NOT EXISTS` only after checking it is valid.
- New unique constraint: build `CREATE UNIQUE INDEX CONCURRENTLY i ON t(c)`, then `ALTER TABLE t ADD CONSTRAINT u UNIQUE USING INDEX i`.
- Indexes on a table created in the same migration need no CONCURRENTLY.

### 4. Constraints and NOT NULL
- Foreign key / check: add `NOT VALID` first (instant, enforces new rows), then `VALIDATE CONSTRAINT` in a later migration.
```sql
ALTER TABLE orders ADD CONSTRAINT orders_user_fk FOREIGN KEY (user_id) REFERENCES users(id) NOT VALID;
ALTER TABLE orders VALIDATE CONSTRAINT orders_user_fk;
```
- Index the referencing FK column (concurrently); Postgres does not do it for you.
- `SET NOT NULL` on a big table: add `CHECK (col IS NOT NULL) NOT VALID`, `VALIDATE` it, then `ALTER COLUMN col SET NOT NULL` (PG 12+ reuses the validated check and skips the scan), then drop the check.
- PG 18+: a `NOT NULL` constraint can itself be added `NOT VALID` and validated later.
- Exclusion constraints cannot be `NOT VALID` (only FK, CHECK and, on 18+, NOT NULL can); there is no zero-downtime path, schedule a window.

### 5. Defaults and new columns
- PG 11+: `ADD COLUMN c type DEFAULT <constant>` is instant. Volatile defaults (`gen_random_uuid()`, `clock_timestamp()`) rewrite the table: add the column with no default, set the default for new rows, backfill old rows in batches.
- `serial`/`bigserial`/identity added to an existing table rewrites it. Create the column plain, then add a sequence/identity and backfill.
- Stored generated columns rewrite the table. Use a normal column plus trigger, or on PG 18+ a virtual generated column (the 18+ default), which is computed on read and needs no rewrite.
- Adding `NOT NULL` with a constant default in one statement is fast on PG 11+; adding `NOT NULL` without a default to a populated table fails.

### 6. Column type change, rename, drop: expand / contract
Never `ALTER COLUMN TYPE` or `RENAME` a column/table the running app uses. Do it over several deploys:
1. Expand: add the new column (nullable, no default or constant default).
2. Dual-write: deploy code that writes both (or add a trigger).
3. Backfill old rows in batches (rule 7).
4. Switch reads to the new column; deploy.
5. Stop writing the old column; deploy.
6. Contract: drop the old column in its own later migration, after no running code reads it.
- Rewrite-free type changes exist (e.g. `varchar(n)` to larger n or to `text`, `numeric` precision increase at same scale, `timestamp` to `timestamptz` when the session zone is UTC on PG 12+). Verify on a copy with `select relfilenode` before and after: unchanged means no rewrite.
- ORMs cache columns: stop the app using a column (ignored-columns setting or equivalent) and deploy before dropping it.
- Enum value renames: `ALTER TYPE ... RENAME VALUE` is instant but breaks code still sending the old label; add the new value, migrate data, switch code. Enum values cannot be removed.

### 7. Backfills
- Batch by primary key range, 1k to 10k rows per batch, commit each batch, sleep a few ms between batches, run outside the DDL transaction.
```sql
UPDATE t SET new_col = old_col
WHERE id > $last AND id <= $last + 5000 AND new_col IS NULL;
```
- Make it resumable and idempotent (`WHERE new_col IS NULL`). Watch replication lag and dead tuples; `VACUUM (ANALYZE)` afterwards.
- Keep backfills out of the schema migration file when the table is large; run them as a job or separate step.

### 8. Rollbacks
- Write the down path before applying. Expand steps are reversible by dropping the new column; contract steps (drop column/table) are not: take a backup or keep the data in a renamed holding table first.
- Prefer rolling forward with a fix. Do not rely on transactional DDL to save you after a deploy has already used the change.
- Dropping a table/column: confirm zero usage first (`pg_stat_user_tables`, grep, app logs), then drop in a separate migration from the code removal.

### 9. Supabase migration files
- Files live in `supabase/migrations/<timestamp>_<name>.sql`. Create with `supabase migration new <name>`; generate from local changes with `supabase db diff -f <name>`; apply to remote with `supabase db push`. Never edit a migration already applied to a shared environment; add a new one.
- The CLI applies each migration file as one transaction/pipeline (maintainer statement in supabase/cli#2898). A file holding exactly one `CREATE INDEX CONCURRENTLY` and nothing else applies; a second concurrent build or any other statement in the same file fails with `cannot be executed within a pipeline (SQLSTATE 25001)`. So: one concurrent index per file, nothing else in it. Behaviour has changed between CLI versions (check https://supabase.com/docs/guides/deployment/database-migrations); if it still fails, run that statement through psql and record it with `supabase migration repair --status applied <version>`.
- New tables in exposed schemas need RLS enabled in the same migration (see `postgres-schema-query.md`).
- Review `db diff` output by hand; it can emit drops and rewrites.

## Pitfalls
- Lock queue pile-up: a harmless-looking `ALTER TABLE` waits behind one slow report query and takes the app down. Cure: `lock_timeout`.
- `ADD COLUMN ... DEFAULT random()/uuid` on a big table rewrites it under ACCESS EXCLUSIVE.
- `CREATE INDEX CONCURRENTLY` inside the tool's default transaction fails at deploy time, not in review. Test the real runner.
- Adding an FK or CHECK without `NOT VALID` blocks writes while it scans.
- Backfill and DDL in the same transaction keeps the table locked for the whole backfill.
- Migration and code deploy ordering: expand migrations run before the new code; contract migrations run after the old code is gone.
- Dropping a column the old app version still selects causes errors during the rolling deploy.
- Pooler in transaction mode silently drops session-level `SET lock_timeout`.

## Verify
- Run the migration against a restored copy of production-size data; record duration and max lock time.
- Squawk lint (offline, no DB): `npx squawk-cli migrations/*.sql`, or install with `npm i -g squawk-cli` / `pip install squawk-cli` and run `squawk migrations/*.sql`. Treat its warnings as blocking unless you can justify them.
- During apply, watch `select * from pg_locks l join pg_stat_activity a using(pid) where not granted`.
- After: `select indexrelid::regclass from pg_index where not indisvalid;` returns nothing; `select conname, convalidated from pg_constraint where not convalidated;` is empty once validation migrations ran.
- Run the app test suite against the migrated schema and against the previous app version (rolling deploy compatibility).
