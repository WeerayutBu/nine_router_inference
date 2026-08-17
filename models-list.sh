#!/bin/sh
set -eu

. "${PUBLIC_API_ENV_FILE:-.public-api.env}"

curl -fsS "${PUBLIC_API_BASE_URL%/}/models" \
  -H "Authorization: Bearer ${PUBLIC_API_KEY}" \
  -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
  -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" |
  jq -r '.data[]?.id // empty' |
  sort
