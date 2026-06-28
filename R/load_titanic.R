# Load Kaggle Titanic competition data (train + test).

suppressPackageStartupMessages({
  library(dplyr)
})

.read_csv <- function(path) {
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

.is_kaggle_repo <- function(d) {
  dir.exists(file.path(d, "R")) && dir.exists(file.path(d, "data"))
}

kaggle_repo_root <- function() {
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
  stop("Cannot find kaggle repo root. Set KAGGLE_REPO_ROOT.", call. = FALSE)
}

titanic_data_dir <- function(root = kaggle_repo_root()) {
  dir <- file.path(root, "data", "titanic")
  if (!dir.exists(dir)) {
    stop("Data not found at ", dir, ". Run: bash scripts/fetch-titanic.sh", call. = FALSE)
  }
  dir
}

.titanic_prepare <- function(raw, labeled = TRUE) {
  out <- raw |>
    mutate(
      Pclass = factor(Pclass, levels = c(1, 2, 3), labels = c("1st", "2nd", "3rd")),
      Sex = factor(Sex),
      Embarked = factor(Embarked, levels = c("C", "Q", "S")),
      FamilySize = SibSp + Parch + 1L,
      Alone = FamilySize == 1L,
      AgeBand = cut(
        Age,
        breaks = c(0, 12, 18, 35, 60, Inf),
        labels = c("Child", "Teen", "Adult", "Middle", "Senior"),
        include.lowest = TRUE,
        right = FALSE
      )
    )

  if (labeled && "Survived" %in% names(out)) {
    out <- out |>
      mutate(
        Survived = factor(Survived, levels = c(0, 1), labels = c("Died", "Survived"))
      )
  }

  out
}

#' Labeled training set (891 rows).
load_titanic_train <- function(root = kaggle_repo_root()) {
  path <- file.path(titanic_data_dir(root), "train.csv")
  if (!file.exists(path)) {
    stop("Missing train.csv — run: bash scripts/fetch-titanic.sh", call. = FALSE)
  }
  .titanic_prepare(.read_csv(path), labeled = TRUE)
}

#' Hold-out test set (no Survived column).
load_titanic_test <- function(root = kaggle_repo_root()) {
  path <- file.path(titanic_data_dir(root), "test.csv")
  if (!file.exists(path)) {
    stop("Missing test.csv — run: bash scripts/fetch-titanic.sh", call. = FALSE)
  }
  .titanic_prepare(.read_csv(path), labeled = FALSE)
}
