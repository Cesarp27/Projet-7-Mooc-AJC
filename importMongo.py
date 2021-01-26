#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 26 12:09:35 2021

@author: formateur
"""

import config
import requests
from pprint import pprint
from pymongo import MongoClient
import urllib

client = MongoClient('mongodb://%s:%s@%s/?authSource=%s'% (config.user, urllib.parse.quote(config.password),'127.0.0.1', 'admin'))
db = client['bdd_grp4']
cours_url=input('Adresse du forum FUN-MOOC please? ')
nom_collec=input('Et dans quelle collec tu veux la mettre? ')
collec = db[nom_collec]
cookies = {
}


headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:84.0) Gecko/20100101 Firefox/84.0',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
    'X-CSRFToken': 'NNZmwVbWE252BFgQXhL09fVZNtpO2X9R',
    'X-Requested-With': 'XMLHttpRequest',
    'Connection': 'keep-alive',
    'Referer': cours_url,
}

params = (
    ('ajax', '1'),
    ('resp_skip', '0'),
    ('resp_limit', '200'),
)

response3 = requests.get(cours_url, headers=headers, params=params, cookies=cookies)
print((response3.json()["num_pages"]))
for page in range(1,(response3.json()["num_pages"]+1)):
    params_p = (
    ('ajax', '1'),
    ('page',page),
    ('sort_key', 'comments'),
    ('sort_order', 'desc'),)
    
    response = requests.get(cours_url, headers=headers, params=params_p, cookies=cookies)
    print("")
    print('page:',page)
    result=response.json()
    

    for block in result["discussion_data"]: 
        response2 = requests.get(cours_url+block['commentable_id']+'/threads/'+block['id'], headers=headers, params=params, cookies=cookies)
        result2 = response2.json()
        collec.insert_one(result2)
        