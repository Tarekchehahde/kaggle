# Soccer Hackathon — feature explainer dashboard (VPS / local).

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(plotly)
  library(scales)
})

source("../../R/load_soccer_features.R", local = TRUE)

FEAT <- load_soccer_features()
MATCHES <- sort(unique(FEAT$match_id))
FEAT_COLS <- setdiff(names(FEAT), c("match_id", "team_id"))

theme_soccer <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#16a34a",
  base_font = font_google("Inter")
)

match_teams <- function(mid) {
  FEAT |> filter(match_id == mid) |> pull(team_id)
}

ui <- page_navbar(
  title = "Soccer Feature Engineering",
  theme = theme_soccer,
  navbar_options = navbar_options(bg = "#16a34a"),
  footer = tagList(
    hr(),
    p(
      class = "text-muted small px-3",
      "Hackathon: ",
      tags$a(
        href = "https://www.kaggle.com/competitions/soccer-feature-engineering-hackathon",
        "Soccer Feature Engineering Hackathon"
      ),
      " · 37 rule-compliant team-level aggregates · GitHub Tarekchehahde/kaggle"
    )
  ),
  nav_panel(
    "Overview",
    layout_column_wrap(
      width = 1/4,
      value_box("Matches", length(MATCHES)),
      value_box("Team-rows", nrow(FEAT)),
      value_box("Features", length(FEAT_COLS)),
      value_box("Themes", length(FEATURE_GROUPS))
    ),
    card(
      card_header("Submission output preview"),
      DT::dataTableOutput("table_all")
    )
  ),
  nav_panel(
    "Match compare",
    layout_sidebar(
      sidebar = sidebar(
        selectInput("match_id", "Match ID", MATCHES, selected = MATCHES[1L]),
        selectInput("metric_group", "Feature group", names(FEATURE_GROUPS)),
        width = 280
      ),
      plotlyOutput("plot_match_compare", height = 420)
    )
  ),
  nav_panel(
    "Feature heatmap",
    layout_sidebar(
      sidebar = sidebar(
        selectInput("heatmap_group", "Feature group", names(FEATURE_GROUPS)),
        width = 260
      ),
      plotlyOutput("plot_heatmap", height = 480)
    )
  ),
  nav_panel(
    "Territory & tempo",
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Attacking third possessions (all teams)"),
        plotlyOutput("plot_territory", height = 320)
      ),
      card(
        card_header("Possession duration vs distance covered"),
        plotlyOutput("plot_tempo", height = 320)
      )
    )
  ),
  nav_panel(
    "Dictionary",
    card(
      card_header("Feature definitions"),
      DT::dataTableOutput("table_dict")
    )
  )
)

server <- function(input, output, session) {
  output$table_all <- DT::renderDataTable({
    FEAT
  }, options = list(pageLength = 10, scrollX = TRUE))

  output$plot_match_compare <- renderPlotly({
    cols <- FEATURE_GROUPS[[input$metric_group]]
    df <- FEAT |>
      filter(match_id == as.integer(input$match_id)) |>
      select(team_id, any_of(cols)) |>
      pivot_longer(-team_id, names_to = "feature", values_to = "value") |>
      mutate(
        label = ifelse(feature %in% names(FEATURE_LABELS), FEATURE_LABELS[feature], feature),
        team = paste0("Team ", team_id)
      )

    p <- ggplot(df, aes(label, value, fill = team)) +
      geom_col(position = "dodge") +
      coord_flip() +
      labs(x = NULL, y = "Raw aggregate", fill = NULL) +
      theme_minimal(base_size = 11)

    ggplotly(p)
  })

  output$plot_heatmap <- renderPlotly({
    cols <- FEATURE_GROUPS[[input$heatmap_group]]
    df <- FEAT |>
      mutate(row = paste0(match_id, " · T", team_id)) |>
      select(row, any_of(cols)) |>
      pivot_longer(-row, names_to = "feature", values_to = "value")

    p <- ggplot(df, aes(feature, row, fill = value, text = paste0(row, "\n", feature, ": ", value))) +
      geom_tile(color = "white") +
      scale_fill_viridis_c(option = "C") +
      labs(x = NULL, y = NULL, fill = NULL) +
      theme_minimal(base_size = 10) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    ggplotly(p, tooltip = "text")
  })

  output$plot_territory <- renderPlotly({
    df <- FEAT |>
      mutate(label = paste0("M", match_id, " · T", team_id)) |>
      arrange(desc(possessions_end_attacking_third))

    p <- ggplot(df, aes(reorder(label, possessions_end_attacking_third),
                        possessions_end_attacking_third,
                        fill = factor(team_id))) +
      geom_col(show.legend = FALSE) +
      labs(x = NULL, y = "Count") +
      theme_minimal(base_size = 11) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    ggplotly(p)
  })

  output$plot_tempo <- renderPlotly({
    df <- FEAT |>
      mutate(label = paste0("M", match_id, " · T", team_id))

    p <- ggplot(df, aes(possession_duration_sec, distance_covered_total_m,
                        color = factor(match_id), text = label)) +
      geom_point(size = 3, alpha = 0.85) +
      labs(
        x = "Possession duration (sec)",
        y = "Distance covered (m)",
        color = "Match"
      ) +
      theme_minimal(base_size = 12)

    ggplotly(p, tooltip = "text")
  })

  dict_df <- data.frame(
    feature = names(FEATURE_LABELS),
    label = unname(FEATURE_LABELS),
    group = vapply(names(FEATURE_LABELS), function(nm) {
      for (g in names(FEATURE_GROUPS)) {
        if (nm %in% FEATURE_GROUPS[[g]]) return(g)
      }
      "Other"
    }, character(1)),
    stringsAsFactors = FALSE
  )

  output$table_dict <- DT::renderDataTable(dict_df, options = list(pageLength = 15))
}

shinyApp(ui, server)
