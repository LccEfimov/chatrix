#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"
BACKUP_DIR="$ROOT_DIR/.tmp_mobile_backup"

if [ -d "$MOBILE_DIR/android" ]; then
  echo "[OK] Flutter Android scaffold already exists: $MOBILE_DIR/android"
  exit 0
fi

if [ ! -f "$MOBILE_DIR/pubspec.yaml" ] || [ ! -d "$MOBILE_DIR/lib" ]; then
  echo "[ERR] Expected $MOBILE_DIR/pubspec.yaml and $MOBILE_DIR/lib/ to exist." >&2
  exit 1
fi

rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$MOBILE_DIR/lib" "$BACKUP_DIR/lib"
cp "$MOBILE_DIR/pubspec.yaml" "$BACKUP_DIR/pubspec.yaml"

CREATE_CMD='cd mobile && flutter create --project-name chatrix --org com.chatrix.app --platforms android --overwrite .'
PUBGET_CMD='cd mobile && flutter pub get'

if command -v flutter >/dev/null 2>&1; then
  echo "[INFO] Using local flutter to generate project scaffold..."
  (cd "$ROOT_DIR" && bash -lc "$CREATE_CMD")
  echo "[INFO] Restoring custom lib/ and pubspec.yaml..."
  rm -rf "$MOBILE_DIR/lib"
  cp -r "$BACKUP_DIR/lib" "$MOBILE_DIR/lib"
  cp "$BACKUP_DIR/pubspec.yaml" "$MOBILE_DIR/pubspec.yaml"
  (cd "$ROOT_DIR" && bash -lc "$PUBGET_CMD")
  echo "[OK] Scaffold generated (local flutter)."
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERR] Neither flutter nor docker found. Install Flutter or Docker, then re-run." >&2
  exit 2
fi

echo "[INFO] Using Docker Flutter image to generate scaffold..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$ROOT_DIR":/work \
  -w /work \
  ghcr.io/cirruslabs/flutter:stable \
  bash -lc "$CREATE_CMD"

echo "[INFO] Restoring custom lib/ and pubspec.yaml..."
rm -rf "$MOBILE_DIR/lib"
cp -r "$BACKUP_DIR/lib" "$MOBILE_DIR/lib"
cp "$BACKUP_DIR/pubspec.yaml" "$MOBILE_DIR/pubspec.yaml"

docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$ROOT_DIR":/work \
  -w /work \
  ghcr.io/cirruslabs/flutter:stable \
  bash -lc "$PUBGET_CMD"

echo "[OK] Scaffold generated (docker flutter)."
