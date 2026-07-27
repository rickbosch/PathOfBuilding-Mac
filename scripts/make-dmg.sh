#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
APP_NAME="Path of Building.app"
APP_PATH="${DIST_DIR}/${APP_NAME}"
DMG_NAME="PathOfBuilding-arm64.dmg"
DMG_PATH="${DIST_DIR}/${DMG_NAME}"
DMG_ROOT="${DIST_DIR}/dmg-root"

if [[ ! -d "${APP_PATH}" ]]; then
    echo "Application bundle not found:"
    echo "  ${APP_PATH}"
    echo
    echo "Run this first:"
    echo "  ./scripts/package.sh"
    exit 1
fi

echo "Preparing DMG contents..."
rm -rf "${DMG_ROOT}"
rm -f "${DMG_PATH}"

mkdir -p "${DMG_ROOT}"

cp -R "${APP_PATH}" "${DMG_ROOT}/"
ln -s /Applications "${DMG_ROOT}/Applications"

echo "Creating DMG..."
hdiutil create \
    -volname "Path of Building" \
    -srcfolder "${DMG_ROOT}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

rm -rf "${DMG_ROOT}"

echo
echo "DMG created:"
echo "  ${DMG_PATH}"

open "${DIST_DIR}"
