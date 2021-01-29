library(mongolite)
m <- mongo("Python_vf", url = "mongodb://cparra:i.}4rF-e(-mUE@127.0.0.1/bdd_grp4?authSource=admin")

x <- m$aggregate('[{"$group": {"_id":"$content.course_id","N": {"$sum": 1 } } }, {"$sort": {"N": -1 } }, {"$limit": 20} ]')
#NOTE: on passe une string (avec guillemet simple) et dedans un JSON (avec des guillemet doublmes pour les clefs)
#m$find('{"x":999}')

#m$aggregate('[{"$limit": 2}]')

#m$find('{"x":"pour valeurs positives, utilisation de if ou for ?"}')

m$find('{ "content.username":"jejezman-56" }')

# Celui-ci fonctionne bien
m$aggregate('[
            {"$match": {"content.username":"jejezman-56" } },
            {"$group": {"_id":"$content.username","N": {"$sum": 1 } } }, 
            {"$sort": {"N": -1 } },
            {"$limit": 20}
            ]')

# Celui-ci fonctionne bien aussi
m$aggregate('[
            {"$group": {"_id":"$content.username","N": {"$sum": 1 } } }, 
            {"$sort": {"N": -1 } },
            {"$limit": 20}
            ]')


m$aggregate('[
            {"$group": {"_id":"$content.course_id","N": {"$sum": 1 } } }, 
            {"$sort": {"N": -1 } }, 
            {"$limit": 20} 
            ]')


db.Python_vf.aggregate([
  {$project:
      {
        usuario: '$content.username',
        id: '$content.course_id',
        status: {$cond:{if:'$lte:['}}
      }
    
    
  }
])
  
