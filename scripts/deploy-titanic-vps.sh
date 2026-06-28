#!/usr/bin/env bash
# Deploy Titanic Shiny app to IONOS VPS (port 3857, /titanic/).
set -euo pipefail

SSH_HOST="${SSH_HOST:-ionos-mastr}"
INSTALL_DIR="/opt/kaggle"
SERVICE="kaggle-titanic"
PORT=3857
PATH_PREFIX="/titanic"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Sync repo to ${SSH_HOST}:${INSTALL_DIR}"
ssh "${SSH_HOST}" "mkdir -p ${INSTALL_DIR} && chown rstudio:rstudio ${INSTALL_DIR}"
rsync -avz \
  --exclude '.git' \
  --exclude 'data/' \
  "${ROOT}/" "${SSH_HOST}:${INSTALL_DIR}/"
ssh "${SSH_HOST}" "chown -R rstudio:rstudio ${INSTALL_DIR}"

echo "==> Fetch Titanic data on VPS"
ssh "${SSH_HOST}" "sudo -u rstudio bash -lc 'export PATH=\$HOME/.local/bin:\$PATH && bash ${INSTALL_DIR}/scripts/fetch-titanic.sh'"

echo "==> Install R packages"
ssh "${SSH_HOST}" "sudo -u rstudio Rscript ${INSTALL_DIR}/scripts/install_packages.R"

echo "==> Install systemd unit"
scp -q "${ROOT}/systemd/${SERVICE}.service" "${SSH_HOST}:/tmp/${SERVICE}.service"
ssh "${SSH_HOST}" "mv /tmp/${SERVICE}.service /etc/systemd/system/${SERVICE}.service && systemctl daemon-reload && systemctl enable ${SERVICE} && systemctl restart ${SERVICE}"

echo "==> Add nginx location (if missing)"
ssh "${SSH_HOST}" "grep -q 'location ${PATH_PREFIX}/' /etc/nginx/sites-available/mastr-hub || python3 - <<'PY'
from pathlib import Path
path = Path('/etc/nginx/sites-available/mastr-hub')
text = path.read_text()
block = '''
    location ${PATH_PREFIX}/ {
        proxy_pass http://127.0.0.1:${PORT}/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
    }
'''
marker = '    location /ai_impact_students/'
if block.strip() not in text:
    text = text.replace(marker, block + marker, 1)
    path.write_text(text)
PY
nginx -t && systemctl reload nginx"

echo "==> Health check"
ssh "${SSH_HOST}" "sleep 5 && curl -s -o /dev/null -w '${PATH_PREFIX}/ HTTP %{http_code}\n' http://127.0.0.1${PATH_PREFIX}/"
echo "Public URL: http://82.165.167.86${PATH_PREFIX}/"
