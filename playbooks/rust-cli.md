# Rust CLI tools

> Sources: [Command Line Applications in Rust](https://rust-cli.github.io/book/) (link only), [clap derive docs](https://docs.rs/clap), agency-agents engineering-rust-refactoring-specialist (MIT), paraphrased · Written 2026-10-27 · Applies to: Rust (2021+ edition), clap 4

**Use when:** writing or changing a command-line tool in Rust: crate layout, argument parsing, errors, output, config, tests, release builds, or refactoring one. Read `cli-design.md` first for flags, output streams, exit codes and config precedence; this page only covers how to do that in Rust.

## Before you start
- Read `cli-design.md`, then the project's `Cargo.toml`, `src/main.rs` and any existing error type. Match its crates (clap vs argh, anyhow vs eyre) before adding new ones.
- Run `cargo build && cargo test && cargo clippy --all-targets -- -D warnings` once to learn the baseline. Fix nothing unrelated.

## Rules

### Crate layout
One package, two targets: `src/lib.rs` holds all logic, `src/main.rs` only parses args, calls the library and maps the result to an exit code. Logic in `main.rs` cannot be tested without spawning a process.
1. Put the clap structs in `src/cli.rs` (or `cli/`), one module per subcommand under `src/commands/`. Each command returns data (`Result<Output, Error>`), it does not print.
2. Keep `pub` small. Use `pub(crate)` by default; every `pub` item in `lib.rs` is API you must keep stable.

### Arguments with clap derive
3. Use the derive API. One `#[derive(Parser)]` root, `#[derive(Subcommand)]` enum for nouns/verbs, `#[derive(Args)]` structs shared between commands.
4. Closed sets of values are `#[derive(ValueEnum)]` enums, not strings; clap then lists them in help and rejects typos.
5. Env fallback with `#[arg(long, env = "TOOL_TOKEN")]` (needs clap feature `env`). Never hide secrets: use `hide_env_values = true`, and do not take the secret as a plain flag at all (cli-design rule 8).
6. Global flags go on the root with `global = true`: `--json`, `--quiet`, `--verbose` (use `ArgAction::Count` for `-vv`), `--no-color`.
7. Help is written in doc comments plus `#[command(after_help = "EXAMPLES:\n  tool job list --json")]`.
8. Validate with `value_parser` (ranges, `PathBuf` existence, custom `FromStr`) so bad input fails in clap with exit code 2, before any work.

```rust
#[derive(Parser)]
#[command(version, about, after_help = "EXAMPLES:\n  tool job list --json")]
struct Cli {
    #[arg(long, global = true)] json: bool,
    #[arg(short, long, global = true, action = clap::ArgAction::Count)] verbose: u8,
    #[command(subcommand)] cmd: Cmd,
}
#[derive(Subcommand)]
enum Cmd { Job { #[command(subcommand)] cmd: JobCmd } }
#[derive(ValueEnum, Clone)]
enum Format { Table, Plain, Json }
```

### Errors
9. Library: a `thiserror` enum with one variant per failure the caller may act on (`NotFound`, `Conflict`, `Auth`, `Io`). No `anyhow` in the library's public signatures.
10. Binary: `anyhow::Result` for the glue and for commands that only report. Add `.with_context(|| format!("reading {}", path.display()))` on every `?` that crosses a boundary (file, network, parse, subprocess). A bare "No such file or directory" is a bug.
11. `main` maps errors to the documented exit codes; it does not return `Result` from `fn main` (that always exits 1 and prints Debug output).
12. User errors never panic. `unwrap`/`expect` only for invariants that a bug would break, with a message saying which.
13. Print the chain with `{:#}` (`error: reading x: permission denied`), stack/backtrace only under `RUST_BACKTRACE` or `-vv`.

```rust
fn main() -> ExitCode {
    let cli = Cli::parse(); // clap exits 2 itself on bad usage
    match tool::run(cli) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::from(match e.downcast_ref::<tool::Error>() {
                Some(tool::Error::NotFound(_)) => 3,
                Some(tool::Error::Conflict(_)) => 4,
                _ => 1,
            })
        }
    }
}
```

### Output
14. Closed pipe (`tool list | head`): `println!` panics on EPIPE. Write with `writeln!(io::stdout().lock(), ..)` and treat a `BrokenPipe` error as quiet success.
15. Commands return a value; one `render` step in the binary writes it. Derive `serde::Serialize` on the output types, so `--json` is `serde_json::to_writer_pretty(stdout, &value)` and the human format reads the same struct. Field names are API: use `#[serde(rename_all = "snake_case")]` and never change them casually.
16. Results to stdout, logs/progress/errors to stderr.
17. Colour and spinners only when `std::io::IsTerminal::is_terminal()` is true on that stream and `NO_COLOR` is unset or empty. `anstream`/`anstyle` (already a clap dependency) strip escapes automatically; use them instead of hand-written ANSI.

### Logging
18. Use `tracing` + `tracing-subscriber` with `EnvFilter`; map `-v`/`-vv` to `info`/`debug` when `RUST_LOG` is not set. Subscriber writes to stderr.

### Config
19. Locate files with the `directories` crate (`ProjectDirs::from("", "", "tool")` gives XDG paths on Linux and the right ones on macOS/Windows). Never hardcode `~/.config`.
20. Precedence flags > env > project file > user file > defaults. Cheapest way: read the file into a `#[derive(Deserialize, Default)]` struct (`toml`), then apply `Option` flags on top. clap's `env =` already merges flags and env. Keep a `config show` that prints the source of each value.

### Async
21. Stay synchronous unless the tool does many concurrent network calls. Blocking `ureq` or `std::process` is simpler and compiles faster.
22. When async is needed: `tokio` with `rt` only and `#[tokio::main(flavor = "current_thread")]`; add `rt-multi-thread` if profiling shows it matters. Do not make library functions async just because one caller is.

### Testing
23. Unit-test the library directly with `tempfile::tempdir()` for filesystem state; no real home dir or network.
24. Test the binary with `assert_cmd` + `predicates`: exit code, stdout, stderr, each checked separately. Set `env("NO_COLOR","1")`, `env("HOME", tmp)`, `current_dir(tmp)`.
25. Snapshot help text and `--json` output with `insta` (`assert_snapshot!`, `assert_json_snapshot!`); review diffs with `cargo insta review`.
26. One test per exit code in your table, one for `--json | parse`, and bad usage (exit 2).

```rust
Command::cargo_bin("tool")?.args(["job","show","nope"])
    .assert().code(3).stdout("").stderr(predicate::str::contains("not found"));
```

### Size and speed
27. Release profile for a distributable tool: `[profile.release] lto = "thin"` (or `true`), `codegen-units = 1`, `strip = true`, optionally `panic = "abort"`. Measure binary size before and after. `panic = "abort"` skips unwinding, so do not use it if you rely on `catch_unwind`.
28. Startup matters: no work before argument parsing, no reading config for `--help` or `--version`. Skip heavy dependencies (`regex`, `reqwest`, `tokio`) the tool does not need.

### Release
29. `cargo-dist` generates GitHub release workflows, installers and checksums for common targets; use it (or the project's existing release action) rather than hand-writing a matrix. Commit `Cargo.lock` for binaries.

### Refactoring safely
30. Green first: tests, `cargo fmt --check` and `cargo clippy --all-targets -- -D warnings` pass before you touch anything. If they do not, say so and do not mix the fix into the refactor.
31. Small steps, each compiling and tested: move code, then rename, then change signatures. Let the compiler list what is left (change the type, follow the errors).
32. CLI flags, JSON fields, exit codes and public `lib` items are contract; changing them needs an explicit decision. Output ordering and which errors are swallowed count as behaviour.
33. Never replace an error with a default or `let _ =` to make a warning go away. No `unsafe` to dodge the borrow checker; clone first, optimise with evidence.
34. Search for a renamed item in: calls, type uses, strings (`"name"` in clap attributes, serde renames, docs), `mod`/`pub use` re-exports, tests, benches, examples and `README` help output.
35. Remove dead code (`cargo clippy` shows unused items; `cargo machete` unused dependencies) in its own commit, before structural moves.

## Pitfalls
- **`println!` to a closed pipe** panics; `tool | head` then shows a panic trace.
- **Tests that read the real `$HOME`** pass locally and fail in CI.
- **Colour forced on in tests**: set `NO_COLOR=1` or snapshots churn.

## Verify
- `cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test` all pass, output read in full.
- `cargo run -q -- --help` and each subcommand's `--help` show examples; a missing arg exits 2.
- `cargo run -q -- list --json | jq .` parses; `... | head -1` exits quietly; `... >/dev/null` still prints errors to stderr.
- Exit codes: success, usage, not-found, conflict each checked with `echo $?`.
- README/help text and snapshots updated for any new flag.

