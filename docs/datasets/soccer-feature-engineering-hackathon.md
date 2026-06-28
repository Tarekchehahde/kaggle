# Dataset: Soccer Feature Engineering Hackathon

| Field | Value |
|-------|--------|
| **URL** | https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon |
| **Prize** | $10,000 (judge-based, no leaderboard) |
| **Deadline** | 26 Jul 2026 |
| **Type** | Hackathon — notebook + **write-up** + `features.csv` |
| **Status** | **Solution built** — ready to submit on Kaggle |

## Deliverables (repo)

| Artifact | Path |
|----------|------|
| Feature code | `R/load_soccer_events.R`, `R/compute_soccer_features.R` |
| Build script | `scripts/build-soccer-features.R` |
| Output | `output/soccer/features.csv` (20 rows, 39 features) |
| Kaggle notebook | `kernels/soccer-feature-engineering/soccer-hackathon-submission.R` |
| Write-up (paste) | `docs/soccer/WRITEUP_KAGGLE.md` |
| Checklist | `docs/soccer/SUBMISSION_CHECKLIST.md` |

## Fetch data

```bash
bash scripts/fetch-soccer-hackathon.sh
Rscript scripts/build-soccer-features.R
```

## Rules reminder

Features must be **raw counts/sums/durations** only — no ratios, percentages, or ML embeddings.
