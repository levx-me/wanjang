---
name: slow
description: The machine feels slow. Find what is using the CPU, memory, swap and disk, say which work it belongs to (which Claude session, dev server, browser, VM), and how to make it faster. Read-only; stopping anything is asked first. /wanjang:slow [what feels slow]
argument-hint: "[what feels slow, e.g. typing lags, builds crawl]"
---
Answer "why is my machine slow?" from one snapshot.

1. Run `slow` with the Bash tool (a plugin `bin/`, so on PATH; else `${CLAUDE_PLUGIN_ROOT}/bin/slow`). It is read-only and takes about a second.
2. If the load average is far above the cores but the listed CPU is low, the CPU numbers from `ps` are averages: sample once more with `top -l 2 -s 2 -o cpu -n 10 -stats pid,command,cpu,mem` (macOS) or `top -b -n 2 -d 2 | head -30` (Linux) and use the second sample. Do not run anything heavier.
3. Say what the slowness is, in the user's language, in this order:
   - the bottleneck in one line: CPU (load above the cores), memory (pressure high, swap in use), or disk (nearly full). If none, say the machine is not under load now, and that the slowness may be in one app or the network.
   - the top 3 to 5 consumers, each tied to the work it belongs to: a `claude` process by its folder (which session), a dev server by its folder, a browser, a VM, a system process (Spotlight `mds`, `backupd`, `kernel_task` when hot). Give the numbers as `slow` printed them.
   - what to do about each, most effective first, with the gain to expect: close idle Claude sessions (each holds about 0.3 to 0.8 GB), stop dev servers and watchers left running for days, close browser tabs or restart the browser, shut down a VM not in use, let Spotlight or a backup finish or pause it, free disk below 10 % free. Name the exact command or place to do it.
   - the `!` lines from `slow` that the points above did not cover.
4. Change nothing yourself. To stop a process, quit an app or delete files, ask with AskUserQuestion, one item per question (what it is, its pid and folder, what is lost if stopped, e.g. an unsaved session or a running build), and act only on a yes. Never stop the current Claude session, herdr, the window server or a system process.
5. If the user named what feels slow (`$ARGUMENTS`), start with what bears on it.
