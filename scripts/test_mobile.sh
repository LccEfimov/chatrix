#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Ensure Flutter scaffold exists (android/). This can use local flutter or Docker.
"$ROOT_DIR/scripts/bootstrap_flutter_project.sh"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERR] docker not found. Install Docker (or install Flutter locally), then re-run." >&2
  exit 1
fi

echo "[INFO] Running Flutter analyze + tests inside Docker..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$ROOT_DIR":/work \
  -w /work/mobile \
  ghcr.io/cirruslabs/flutter:stable \
  bash -lc 'flutter --version && flutter pub get && flutter analyze && flutter test'

echo "[OK] Mobile tests passed."
