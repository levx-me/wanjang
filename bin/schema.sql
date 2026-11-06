-- wanjang's one database, ${CLAUDE_CONFIG_DIR:-~/.claude}/wanjang/wanjang.db. Every reader runs this file on open
-- (it only creates what is missing): python `executescript`, shell `sqlite3 "$db" < schema.sql`.
-- steps: every finished step of every agent, derived from the transcripts' TaskCreate/TaskUpdate calls (bin/status --eta)
CREATE TABLE IF NOT EXISTS transcripts(path TEXT PRIMARY KEY, mtime REAL, size INT);
CREATE TABLE IF NOT EXISTS steps(path TEXT, agent_type TEXT, model TEXT, tag TEXT, minutes REAL, t0 REAL, t1 REAL);
CREATE INDEX IF NOT EXISTS steps_group ON steps(agent_type, model, tag);
CREATE INDEX IF NOT EXISTS steps_path ON steps(path);
-- eta_cache: the minutes finished agents took, by type and model ("*" = every model); built = when it was written
CREATE TABLE IF NOT EXISTS eta_cache(agent_type TEXT, model TEXT, minutes REAL, built REAL);
-- eta_held: each running agent's first estimate, kept until it passes or its step/task counts change
CREATE TABLE IF NOT EXISTS eta_held(agent_id TEXT PRIMARY KEY, likely REAL, key TEXT, seen REAL, e TEXT);
-- meta: one-time flags (an import of an old file already done)
CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT);
-- crew_runs: one row per bin/crew-run process, written at its start and on every exit (the runs/<session>.json record
-- is still written beside it, a consumer such as the deck reads that); updated = epoch seconds of the last write
CREATE TABLE IF NOT EXISTS crew_runs(session_id TEXT PRIMARY KEY, parent_session_id TEXT, agent TEXT, model TEXT, effort TEXT,
  title TEXT, cwd TEXT, pid INT, started INT, status TEXT, cost_usd REAL, exit INT, ended INT, log TEXT, updated REAL);
CREATE INDEX IF NOT EXISTS crew_runs_parent ON crew_runs(parent_session_id);
-- ledger: the manager's event log (bin/manager), one JSON event per row in write order; the transaction that
-- `lock()` opens (BEGIN IMMEDIATE) is the manager's lock for the ledger and state.json
CREATE TABLE IF NOT EXISTS ledger(seq INTEGER PRIMARY KEY AUTOINCREMENT, t TEXT, ev TEXT, id TEXT, data TEXT);
CREATE INDEX IF NOT EXISTS ledger_id ON ledger(id);
