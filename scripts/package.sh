#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "ROOT_DIR=${ROOT_DIR}"
pwd

BUILD_DIR="${ROOT_DIR}/build"
DIST_DIR="${ROOT_DIR}/dist"
APP_NAME="Path of Building.app"

echo "Configuring Path of Building..."
cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release

echo "Building Path of Building..."
cmake --build "${BUILD_DIR}" --config Release --parallel

echo "Preparing distribution directory..."
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

echo "Packaging application..."
cmake --install "${BUILD_DIR}" \
    --config Release \
    --prefix "${DIST_DIR}"

APP_PATH="${DIST_DIR}/${APP_NAME}"

if [[ ! -d "${APP_PATH}" ]]; then
    echo "Error: application bundle was not created at:"
    echo "${APP_PATH}"
    exit 1
fi

echo
echo "Build complete:"
echo "${APP_PATH}"
echo
echo "Open the distribution folder with:"
echo "open \"${DIST_DIR}\""
