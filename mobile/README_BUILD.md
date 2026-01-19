# ChatriX (mobile) — APK build on Ubuntu 22.04

## Why you currently cannot build
This repository's `mobile/` directory contains only `lib/` and `pubspec.yaml` as a starter UI mock.
A real Flutter Android project requires generated folders (at minimum `android/`, plus `.metadata`, `analysis_options.yaml`, `test/`, etc.).

## Fastest way (recommended): build in Docker
### Requirements
- Docker installed and running.

### Steps
From repo root:
```bash
chmod +x scripts/bootstrap_flutter_project.sh scripts/build_apk_docker.sh
./scripts/build_apk_docker.sh
```
Resulting APK:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

## Native build (without Docker)
### Requirements
- Flutter SDK installed (stable)
- Java 17
- Android SDK (platform-tools, build-tools)

### Steps
1) Generate Android scaffold (only once):
```bash
./scripts/bootstrap_flutter_project.sh
```
2) Build:
```bash
cd mobile
flutter build apk --release
```

## Notes
- The scaffold step uses `flutter create --overwrite .` and then restores the custom `lib/` and `pubspec.yaml`.
- iOS can be added later by regenerating with `--platforms android,ios`.
