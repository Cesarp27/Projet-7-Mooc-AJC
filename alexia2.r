library(mongolite)
library(ggplot2)
library(jsonlite)
library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(tm)
library(flipTextAnalysis)
library("SnowballC")

#import data from mongodb
m <- mongo("messages_Art_feminin", url = "mongodb://adeboynes:Ksd-Z9=gT<z~c@127.0.0.1:27018/bdd_grp4?authSource=admin")
n <- mongo("messages_Les_mots_du_pouvoir", url = "mongodb://adeboynes:Ksd-Z9=gT<z~c@127.0.0.1:27018/bdd_grp4?authSource=admin")

t <- m$find(
  query = '{}',
  fields = '{ "title":1,"votes.count":1,"username":1, "body":1 }',
  
)

print(t)

tt <- m$find(
  query = '{}',
  fields = '{"_id": 0,"body":1 }',
  
)
print(tt)


t$nwords <- lengths(strsplit(t$body, "\\s+"))

# EFA  nombre de commentaire par utilisateur
t1<-m$aggregate('[
            {"$group": {"_id":"$username","N": {"$sum": 1 } } }, 
            {"$sort": {"N": -1 } },
            {"$limit": 20}
        
            ]')

t1[is.na(t1$"_id"),]$"_id"=0
t1



tt1 = t1[order(t1$N),]
print(t1)

#histogramme nbre de commentaires par utilisateur EFA

plot1 <-ggplot(t1) +
  aes(x = reorder(`_id`, -N), weight = N) +
  geom_bar(fill = "#bd3786") +
  coord_flip() +
  theme_minimal()

plot1

#LMP commentaires par utilisateur

t2<-n$aggregate('[
            {"$group": {"_id":"$username","N": {"$sum": 1 } } }, 
            {"$sort": {"N": -1 } },
            {"$limit": 20}
        
            ]')

t2[is.na(t2$"_id"),]$"_id"=0

#histogramme nbre de commentaires par utilisateur MDP

plot2 <-ggplot(t2) +
 aes(x = reorder(`_id`, -N), weight = N) +
 geom_bar(fill = "#fde725") +
 coord_flip() +
 theme_minimal()


plot2



#wordcloud 
#create a vector containing only the text
text <- tt$body
# Create a corpus  
docs <- Corpus(VectorSource(text))

clean<-function(text){
docs <- docs %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("french"))
return(docs)
}


nuage<-function(x){dtm <- TermDocumentMatrix(x)
matrix <- as.matrix(dtm)
words <- sort(rowSums(matrix),decreasing=TRUE)
df <- data.frame(word = names(words),freq=words)


set.seed(1234) # for reproducibility 
wordcloud(words = df$word, freq = df$freq, min.freq = 1,max.words=200, random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))

}
docs<-clean(tt$body)
nuage(docs)



