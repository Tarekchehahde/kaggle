# Load AI Impact on Students dataset (Kaggle: laveshjadon/ai-impact-on-students).

suppressPackageStartupMessages({
  library(dplyr)
})

#' Read CSV with consistent UTF-8 handling (base R — no readr on VPS R 4.6).
.read_students_csv <- function(path) {
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

.is_kaggle_repo <- function(d) {
  dir.exists(file.path(d, "R")) && dir.exists(file.path(d, "data"))
}

#' Resolve repo root from env, working directory, or parent paths.
ai_students_repo_root <- function() {
  env <- Sys.getenv("KAGGLE_REPO_ROOT", unset = "")
  if (nzchar(env) && .is_kaggle_repo(env)) {
    return(normalizePath(env, winslash = "/"))
  }
  wd <- normalizePath(getwd(), winslash = "/")
  for (d in unique(c(wd, dirname(wd), dirname(dirname(wd))))) {
    if (.is_kaggle_repo(d)) {
      return(normalizePath(d, winslash = "/"))
    }
  }
  stop(
    "Cannot find kaggle repo root. Set KAGGLE_REPO_ROOT or run from repo / shiny/.",
    call. = FALSE
  )
}

#' Find the CSV under data/laveshjadon/ai-impact-on-students (Kaggle zip name may vary).
ai_students_csv_path <- function(root = ai_students_repo_root()) {
  dir <- file.path(root, "data", "laveshjadon", "ai-impact-on-students")
  if (!dir.exists(dir)) {
    stop(
      "Data not found at ", dir, ". Run: bash scripts/fetch-ai-impact-on-students.sh",
      call. = FALSE
    )
  }
  hits <- list.files(dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(hits) == 0L) {
    stop("No CSV in ", dir, call. = FALSE)
  }
  hits[[1L]]
}

#' Read and type-coerce the student impact dataset.
load_ai_students <- function(root = ai_students_repo_root()) {
  path <- ai_students_csv_path(root)
  raw <- .read_students_csv(path)

  raw |>
    mutate(
      Major_Category = factor(Major_Category),
      Year_of_Study = factor(
        Year_of_Study,
        levels = c("Freshman", "Sophomore", "Junior", "Senior", "Graduate")
      ),
      Primary_Use_Case = factor(Primary_Use_Case),
      Prompt_Engineering_Skill = factor(
        Prompt_Engineering_Skill,
        levels = c("Beginner", "Intermediate", "Advanced")
      ),
      Institutional_Policy = factor(Institutional_Policy),
      Burnout_Risk_Level = factor(
        Burnout_Risk_Level,
        levels = c("Low", "Medium", "High")
      ),
      Paid_Subscription = as.logical(Paid_Subscription),
      GPA_Delta = Post_Semester_GPA - Pre_Semester_GPA,
      Total_Study_Hours = Weekly_GenAI_Hours + Traditional_Study_Hours,
      AI_Share_of_Study = Weekly_GenAI_Hours / pmax(Total_Study_Hours, 0.01)
    )
}
