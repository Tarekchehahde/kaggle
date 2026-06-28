# One-time (or after R upgrade): install packages for load + Shiny app.
pkgs <- c(
  "shiny", "bslib", "dplyr", "tidyr", "ggplot2",
  "plotly", "scales", "DT"
)
install_if_missing <- function(p) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
  invisible(TRUE)
}
invisible(vapply(pkgs, install_if_missing, logical(1)))
message("Packages ready: ", paste(pkgs, collapse = ", "))
