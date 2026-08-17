#!/usr/bin/env bash
set -euo pipefail

source "${PUBLIC_API_ENV_FILE:-.public-api.env}"

prompt="This is an API smoke test. Reply with exactly: 9ROUTER_SMOKE_TEST_OK"

jq -n --arg model "${PUBLIC_API_MODEL}" --arg prompt "${prompt}" \
  '{model: $model, messages: [{role: "user", content: $prompt}]}' |
  curl -sS --fail-with-body "${PUBLIC_API_BASE_URL%/}/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${PUBLIC_API_KEY}" \
    -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
    -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" \
    --data-binary @- | jq .
