#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Running backend tests in Docker..."
  docker build -t chatrix-api-test ./backend >/dev/null
  docker run --rm \
    -e DATABASE_URL="sqlite+pysqlite:///:memory:" \
    -e JWT_SECRET="test-secret" \
    chatrix-api-test \
    bash -lc "pytest -q"
  echo "[OK] Backend tests passed."
  exit 0
fi

# Fallback (if docker is not available)
if command -v python3 >/dev/null 2>&1; then
  echo "[WARN] Docker not found. Running backend tests locally (venv)."
  python3 -m venv .venv_backend
  # shellcheck disable=SC1091
  source .venv_backend/bin/activate
  python -m pip install --upgrade pip >/dev/null
  python -m pip install -r backend/requirements.txt >/dev/null
  (cd backend && pytest -q)
  deactivate
  echo "[OK] Backend tests passed (local)."
  exit 0
fi

echo "[ERR] Neither docker nor python3 found. Install Docker or Python 3, then re-run." >&2
exit 2
