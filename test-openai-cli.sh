#!/usr/bin/env bash
set -euo pipefail

. "${PUBLIC_API_ENV_FILE:-.public-api.env}"

: "${PUBLIC_API_BASE_URL:?Set PUBLIC_API_BASE_URL in .public-api.env}"
: "${PUBLIC_API_MODEL:?Set PUBLIC_API_MODEL in .public-api.env}"
: "${PUBLIC_API_KEY:?Set PUBLIC_API_KEY in .public-api.env}"
: "${CF_ACCESS_CLIENT_ID:?Set CF_ACCESS_CLIENT_ID in .public-api.env}"
: "${CF_ACCESS_CLIENT_SECRET:?Set CF_ACCESS_CLIENT_SECRET in .public-api.env}"
command -v codex >/dev/null || { echo "codex CLI is not installed" >&2; exit 1; }

model="${1:-$PUBLIC_API_MODEL}"
export NINE_ROUTER_API_KEY="$PUBLIC_API_KEY"
export CF_ACCESS_CLIENT_ID CF_ACCESS_CLIENT_SECRET

exec codex \
  --config 'model_provider="nine_router"' \
  --config "model_providers.nine_router.name=\"9Router\"" \
  --config "model_providers.nine_router.base_url=\"${PUBLIC_API_BASE_URL%/}\"" \
  --config 'model_providers.nine_router.env_key="NINE_ROUTER_API_KEY"' \
  --config 'model_providers.nine_router.wire_api="responses"' \
  --config 'model_providers.nine_router.env_http_headers={"CF-Access-Client-Id"="CF_ACCESS_CLIENT_ID","CF-Access-Client-Secret"="CF_ACCESS_CLIENT_SECRET"}' \
  --config 'shell_environment_policy.filters={NINE_ROUTER_API_KEY="exclude",PUBLIC_API_KEY="exclude",CF_ACCESS_CLIENT_ID="exclude",CF_ACCESS_CLIENT_SECRET="exclude"}' \
  --model "$model"
