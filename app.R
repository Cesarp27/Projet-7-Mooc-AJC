#if (interactive()) {
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(mongolite)
library(syuzhet)
library(stringr)
library(dplyr)
library(ggplot2)
library(NLP)
library(tm)
library(wordcloud)
library(wordcloud2)

#####################
trait_sent <- function (df_t) {
    df2 <- str_replace_all(df_t, "\n"," ")
    char_v <- get_sentences(df2)
    method <- "nrc"
    lang <- "french"
    head(char_v)
    mtv <- get_nrc_sentiment(char_v, language=lang)
    mtv2 <- as.data.frame(cbind(sort(colSums(prop.table(mtv[,1:8]))))) %>%
    mutate(sent=row.names(.)) %>%
    rename(per=V1)
    return(mtv2)
    }

###############
#Fonction clean qui permet de traiter le texte pour le rendre plus opérable
clean <- function(text){
    docs <- Corpus(VectorSource(text)) 
    toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
    docs <- tm_map(docs, toSpace, "/") 
    docs <- tm_map(docs, content_transformer(tolower))
    docs <- tm_map(docs, removeNumbers)
    docs <- tm_map(docs, removeWords, stopwords("french"))
    docs <- tm_map(docs, removePunctuation)
    docs <- tm_map(docs, stripWhitespace)
    return(docs)
}

#Fonction nuage pour compter les mots et créer le nuage de mots
nuage <- function(x){dtm <- TermDocumentMatrix(x)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
set.seed(1234)
wordcloud2(data=d)}

# Define UI for application that draws a histogram
ui <- dashboardPage(
    dashboardHeader(title = "Sentiment Analysis"),
    dashboardSidebar(
        pickerInput(
            inputId = "Mooc",
            label = "Les Moocs",
            choices = c(
                "Les mots du pouvoir"="messages_Les_mots_du_pouvoir",
                "Elles font l'art"="messages_Art_feminin",
                "Introduction à la physique quantique"="messages_Physique_Quantique",
                "Apprendre à coder avec Python"="messages_Python_vf"
                )
        )
    ),
    dashboardBody(
        #shinyDashboardThemes(theme = "blue_gradient"),
        # Boxes need to be put in a row (or column)
        fluidRow(
            boxPlus(title = "Le nuage", background = "maroon", solidHeader = TRUE, closable = FALSE, collapsible = TRUE, height = "80vh", wordcloud2Output("wordcloud", height = "72vh")),
            #boxPlus(title = "La roue", background = "black", solidHeader = TRUE, closable = FALSE, collapsible = TRUE, plotOutput("plot1")),
            boxPlus(title = "Plop",  background = "black", solidHeader = TRUE, closable = FALSE, collapsible = TRUE, verbatimTextOutput("value")),
            boxPlus(title = "Plip",  background = "black", solidHeader = TRUE, closable = FALSE, collapsible = TRUE,  tableOutput("table"))
            )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    reac_dfval <- reactive({ 
        o <- mongo(input$Mooc, url = "mongodb://jphilippe:yAk%252M%3C%28WavU%40@127.0.0.1:27017/bdd_grp4?authSource=admin")
        o$aggregate('[{"$project": {"_id":0,"body":"$body"}}]')
        })
    
    output$table <- renderTable(reac_dfval()$body[1])
    output$value <- renderPrint(input$Mooc)
    
    output$plot1 <- renderPlot({
        mtv2 <- trait_sent(reac_dfval()$body)
        plot <- ggplot(mtv2,
                       aes(
                           x = sent,
                           y = per,
                           fill = sent,
                           text="daadad"
                       )) +
            geom_col(width = 1, color = "white") +
            coord_polar()+ labs(
                x = "",
                y = ""#,
                #title = "Your Title",
                #subtitle = "Your Subtitle", 
                #caption = "Your Caption"
            ) +
            theme_minimal()+
            theme(
                legend.position = "none",
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks = element_blank(),
                axis.text.y = element_blank(),
                axis.text.x = element_text(face = "bold"),
                plot.title = element_text(size = 24, face = "bold"),
                plot.subtitle = element_text(size = 12)
            )
        plot
        # generate bins based on input$bins from ui.R
        #x    <- faithful[, 2]
        #"bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })


    output$wordcloud <- renderWordcloud2({
        docs <- clean(reac_dfval()$body)
        nuage(docs)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
#}