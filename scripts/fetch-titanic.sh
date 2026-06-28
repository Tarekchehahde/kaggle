#!/usr/bin/env bash
# Download Kaggle Titanic competition data (requires ~/.kaggle/access_token).
# Accept rules at https://www.kaggle.com/c/titanic/rules if download fails.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/data/titanic"
COMP="titanic"

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v kaggle >/dev/null 2>&1; then
  echo "kaggle CLI not found. Install: pip3 install kaggle" >&2
  exit 1
fi

mkdir -p "${DEST}"
kaggle competitions download -c "${COMP}" -p "${DEST}"
unzip -o "${DEST}/titanic.zip" -d "${DEST}"
echo "Downloaded to ${DEST}"
ls -la "${DEST}"/*.csv
