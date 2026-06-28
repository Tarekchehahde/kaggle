# Submit the Soccer Hackathon (checklist)

Deadline: **26 Jul 2026, 23:00 GMT+2**

## 1. Kaggle notebook (required)

### Add competition data (step-by-step)

1. Open the competition:  
   https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon

2. Click the **Code** tab (top menu).

3. Click **New Notebook** (top right).

4. In the notebook editor, open the **Input** panel on the right:
   - If collapsed: click **➕ Add Input** or the **Add data** button (right sidebar).
   - Or: top menu **File → Add input**.

5. Choose **Competition Data** (not “Your datasets”):
   - Search: `soccer feature engineering`
   - Select **Soccer Feature Engineering Hackathon**
   - Click **Add** (or **Mount**).

6. Confirm the path appears in the sidebar, e.g.:
   ```
   /kaggle/input/soccer-feature-engineering-hackathon/
     └── skillcorner_opendata/
           └── *_dynamic_events.csv
   ```

7. Set kernel to **R** (Edit → Editor type → R, if needed).

8. Paste `kernels/soccer-feature-engineering/soccer-hackathon-submission.R` into a cell (or the whole script as one cell).

9. **Run All** → Output should include `features.csv` (20 rows).

10. **Save Version** → keep notebook **Private**.

**Shortcut:** From the competition **Code** tab, some flows auto-attach data when you click “New Notebook” from that page — still verify `/kaggle/input/soccer-feature-engineering-hackathon/` exists before running.

### Notebook source

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
