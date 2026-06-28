# Load built features.csv for Shiny / reports.

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

features_csv_path <- function(root = kaggle_repo_root()) {
  candidates <- c(
    file.path(root, "output", "soccer", "features.csv"),
    file.path(root, "features.csv")
  )
  for (p in candidates) {
    if (file.exists(p)) return(normalizePath(p, winslash = "/"))
  }
  stop(
    "features.csv not found. Run: Rscript scripts/build-soccer-features.R",
    call. = FALSE
  )
}

load_soccer_features <- function(root = kaggle_repo_root()) {
  read.csv(features_csv_path(root), stringsAsFactors = FALSE, check.names = FALSE)
}

FEATURE_GROUPS <- list(
  "Event volume" = c(
    "player_possession_events", "passing_option_events",
    "on_ball_engagement_events", "off_ball_run_events"
  ),
  "Territory" = c(
    "possessions_end_attacking_third", "possessions_end_penalty_area",
    "actions_start_attacking_third", "actions_start_defensive_third"
  ),
  "Passing" = c(
    "pass_distance_total_m", "pass_distance_received_total_m",
    "forward_pass_count", "long_pass_count", "one_touch_action_count",
    "quick_pass_count", "carry_action_count"
  ),
  "Tempo & physical" = c(
    "possession_duration_sec", "distance_covered_total_m",
    "sprinting_band_event_count", "high_speed_run_band_event_count"
  ),
  "Runs & pressing" = c(
    "line_break_run_count", "push_line_run_count", "give_and_go_action_count",
    "pressing_chain_event_count", "consecutive_engagement_total",
    "force_backward_action_count"
  ),
  "Threat flags" = c(
    "lead_to_shot_action_count", "lead_to_goal_action_count", "dangerous_action_count"
  ),
  "Phase structure" = c(
    "create_phase_actions", "build_up_phase_actions", "transition_phase_actions",
    "direct_phase_actions", "set_play_phase_actions", "quick_break_phase_actions"
  ),
  "Channels" = c(
    "wide_left_channel_action_count", "wide_right_channel_action_count",
    "half_space_left_action_count", "half_space_right_action_count",
    "center_channel_action_count"
  )
)

FEATURE_LABELS <- c(
  player_possession_events = "Player possession events",
  passing_option_events = "Passing option events",
  on_ball_engagement_events = "On-ball engagement events",
  off_ball_run_events = "Off-ball run events",
  possessions_end_attacking_third = "Possessions ending attacking third",
  possessions_end_penalty_area = "Possessions ending penalty area",
  actions_start_attacking_third = "Actions starting attacking third",
  actions_start_defensive_third = "Actions starting defensive third",
  pass_distance_total_m = "Total pass distance (m)",
  pass_distance_received_total_m = "Total pass distance received (m)",
  forward_pass_count = "Forward passes",
  long_pass_count = "Long passes",
  one_touch_action_count = "One-touch actions",
  quick_pass_count = "Quick passes",
  carry_action_count = "Carry actions",
  possession_duration_sec = "Possession duration (sec)",
  distance_covered_total_m = "Distance covered (m)",
  sprinting_band_event_count = "Sprinting-band events",
  high_speed_run_band_event_count = "HSR-band events",
  line_break_run_count = "Line-break runs",
  push_line_run_count = "Push-line runs",
  give_and_go_action_count = "Give-and-go actions",
  pressing_chain_event_count = "Pressing-chain events",
  consecutive_engagement_total = "Consecutive engagements (sum)",
  force_backward_action_count = "Force-backward actions",
  lead_to_shot_action_count = "Lead-to-shot actions",
  lead_to_goal_action_count = "Lead-to-goal actions",
  dangerous_action_count = "Dangerous actions",
  create_phase_actions = "Create-phase actions",
  build_up_phase_actions = "Build-up phase actions",
  transition_phase_actions = "Transition-phase actions",
  direct_phase_actions = "Direct-phase actions",
  set_play_phase_actions = "Set-play phase actions",
  quick_break_phase_actions = "Quick-break phase actions",
  wide_left_channel_action_count = "Wide-left channel actions",
  wide_right_channel_action_count = "Wide-right channel actions",
  half_space_left_action_count = "Half-space left actions",
  half_space_right_action_count = "Half-space right actions",
  center_channel_action_count = "Center channel actions"
)
