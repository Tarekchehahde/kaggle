# Solution: AI Impact on Students

Interactive Shiny dashboard over the [Kaggle dataset](https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students) (50k synthetic student records).

## Question

How does **Generative AI usage** relate to **academic outcomes** (GPA), **skill retention**, and **burnout** — and does **institutional AI policy** or **major** change the picture?

## What we built

| Piece | Path |
|-------|------|
| Fetch script | `scripts/fetch-ai-impact-on-students.sh` |
| Data loader | `R/load_ai_students.R` |
| Aggregates (batch) | `R/summarize_ai_students.R` |
| Shiny app | `shiny/app.R` |
| Launcher | `run_app.R` |

## Dashboard tabs

1. **Overview** — KPIs, burnout distribution, GPA change vs GenAI hours (sampled scatter + trend)
2. **Institutional policy** — burnout mix and mean GPA change by policy stance
3. **Majors & AI use** — GenAI hours and high-burnout rates by major; primary use cases
4. **Well-being** — retention vs AI dependency, anxiety vs GenAI hours, retention heatmap by prompt skill
5. **Data table** — filterable sample of 500 rows

Global **sidebar filters**: major, year of study, institutional policy.

## Run locally

```bash
# 1. Data (once)
bash scripts/fetch-ai-impact-on-students.sh

# 2. R packages (once)
Rscript scripts/install_packages.R

# 3. App
Rscript run_app.R
# or: R -e "shiny::runApp('shiny')"
```

Requires Kaggle token in `~/.kaggle/access_token` for fetch only.

## Run on VPS

**Live URL:** http://82.165.167.86/ai_impact_students/

Deploy (from Mac):

```bash
bash scripts/deploy-vps.sh
```

Manual steps:

```bash
ssh ionos-mastr
# code at /opt/kaggle, service kaggle-ai-impact-students, port 3856
sudo systemctl status kaggle-ai-impact-students
```

## Data notes

- CSV filename from Kaggle may include `(1)`; loader picks the first `*.csv` in the data folder.
- Derived columns: `GPA_Delta`, `Total_Study_Hours`, `AI_Share_of_Study`.
- Publisher describes data as **synthetic** (CC0-1.0).

## Possible extensions

- Logistic model for `Burnout_Risk_Level` (tidymodels)
- Deploy as `/ai_impact_students/` on IONOS hub
- Scheduled re-fetch if Kaggle dataset updates quarterly
