#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
. "${PUBLIC_API_ENV_FILE:-$repo_root/.public-api.env}"

model="${1:-$PUBLIC_API_MODEL}"
messages='[
  {"role":"user","content":"What is (11434 + 12341) * 412? Use tools for all arithmetic."}
]'
tools='[
  {
    "type": "function",
    "function": {
      "name": "add",
      "description": "Add two integers",
      "parameters": {
        "type": "object",
        "properties": {"a":{"type":"integer"}, "b":{"type":"integer"}},
        "required": ["a", "b"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "multiply",
      "description": "Multiply two integers",
      "parameters": {
        "type": "object",
        "properties": {"a":{"type":"integer"}, "b":{"type":"integer"}},
        "required": ["a", "b"]
      }
    }
  }
]'

chat() {
  jq -nc \
    --arg model "$model" \
    --argjson messages "$messages" \
    --argjson tools "$tools" \
    '{model:$model, messages:$messages, tools:$tools, stream:false}' |
    curl -fsS "${PUBLIC_API_BASE_URL%/}/chat/completions" \
      -H "Authorization: Bearer $PUBLIC_API_KEY" \
      -H 'Content-Type: application/json' \
      -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID:-}" \
      -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET:-}" \
      --data-binary @-
}

for _ in {1..8}; do
  message="$(chat | jq -c '.choices[0].message')"
  messages="$(jq -c --argjson message "$message" '. + [$message]' <<<"$messages")"
  calls="$(jq -c '.tool_calls // []' <<<"$message")"

  if [[ "$(jq length <<<"$calls")" == 0 ]]; then
    jq -r '.content' <<<"$message"
    exit 0
  fi

  while IFS= read -r call; do
    id="$(jq -r '.id' <<<"$call")"
    name="$(jq -r '.function.name' <<<"$call")"
    args="$(jq -c '.function.arguments | fromjson' <<<"$call")"

    case "$name" in
      add)      result="$(jq -r '.a + .b' <<<"$args")" ;;
      multiply) result="$(jq -r '.a * .b' <<<"$args")" ;;
      *)        result="Unknown tool: $name" ;;
    esac

    printf '%s(%s) = %s\n' "$name" "$args" "$result"
    messages="$(jq -c --arg id "$id" --arg result "$result" \
      '. + [{role:"tool", tool_call_id:$id, content:$result}]' <<<"$messages")"
  done < <(jq -c '.[]' <<<"$calls")
done

echo 'Agent exceeded 8 turns' >&2
exit 1
