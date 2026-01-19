#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERR] docker not found. Install Docker or run linters manually." >&2
  exit 1
fi

echo "[INFO] Running backend linters (ruff, black) in Docker..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$ROOT_DIR/backend":/app \
  -w /app \
  python:3.12-slim \
  bash -lc 'pip install --no-cache-dir -r requirements.txt -r requirements-dev.txt >/dev/null && ruff check . && black --check .'

echo "[OK] Linters passed."
