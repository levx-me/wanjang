---
name: provider
description: Switch this Claude Code session between the claude.ai subscription and OpenRouter without restarting. Use when the user types /wanjang:provider, or asks to move to OpenRouter or back to the Claude login.
argument-hint: "openrouter [--opus M --sonnet M --haiku M] | claude | key | status  [--user]"
---
Run `"<this skill's base directory>/../../bin/provider" $ARGUMENTS` with the Bash tool (no arguments: `status`), and report its last line.

- It rewrites this project's `.claude/settings.local.json` (`env` and `apiKeyHelper`); the running session reloads that file on save. `--user` writes `~/.claude/settings.json` instead and so switches every open session: say so before running it.
- The OpenRouter key is read by `bin/openrouter-key` from the macOS keychain, Linux `secret-tool`, or `OPENROUTER_API_KEY`. The first `openrouter` with no stored key, and `key` (to enter or replace it), open an OS password dialog: before running them, tell the user a dialog will appear on their screen and to type the key there. The key goes from the dialog straight to the keychain; you never see it. `status` and `claude` never ask. If the script says no dialog is available (e.g. over SSH), show the store command it printed and let the user run it themselves. Never ask for the key in chat, and never put it in a file or a command.
- Afterwards ask the user to run `/status` and check the "Anthropic base URL" line: `https://openrouter.ai/api` for OpenRouter, `https://api.anthropic.com` for the subscription. If it did not change, the session read that value at startup: a new session picks it up.
- The subscription's login token is never sent anywhere but Anthropic: OpenRouter gets only its own key. While on OpenRouter, features that need the claude.ai login (Remote Control, voice, claude.ai connectors) are off.
