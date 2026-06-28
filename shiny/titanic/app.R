# Titanic — survival exploration (Kaggle competition: titanic)

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(ggplot2)
  library(plotly)
  library(scales)
})

source("../../R/load_titanic.R", local = TRUE)

TRAIN <- load_titanic_train()
SURV_COLORS <- c(Died = "#64748b", Survived = "#0ea5e9")

theme_titanic <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#0ea5e9",
  base_font = font_google("Inter")
)

sample_rows <- function(df, k) {
  dplyr::slice_sample(df, n = min(k, nrow(df)))
}

filter_passengers <- function(df, sexes, classes, embarked) {
  df |>
    filter(
      Sex %in% sexes,
      Pclass %in% classes,
      Embarked %in% embarked | is.na(Embarked)
    )
}

ui <- page_navbar(
  title = "Titanic Survival",
  theme = theme_titanic,
  navbar_options = navbar_options(bg = "#0ea5e9"),
  footer = tagList(
    hr(),
    p(
      class = "text-muted small px-3",
      "Data: ",
      tags$a(href = "https://www.kaggle.com/c/titanic", "Kaggle — Titanic competition"),
      " (train.csv, 891 passengers)."
    )
  ),
  sidebar = sidebar(
    width = 260,
    title = "Filters",
    checkboxGroupInput("sexes", "Sex", levels(TRAIN$Sex), selected = levels(TRAIN$Sex)),
    checkboxGroupInput("classes", "Class", levels(TRAIN$Pclass), selected = levels(TRAIN$Pclass)),
    checkboxGroupInput(
      "embarked", "Embarked",
      c("C", "Q", "S"),
      selected = c("C", "Q", "S")
    ),
    hr(),
    p(class = "small text-muted", "Classic starter: who survived the Titanic?")
  ),
  nav_panel(
    "Overview",
    layout_column_wrap(
      width = 1/4,
      value_box("Passengers", textOutput("kpi_n")),
      value_box("Survival rate", textOutput("kpi_surv")),
      value_box("Median age", textOutput("kpi_age")),
      value_box("Median fare", textOutput("kpi_fare"))
    ),
    layout_column_wrap(
      width = 1/2,
      card(card_header("Survival counts"), plotOutput("plot_surv_bar", height = 300)),
      card(card_header("Survival rate by sex"), plotlyOutput("plot_sex", height = 300))
    )
  ),
  nav_panel(
    "Class & fare",
    layout_column_wrap(
      width = 1/2,
      card(card_header("Survival by passenger class"), plotlyOutput("plot_class", height = 340)),
      card(card_header("Fare vs age (train)"), plotlyOutput("plot_fare_age", height = 340))
    ),
    card(card_header("Median fare by class and survival"), plotOutput("plot_fare_class", height = 280))
  ),
  nav_panel(
    "Families",
    layout_column_wrap(
      width = 1/2,
      card(card_header("Survival by family size"), plotlyOutput("plot_family", height = 340)),
      card(card_header("Traveling alone vs with family"), plotOutput("plot_alone", height = 340))
    )
  ),
  nav_panel(
    "Model hint",
    card(
      card_header("Simple logistic regression (Survived ~ Sex + Pclass + Age + Fare)"),
      p(class = "text-muted small", "Quick benchmark — not a competition submission."),
      verbatimTextOutput("model_summary")
    )
  ),
  nav_panel(
    "Data",
    card(card_header("Training sample"), DT::dataTableOutput("table_train"))
  )
)

