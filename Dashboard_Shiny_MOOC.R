# fbrisadelamontaña()

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
                  collapsible = TRUE,width = 4,
                  plotlyOutput("plot1_p")),
                box(
                  title = "Top 20 des utilisateurs les plus actifs", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,width = 4,
                  plotlyOutput("plot2_p")),
                
                box(
                  title = "Word cloud Python", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE,width = 4,
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
                  collapsible = TRUE, width = 4,
                  plotlyOutput("plot1_r")),
                box(
                  title = "Top 20 des utilisateurs les plus actifs", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE, width = 4,
                  plotlyOutput("plot2_r")),
              
                box(
                  title = "Word cloud R", status = "primary",solidHeader = TRUE,
                  collapsible = TRUE, width = 4,
                  wordcloud2Output("cloud_R")
                )
              )
              
      ),
      
      # quatrième content
      tabItem(tabName = "donnees", div(class = "my-class", p("")),
              div(class = "my-class", a("Quelques exemples", href = "https://rstudio.github.io/shinydashboard/examples.html")),
      )

)
)
)

server <- function(input, output) {
  
#----------- server de Python --------------------------------------------------------------------
  
  #  Début infoBoxes
  
  # result_python$votes_par_mois -- est dans le fichier 20210208_MOOC_python.R
  output$plot1_p <-  renderPlotly({ 
    ggplotly(ggplot(result_python$votes_par_mois) +     
      aes(x = mois_annee, y = subtotal) +
      geom_line(size = 1L, colour = "#4292c6") +
      labs(x = "mois (2020/2021)", y = "Nombre de commentaires") +
      theme_classic())
  })
  
  
  # result_python$pub_par_ut -- est dans le fichier 20210208_MOOC_python.R
  output$plot2_p <-  renderPlotly({ 
    ggplotly(ggplot(result_python$pub_par_ut) +
      aes(x = reorder(`_id`, publications), weight = publications) +
      geom_bar(fill = "#0c4c8a") +
      coord_flip() +
      labs(x = "Utilisateurs") +
      theme_minimal())
  })
  
  
  # result_W_python  --  est dans le fichier wordcloud_cesar_python.r
  output$cloud <- renderWordcloud2({
    wordcloud2a(data=result_W_python, size=0.4, color='random-dark', shape = 'diamond')
  })
  
  # result_python$utilisateurs -- est dans le fichier 20210208_MOOC_python.R
  output$progressBox_p <- renderInfoBox({
    infoBox(
      "Nombre de utilisateurs", result_python$utilisateurs, icon = icon("list"),
      color = "aqua"
    )
  })
  
  # result_python$plus_actif -- est dans le fichier 20210208_MOOC_python.R
  output$approvalBox_p <- renderInfoBox({
    infoBox(
      "Utilisateur plus actif", result_python$plus_actif, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  # Same as above, but with fill=TRUE
  # result_python$publications -- est dans le fichier 20210208_MOOC_python.R
  output$progressBox2_p <- renderInfoBox({
    infoBox(
      "nombre total de publications", result_python$publications, icon = icon("list"),
      color = "aqua", fill = TRUE
    )
  })
  
  # result_python$pub_plus_actif -- est dans le fichier 20210208_MOOC_python.R
  output$approvalBox2_p <- renderInfoBox({
    infoBox(
      "Nombre de posts", result_python$pub_plus_actif, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
#----------- server de R --------------------------------------------------------------------
  
  # result_R$votes_par_mois -- est dans le fichier 20210209_MOOC_R.R
  output$plot1_r <-  renderPlotly({ 
    ggplotly(ggplot(result_R$votes_par_mois) + 
               aes(x = mois_annee, y = subtotal) +
               geom_line(size = 1L, colour = "#4292c6") +
               labs(x = "mois", y = "Nombre de commentaires") +
               theme_classic())
  })
  
  # result_R$pub_par_ut -- est dans le fichier 20210209_MOOC_R.R
  output$plot2_r <-  renderPlotly({ 
    ggplotly(ggplot(result_R$pub_par_ut) +
               aes(x = reorder(`_id`, publications), weight = publications) +
               geom_bar(fill = "#0c4c8a") +
               coord_flip() +
               labs(x = "Utilisateurs") +
               theme_minimal())
  })
  
  # result_W_python  --  est dans le fichier wordcloud_cesar_R.r
  output$cloud_R <- renderWordcloud2({
    wordcloud2a(data=result_W_R, size=0.4, color='random-dark', shape = 'diamond')
  })
  
  # result_R$utilisateurs -- est dans le fichier 20210209_MOOC_R.R
  output$progressBox_r <- renderInfoBox({
    infoBox(
      "Nombre de utilisateurs", result_R$utilisateurs, icon = icon("list"),
      color = "aqua"
    )
  })
  
  #result_R$plus_actif -- est dans le fichier 20210209_MOOC_R.R
  output$approvalBox_r <- renderInfoBox({
    infoBox(
      "Utilisateur plus actif", result_R$plus_actif, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  # Same as above, but with fill=TRUE
  # result_R$publications -- est dans le fichier 20210209_MOOC_R.R
  output$progressBox2_r <- renderInfoBox({
    infoBox(
      "nombre total de publications", result_R$publications, icon = icon("list"),
      color = "aqua", fill = TRUE
    )
  })
  
  #result_R$pub_plus_actif -- est dans le fichier 20210209_MOOC_R.R
  output$approvalBox2_r <- renderInfoBox({
    infoBox(
      "Nombre de posts", result_R$pub_plus_actif, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
  #  fin infoBoxes
}


shinyApp(ui, server)















