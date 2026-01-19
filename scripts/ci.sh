#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[CI] Backend: tests"
"$ROOT_DIR/scripts/test_backend.sh"

echo "[CI] Mobile: analyze + tests"
"$ROOT_DIR/scripts/test_mobile.sh"

if [[ "${BUILD_APK:-0}" == "1" ]]; then
  echo "[CI] Build APK (BUILD_APK=1)"
  "$ROOT_DIR/scripts/build_apk_docker.sh"
else
  echo "[CI] Skipping APK build. Set BUILD_APK=1 to enable."
fi

echo "[CI] OK"
