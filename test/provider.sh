#!/usr/bin/env bash
# Runs bin/provider on a made-up settings file; fails on any wrong result.
cd "$(dirname "$0")/.." || exit 2
T=$(mktemp -d); trap 'rm -rf "${T:?}"' EXIT
F=$T/settings.json
fail=0
bad() { echo "FAIL $1"; fail=1; }
q() { jq -r "$1" "$F"; }
echo '{"permissions":{"allow":["Bash(ls)"]},"env":{"FOO":"1"}}' > "$F"
# No key anywhere (keychain and secret-tool looked up under a name that does not exist): stops, file untouched.
cp "$F" "$T/before"
USER=wanjang-test-nobody OPENROUTER_API_KEY= bin/provider openrouter --file "$F" >/dev/null 2>&1; rc=$?
[ $rc = 3 ] || bad "missing key: exit $rc, want 3"
cmp -s "$F" "$T/before" || bad "missing key changed the file"
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
