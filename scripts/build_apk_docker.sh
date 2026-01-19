#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERR] docker not found. Install Docker, then re-run." >&2
  exit 1
fi

# Ensure scaffold exists (android/)
"$ROOT_DIR/scripts/bootstrap_flutter_project.sh"

echo "[INFO] Building release APK inside Docker..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$ROOT_DIR":/work \
  -w /work/mobile \
  ghcr.io/cirruslabs/flutter:stable \
  bash -lc 'flutter doctor -v && flutter build apk --release'

APK_PATH="$MOBILE_DIR/build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
  echo "[OK] APK built: $APK_PATH"
else
  echo "[ERR] APK not found at expected path: $APK_PATH" >&2
  exit 2
fi
