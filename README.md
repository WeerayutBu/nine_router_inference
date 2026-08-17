# 9Router Public API Smoke Test

A small Bash smoke test that sends a chat request to `gpt-5.6-sol` through a
remote 9Router API.

Requires Bash, `curl`, and `jq`.

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

The real `.public-api.env` is ignored by Git and should never be committed.
