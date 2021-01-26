#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 25 14:08:09 2021

@author: formateur
"""

import config
import requests
from pprint import pprint
from pymongo import MongoClient
import urllib

client = MongoClient('mongodb://%s:%s@%s/?authSource=%s'% (config.user, urllib.parse.quote(config.password),'127.0.0.1', 'admin'))
db = client['bdd_grp4']
collec = db['MOOC_R_1_4']
#print(str)

cookies = {
    'csrftoken': 'NNZmwVbWE252BFgQXhL09fVZNtpO2X9R',
    'atuserid': '%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%22b032a6c0-0cd8-4048-bc81-ee6c84b9b086%22%2C%22options%22%3A%7B%22end%22%3A%222021-11-12T16%3A04%3A50.295Z%22%2C%22path%22%3A%22%2F%22%7D%7D',
    'atidvisitor': '%7B%22name%22%3A%22atidvisitor%22%2C%22val%22%3A%7B%22vrn%22%3A%22-602676-%22%7D%2C%22options%22%3A%7B%22path%22%3A%22%2F%22%2C%22session%22%3A15724800%2C%22end%22%3A15724800%7D%7D',
    'acceptCookieFun': 'on',
    'edxloggedin': 'true',
    'edx-user-info': '{\\"username\\": \\"cesarparra27\\"\\054 \\"version\\": 1\\054 \\"email\\": \\"cesardeveloppeurdata2020@gmail.com\\"\\054 \\"header_urls\\": {\\"learner_profile\\": \\"https://www.fun-mooc.fr/u/cesarparra27\\"\\054 \\"logout\\": \\"https://www.fun-mooc.fr/logout\\"\\054 \\"account_settings\\": \\"https://www.fun-mooc.fr/account/settings\\"}}',
    'sessionid': '9vx7u61x6ueh54np5l06b3q0ae8xtxgv',
    'edx_session': 'h1kz1apnme4olkiu9g0txlf5klve119c',
}

headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:84.0) Gecko/20100101 Firefox/84.0',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
    'X-CSRFToken': 'NNZmwVbWE252BFgQXhL09fVZNtpO2X9R',
    'X-Requested-With': 'XMLHttpRequest',
    'Connection': 'keep-alive',
    'Referer': 'https://www.fun-mooc.fr/courses/course-v1:ParisSaclay+71007+session14/discussion/forum/i4x-ParisSaclay-71007-course-session14_general/threads/5f8b3f22d6ae61000101944a',
}

params3 = (
    ('ajax', '1'),
    ('page', '1'),
    ('sort_key', 'comments'),
    ('sort_order', 'desc'),
)

response3 = requests.get('https://www.fun-mooc.fr/courses/course-v1:ParisSaclay+71007+session14/discussion/forum', headers=headers, params=params3, cookies=cookies)


print(response3.json()["num_pages"])


for page in range(1,(response3.json()["num_pages"]+1)):
    params = (
    ('ajax', '1'),
    ('page',page),
    ('sort_key', 'comments'),
    ('sort_order', 'desc'),)
    
    response = requests.get('https://www.fun-mooc.fr/courses/course-v1:ParisSaclay+71007+session14/discussion/forum', headers=headers, params=params, cookies=cookies)

    print("")
    print('page:',page)
    result=response.json()
    #print(result)
    #print("-----------------------------")    

    for block in result["discussion_data"]:
        #pprint(block)
        #print("-----------------------------")
        headers2 = {
    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:84.0) Gecko/20100101 Firefox/84.0',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
    'X-CSRFToken': 'NNZmwVbWE252BFgQXhL09fVZNtpO2X9R',
    'X-Requested-With': 'XMLHttpRequest',
    'Connection': 'keep-alive',
    'Referer': 'https://www.fun-mooc.fr/courses/course-v1:ParisSaclay+71007+session14/discussion/forum/i4x-ParisSaclay-71007-course-session14_general/threads/5f3a86fafc4c1c0001000880',
}
        params2 = (
    ('ajax', '1'),
    ('resp_skip', '0'),
    ('resp_limit', '200'),
)
    
        response2 = requests.get('https://www.fun-mooc.fr/courses/course-v1:ParisSaclay+71007+session14/discussion/forum/'+block['commentable_id']+'/threads/'+block['id'], headers=headers2, params=params2, cookies=cookies)
        result2 = response2.json()
        pprint(result2["content"]["title"])
        #print("-----------------------------")
        collec.insert_one(result2)
        
        
        
        
        
        
        
        
        
        
        
        
        
        