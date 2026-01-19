#!/usr/bin/env bash
set -e
cp -n backend/.env.example backend/.env || true
docker compose up --build
