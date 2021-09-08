import requests
import os
import json
from dotenv import load_dotenv

load_dotenv() # Loading env file

API_KEY = os.environ['API_KEY']
URL = f"https://api.nal.usda.gov/fdc/v1/foods/list?api_key={API_KEY}"
URL_2 = f"https://api.nal.usda.gov/fdc/v1/foods/search?api_key={API_KEY}&query=Cheddar%20Cheese" # testing the query

r = requests.get(URL)
data = r.json()

print(r)
print(data)