# kaggle

Standalone project: **Kaggle datasets → R analysis → Shiny dashboards** on a self-hosted RStudio VPS, orchestrated with Cursor.

This repo is **independent** of MaStR, transtek, and other workspaces. It only documents and (later) automates the Kaggle pipeline.

## What lives here

| Path | Purpose |
|------|---------|
| [`docs/WORKFLOW.md`](docs/WORKFLOW.md) | How we pick a dataset, what you send, what gets built |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Mac, VPS, Kaggle CLI, Shiny — technical layout |
| [`docs/CREDENTIALS.md`](docs/CREDENTIALS.md) | Where API tokens go (never in git) |
| [`docs/datasets/`](docs/datasets/) | One note per dataset you choose |

## Current pilot dataset

**[Impact of AI on Students](https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students)** — `laveshjadon/ai-impact-on-students`

See [`docs/datasets/ai-impact-on-students.md`](docs/datasets/ai-impact-on-students.md).

## Status

- [x] Kaggle CLI + token on Mac and IONOS VPS (`rstudio` user)
- [x] Workflow and architecture documented
- [ ] Fetch / ETL scripts (waiting for explicit go-ahead)
- [ ] R analysis + Shiny app
- [ ] VPS deploy

## Quick links

- Kaggle dataset: https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students
- VPS hub (separate project): [shiny-dashboard-hub](https://github.com/Tarekchehahde/shiny-dashboard-hub)
