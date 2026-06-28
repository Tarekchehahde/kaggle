# Aggregates and simple models for AI Impact on Students dashboard.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

source(file.path(dirname(sys.frame(1)$ofile), "load_ai_students.R"))

ai_students_overview <- function(df) {
  list(
    n_students = nrow(df),
    median_gpa_delta = median(df$GPA_Delta, na.rm = TRUE),
    median_genai_hrs = median(df$Weekly_GenAI_Hours, na.rm = TRUE),
    pct_high_burnout = mean(df$Burnout_Risk_Level == "High", na.rm = TRUE) * 100,
    median_retention = median(df$Skill_Retention_Score, na.rm = TRUE)
  )
}

ai_students_burnout_by_policy <- function(df) {
  df |>
    count(Institutional_Policy, Burnout_Risk_Level, name = "n") |>
    group_by(Institutional_Policy) |>
    mutate(pct = n / sum(n) * 100) |>
    ungroup()
}

ai_students_gpa_by_genai_bin <- function(df, bins = 8L) {
  df |>
    mutate(
      genai_bin = cut(
        Weekly_GenAI_Hours,
        breaks = bins,
        include.lowest = TRUE
      )
    ) |>
    group_by(genai_bin) |>
    summarise(
      n = n(),
      mean_gpa_delta = mean(GPA_Delta, na.rm = TRUE),
      mean_post_gpa = mean(Post_Semester_GPA, na.rm = TRUE),
      mean_retention = mean(Skill_Retention_Score, na.rm = TRUE),
      .groups = "drop"
    )
}

ai_students_major_summary <- function(df) {
  df |>
    group_by(Major_Category) |>
    summarise(
      n = n(),
      mean_genai = mean(Weekly_GenAI_Hours, na.rm = TRUE),
      mean_gpa_delta = mean(GPA_Delta, na.rm = TRUE),
      pct_high_burnout = mean(Burnout_Risk_Level == "High", na.rm = TRUE) * 100,
      mean_retention = mean(Skill_Retention_Score, na.rm = TRUE),
      .groups = "drop"
    ) |>
    arrange(desc(mean_genai))
}

ai_students_retention_vs_dependency <- function(df) {
  df |>
    mutate(
      dependency_bin = cut(
        Perceived_AI_Dependency,
        breaks = c(0, 3, 6, 10),
        labels = c("Low (1-3)", "Mid (4-6)", "High (7-10)"),
        include.lowest = TRUE
      )
    ) |>
    group_by(dependency_bin, Prompt_Engineering_Skill) |>
    summarise(
      n = n(),
      mean_retention = mean(Skill_Retention_Score, na.rm = TRUE),
      .groups = "drop"
    )
}
