# 9Router Public API Smoke Test

A small Bash smoke test that sends a chat request to `gpt-5.6-sol` through a
remote 9Router API.

The shell scripts require Bash, `curl`, and `jq`. The Python client requires
Python 3.10 or newer.

## Quick start

```bash
cp .public-api.env.example .public-api.env
chmod 600 .public-api.env
```

Set the API URL, model, API key, and Cloudflare Access credentials in
`.public-api.env`.

Then run:

```bash
sh models-list.sh      # Print every supported model ID
./test-public-api.sh
```

To run the same smoke test with LangChain's `ChatOpenAI`:

```bash
uv sync
uv run test-public-api.py
```

Pass a model ID as the first argument to override `PUBLIC_API_MODEL`:

```bash
uv run test-public-api.py gpt-5.6-sol
```

The real `.public-api.env` is ignored by Git and should never be committed.
