# kaggle

Standalone project: **Kaggle datasets → R analysis → Shiny dashboards** on a self-hosted RStudio VPS, orchestrated with Cursor.

This repo is **independent** of MaStR, transtek, and other workspaces.

## Current solution

**[Impact of AI on Students](https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students)** — interactive Shiny dashboard.

| Step | Command |
|------|---------|
| Fetch data | `bash scripts/fetch-ai-impact-on-students.sh` |
| Install R packages | `Rscript scripts/install_packages.R` |
| Run dashboard | `Rscript run_app.R` |

Full write-up: [`docs/SOLUTION.md`](docs/SOLUTION.md)

## Repo layout

```
kaggle/
├── R/                 # load_ai_students.R, summarize_ai_students.R
├── shiny/app.R        # dashboard
├── scripts/           # fetch, install_packages
├── docs/              # workflow, architecture, datasets
└── data/              # gitignored — downloaded CSVs
```

## Documentation

| Path | Purpose |
|------|---------|
| [`docs/WORKFLOW.md`](docs/WORKFLOW.md) | How we pick a dataset and when to script |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Mac, VPS, Kaggle CLI |
| [`docs/CREDENTIALS.md`](docs/CREDENTIALS.md) | Tokens (never in git) |
| [`docs/SOLUTION.md`](docs/SOLUTION.md) | AI-on-students dashboard |
| [`docs/datasets/`](docs/datasets/) | Per-dataset notes |

## Status

- [x] Kaggle CLI + token on Mac and VPS
- [x] Dataset fetched (local; not in git)
- [x] R loader + Shiny dashboard
- [ ] VPS deploy (systemd/nginx)

## Links

- GitHub: https://github.com/Tarekchehahde/kaggle
- Dataset: https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students