server <- function(input, output, session) {
  filtered <- reactive({
    filter_passengers(filter(TRAIN, !is.na(Embarked)), input$sexes, input$classes, input$embarked)
  })

  output$kpi_n <- renderText(format(nrow(filtered()), big.mark = ","))
  output$kpi_surv <- renderText({
    pct <- mean(filtered()$Survived == "Survived", na.rm = TRUE) * 100
    paste0(round(pct, 1), "%")
  })
  output$kpi_age <- renderText({
    sprintf("%.0f yrs", median(filtered()$Age, na.rm = TRUE))
  })
  output$kpi_fare <- renderText({
    sprintf("$%.2f", median(filtered()$Fare, na.rm = TRUE))
  })

  output$plot_surv_bar <- renderPlot({
    df <- filtered() |> count(Survived)
    ggplot(df, aes(Survived, n, fill = Survived)) +
      geom_col(width = 0.6, show.legend = FALSE) +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = NULL, y = "Passengers") +
      theme_minimal(base_size = 13)
  })

  output$plot_sex <- renderPlotly({
    df <- filtered() |>
      count(Sex, Survived) |>
      group_by(Sex) |>
      mutate(rate = n / sum(n)) |>
      ungroup()
    p <- ggplot(df, aes(Sex, rate, fill = Survived)) +
      geom_col(position = "stack") +
      scale_y_continuous(labels = percent_format()) +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = NULL, y = "Share", fill = NULL) +
      theme_minimal(base_size = 12)
    ggplotly(p)
  })

  output$plot_class <- renderPlotly({
    df <- filtered() |>
      count(Pclass, Survived) |>
      group_by(Pclass) |>
      mutate(rate = n / sum(n)) |>
      ungroup()
    p <- ggplot(df, aes(Pclass, rate, fill = Survived)) +
      geom_col(position = "dodge") +
      scale_y_continuous(labels = percent_format()) +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = "Class", y = "Share", fill = NULL) +
      theme_minimal(base_size = 12)
    ggplotly(p)
  })

  output$plot_fare_age <- renderPlotly({
    df <- sample_rows(filtered() |> filter(!is.na(Age), !is.na(Fare)), 500L)
    p <- ggplot(df, aes(Age, Fare, color = Survived)) +
      geom_point(alpha = 0.7, size = 2) +
      scale_y_log10() +
      scale_color_manual(values = SURV_COLORS) +
      labs(x = "Age", y = "Fare (log scale)", color = NULL) +
      theme_minimal(base_size = 12)
    ggplotly(p, tooltip = "none")
  })

  output$plot_fare_class <- renderPlot({
    df <- filtered() |>
      filter(!is.na(Fare)) |>
      group_by(Pclass, Survived) |>
      summarise(median_fare = median(Fare), .groups = "drop")
    ggplot(df, aes(Pclass, median_fare, fill = Survived)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = "Class", y = "Median fare ($)", fill = NULL) +
      theme_minimal(base_size = 12)
  })

  output$plot_family <- renderPlotly({
    df <- filtered() |>
      count(FamilySize, Survived) |>
      group_by(FamilySize) |>
      mutate(rate = n / sum(n)) |>
      ungroup() |>
      filter(FamilySize <= 8)
    p <- ggplot(df, aes(FamilySize, rate, fill = Survived)) +
      geom_col(position = "stack") +
      scale_y_continuous(labels = percent_format()) +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = "Family size (SibSp + Parch + 1)", y = "Share", fill = NULL) +
      theme_minimal(base_size = 12)
    ggplotly(p)
  })

  output$plot_alone <- renderPlot({
    df <- filtered() |>
      mutate(group = if_else(Alone, "Alone", "With family")) |>
      count(group, Survived) |>
      group_by(group) |>
      mutate(rate = n / sum(n)) |>
      ungroup()
    ggplot(df, aes(group, rate, fill = Survived)) +
      geom_col(position = "stack") +
      scale_y_continuous(labels = percent_format()) +
      scale_fill_manual(values = SURV_COLORS) +
      labs(x = NULL, y = "Share", fill = NULL) +
      theme_minimal(base_size = 12)
  })

  output$model_summary <- renderPrint({
    df <- filtered() |>
      filter(!is.na(Age), !is.na(Fare)) |>
      mutate(y = as.integer(Survived == "Survived"))
    fit <- glm(y ~ Sex + Pclass + Age + Fare, data = df, family = binomial())
    summary(fit)
  })

  output$table_train <- DT::renderDataTable({
    filtered() |>
      select(PassengerId, Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked, FamilySize) |>
      head(300)
  }, options = list(pageLength = 10, scrollX = TRUE))
}

shinyApp(ui, server)
