# Technical architecture

Bridge: **Kaggle** → **R on IONOS VPS** → **Shiny dashboard**, with **Cursor** on your Mac writing and running orchestration commands.

## Components

| Layer | Role |
|-------|------|
| **Kaggle** | Dataset source; API via CLI (`kaggle datasets download …`) |
| **Mac + Cursor** | Edit repo, run SSH/rsync, local tests |
| **IONOS VPS** | R 4.6, RStudio Server `:8787`, optional public Shiny |
| **This repo (`kaggle`)** | Docs, later `R/`, `scripts/`, `shiny/` — **not** MaStR/transtek |

## Data flow

```
Browser / you
    │
    ▼
Cursor (Documents/kaggle)
    │  git push
    ▼
GitHub: Tarekchehahde/kaggle
    │
    │  ssh / git pull / rsync
    ▼
VPS (82.165.167.86)
    ├── Kaggle CLI (user rstudio) → data/ (gitignored on disk)
    ├── RStudio :8787 (tunnel) → analysis
    └── Shiny app → nginx :80 (when deployed)
```

## Cursor ↔ VPS integration

Cursor has **no agent on the server**. Integration is:

| Mechanism | Use |
|-----------|-----|
| **SSH** | `ssh ionos-mastr` — batch `Rscript`, install packages, restart services |
| **SSH tunnel** | RStudio at `http://localhost:8787` (existing Mac launcher pattern) |
| **rsync / scp** | Push code or single files before git pull is wired |
| **git** | Source of truth; VPS clone of **this** repo when set up |

SSH host alias `ionos-mastr` is configured on your Mac (same VPS as MaStR hub, **separate app directory** for this project).

## VPS resources (shared machine)

| Spec | Implication for Kaggle work |
|------|----------------------------|
| 6 vCPU, 8 GB RAM, 240 GB disk | Fine for tabular sets up to a few GB |
| No GPU | No large deep-learning competitions on-server |
| Many Shiny services already running | Heavy jobs should run off-peak or with memory limits |

**AI Impact on Students:** ~50k rows, ~1.2 MB — well within limits.

## Planned repo layout (future)

```
kaggle/
├── docs/
├── data/              # gitignored — downloaded CSVs
├── R/                 # loaders, EDA helpers
├── scripts/           # fetch.sh, deploy.sh
├── shiny/             # dashboard app(s)
└── systemd/           # optional VPS unit files
```

Not created until you approve scripting.

## Relation to other projects

| Project | Relationship |
|---------|----------------|
| **transtek** | None |
| **mastr-shiny / shiny-dashboard-hub** | Same VPS possible; different repo and paths (`/opt/kaggle/` vs `/opt/mastr-shiny/`) |
| **This repo** | Single source for Kaggle pipeline docs and code |
