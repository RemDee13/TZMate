#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/release"
DERIVED_DATA_DIR="${BUILD_DIR}/DerivedData"
PRODUCTS_DIR="${DERIVED_DATA_DIR}/Build/Products/Release"
APP_PATH="${PRODUCTS_DIR}/TZMate.app"
ZIP_PATH="${BUILD_DIR}/TZMate.zip"

echo "Preparing local Release build..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

cd "${ROOT_DIR}"

xcodebuild \
  -scheme TZMate \
  -configuration Release \
  -derivedDataPath "${DERIVED_DATA_DIR}" \
  build \
  CODE_SIGNING_ALLOWED="${CODE_SIGNING_ALLOWED:-NO}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Expected app not found at ${APP_PATH}" >&2
  exit 1
fi

echo "Creating ZIP package..."
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

cat <<EOF

Created:
${ZIP_PATH}

This script is for local testing and draft release packaging.
For a public GitHub Release:
1. Build with Developer ID signing enabled.
2. Notarize the app or DMG with Apple.
3. Staple the notarization ticket.
4. Prefer a signed and notarized DMG for public users.

EOF
