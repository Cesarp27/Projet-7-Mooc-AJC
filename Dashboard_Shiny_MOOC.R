library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(dplyr)
library(NLP)
library(tm)
library(wordcloud)
library(wordcloud2)

ui <- dashboardPage(
  dashboardHeader(title = "Dashboard DataLab"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("MOOC Python", tabName = "dashboard_python", icon = icon("dashboard")),
      menuItem("MOOC R", tabName = "dashboard_R", icon = icon("dashboard")),
      menuItem("Exemples", tabName = "donnees", icon = icon("file-code-o"))
    )
  ),
  ## Body content
  dashboardBody(
    
    tags$head(tags$style(HTML('
      .my-class { 
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 24px;
      }
    '))),
    
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                
                box(
                  title = "Controls", status = "primary", solidHeader = TRUE,
                  collapsible = TRUE,
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                ),
                
                # A static infoBox
                infoBox("New Orders", 10 * 2, icon = icon("credit-card")),
                # Dynamic infoBoxes
                infoBoxOutput("progressBox"),
                infoBoxOutput("approvalBox")
              ),
              
              # infoBoxes with fill=TRUE
              fluidRow(
                infoBox("New Orders", 10 * 2, icon = icon("credit-card"), fill = TRUE),
                infoBoxOutput("progressBox2"),
                infoBoxOutput("approvalBox2")
              ),
              
              fluidRow(
                # Clicking this will increment the progress amount
                box(width = 4, actionButton("count", "Increment progress")),
                box(
                  title = "Histogram", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot1", height = 250)),
                box(
                  title = "Histogram", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotOutput("plot2", height = 250))
              )
      
      
        ),
      # Second tab content
      tabItem(tabName = "dashboard_python",
              fluidRow(
                
                # Dynamic infoBoxes
                infoBoxOutput("progressBox_p", width = 6),
                infoBoxOutput("approvalBox_p", width = 6)
              ),
              
              # infoBoxes with fill=TRUE
              fluidRow(
                infoBoxOutput("progressBox2_p", width = 6),
                infoBoxOutput("approvalBox2_p", width = 6)
              ),
              
              fluidRow(
                # Clicking this will increment the progress amount
                
                box(
                  title = "Nombre de commentaires par mois", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotlyOutput("plot1_p", height = 350)),
                box(
                  title = "Top 20 des utilisateurs les plus actifs", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotlyOutput("plot2_p", height = 350))
              ),
              
              fluidRow(
                
                box(
                  title = "Top 20 des utilisateurs les plus actifs", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  wordcloud2Output("cloud")
                  )
              )
              
      ),
      
      # troisième tab content
      tabItem(tabName = "dashboard_R",
              fluidRow(
                
                # Dynamic infoBoxes
                infoBoxOutput("progressBox_r", width = 6),
                infoBoxOutput("approvalBox_r", width = 6)
              ),
              
              # infoBoxes with fill=TRUE
              fluidRow(
                infoBoxOutput("progressBox2_r", width = 6),
                infoBoxOutput("approvalBox2_r", width = 6)
              ),
              
              fluidRow(
                # Clicking this will increment the progress amount
                
                box(
                  title = "Nombre de commentaires par mois", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotlyOutput("plot1_r", height = 350)),
                box(
                  title = "Top 20 des utilisateurs les plus actifs", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,
                  plotlyOutput("plot2_r", height = 350))
              )
              
      ),
      
      # tquatrième content
      tabItem(tabName = "donnees", div(class = "my-class", p("")),
              div(class = "my-class", a("Quelques exemples", href = "https://rstudio.github.io/shinydashboard/examples.html")),
      )

)
)
)

server <- function(input, output) {
  #  Début infoBoxes
  
  output$plot1_p <-  renderPlotly({ 
    ggplotly(ggplot(df_votes_par_mois_python) + 
      aes(x = mois_annee, y = subtotal) +
      geom_line(size = 1L, colour = "#4292c6") +
      labs(x = "mois (2020/2021)", y = "Nombre de commentaires") +
      theme_classic())
  })
  
  output$plot2_p <-  renderPlotly({ 
    ggplotly(ggplot(pub_par_ut_2_python) +
      aes(x = reorder(`_id`, publications), weight = publications) +
      geom_bar(fill = "#0c4c8a") +
      coord_flip() +
      labs(x = "Utilisateurs") +
      theme_minimal())
  })
  
  output$cloud <- renderWordcloud2({
    wordcloud2a(data=df_p, size=0.6, color='random-dark')
  })
    
  output$progressBox_p <- renderInfoBox({
    infoBox(
      "Nombre de utilisateurs", nombre_d_utilisateurs_python, icon = icon("list"),
      color = "aqua"
    )
  })
  output$approvalBox_p <- renderInfoBox({
    infoBox(
      "Utilisateur plus actif", ut_plus_actif_python, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  # Same as above, but with fill=TRUE
  output$progressBox2_p <- renderInfoBox({
    infoBox(
      "nombre total de publications", tot_publications_python, icon = icon("list"),
      color = "aqua", fill = TRUE
    )
  })
  output$approvalBox2_p <- renderInfoBox({
    infoBox(
      "Nombre de posts", num_max_pub_python, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
#----------- server de R --------------------------------------------------------------------
  
  output$plot1_r <-  renderPlotly({ 
    ggplotly(ggplot(df_votes_par_mois_R) + 
               aes(x = mois_annee, y = subtotal) +
               geom_line(size = 1L, colour = "#4292c6") +
               labs(x = "mois (2020/2021)", y = "Nombre de commentaires") +
               theme_classic())
  })
  
  output$plot2_r <-  renderPlotly({ 
    ggplotly(ggplot(pub_par_ut_2_R) +
               aes(x = reorder(`_id`, publications), weight = publications) +
               geom_bar(fill = "#0c4c8a") +
               coord_flip() +
               labs(x = "Utilisateurs") +
               theme_minimal())
  })
  
  output$progressBox_r <- renderInfoBox({
    infoBox(
      "Nombre de utilisateurs", nombre_d_utilisateurs_R, icon = icon("list"),
      color = "aqua"
    )
  })
  output$approvalBox_r <- renderInfoBox({
    infoBox(
      "Utilisateur plus actif", ut_plus_actif_R, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  # Same as above, but with fill=TRUE
  output$progressBox2_r <- renderInfoBox({
    infoBox(
      "nombre total de publications", tot_publications_R, icon = icon("list"),
      color = "aqua", fill = TRUE
    )
  })
  output$approvalBox2_r <- renderInfoBox({
    infoBox(
      "Nombre de posts", num_max_pub_R, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
  #  fin infoBoxes
}


shinyApp(ui, server)















