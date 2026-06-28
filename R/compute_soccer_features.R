# Team-level match aggregates for Soccer Feature Engineering Hackathon.
# All features are raw counts, sums, or durations (no ratios / percentages).

suppressPackageStartupMessages({
  library(dplyr)
})

.is_true <- function(x) {
  if (is.logical(x)) {
    return(!is.na(x) & x)
  }
  tolower(trimws(as.character(x))) %in% c("true", "t", "1", "yes")
}

.num_sum <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x[is.na(x)] <- 0
  sum(x)
}

.count_type <- function(event_type, label) {
  sum(event_type == label, na.rm = TRUE)
}

#' Compute one row of features per (match_id, team_id).
compute_team_match_features <- function(events) {
  stopifnot(nrow(events) > 0L)

  events <- events |>
    mutate(
      match_id = as.integer(.data$match_id),
      team_id = as.integer(.data$team_id)
    )

  events |>
    group_by(.data$match_id, .data$team_id) |>
    summarise(
      # --- Event volume by type ---
      player_possession_events = .count_type(.data$event_type, "player_possession"),
      passing_option_events = .count_type(.data$event_type, "passing_option"),
      on_ball_engagement_events = .count_type(.data$event_type, "on_ball_engagement"),
      off_ball_run_events = .count_type(.data$event_type, "off_ball_run"),

      # --- Territorial progression (counts) ---
      possessions_end_attacking_third = sum(
        .data$event_type == "player_possession" &
          .data$third_end == "attacking_third",
        na.rm = TRUE
      ),
      possessions_end_penalty_area = sum(
        .data$event_type == "player_possession" & .is_true(.data$penalty_area_end),
        na.rm = TRUE
      ),
      actions_start_attacking_third = sum(.data$third_start == "attacking_third", na.rm = TRUE),
      actions_start_defensive_third = sum(.data$third_start == "defensive_third", na.rm = TRUE),

      # --- Passing structure (sums / counts) ---
      pass_distance_total_m = .num_sum(.data$pass_distance),
      pass_distance_received_total_m = .num_sum(.data$pass_distance_received),
      forward_pass_count = sum(
        .data$pass_direction == "forward" & !is.na(.data$pass_direction),
        na.rm = TRUE
      ),
      long_pass_count = sum(
        .data$pass_range == "long" & !is.na(.data$pass_range),
        na.rm = TRUE
      ),
      one_touch_action_count = sum(.is_true(.data$one_touch), na.rm = TRUE),
      quick_pass_count = sum(.is_true(.data$quick_pass), na.rm = TRUE),
      carry_action_count = sum(.is_true(.data$carry), na.rm = TRUE),

      # --- Tempo & physical output ---
      possession_duration_sec = .num_sum(
        ifelse(.data$event_type == "player_possession", .data$duration, 0)
      ),
      distance_covered_total_m = .num_sum(.data$distance_covered),
      sprinting_band_event_count = sum(.data$speed_avg_band == "sprinting", na.rm = TRUE),
      high_speed_run_band_event_count = sum(.data$speed_avg_band == "hsr", na.rm = TRUE),

      # --- Off-ball movement intent ---
      line_break_run_count = sum(.is_true(.data$break_defensive_line), na.rm = TRUE),
      push_line_run_count = sum(.is_true(.data$push_defensive_line), na.rm = TRUE),
      give_and_go_action_count = sum(.is_true(.data$give_and_go), na.rm = TRUE),

      # --- Defensive disruption ---
      pressing_chain_event_count = sum(.is_true(.data$pressing_chain), na.rm = TRUE),
      consecutive_engagement_total = .num_sum(.data$consecutive_on_ball_engagements),
      force_backward_action_count = sum(.is_true(.data$force_backward), na.rm = TRUE),

      # --- Threat creation (event flags, not model outputs) ---
      lead_to_shot_action_count = sum(.is_true(.data$lead_to_shot), na.rm = TRUE),
      lead_to_goal_action_count = sum(.is_true(.data$lead_to_goal), na.rm = TRUE),
      dangerous_action_count = sum(.is_true(.data$dangerous), na.rm = TRUE),

      # --- Phase-of-play structure (counts) ---
      create_phase_actions = sum(.data$team_in_possession_phase_type == "create", na.rm = TRUE),
      build_up_phase_actions = sum(.data$team_in_possession_phase_type == "build_up", na.rm = TRUE),
      transition_phase_actions = sum(.data$team_in_possession_phase_type == "transition", na.rm = TRUE),
      direct_phase_actions = sum(.data$team_in_possession_phase_type == "direct", na.rm = TRUE),
      set_play_phase_actions = sum(.data$team_in_possession_phase_type == "set_play", na.rm = TRUE),
      quick_break_phase_actions = sum(.data$team_in_possession_phase_type == "quick_break", na.rm = TRUE),

      # --- Wide channel usage (counts) ---
      wide_left_channel_action_count = sum(.data$channel_start == "wide_left", na.rm = TRUE),
      wide_right_channel_action_count = sum(.data$channel_start == "wide_right", na.rm = TRUE),
      half_space_left_action_count = sum(.data$channel_start == "half_space_left", na.rm = TRUE),
      half_space_right_action_count = sum(.data$channel_start == "half_space_right", na.rm = TRUE),
      center_channel_action_count = sum(.data$channel_start == "center", na.rm = TRUE),

      .groups = "drop"
    )
}

#' Build features.csv content for all matches in the data directory.
build_soccer_features <- function(root = kaggle_repo_root()) {
  files <- soccer_event_files(root)
  pieces <- lapply(files, function(f) {
    compute_team_match_features(load_soccer_match(f))
  })
  out <- bind_rows(pieces) |> arrange(.data$match_id, .data$team_id)
  out
}
