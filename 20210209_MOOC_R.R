library(mongolite)
library(tidyverse)
library(plotly)

m_R <- mongo("messages_R", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1/bdd_grp4?authSource=admin")


mooc_R <- function() {

# Combien de publications chaque utilisateur a-t-il faites
pub_par_ut_R <- m_R$aggregate('[
            {"$group": {"_id":"$username","publications": {"$sum": 1 } } }, 
            {"$sort": {"publications": -1 } },
            {"$limit": 20}
            ]')

pub_par_ut_2_R <- pub_par_ut_R[-1,]  # nous éliminons le premier endroit qui est le formateur

# Top 20 des utilisateurs les plus actifs
plot_top_20_utilisateurs_R <- ggplot(pub_par_ut_2_R) +
  aes(x = reorder(`_id`, publications), weight = publications) +
  geom_bar(fill = "#0c4c8a") +
  coord_flip() +
  labs(title = "Top 20 des utilisateurs les plus actifs") +
  labs(x = "Utilisateurs") +
  theme_minimal()

plot_top_20_utilisateurs_plotly_R <- ggplotly(plot_top_20_utilisateurs_R)




# utilisateur qui a publié le plus grand nombre de messages
ut_plus_actif_R <- pub_par_ut_R[1,1]

# Combien de messages a-t-il postés
num_max_pub_R <- pub_par_ut_R[1,2]


# Combien de publications au total y a-t-il dans le MOOC?
tot_publications_R <- m_R$aggregate('[
            {"$group": {"_id":"$username","publications": {"$sum": 1 } } }, 
            {"$sort": {"publications": -1 } },
            {"$group":{"_id":"", "total":{"$sum":"$publications"}}}
            ]')


# Combien d'utilisateurs sont dans le MOOC
list_user_R <- m_R$distinct("username")
nombre_d_utilisateurs_R <- length(list_user_R)

# dans MongoDB: db.countries.distinct('country').length


#--------------------------------------------------------------

# Combien de messages ont été publiés au total par mois
m_R$aggregate('[{
              "$project":
              {
                "updated_at":1,
                "username":1,
                "date": { "$dateFromString": {"dateString": "$updated_at"} }
                
              }
},
{"$group":{"_id":{ "annee":{"$year":"$date"}, "mois":{"$month":"$date"}}, "subtotal":{"$sum":1}}},
            {"$sort":{"_id":1}}
]')



# On ajoute le résultat précédent dans une variable

df_par_mois_R <- m_R$aggregate('[{
              "$project":
              {
                "updated_at":1,
                "username":1,
                "date": { "$dateFromString": {"dateString": "$updated_at"} }
                
              }
},
{"$group":{"_id":{ "annee":{"$year":"$date"}, "mois":{"$month":"$date"}}, "subtotal":{"$sum":1}}},
            {"$sort":{"_id":1}}
]')

#nous mettons les données à plat, convertissant les colonnes id en colonnes normales avec flatten
#puis avec #mutate nous faisons la concaténation des colonnes du mois et de l'année 
#et le forçons à être une date en ajoutant 1 comme jour de chaque mois et un séparateur

df_votes_par_mois_R <- jsonlite::flatten(df_par_mois_R) %>%
  mutate(mois_annee=as.Date(paste(`_id.annee`,`_id.mois`,'01',sep='-')))

# On ajoute une nouvelle colonne au df avec le nom du mooc
df_votes_par_mois_R$MOOC <- "R"

# ici on fait le graphique "Nombre de commentaires par mois"
posts_par_mois_R <- ggplot(df_votes_par_mois_R) +
  aes(x = mois_annee, y = subtotal) +
  geom_line(size = 1L, colour = "#4292c6") +
  labs(x = "mois (2020/2021)", y = "Nombre de commentaires", title = "Nombre de commentaires par mois") +
  theme_classic()

posts_par_mois_plotly_R <- ggplotly(posts_par_mois_R)

return(list(utilisateurs = nombre_d_utilisateurs_R, 
            plus_actif = ut_plus_actif_R, 
            publications = tot_publications_R, 
            pub_plus_actif = num_max_pub_R,
            votes_par_mois = df_votes_par_mois_R,
            pub_par_ut = pub_par_ut_2_R))

}

result_R <- mooc_R()

result_R$utilisateurs
result_R$plus_actif
result_R$publications
result_R$pub_plus_actif
result_R$votes_par_mois
result_R$pub_par_ut







#- Combien d'utilisateurs sont dans le MOOC
# Combien de publications au total y a-t-il dans le MOOC?
# utilisateur qui a publié le plus grand nombre de messages (formateur)
# Combien de messages a-t-il postés


# graphique top 20 utilisateurs
# graphique des publications par mois
# mot nuage