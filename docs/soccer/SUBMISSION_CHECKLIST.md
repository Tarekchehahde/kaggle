# Submit the Soccer Hackathon (checklist)

Deadline: **26 Jul 2026, 23:00 GMT+2**

## 1. Kaggle notebook (required)

1. Go to [competition Code tab](https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon/code)
2. **New Notebook** → R kernel → add competition data `soccer-feature-engineering-hackathon`
3. Paste contents of `kernels/soccer-feature-engineering/soccer-hackathon-submission.R` (or upload from GitHub)
4. **Run All** → confirm `features.csv` appears in Output (20 rows)
5. Save version → keep notebook **Private**

## 2. Write-up (required)

1. Open [Writeups tab](https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon/writeups)
2. **+ New Writeup**
3. Paste from `docs/soccer/WRITEUP_KAGGLE.md` (edit title, add notebook link for host)
4. **Submit** before deadline (not draft)

## 3. Privacy rules

- Do **not** make notebook or writeup public
- Share notebook with host as collaborator if requested

## 4. Local / GitHub

```bash
bash scripts/fetch-soccer-hackathon.sh
Rscript scripts/build-soccer-features.R
# → output/soccer/features.csv
```

Repo: https://github.com/Tarekchehahde/kaggle

## 5. Honest expectation

This is **judge-based** — no leaderboard. We maximized rubric alignment (interpretable features, rigor, reproducibility). Winning depends on judge panel vs ~54 teams.
