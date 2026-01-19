#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/backend"

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Running migrations inside docker compose api container..."
  docker compose run --rm api bash -lc 'alembic upgrade head'
else
  echo "[ERR] docker not found. Install Docker or run alembic locally." >&2
  exit 1
fi
