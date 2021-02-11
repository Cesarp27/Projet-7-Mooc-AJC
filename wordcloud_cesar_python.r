library(mongolite)
library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(dplyr)
library(NLP)
library(tm)

#édition de la librairie wordcloud2 afin que le nuage de mots et d'autres graphiques puissent être affichés en même temps
#--------------------------------------------------------------------------------------------

wordcloud2a <- function (data, size = 1, minSize = 0, gridSize = 0, fontFamily = "Segoe UI", 
                         fontWeight = "bold", color = "random-dark", backgroundColor = "white", 
                         minRotation = -pi/4, maxRotation = pi/4, shuffle = TRUE, 
                         rotateRatio = 0.4, shape = "circle", ellipticity = 0.65, 
                         widgetsize = NULL, figPath = NULL, hoverFunction = NULL) 
{
  if ("table" %in% class(data)) {
    dataOut = data.frame(name = names(data), freq = as.vector(data))
  }
  else {
    data = as.data.frame(data)
    dataOut = data[, 1:2]
    names(dataOut) = c("name", "freq")
  }
  if (!is.null(figPath)) {
    if (!file.exists(figPath)) {
      stop("cannot find fig in the figPath")
    }
    spPath = strsplit(figPath, "\\.")[[1]]
    len = length(spPath)
    figClass = spPath[len]
    if (!figClass %in% c("jpeg", "jpg", "png", "bmp", "gif")) {
      stop("file should be a jpeg, jpg, png, bmp or gif file!")
    }
    base64 = base64enc::base64encode(figPath)
    base64 = paste0("data:image/", figClass, ";base64,", 
                    base64)
  }
  else {
    base64 = NULL
  }
  weightFactor = size * 180/max(dataOut$freq)
  settings <- list(word = dataOut$name, freq = dataOut$freq, 
                   fontFamily = fontFamily, fontWeight = fontWeight, color = color, 
                   minSize = minSize, weightFactor = weightFactor, backgroundColor = backgroundColor, 
                   gridSize = gridSize, minRotation = minRotation, maxRotation = maxRotation, 
                   shuffle = shuffle, rotateRatio = rotateRatio, shape = shape, 
                   ellipticity = ellipticity, figBase64 = base64, hover = htmlwidgets::JS(hoverFunction))
  chart = htmlwidgets::createWidget("wordcloud2", settings, 
                                    width = widgetsize[1], height = widgetsize[2], sizingPolicy = htmlwidgets::sizingPolicy(viewer.padding = 0, 
                                                                                                                            browser.padding = 0, browser.fill = TRUE))
  chart
}

#-----------------------------fin de l'édition de librairie--------------------------------------------------------------------------------------------------------------


#Importation des collections dans les variables 
#m_pq <- mongo("messages_Physique_Quantique", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1:27017/bdd_grp4?authSource=admin")
#m_af <- mongo("messages_Art_feminin", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1:27017/bdd_grp4?authSource=admin")
#m_mp <- mongo("messages_Les_mots_du_pouvoir", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1:27017/bdd_grp4?authSource=admin")
m <- mongo("messages_Python_vf", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1:27017/bdd_grp4?authSource=admin")

wordcloud_python <- function() {

#Construction de la df s'appuyant sur la key body
text <- m$aggregate('[{"$project": {"_id":0,"body":"$body"}}]')

# Create a corpus  
docs <- Corpus(VectorSource(text$body))

docs <- docs %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("french"))

dtm <- TermDocumentMatrix(docs) 
matrix <- as.matrix(dtm) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
df_p <- data.frame(word = names(words),freq=words)

return(df_p)

}

result_W_python <- wordcloud_python()

set.seed(1234) # for reproducibility 
wordcloud2a(data=result_W_python, size=0.5, color='random-dark')


