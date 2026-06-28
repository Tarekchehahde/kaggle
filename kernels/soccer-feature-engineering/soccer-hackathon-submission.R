# Kaggle submission notebook — Soccer Feature Engineering Hackathon
# Self-contained R script: attach competition data, run all cells, outputs features.csv

suppressPackageStartupMessages({
  library(dplyr)
})

# --- paths (Kaggle competition input) ----------------------------------------
find_events_dir <- function() {
  candidates <- c(
    "/kaggle/input/soccer-feature-engineering-hackathon/skillcorner_opendata",
    "data/soccer-hackathon/skillcorner_opendata"
  )
  for (d in candidates) {
    if (dir.exists(d) && length(list.files(d, pattern = "_dynamic_events\\.csv$")) > 0L) {
      return(d)
    }
  }
  stop("Attach competition data: soccer-feature-engineering-hackathon")
}

events_dir <- find_events_dir()
event_files <- sort(list.files(events_dir, pattern = "_dynamic_events\\.csv$", full.names = TRUE))
cat("Matches found:", length(event_files), "\n")

# --- helpers (same as repo R/compute_soccer_features.R) ----------------------
.is_true <- function(x) {
  if (is.logical(x)) return(!is.na(x) & x)
  tolower(trimws(as.character(x))) %in% c("true", "t", "1", "yes")
}
.num_sum <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x[is.na(x)] <- 0
  sum(x)
}
.count_type <- function(event_type, label) sum(event_type == label, na.rm = TRUE)

compute_team_match_features <- function(events) {
  events <- events |>
    mutate(match_id = as.integer(match_id), team_id = as.integer(team_id))
  events |>
    group_by(match_id, team_id) |>
    summarise(
      player_possession_events = .count_type(event_type, "player_possession"),
      passing_option_events = .count_type(event_type, "passing_option"),
      on_ball_engagement_events = .count_type(event_type, "on_ball_engagement"),
      off_ball_run_events = .count_type(event_type, "off_ball_run"),
      possessions_end_attacking_third = sum(
        event_type == "player_possession" & third_end == "attacking_third", na.rm = TRUE
      ),
      possessions_end_penalty_area = sum(
        event_type == "player_possession" & .is_true(penalty_area_end), na.rm = TRUE
      ),
      actions_start_attacking_third = sum(third_start == "attacking_third", na.rm = TRUE),
      actions_start_defensive_third = sum(third_start == "defensive_third", na.rm = TRUE),
      pass_distance_total_m = .num_sum(pass_distance),
      pass_distance_received_total_m = .num_sum(pass_distance_received),
      forward_pass_count = sum(pass_direction == "forward" & !is.na(pass_direction), na.rm = TRUE),
      long_pass_count = sum(pass_range == "long" & !is.na(pass_range), na.rm = TRUE),
      one_touch_action_count = sum(.is_true(one_touch), na.rm = TRUE),
      quick_pass_count = sum(.is_true(quick_pass), na.rm = TRUE),
      carry_action_count = sum(.is_true(carry), na.rm = TRUE),
      possession_duration_sec = .num_sum(ifelse(event_type == "player_possession", duration, 0)),
      distance_covered_total_m = .num_sum(distance_covered),
      sprinting_band_event_count = sum(speed_avg_band == "sprinting", na.rm = TRUE),
      high_speed_run_band_event_count = sum(speed_avg_band == "hsr", na.rm = TRUE),
      line_break_run_count = sum(.is_true(break_defensive_line), na.rm = TRUE),
      push_line_run_count = sum(.is_true(push_defensive_line), na.rm = TRUE),
      give_and_go_action_count = sum(.is_true(give_and_go), na.rm = TRUE),
      pressing_chain_event_count = sum(.is_true(pressing_chain), na.rm = TRUE),
      consecutive_engagement_total = .num_sum(consecutive_on_ball_engagements),
      force_backward_action_count = sum(.is_true(force_backward), na.rm = TRUE),
      lead_to_shot_action_count = sum(.is_true(lead_to_shot), na.rm = TRUE),
      lead_to_goal_action_count = sum(.is_true(lead_to_goal), na.rm = TRUE),
      dangerous_action_count = sum(.is_true(dangerous), na.rm = TRUE),
      create_phase_actions = sum(team_in_possession_phase_type == "create", na.rm = TRUE),
      build_up_phase_actions = sum(team_in_possession_phase_type == "build_up", na.rm = TRUE),
      transition_phase_actions = sum(team_in_possession_phase_type == "transition", na.rm = TRUE),
      direct_phase_actions = sum(team_in_possession_phase_type == "direct", na.rm = TRUE),
      set_play_phase_actions = sum(team_in_possession_phase_type == "set_play", na.rm = TRUE),
      quick_break_phase_actions = sum(team_in_possession_phase_type == "quick_break", na.rm = TRUE),
      wide_left_channel_action_count = sum(channel_start == "wide_left", na.rm = TRUE),
      wide_right_channel_action_count = sum(channel_start == "wide_right", na.rm = TRUE),
      half_space_left_action_count = sum(channel_start == "half_space_left", na.rm = TRUE),
      half_space_right_action_count = sum(channel_start == "half_space_right", na.rm = TRUE),
      center_channel_action_count = sum(channel_start == "center", na.rm = TRUE),
      .groups = "drop"
    )
}

# --- build output -------------------------------------------------------------
features <- lapply(event_files, function(f) {
  compute_team_match_features(read.csv(f, stringsAsFactors = FALSE, check.names = FALSE))
}) |> bind_rows() |> arrange(match_id, team_id)

stopifnot(nrow(features) == 20L)

write.csv(features, "features.csv", row.names = FALSE)
cat("Wrote features.csv:", nrow(features), "rows,", ncol(features) - 2L, "features\n")
print(head(features, 4))
