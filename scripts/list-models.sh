#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
. "${PUBLIC_API_ENV_FILE:-$repo_root/.public-api.env}"

curl -fsS "${PUBLIC_API_BASE_URL%/}/models" \
  -H "Authorization: Bearer ${PUBLIC_API_KEY}" \
  -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
  -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" |
  jq -r '.data[]?.id // empty' |
  sort
