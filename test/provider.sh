#!/usr/bin/env bash
# Runs bin/provider on a made-up settings file; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
F=$T/settings.json
fail=0
bad() { echo "FAIL $1"; fail=1; }
q() { jq -r "$1" "$F"; }
echo '{"permissions":{"allow":["Bash(ls)"]},"env":{"FOO":"1"}}' > "$F"
# The dialog and the store are replaced (PROVIDER_ASK_CMD / PROVIDER_STORE_CMD) so no dialog shows and
# the real keychain is never touched; keychain and secret-tool are looked up under a user that does not exist.
export USER=wanjang-test-nobody OPENROUTER_API_KEY=
cp "$F" "$T/before"
# No key and no dialog available: stops with the manual command, file untouched.
PROVIDER_ASK_CMD=none bin/provider openrouter --file "$F" >/dev/null 2>&1; rc=$?
[ $rc = 3 ] || bad "no dialog: exit $rc, want 3"
cmp -s "$F" "$T/before" || bad "no dialog changed the file"
# No key, dialog cancelled: exit 5, nothing stored, file untouched.
PROVIDER_ASK_CMD='exit 1' PROVIDER_STORE_CMD="cat > $T/stored" bin/provider openrouter --file "$F" >/dev/null 2>&1; rc=$?
[ $rc = 5 ] || bad "cancel: exit $rc, want 5"
[ ! -e "$T/stored" ] && cmp -s "$F" "$T/before" || bad "cancel stored a key or changed the file"
# status and claude never prompt: a dialog that would fail the test is never run.
PROVIDER_ASK_CMD="touch $T/asked" bin/provider status --file "$F" >/dev/null
PROVIDER_ASK_CMD="touch $T/asked" bin/provider claude --file "$F" >/dev/null
[ ! -e "$T/asked" ] || bad "status or claude opened the dialog"
cp "$T/before" "$F"
# `key`: the dialog's answer reaches the store and never the output.
out=$(PROVIDER_ASK_CMD='printf sk-or-v1-testsecret' PROVIDER_STORE_CMD="cat > $T/stored" bin/provider key 2>&1) || bad "key: exit $?"
[ "$(cat "$T/stored" 2>/dev/null)" = sk-or-v1-testsecret ] || bad "key: not stored"
case "$out" in *testsecret*) bad "key: the key appeared in the output" ;; esac
# A non-key answer (quotes) is refused, not stored.
rm -f "$T/stored"
PROVIDER_ASK_CMD="printf 'a\"b'" PROVIDER_STORE_CMD="cat > $T/stored" bin/provider key >/dev/null 2>&1; rc=$?
[ $rc = 5 ] && [ ! -e "$T/stored" ] || bad "bad key: exit $rc or stored"
# openrouter with no key: asks, stores, switches; the key is in neither the output nor the settings file.
out=$(PROVIDER_ASK_CMD='printf sk-or-v1-testsecret' PROVIDER_STORE_CMD="cat > $T/stored" bin/provider openrouter --file "$F" 2>&1) || bad "first use: exit $?"
[ "$(q .env.ANTHROPIC_BASE_URL)" = https://openrouter.ai/api ] || bad "first use: did not switch"
case "$out$(cat "$F")" in *testsecret*) bad "first use: the key leaked into output or settings" ;; esac
cp "$T/before" "$F"
# To OpenRouter, with a key from the environment.
OPENROUTER_API_KEY=sk-test bin/provider openrouter --file "$F" --haiku x/h >/dev/null || bad "openrouter: exit $?"
[ "$(q .env.ANTHROPIC_BASE_URL)" = https://openrouter.ai/api ] || bad "openrouter: base url"
[ "$(q .apiKeyHelper)" = "$PWD/bin/openrouter-key" ] || bad "openrouter: key helper path"
[ "$(q .env.ANTHROPIC_DEFAULT_HAIKU_MODEL)" = x/h ] || bad "openrouter: haiku model"
[ "$(q .env.FOO)" = 1 ] && [ "$(q '.permissions.allow[0]')" = 'Bash(ls)' ] || bad "openrouter: other settings lost"
# Back to the subscription: helper gone, values overwritten (not deleted), other settings kept.
bin/provider claude --file "$F" >/dev/null || bad "claude: exit $?"
[ "$(q '.apiKeyHelper // "none"')" = none ] || bad "claude: key helper still set"
[ "$(q .env.ANTHROPIC_BASE_URL)" = https://api.anthropic.com ] || bad "claude: base url"
[ "$(q .env.ANTHROPIC_AUTH_TOKEN)" = "" ] && [ "$(q .env.ANTHROPIC_DEFAULT_HAIKU_MODEL)" = "" ] || bad "claude: token or model not blanked"
[ "$(q .env.FOO)" = 1 ] || bad "claude: other settings lost"
[ "$(bin/provider status --file "$F")" = "provider: claude ($F)" ] || bad "status"
[ $fail = 0 ] && echo "provider: all cases pass"
exit $fail
