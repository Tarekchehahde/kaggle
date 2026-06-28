# Discover and load SkillCorner dynamic event files (Soccer Hackathon).

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
  stop("Set KAGGLE_REPO_ROOT or run from kaggle repo.", call. = FALSE)
}

#' Resolve directory containing *_dynamic_events.csv files.
soccer_events_dir <- function(root = kaggle_repo_root()) {
  candidates <- c(
    file.path(root, "data", "soccer-hackathon", "skillcorner_opendata"),
    file.path(root, "data", "soccer-hackathon", "opendata", "data", "matches"),
    "/kaggle/input/soccer-feature-engineering-hackathon/skillcorner_opendata",
    "/kaggle/input/soccer-feature-engineering-hackathon/opendata/data/matches"
  )
  for (dir in candidates) {
    if (!dir.exists(dir)) next
    flat <- list.files(dir, pattern = "_dynamic_events\\.csv$", full.names = TRUE)
    if (length(flat) > 0L) {
      return(normalizePath(dir, winslash = "/"))
    }
    nested <- list.files(
      dir,
      pattern = "_dynamic_events\\.csv$",
      recursive = TRUE,
      full.names = TRUE
    )
    if (length(nested) > 0L) {
      return(normalizePath(dir, winslash = "/"))
    }
  }
  stop(
    "No dynamic event CSVs found. Run: bash scripts/fetch-soccer-hackathon.sh",
    call. = FALSE
  )
}

#' List paths to all match dynamic event files (no hardcoded match IDs).
soccer_event_files <- function(root = kaggle_repo_root()) {
  base <- soccer_events_dir(root)
  hits <- list.files(
    base,
    pattern = "_dynamic_events\\.csv$",
    recursive = TRUE,
    full.names = TRUE
  )
  if (length(hits) == 0L) {
    stop("No *_dynamic_events.csv under ", base, call. = FALSE)
  }
  sort(hits)
}

.read_events_csv <- function(path) {
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

#' Load all match event tables into one data frame.
load_soccer_events <- function(root = kaggle_repo_root()) {
  files <- soccer_event_files(root)
  pieces <- lapply(files, .read_events_csv)
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}

#' Load events for a single match file.
load_soccer_match <- function(path) {
  .read_events_csv(path)
}
