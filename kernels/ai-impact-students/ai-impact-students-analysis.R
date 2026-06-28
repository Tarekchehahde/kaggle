# AI Impact on Students — Kaggle kernel (R script)
# Dataset: laveshjadon/ai-impact-on-students
# Companion Shiny app: https://github.com/Tarekchehahde/kaggle

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

find_csv <- function() {
  hits <- list.files("/kaggle/input", pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  if (length(hits) == 0L) {
    stop("No CSV under /kaggle/input — attach laveshjadon/ai-impact-on-students")
  }
  hits[[1L]]
}

cat("=== AI Impact on Students — solution summary ===\n\n")

raw <- read_csv(find_csv(), show_col_types = FALSE)
df <- raw |>
  mutate(
    GPA_Delta = Post_Semester_GPA - Pre_Semester_GPA,
    Burnout_Risk_Level = factor(Burnout_Risk_Level, levels = c("Low", "Medium", "High")),
    Institutional_Policy = factor(Institutional_Policy),
    Major_Category = factor(Major_Category)
  )

cat("Rows:", nrow(df), "| Columns:", ncol(raw), "\n\n")

cat("--- Key metrics ---\n")
cat(sprintf("Median GPA change: %+.3f\n", median(df$GPA_Delta, na.rm = TRUE)))
cat(sprintf("Median weekly GenAI hours: %.2f\n", median(df$Weekly_GenAI_Hours, na.rm = TRUE)))
cat(sprintf("Median skill retention: %.1f\n", median(df$Skill_Retention_Score, na.rm = TRUE)))
cat(sprintf("High burnout share: %.1f%%\n",
            mean(df$Burnout_Risk_Level == "High", na.rm = TRUE) * 100))

cat("\n--- Burnout by institutional policy (row %) ---\n")
policy_tbl <- df |>
  count(Institutional_Policy, Burnout_Risk_Level) |>
  group_by(Institutional_Policy) |>
  mutate(pct = round(n / sum(n) * 100, 1)) |>
  arrange(Institutional_Policy, Burnout_Risk_Level)
print(as.data.frame(policy_tbl), row.names = FALSE)

cat("\n--- Mean GPA change by policy ---\n")
gpa_policy <- df |>
  group_by(Institutional_Policy) |>
  summarise(
    n = n(),
    mean_gpa_delta = round(mean(GPA_Delta, na.rm = TRUE), 3),
    mean_retention = round(mean(Skill_Retention_Score, na.rm = TRUE), 1),
    .groups = "drop"
  ) |>
  arrange(desc(mean_gpa_delta))
print(as.data.frame(gpa_policy), row.names = FALSE)

cat("\n--- GenAI hours & burnout by major ---\n")
major_tbl <- df |>
  group_by(Major_Category) |>
  summarise(
    n = n(),
    mean_genai = round(mean(Weekly_GenAI_Hours, na.rm = TRUE), 2),
    pct_high_burnout = round(mean(Burnout_Risk_Level == "High", na.rm = TRUE) * 100, 1),
    mean_gpa_delta = round(mean(GPA_Delta, na.rm = TRUE), 3),
    .groups = "drop"
  ) |>
  arrange(desc(mean_genai))
print(as.data.frame(major_tbl), row.names = FALSE)

cat("\n--- Retention vs AI dependency (binned) ---\n")
dep_tbl <- df |>
  mutate(
    dep_bin = cut(
      Perceived_AI_Dependency,
      breaks = c(0, 3, 6, 10),
      labels = c("Low (1-3)", "Mid (4-6)", "High (7-10)"),
      include.lowest = TRUE
    )
  ) |>
  group_by(dep_bin) |>
  summarise(
    n = n(),
    mean_retention = round(mean(Skill_Retention_Score, na.rm = TRUE), 1),
    .groups = "drop"
  )
print(as.data.frame(dep_tbl), row.names = FALSE)

# Save figures for kernel output
dir.create("/kaggle/working", showWarnings = FALSE)

p1 <- ggplot(df, aes(Burnout_Risk_Level, fill = Burnout_Risk_Level)) +
  geom_bar(show.legend = FALSE) +
  scale_fill_manual(values = c(Low = "#10b981", Medium = "#f59e0b", High = "#ef4444")) +
  labs(title = "Burnout risk distribution", x = NULL, y = "Students") +
  theme_minimal(base_size = 12)

ggsave("/kaggle/working/01_burnout_distribution.png", p1, width = 7, height = 4, dpi = 120)

p2 <- df |>
  group_by(Institutional_Policy) |>
  summarise(mean_delta = mean(GPA_Delta, na.rm = TRUE), .groups = "drop")

p2_plot <- ggplot(p2, aes(reorder(Institutional_Policy, mean_delta), mean_delta)) +
  geom_col(fill = "#6366f1", width = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Mean GPA change by AI policy", x = NULL, y = "GPA change") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("/kaggle/working/02_gpa_by_policy.png", p2_plot, width = 8, height = 4, dpi = 120)

p3 <- major_tbl |>
  ggplot(aes(reorder(Major_Category, mean_genai), mean_genai)) +
  geom_col(fill = "#818cf8") +
  coord_flip() +
  labs(title = "Mean weekly GenAI hours by major", x = NULL, y = "Hours") +
  theme_minimal(base_size = 12)

ggsave("/kaggle/working/03_genai_by_major.png", p3, width = 7, height = 4, dpi = 120)

cat("\nSaved plots to /kaggle/working/\n")
cat("Shiny dashboard (full interactive solution): deploy via github.com/Tarekchehahde/kaggle\n")
cat("=== Done ===\n")
