#!/usr/bin/env python3
"""Send the public API smoke-test prompt through LangChain's ChatOpenAI."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

from dotenv import load_dotenv
from langchain_openai import ChatOpenAI


PROMPT = "This is an API smoke test. Reply with exactly: 9ROUTER_SMOKE_TEST_OK"


def required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise SystemExit(f"Missing required environment variable: {name}")
    return value


def main() -> None:
    parser = argparse.ArgumentParser(description="Test the 9Router public API")
    parser.add_argument("model", nargs="?", help="Override PUBLIC_API_MODEL")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    env_file = Path(os.getenv("PUBLIC_API_ENV_FILE", repo_root / ".public-api.env"))
    load_dotenv(env_file)

    model = args.model or required_env("PUBLIC_API_MODEL")
    llm = ChatOpenAI(
        model=model,
        api_key=required_env("PUBLIC_API_KEY"),
        base_url=required_env("PUBLIC_API_BASE_URL").rstrip("/"),
        default_headers={
            "CF-Access-Client-Id": required_env("CF_ACCESS_CLIENT_ID"),
            "CF-Access-Client-Secret": required_env("CF_ACCESS_CLIENT_SECRET"),
        },
        timeout=60,
        max_retries=0,
    )

    response = llm.invoke(PROMPT)
    print(response.content)


if __name__ == "__main__":
    main()
