# kaggle

Standalone project: **Kaggle datasets → R analysis → Shiny dashboards** on a self-hosted RStudio VPS, orchestrated with Cursor.

This repo is **independent** of MaStR, transtek, and other workspaces.

## Solutions

| Dataset | Local run | Live VPS |
|---------|-----------|----------|
| [AI on students](https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students) | `Rscript run_app.R` | http://82.165.167.86/ai_impact_students/ |
| [Titanic](https://www.kaggle.com/c/titanic) | `Rscript run_titanic.R` | http://82.165.167.86/titanic/ |
| **[Soccer Hackathon](https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon)** | `Rscript scripts/build-soccer-features.R` | Submit writeup + notebook (see below) |

Fetch: `bash scripts/fetch-soccer-hackathon.sh`  
Submit: [`docs/soccer/SUBMISSION_CHECKLIST.md`](docs/soccer/SUBMISSION_CHECKLIST.md)

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
| [`docs/AGENT_HANDOFF.md`](docs/AGENT_HANDOFF.md) | **Start here** — copy-paste prompt for a new agent |
| [`docs/WORKFLOW.md`](docs/WORKFLOW.md) | How we pick a dataset and when to script |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Mac, VPS, Kaggle CLI |
| [`docs/CREDENTIALS.md`](docs/CREDENTIALS.md) | Tokens (never in git) |
| [`docs/SOLUTION.md`](docs/SOLUTION.md) | AI-on-students dashboard |
| [`docs/datasets/`](docs/datasets/) | Per-dataset notes |

VPS deploy (systemd + nginx):

```bash
bash scripts/deploy-vps.sh
```

**Live:** http://82.165.167.86/ai_impact_students/

## Kaggle kernel

R script kernel in `kernels/ai-impact-students/` — push with:

```bash
cd kernels/ai-impact-students && kaggle kernels push -p .
```

Profile: https://www.kaggle.com/tarekchehade/code (after push succeeds)

## Status

- [x] Kaggle CLI + token on Mac and VPS
- [x] Dataset fetched (local + VPS; not in git)
- [x] R loader + Shiny dashboard
- [x] VPS deploy at `/ai_impact_students/`
- [ ] Kaggle kernel push via API (403 — use [`docs/KAGGLE_KERNEL.md`](docs/KAGGLE_KERNEL.md) manual import)

## Links

- GitHub: https://github.com/Tarekchehahde/kaggle
- Dataset: https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students
