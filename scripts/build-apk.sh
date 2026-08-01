#!/usr/bin/env bash
set -euo pipefail

# Script to scaffold a Cordova Android project and copy the admin dashboard into it.
# Requires: node, npm, cordova CLI, Java JDK, Android SDK/NDK installed and configured.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/mobile-admin"
WWW_SRC="$ROOT_DIR/pages"

echo "Preparing Cordova project in $APP_DIR"
if ! command -v cordova >/dev/null 2>&1; then
  echo "cordova CLI not found. Install with: npm install -g cordova" >&2
  exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

cordova create admin com.zsazsa.admin ZsazsaAdmin || true
cd admin
cordova platform add android || true

echo "Copying admin dashboard pages to Cordova www folder..."
rm -rf www/*
mkdir -p www
cp -r "$WWW_SRC"/* www/ || true

echo "Building Android APK (this may take several minutes)..."
cordova build android --release

echo "APK build finished. See $APP_DIR/admin/platforms/android/app/build/outputs/apk/ for generated APKs"
