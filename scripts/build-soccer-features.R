#!/usr/bin/env Rscript
# Build features.csv for Soccer Feature Engineering Hackathon.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
root <- Sys.getenv("KAGGLE_REPO_ROOT", unset = "")
if (!nzchar(root) && length(file_arg)) {
  root <- normalizePath(
    file.path(dirname(sub("^--file=", "", file_arg)), ".."),
    winslash = "/"
  )
}
if (!nzchar(root)) {
  root <- normalizePath(file.path(getwd(), ".."), winslash = "/")
}
Sys.setenv(KAGGLE_REPO_ROOT = root)

source(file.path(root, "R/load_soccer_events.R"))
source(file.path(root, "R/compute_soccer_features.R"))

out_dir <- Sys.getenv("SOCCER_OUTPUT_DIR", unset = file.path(root, "output", "soccer"))
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

features <- build_soccer_features(root)
out_path <- file.path(out_dir, "features.csv")
write.csv(features, out_path, row.names = FALSE)

cat("Wrote", out_path, "\n")
cat("Rows:", nrow(features), "| Feature columns:", ncol(features) - 2L, "\n")
cat("Matches:", length(unique(features$match_id)), "\n")
stopifnot(nrow(features) == 20L)
