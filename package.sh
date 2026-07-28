#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
DIST_DIR="${ROOT_DIR}/dist"
DMG_STAGE_DIR="${BUILD_DIR}/dmg-stage"

APP_NAME="Path of Building.app"
RELEASE_VERSION="${RELEASE_VERSION:-$(git describe --tags --abbrev=0 | sed 's/^v//')}"
DMG_NAME="PathOfBuilding-Community-macOS-Apple-Silicon-v${RELEASE_VERSION}.dmg"

APP_PATH="${DIST_DIR}/${APP_NAME}"
STAGED_APP_PATH="${DMG_STAGE_DIR}/${APP_NAME}"
DMG_PATH="${DIST_DIR}/${DMG_NAME}"

echo "Configuring Path of Building..."
cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release

echo "Building Path of Building..."
cmake --build "${BUILD_DIR}" --config Release --parallel

echo "Preparing distribution directory..."
mkdir -p "${DIST_DIR}"
find "${DIST_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

echo "Packaging application..."
cmake --install "${BUILD_DIR}" \
    --config Release \
    --prefix "${DIST_DIR}"

if [[ ! -d "${APP_PATH}" ]]; then
    echo "Error: application bundle was not created at:"
    echo "${APP_PATH}"
    exit 1
fi

echo "Removing any stale application signature..."
codesign --remove-signature "${APP_PATH}" 2>/dev/null || true

echo "Signing application bundle..."
codesign \
    --force \
    --deep \
    --sign - \
    "${APP_PATH}"

echo "Verifying application signature..."
codesign \
    --verify \
    --deep \
    --strict \
    --verbose=2 \
    "${APP_PATH}"

echo "Preparing DMG staging directory..."
rm -rf "${DMG_STAGE_DIR}"
mkdir -p "${DMG_STAGE_DIR}"

ditto "${APP_PATH}" "${STAGED_APP_PATH}"

echo "Verifying staged application..."
codesign \
    --verify \
    --deep \
    --strict \
    --verbose=2 \
    "${STAGED_APP_PATH}"

echo "Creating DMG..."
rm -f "${DMG_PATH}"

hdiutil create \
    -volname "Path of Building" \
    -srcfolder "${DMG_STAGE_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

echo
echo "Build complete:"
echo "${APP_PATH}"
echo
echo "DMG created:"
echo "${DMG_PATH}"
