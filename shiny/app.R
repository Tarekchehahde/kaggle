# AI Impact on Students — interactive exploration (Kaggle: laveshjadon/ai-impact-on-students).

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(ggplot2)
  library(plotly)
  library(scales)
})

source("../R/load_ai_students.R", local = TRUE)

STUDENTS <- load_ai_students()
MAJORS <- levels(STUDENTS$Major_Category)
YEARS <- levels(STUDENTS$Year_of_Study)
POLICIES <- levels(STUDENTS$Institutional_Policy)
BURNOUT_COLORS <- c(Low = "#10b981", Medium = "#f59e0b", High = "#ef4444")

theme_ai <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#6366f1",
  base_font = font_google("Inter")
)

filter_students <- function(majors, years, policies) {
  STUDENTS |>
    filter(
      Major_Category %in% majors,
      Year_of_Study %in% years,
      Institutional_Policy %in% policies
    )
}

ui <- page_navbar(
  title = "AI Impact on Students",
  theme = theme_ai,
  navbar_options = navbar_options(bg = "#6366f1"),
  footer = tagList(
    hr(),
    p(
      class = "text-muted small px-3",
      "Data: ",
      tags$a(
        href = "https://www.kaggle.com/datasets/laveshjadon/ai-impact-on-students",
        "Kaggle — laveshjadon/ai-impact-on-students"
      ),
      " (CC0-1.0). Synthetic student records for research/education."
    )
  ),
  sidebar = sidebar(
    width = 280,
    title = "Filters",
    checkboxGroupInput("majors", "Major", MAJORS, selected = MAJORS),
    checkboxGroupInput("years", "Year of study", YEARS, selected = YEARS),
    checkboxGroupInput("policies", "Institutional policy", POLICIES, selected = POLICIES),
    hr(),
    p(class = "small text-muted", "50k student profiles: GenAI usage, GPA, retention, burnout.")
  ),
  nav_panel(
    "Overview",
    layout_column_wrap(
      width = 1/4,
      value_box("Students", textOutput("kpi_n")),
      value_box("Median GPA change", textOutput("kpi_gpa")),
      value_box("Median GenAI hrs/week", textOutput("kpi_ai")),
      value_box("High burnout %", textOutput("kpi_burnout"))
    ),
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Burnout risk distribution"),
        plotOutput("plot_burnout_pie", height = 320)
      ),
      card(
        card_header("GPA change vs weekly GenAI hours"),
        plotlyOutput("plot_gpa_scatter", height = 320)
      )
    )
  ),
  nav_panel(
    "Institutional policy",
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Burnout mix by policy"),
        plotlyOutput("plot_policy_burnout", height = 380)
      ),
      card(
        card_header("Mean GPA change by policy"),
        plotOutput("plot_policy_gpa", height = 380)
      )
    )
  ),
  nav_panel(
    "Majors & AI use",
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("GenAI hours by major"),
        plotlyOutput("plot_major_genai", height = 360)
      ),
      card(
        card_header("High burnout rate by major"),
        plotOutput("plot_major_burnout", height = 360)
      )
    ),
    card(
      card_header("Primary AI use case"),
      plotOutput("plot_use_case", height = 280)
    )
  ),
  nav_panel(
    "Well-being",
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Skill retention vs AI dependency"),
        plotlyOutput("plot_retention_dep", height = 360)
      ),
      card(
        card_header("Exam anxiety vs GenAI hours"),
        plotlyOutput("plot_anxiety", height = 360)
      )
    ),
    card(
      card_header("Retention by prompt skill & dependency"),
      plotOutput("plot_retention_heat", height = 320)
    )
  ),
  nav_panel(
    "Data table",
    card(
      card_header("Filtered sample (first 500 rows)"),
      DT::dataTableOutput("table_sample")
    )
  )
)

