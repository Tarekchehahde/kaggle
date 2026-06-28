#!/usr/bin/env bash
# Download laveshjadon/ai-impact-on-students from Kaggle (requires ~/.kaggle/access_token).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/data/laveshjadon/ai-impact-on-students"
SLUG="laveshjadon/ai-impact-on-students"

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v kaggle >/dev/null 2>&1; then
  echo "kaggle CLI not found. Install: pip3 install kaggle" >&2
  exit 1
fi

mkdir -p "${DEST}"
kaggle datasets download -d "${SLUG}" -p "${DEST}" --unzip
echo "Downloaded to ${DEST}"
ls -la "${DEST}"
