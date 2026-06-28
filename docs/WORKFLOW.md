# Workflow — dedicated Kaggle dataset

How we work when you point at a specific dataset (competition or public dataset).

## What you send

Send **one Kaggle link** (and optionally a short goal). That is enough to start.

| Link type | Example | Slug we use |
|-----------|---------|-------------|
| **Dataset** | `https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students` | `laveshjadon/ai-impact-on-students` |
| **Competition** | `https://www.kaggle.com/c/titanic` | competition `titanic` |

Optional but helpful:

- **Goal** — e.g. “burnout dashboard”, “GPA regression”, “exploratory only”
- **Audience** — private RStudio vs public Shiny on VPS
- **Constraints** — “keep it small”, “no ML yet”, “German UI”

You do **not** need to download files yourself. The Kaggle CLI on your Mac or VPS does that once we script it.

## What happens (phases)

Nothing runs automatically until you say so. Typical sequence:

```
1. You send link  →  2. Dataset doc  →  3. You approve  →  4. Fetch  →  5. R work  →  6. Shiny  →  7. VPS deploy
```

### Phase 1 — Understand (no scripts)

1. You paste the Kaggle URL in Cursor.
2. Agent reads metadata (CLI or Kaggle page): rows, columns, license, size.
3. Agent adds or updates `docs/datasets/<slug>.md` in **this repo**.
4. Agent proposes: research questions, chart ideas, VPS fit, risks.
5. **You confirm** before any fetch or code.

### Phase 2 — Fetch (when you say “go”)

1. Download via Kaggle CLI to a **gitignored** path, e.g. `data/laveshjadon/ai-impact-on-students/`.
2. Same layout on VPS under a dedicated directory (not mixed with MaStR).
3. Record file names, row counts, and download date in the dataset doc.

Commands (for reference — not run until approved):

```bash
kaggle datasets download -d laveshjadon/ai-impact-on-students -p data/laveshjadon/ai-impact-on-students --unzip
```

### Phase 3 — Analysis in R

1. Open project on VPS in RStudio (SSH tunnel to `:8787`) or work locally.
2. EDA: summaries, missing values, factor levels.
3. Optional modeling (tidymodels, etc.) aligned with your goal.
4. Scripts live in this repo under `R/` and `scripts/` when we add them.

### Phase 4 — Dashboard (Shiny)

1. Shiny app reads **processed** artifacts (aggregates, models), not raw 50k rows on every click if avoidable.
2. App code in `shiny/` (or deploy into VPS hub later — separate decision).
3. nginx + systemd on VPS, same pattern as other Shiny apps.

### Phase 5 — Cursor as orchestrator

Cursor does not run on the VPS. It:

- Edits files in this repo
- Runs local shell: `ssh ionos-mastr`, `rsync`, `git push`
- Generates one-off commands you approve

You stay in the loop at: dataset choice, “start scripting”, deploy, and anything that touches credentials.

## Example: your AI-on-students link

| Step | Action |
|------|--------|
| You | Sent `https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students` |
| Agent | Documented dataset in `docs/datasets/ai-impact-on-students.md` |
| Next (when you ask) | Fetch CSV → EDA → Shiny (burnout/GPA/policy views) → optional VPS |

## What never goes in git

- Kaggle API token (`~/.kaggle/access_token`, `KAGGLE_API_TOKEN`)
- Downloaded CSVs / zips under `data/`
- VPS passwords (`*.credentials.local.md`)

See [`CREDENTIALS.md`](CREDENTIALS.md).

## Decision checklist (before scripting)

- [ ] Dataset link and slug confirmed
- [ ] Goal stated (EDA / classification / regression / dashboard only)
- [ ] Size OK for VPS (~1.2 MB for this dataset — fine)
- [ ] License noted (CC0-1.0 for AI-on-students)
- [ ] You said **“go”** or **“script it”**
