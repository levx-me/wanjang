<div align="center">

# Wanjang

**A wanjang and its crew for Claude Code.**<br>
The wanjang plans and delegates; a planner, builder, designer, scout, QA tester and checker do the work, each on the model the task needs.

![license](https://img.shields.io/badge/license-MIT-blue)

</div>

## Features

- **Roles by permission and cost, not by field.** Seven agents cover nearly every project: what changes is the brief and the model, not the agent.
- **Model per task.** The wanjang picks Haiku, Sonnet or Opus for each worker call, and moves a failed task one tier up.
- **The wanjang never builds.** It plans, briefs and judges; a hook refuses file writes from its Bash, so fixes go to a worker.
- **Playbooks instead of a hundred agents.** Specialist know-how lives in Markdown playbooks that cost no context until the wanjang picks one for a brief.
- **Verified before it reports.** QA uses the running product like a user; the checker runs the build and tests and checks every requirement, the docs and the accessibility basics, with a security review for auth, payments and permissions.
- **On by default.** A session-start hook puts the routing rule in every session; `/wanjang:wanjang` forces a hand-over.
- **Survives a crash.** A run log, step commits and `/wanjang:wanjang resume` pick a stopped run up where it was.
- **Light on context.** Briefs and reports travel as files in the run folder; workers return a status line, fixes resume the same worker, and the main session keeps only what it needs.

## Quick start

```sh
claude plugin marketplace add ~/workspace/wanjang
claude plugin install wanjang@wanjang
```

Start a new session (or `/restart`). Ask for a feature as usual; multi-step work goes to the wanjang on its own. To hand something over explicitly:

```text
/wanjang:wanjang add refresh tokens to the auth middleware
```

## The crew

| Agent | Model | Writes code | Does |
|---|---|---|---|
| `wanjang:wanjang` | Sonnet, Opus when something must be found out first | no | Splits the work by layer, agrees the contract, briefs workers with playbooks, runs QA and the checker, reports once |
| `wanjang:planner` | Opus | no | Turns a vague request into a spec: goal, flow, scope, testable acceptance criteria, open questions |
| `wanjang:scout` | Haiku | no | Finds files, reads logs, queries data, runs tests and summarises |
| `wanjang:builder` | Haiku / Sonnet / Opus per call | yes | Server, data, tests, docs, fixes |
| `wanjang:designer` | Opus | yes | All user-facing UI, with states and accessibility |
| `wanjang:qa` | Sonnet | no | Uses the running product, reports bugs with steps to reproduce |
| `wanjang:checker` | Sonnet, Opus for a security review | no | Builds, tests and checks every requirement against the spec |

```mermaid
flowchart LR
  main[main session] -->|multi-step work| F[wanjang]
  main -->|lookups| S[scout]
  F -->|vague request| P[planner]
  F --> S
  F --> B[builder]
  F --> D[designer]
  B & D --> Q[qa]
  B & D --> C[checker]
  Q & C -->|blockers| F
  F -->|one summary| main
```

## When a run stops

A crash, a lost connection or a restart kills the wanjang and its workers mid-run. Three things keep the work:

- **Run folder.** Each run keeps its log (goal, contract, decisions, tasks, files touched, next), the briefs and the workers' reports in `.git/wanjang/<date>-<slug>/` (never committed), updated as workers start and return.
- **Step commits.** The builder and designer commit each step as soon as its checks pass, so a crash costs at most the step in hand.
- **Resume.** A new session in that repository is told about any run still `in progress`. `/wanjang:wanjang resume` hands it back to a wanjang, which checks the log against git, keeps what is done and carries on with the rest.

```text
/wanjang:wanjang resume
```

## Playbooks

A playbook is a Markdown file of know-how for one kind of work (a Postgres migration, Stripe webhooks, a security review). The wanjang reads the indexes when it splits work and names the playbooks that fit in a worker's brief:

1. `.claude/playbooks/INDEX.md` in the project (read first)
2. `~/.claude/playbooks/INDEX.md` for every project

```markdown
- [postgres-migration](postgres-migration.md) — schema changes on a live Postgres: locks, backfills, rollbacks
```

Add one when a kind of work keeps coming back. Nothing is loaded until it is picked.

## What is in the plugin

| Path | What |
|---|---|
| `agents/` | The seven agents |
| `ROUTING.md` | The routing rule a session-start hook adds to every session |
| `bin/route` | That hook; it also names any unfinished run in the repository |
| `bin/guard` | PreToolUse hook: the wanjang and the read-only crew write only into run folders (and temp dirs for the read-only crew) |
| `skills/wanjang/` | The `/wanjang:wanjang` command (and `/wanjang:optimize`) |
| `test/guard.sh` | Checks the guard on commands the wanjang might send |

```sh
test/guard.sh   # guard: all cases pass
```

## License

MIT
