# CLI design for people and agents

> Sources: [clig.dev Command Line Interface Guidelines](https://clig.dev) (CC-BY-SA 4.0, paraphrased only), [no-color.org](https://no-color.org) (link only), the user's own `~/.claude/rules/cli-checklist.md` · Written 2026-10-20 · Applies to: any language; examples in shell · This file is CC BY-SA 4.0 (it adapts CC BY-SA material)

**Use when:** creating or changing a command-line tool, its flags, output, errors or config. A tool that scripts or AI agents will call needs the machine-facing parts (JSON, exit codes, no prompts) as much as a good human experience.

## Before you start
- Check how the project's existing commands name flags, format output and exit; match them before applying anything below.
- Pick the arg parser the project already uses (commander, clap, cobra, argparse, click); do not hand-roll parsing.
- List who calls it: a human in a terminal, a shell script, an agent, CI. Each needs something different from the same command.

## Rules

### Help
1. `-h` and `--help` work on every command and subcommand, anywhere on the line, and only mean help.
2. Missing required input prints a short usage (one-line purpose, one or two examples, pointer to `--help`) to stderr, not a stack trace.
3. Full help leads with examples, lists common flags first, and shows defaults and env var names. A `--help` without a real example is unfinished.
4. Offer a suggestion on a likely typo ("did you mean `deploy`?") but do not run it.

### Arguments and flags
5. Prefer flags to positional args beyond one obvious primary argument (a file, a name). Every flag has a long form (`--output`); short forms only for the common ones, using conventional letters (`-v`, `-q`, `-o`, `-f`, `-n`).
6. Standard names: `--help`, `--version`, `--json`, `--quiet`, `--verbose`, `--dry-run`, `--yes`/`--force`, `--no-color`, `--output`.
7. Accept `-` for stdin/stdout and several file args where it makes sense. Flag order must not matter.
8. Never take secrets as a flag value (shows in `ps` and shell history). Read them from a file, stdin or a credential store.
9. Validate everything up front, before changing anything.

### Output
10. stdout carries the result (and only the result); stderr carries progress, warnings, errors and chatter. So `tool list --json | jq` always works.
11. `--json` gives stable, documented structure with consistent field names and types across commands (same `id`, `created_at` everywhere). Print nothing else to stdout in that mode. Keep a `--plain` line-oriented form if tables are the human default.
12. `--quiet` prints only the bare value (an id, a path) for piping; success otherwise is brief, but state changes are confirmed in a line.
13. Detect the terminal: only colour, spinners, tables and prompts when stdout/stderr `isatty`. Disable colour when `NO_COLOR` is present and non-empty, whatever its value (no-color.org; an empty `NO_COLOR=` does not count), `TERM=dumb`, or `--no-color`.
14. Slow work (over about a second) shows progress on stderr; non-TTY gets plain periodic lines or nothing, never carriage-return animation into logs.
15. Do not page output unless interactive.

### Exit codes
16. `0` success only; never exit 0 after printing an error. Beyond that there is no universal standard, so pick a small table, document it in help, and keep it stable. A suggested convention: `1` general failure, `2` bad usage (Bash builtins and most parsers use 2), `3` not found, `4` conflict, `5` auth, `130` interrupted (128 + SIGINT 2). Keep custom codes below 126: shells use 126/127 for "cannot execute"/"not found" and 128+N for death by signal N. If the project already follows BSD `sysexits.h` (64 usage, 69 unavailable, 75 temporary failure, 77 permission), use that instead.

### Errors
17. Error messages say what failed, why, and what to do: `error: cannot open config.toml: permission denied. Run chmod u+r config.toml or pass --config`. Give a stable error code in JSON mode (`{"error":{"code":"E_NOT_FOUND","message":"..."}}` on stderr or per-contract). Put the key sentence last where long output precedes it.
18. Expected errors get friendly text; a traceback appears only for bugs, ideally written to a log file with a hint on how to report.

### Interactivity and safety
19. Prompt only when stdin is a TTY, and every prompt has a flag equivalent. `--no-input` (or no TTY) means fail with instructions instead of waiting.
20. Scale confirmation to danger: mild, none; destructive, a y/N prompt; severe, type the resource name. `--yes` skips it; `--force` for overriding safeguards.
21. Destructive or remote-changing commands have `--dry-run` that prints exactly what would happen and changes nothing.
22. Make mutating commands idempotent ("create" of an existing identical thing succeeds, a different one reports a clear conflict). Safe to retry after a crash or timeout.
23. Offer batch forms for bulk work (multiple args, `--from-file`, stdin lines) instead of forcing a loop.

### Structure
24. Consistent hierarchy, noun then verb: `tool job list`, `tool job delete ID`. Same flag does the same thing in every subcommand. Avoid near-synonym names (`update` vs `upgrade`) and a catch-all default subcommand or free abbreviations, which block adding commands later.

### Configuration
25. Precedence, highest first: flags, environment variables, project config file, user config (XDG: `$XDG_CONFIG_HOME/tool/`, default `~/.config/tool/`), system defaults. Document it, and make a `config show` that reveals where each value came from.
26. Env vars: uppercase `TOOL_` prefix, one line values; honour standard ones (`NO_COLOR`, `HTTP_PROXY`, `TMPDIR`, `EDITOR`). Do not edit other tools' config files without asking.

### Robustness
27. Network calls have timeouts. Respond quickly (print something within ~100 ms).
28. Ctrl-C (SIGINT) exits promptly with code 130 after bounded cleanup; a second Ctrl-C forces quit. Handle SIGTERM likewise. Assume the previous run died mid-way: leftovers (lock files, temp output) must not break the next run; write files atomically (temp then rename).
29. Compatibility: add, do not change. Flags and JSON fields are public API; deprecate with a stderr warning for a release or two, then remove. Human output may change, `--json` and `--plain` may not.

## Pitfalls
- **Logging to stdout** breaks pipes and `--json` consumers. Test: `tool cmd >/dev/null` should still show messages.
- **Prompt in CI hangs forever.** Run it with `< /dev/null` to check.
- **Exit code swallowed by a pipe or wrapper**; use `set -o pipefail` when testing.
- **ANSI codes in logs**: check `tool cmd | cat`.
- **Different JSON shape per command** or a bare string where a list is expected when there is one result.
- **Interactive-only features** (wizard, editor) with no flags.
- **Secrets in env echo or `--verbose` output**: redact.

## Verify
- `tool --help`, `tool sub --help` show examples; `tool` with a missing arg exits with your usage code (2 in the suggested table) and prints usage.
- `tool list --json | jq .` parses; stderr empty on success; run twice for idempotency.
- `echo $?` for success, usage error, not-found and interrupted (Ctrl-C) cases.
- `NO_COLOR=1 tool ...` and `tool ... | cat` produce no escape codes: `| grep -c $'\033'` returns 0.
- `tool dangerous --dry-run` changes nothing (check `git status` / state); `--yes` works unattended with `< /dev/null`.
- Project tests, type-check and linter pass; README/help updated for new flags.

## Skeleton
```sh
tool job list [--json] [--quiet]     # result on stdout, nothing else
tool job delete ID [--dry-run] [--yes]
# exit (suggested convention): 0 ok, 1 error, 2 usage, 3 not found, 4 conflict, 130 interrupted
```
Document the exit codes and JSON fields in `--help` or a docs page; they are the contract.
