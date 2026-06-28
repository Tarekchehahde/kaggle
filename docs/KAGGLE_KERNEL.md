# Publishing to your Kaggle account

Prepared kernel: `kernels/ai-impact-students/`

| File | Role |
|------|------|
| `ai-impact-on-students-solution.ipynb` | R notebook (EDA + charts) |
| `ai-impact-on-students-solution.Rmd` | Source (jupytext) |
| `ai-impact-students-analysis.R` | R script variant |
| `kernel-metadata.json` | CLI metadata |

## API push (automated)

```bash
cd kernels/ai-impact-students
kaggle kernels push -p .
```

**Current status:** `403 Forbidden` on `SaveKernel` with the `KGAT_…` token. Dataset download works; kernel **create/update via API** may require:

1. [Kaggle Settings → API](https://www.kaggle.com/settings) — regenerate token after any leak
2. Confirm phone / account verification on Kaggle
3. Retry push; if still 403, use manual import below (same content)

## Manual import (works today)

1. Open [Kaggle → New Notebook](https://www.kaggle.com/code/new)
2. **File → Import notebook** (or upload)
3. Import from GitHub:
   `https://github.com/Tarekchehahde/kaggle/blob/main/kernels/ai-impact-students/ai-impact-on-students-solution.ipynb`
4. **Add data** → search `laveshjadon/ai-impact-on-students` → Add
5. Run all cells → **Save Version** → set visibility Public if desired

Profile after publish: https://www.kaggle.com/tarekchehade/code

## Full interactive solution (not on Kaggle)

Shiny needs a server — live on your VPS:

**http://82.165.167.86/ai_impact_students/**

Source: `shiny/app.R` in this repo.
