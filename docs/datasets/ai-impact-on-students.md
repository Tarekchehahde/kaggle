# Dataset: Impact of AI on Students

| Field | Value |
|-------|--------|
| **URL** | https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students |
| **Slug** | `laveshjadon/ai-impact-on-students` |
| **Owner** | laveshjadon |
| **License** | CC0-1.0 |
| **Format** | CSV |
| **Size (approx.)** | ~1.2 MB |
| **Rows** | 50,000 |
| **Columns** | 16 |
| **Missing values** | None (per publisher) |
| **Status** | Documented — **not downloaded yet** |

## Subtitle

*Is AI a Tutor or a Cheat Code? 50,000 Student Records on GenAI Usage and Burnout*

## Research angles (for later R / Shiny)

1. **GPA change** — `Pre_Semester_GPA` vs `Post_Semester_GPA` vs `Weekly_GenAI_Hours`
2. **Burnout classification** — predict `Burnout_Risk_Level` from AI and study habits
3. **Skill retention** — `Skill_Retention_Score` vs `Perceived_AI_Dependency`
4. **Policy comparison** — outcomes by `Institutional_Policy`
5. **Major / year breakdown** — `Major_Category`, `Year_of_Study`

## Suggested target variables

| Task | Column |
|------|--------|
| Regression | `Post_Semester_GPA`, `Skill_Retention_Score` |
| Classification | `Burnout_Risk_Level` |
| Exploratory | `Perceived_AI_Dependency`, `Anxiety_Level_During_Exams` |

## Columns (summary)

| Group | Columns |
|-------|---------|
| ID | `Student_ID` |
| Academic | `Major_Category`, `Year_of_Study`, `Pre_Semester_GPA`, `Post_Semester_GPA` |
| AI usage | `Weekly_GenAI_Hours`, `Primary_Use_Case`, `Prompt_Engineering_Skill`, `Tool_Diversity`, `Paid_Subscription` |
| Study | `Traditional_Study_Hours`, `Perceived_AI_Dependency` |
| Institution | `Institutional_Policy` |
| Well-being | `Anxiety_Level_During_Exams`, `Skill_Retention_Score`, `Burnout_Risk_Level` |

## VPS fit

| Check | Result |
|-------|--------|
| Disk | OK |
| RAM | OK |
| GPU | Not required |

## Fetch command (when approved)

```bash
mkdir -p data/laveshjadon/ai-impact-on-students
kaggle datasets download -d laveshjadon/ai-impact-on-students \
  -p data/laveshjadon/ai-impact-on-students --unzip
```

## Notes

- Publisher states data is **synthetically generated** for education/research scenarios.
- Expected update frequency on Kaggle: quarterly (may change metadata only).
