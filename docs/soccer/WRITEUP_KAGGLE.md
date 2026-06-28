# Kaggle Write-up — paste into Soccer Feature Engineering Hackathon

**Title suggestion:** *Territory, Tempo, and Pressure: 37 Team-Level Match Attributes from SkillCorner Events*

**Author:** Tarek Chehade  
**Competition:** [Soccer Feature Engineering Hackathon](https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon)

---

## 1. Executive summary

We propose **37 interpretable, match-level team attributes** derived from SkillCorner dynamic event data across **10 matches**. Features are grouped into five tactical themes:

1. **Territorial progression** — how often a team ends possessions in the attacking third or penalty area  
2. **Passing structure** — volume, distance, forward/long passes, one-touch and quick actions  
3. **Tempo & physical output** — possession time, distance covered, sprint/HSR event counts  
4. **Off-ball & defensive disruption** — line-breaking runs, pressing chains, forced backward actions  
5. **Phase & channel structure** — create/build-up/transition/direct/set-play/quick-break counts; wide and half-space usage  

All outputs are **raw aggregates** (counts, sums, durations in metres/seconds) — no ratios, percentages, or model-derived embeddings, per competition rules.

---

## 2. Why these attributes matter

Box-score stats (goals, shots) miss **how** a team creates advantage. Scouts and analysts care about:

- **Territory:** repeated entries into the final third and penalty box (possessions ending there) signal sustained attacking presence.  
- **Tempo:** total possession duration and high-speed actions proxy game intensity.  
- **Structure:** phase-of-play counts (create vs direct vs transition) describe tactical identity without normalizing by minutes.  
- **Pressing:** pressing-chain and force-backward counts capture defensive aggression as event volumes.  

These are **match-level** descriptors comparable across the 10-sample dataset and extensible to full seasons.

---

## 3. Data & reproducibility

- **Source:** SkillCorner Open Data (MIT), provided via competition `skillcorner_opendata/*.csv`  
- **Loader:** discovers all `*_dynamic_events.csv` files dynamically — **no hardcoded match IDs**  
- **Grain:** one row per `(match_id, team_id)` → **20 rows** total  
- **Code:** GitHub [`Tarekchehahde/kaggle`](https://github.com/Tarekchehahde/kaggle) — `R/load_soccer_events.R`, `R/compute_soccer_features.R`, `scripts/build-soccer-features.R`  
- **Notebook:** `kernels/soccer-feature-engineering/soccer-hackathon-submission.R` → outputs `features.csv`

---

## 4. Feature dictionary (summary)

| Feature | Definition | Type |
|---------|------------|------|
| `player_possession_events` | Count of on-ball possession events | count |
| `passing_option_events` | Count of passing-option events | count |
| `on_ball_engagement_events` | Defensive/on-ball duel events | count |
| `off_ball_run_events` | Off-ball run events | count |
| `possessions_end_attacking_third` | Possessions ending in attacking third | count |
| `possessions_end_penalty_area` | Possessions ending in penalty area | count |
| `actions_start_attacking_third` | Events starting in attacking third | count |
| `actions_start_defensive_third` | Events starting in defensive third | count |
| `pass_distance_total_m` | Sum of outgoing pass distances (m) | sum |
| `pass_distance_received_total_m` | Sum of received pass distances (m) | sum |
| `forward_pass_count` | Passes with forward direction | count |
| `long_pass_count` | Passes classified as long range | count |
| `one_touch_action_count` | One-touch actions | count |
| `quick_pass_count` | Quick passes | count |
| `carry_action_count` | Carry actions | count |
| `possession_duration_sec` | Sum of possession event durations (sec) | sum |
| `distance_covered_total_m` | Sum of tracked distance (m) | sum |
| `sprinting_band_event_count` | Events with sprinting speed band | count |
| `high_speed_run_band_event_count` | Events with HSR speed band | count |
| `line_break_run_count` | Runs flagged as breaking defensive line | count |
| `push_line_run_count` | Runs pushing defensive line | count |
| `give_and_go_action_count` | Give-and-go actions | count |
| `pressing_chain_event_count` | Events part of pressing chain | count |
| `consecutive_engagement_total` | Sum of consecutive engagement counts | sum |
| `force_backward_action_count` | Actions forcing opponent backward | count |
| `lead_to_shot_action_count` | Actions leading to shot | count |
| `lead_to_goal_action_count` | Actions leading to goal | count |
| `dangerous_action_count` | Events flagged dangerous (binary flag count) | count |
| `create_phase_actions` | Events in create phase | count |
| `build_up_phase_actions` | Events in build-up phase | count |
| `transition_phase_actions` | Events in transition phase | count |
| `direct_phase_actions` | Events in direct phase | count |
| `set_play_phase_actions` | Events in set-play phase | count |
| `quick_break_phase_actions` | Events in quick-break phase | count |
| `wide_left_channel_action_count` | Actions starting wide left | count |
| `wide_right_channel_action_count` | Actions starting wide right | count |
| `half_space_left_action_count` | Actions starting left half-space | count |
| `half_space_right_action_count` | Actions starting right half-space | count |
| `center_channel_action_count` | Actions starting center channel | count |

Full definitions align with SkillCorner column semantics (e.g. `third_end`, `team_in_possession_phase_type`, `speed_avg_band`).

---

## 5. Methodology

For each match file:

1. Load `*_dynamic_events.csv`  
2. Group events by `match_id` and `team_id`  
3. Aggregate using explicit rules above (boolean flags normalized via safe string/logical parsing)  
4. Append to master table; sort by match and team  

**Excluded by design:** xThreat, xPass, xG-style columns (model outputs), any per-minute rates, percentages, z-scores.

**Validation:** `nrow(features) == 20`, two teams per match, 10 unique match IDs.

---

## 6. Example interpretation (match 1886347)

| Team | Notable pattern |
|------|-----------------|
| 1805 | Higher defensive-third starts — deeper initial territory |
| 4177 | More possessions ending in attacking third (157 vs 57) — stronger territorial finishing |

Analysts can compare teams within a match without normalized rates because raw volumes reflect total offensive/defensive activity in the sample.

---

## 7. Limitations & future work

- **Sample size:** 10 matches — features describe behaviour in this sample, not league-wide baselines  
- **No phases_of_play CSV** in competition bundle — phase features use in-event phase type fields only  
- **Future:** merge with full SkillCorner repo structure; add complementary spatial features (e.g. sum of progressive pass distance into final third only); validate stability across seasons  

---

## 8. Submission artifacts

- `features.csv` — 20 rows × 39 columns (`match_id`, `team_id`, 37 features)  
- Reproducible R notebook (private per competition rules)  
- GitHub mirror for judges / host review  

---

## 9. Rubric alignment

| Criterion | How we address it |
|-----------|-------------------|
| **Concept & relevance (30%)** | Five tactical themes; each feature has clear football meaning |
| **Methodology & rigor (40%)** | Precise definitions; rule-compliant aggregates; validated row count |
| **Execution & quality (30%)** | Dynamic file discovery; documented dictionary; open GitHub + notebook |

---

*Submission remains private per competition rules until host review.*