server <- function(input, output, session) {
  filtered <- reactive({
    filter_students(input$majors, input$years, input$policies)
  })

  output$kpi_n <- renderText({
    format(nrow(filtered()), big.mark = ",")
  })

  output$kpi_gpa <- renderText({
    d <- median(filtered()$GPA_Delta, na.rm = TRUE)
    sprintf("%+.2f", d)
  })

  output$kpi_ai <- renderText({
    sprintf("%.1f h", median(filtered()$Weekly_GenAI_Hours, na.rm = TRUE))
  })

  output$kpi_burnout <- renderText({
    sprintf(
      "%.1f%%",
      mean(filtered()$Burnout_Risk_Level == "High", na.rm = TRUE) * 100
    )
  })

  output$plot_burnout_pie <- renderPlot({
    df <- filtered() |>
      count(Burnout_Risk_Level) |>
      mutate(Burnout_Risk_Level = factor(Burnout_Risk_Level, levels = names(BURNOUT_COLORS)))

    ggplot(df, aes(Burnout_Risk_Level, n, fill = Burnout_Risk_Level)) +
      geom_col(width = 0.65, show.legend = FALSE) +
      scale_fill_manual(values = BURNOUT_COLORS) +
      labs(x = NULL, y = "Students") +
      theme_minimal(base_size = 13)
  })

  output$plot_gpa_scatter <- renderPlotly({
    df <- filtered() |>
      slice_sample(n = min(4000L, n()))

    p <- ggplot(df, aes(Weekly_GenAI_Hours, GPA_Delta, color = Burnout_Risk_Level)) +
      geom_point(alpha = 0.25, size = 1.2) +
      geom_smooth(method = "loess", se = FALSE, color = "#1e293b", linewidth = 0.9) +
      scale_color_manual(values = BURNOUT_COLORS) +
      labs(
        x = "Weekly GenAI hours",
        y = "GPA change (post − pre)",
        color = "Burnout"
      ) +
      theme_minimal(base_size = 12)

    ggplotly(p, tooltip = "none") |>
      layout(showlegend = TRUE)
  })

  output$plot_policy_burnout <- renderPlotly({
    df <- filtered() |>
      count(Institutional_Policy, Burnout_Risk_Level) |>
      group_by(Institutional_Policy) |>
      mutate(pct = n / sum(n) * 100) |>
      ungroup()

    p <- ggplot(df, aes(Institutional_Policy, pct, fill = Burnout_Risk_Level)) +
      geom_col(position = "stack") +
      scale_fill_manual(values = BURNOUT_COLORS) +
      labs(x = NULL, y = "% of students", fill = "Burnout") +
      theme_minimal(base_size = 12) +
      theme(axis.text.x = element_text(angle = 25, hjust = 1))

    ggplotly(p)
  })

  output$plot_policy_gpa <- renderPlot({
    df <- filtered() |>
      group_by(Institutional_Policy) |>
      summarise(
        mean_delta = mean(GPA_Delta, na.rm = TRUE),
        se = sd(GPA_Delta, na.rm = TRUE) / sqrt(n()),
        .groups = "drop"
      )

    ggplot(df, aes(reorder(Institutional_Policy, mean_delta), mean_delta)) +
      geom_col(fill = "#6366f1", width = 0.6) +
      geom_errorbar(aes(ymin = mean_delta - se, ymax = mean_delta + se), width = 0.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "#94a3b8") +
      labs(x = NULL, y = "Mean GPA change") +
      theme_minimal(base_size = 12) +
      theme(axis.text.x = element_text(angle = 25, hjust = 1))
  })

  output$plot_major_genai <- renderPlotly({
    df <- filtered() |>
      group_by(Major_Category) |>
      summarise(mean_genai = mean(Weekly_GenAI_Hours, na.rm = TRUE), .groups = "drop") |>
      arrange(desc(mean_genai))

    p <- ggplot(df, aes(reorder(Major_Category, mean_genai), mean_genai)) +
      geom_col(fill = "#818cf8") +
      coord_flip() +
      labs(x = NULL, y = "Mean weekly GenAI hours") +
      theme_minimal(base_size = 12)

    ggplotly(p)
  })

  output$plot_major_burnout <- renderPlot({
    df <- filtered() |>
      group_by(Major_Category) |>
      summarise(
        pct = mean(Burnout_Risk_Level == "High", na.rm = TRUE) * 100,
        .groups = "drop"
      ) |>
      arrange(desc(pct))

    ggplot(df, aes(reorder(Major_Category, pct), pct)) +
      geom_col(fill = "#ef4444", width = 0.65) +
      coord_flip() +
      labs(x = NULL, y = "High burnout (%)") +
      theme_minimal(base_size = 12)
  })

  output$plot_use_case <- renderPlot({
    df <- filtered() |>
      count(Primary_Use_Case, sort = TRUE) |>
      mutate(Primary_Use_Case = reorder(Primary_Use_Case, n))

    ggplot(df, aes(Primary_Use_Case, n)) +
      geom_col(fill = "#6366f1", width = 0.7) +
      coord_flip() +
      labs(x = NULL, y = "Students") +
      theme_minimal(base_size = 12)
  })

  output$plot_retention_dep <- renderPlotly({
    df <- filtered() |>
      group_by(Perceived_AI_Dependency) |>
      summarise(
        mean_retention = mean(Skill_Retention_Score, na.rm = TRUE),
        n = n(),
        .groups = "drop"
      )

    p <- ggplot(df, aes(Perceived_AI_Dependency, mean_retention, size = n)) +
      geom_point(color = "#6366f1", alpha = 0.85) +
      geom_smooth(method = "loess", se = TRUE, color = "#334155", linewidth = 0.8) +
      labs(
        x = "Perceived AI dependency (1–10)",
        y = "Mean skill retention score",
        size = "Students"
      ) +
      theme_minimal(base_size = 12)

    ggplotly(p)
  })

  output$plot_anxiety <- renderPlotly({
    df <- filtered() |>
      slice_sample(n = min(3000L, n()))

    p <- ggplot(df, aes(Weekly_GenAI_Hours, Anxiety_Level_During_Exams, color = Burnout_Risk_Level)) +
      geom_point(alpha = 0.2, size = 1.2) +
      scale_color_manual(values = BURNOUT_COLORS) +
      labs(
        x = "Weekly GenAI hours",
        y = "Exam anxiety (1–10)",
        color = "Burnout"
      ) +
      theme_minimal(base_size = 12)

    ggplotly(p, tooltip = "none")
  })

  output$plot_retention_heat <- renderPlot({
    df <- filtered() |>
      mutate(
        dep_bin = cut(
          Perceived_AI_Dependency,
          breaks = c(0, 3, 6, 10),
          labels = c("Low", "Mid", "High"),
          include.lowest = TRUE
        )
      ) |>
      group_by(dep_bin, Prompt_Engineering_Skill) |>
      summarise(ret = mean(Skill_Retention_Score, na.rm = TRUE), .groups = "drop")

    ggplot(df, aes(Prompt_Engineering_Skill, dep_bin, fill = ret)) +
      geom_tile(color = "white") +
      scale_fill_viridis_c(option = "C", limits = c(60, 90)) +
      labs(
        x = "Prompt engineering skill",
        y = "AI dependency",
        fill = "Retention"
      ) +
      theme_minimal(base_size = 12)
  })

  output$table_sample <- DT::renderDataTable({
    filtered() |>
      select(
        Student_ID, Major_Category, Year_of_Study,
        Weekly_GenAI_Hours, GPA_Delta, Skill_Retention_Score,
        Burnout_Risk_Level, Institutional_Policy
      ) |>
      head(500)
  }, options = list(pageLength = 10, scrollX = TRUE))
}

shinyApp(ui, server)
