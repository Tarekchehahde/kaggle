# Dataset: Titanic (Kaggle competition)

| Field | Value |
|-------|--------|
| **URL** | https://www.kaggle.com/c/titanic |
| **Slug** | `titanic` (competition) |
| **License** | Competition rules |
| **Files** | `train.csv` (891), `test.csv` (418), `gender_submission.csv` |
| **Status** | Fetched; Shiny at `shiny/titanic/app.R` |

## Fetch

```bash
bash scripts/fetch-titanic.sh
```

Uses `kaggle competitions download -c titanic` (accept rules on Kaggle first if 403).

## Solution

| Piece | Path |
|-------|------|
| Loader | `R/load_titanic.R` |
| Shiny | `shiny/titanic/app.R` |
| Run local | `Rscript run_titanic.R` |
| Deploy VPS | `bash scripts/deploy-titanic-vps.sh` |
| **Live** | http://82.165.167.86/titanic/ |

## Dashboard tabs

Overview · Class & fare · Families · Model hint (glm) · Data table

## Columns (train)

`PassengerId`, `Survived`, `Pclass`, `Name`, `Sex`, `Age`, `SibSp`, `Parch`, `Ticket`, `Fare`, `Cabin`, `Embarked`

Derived: `FamilySize`, `Alone`, `AgeBand`
