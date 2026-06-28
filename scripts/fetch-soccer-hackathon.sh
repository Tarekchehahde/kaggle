#!/usr/bin/env bash
# Download Soccer Feature Engineering Hackathon data from Kaggle.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/data/soccer-hackathon"
COMP="soccer-feature-engineering-hackathon"

export PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${DEST}"
kaggle competitions download -c "${COMP}" -p "${DEST}"
unzip -o "${DEST}/${COMP}.zip" -d "${DEST}" 2>/dev/null || unzip -o "${DEST}"/*.zip -d "${DEST}"
echo "Downloaded to ${DEST}/skillcorner_opendata"
ls "${DEST}/skillcorner_opendata"/*.csv | wc -l
