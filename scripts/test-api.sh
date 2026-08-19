#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
source "${PUBLIC_API_ENV_FILE:-$repo_root/.public-api.env}"

model="${1:-${PUBLIC_API_MODEL}}"
prompt="This is an API smoke test. Reply with exactly: 9ROUTER_SMOKE_TEST_OK"

jq -n --arg model "${model}" --arg prompt "${prompt}" \
  '{model: $model, stream: false, messages: [{role: "user", content: $prompt}]}' |
  curl -sS --fail-with-body "${PUBLIC_API_BASE_URL%/}/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${PUBLIC_API_KEY}" \
    -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
    -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" \
    --data-binary @- | jq .
