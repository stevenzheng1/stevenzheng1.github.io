

import pandas as pd
import os
import json
os.chdir('C:/Users/shillenbrand\Dropbox (Harvard University)/6_MP Survey/Design of Survey/json files')


#Load data
data = pd.read_excel("../Bloomberg inputs/Bloomberg_06192023.xlsx", skiprows=6, index_col=0)
data = data[['Bloomberg Value']]

#Transpose such that variables names are the column names
data = data.transpose()

#Convert to json
result = data.to_json(orient="split")
parsed = loads(result)
dumps(parsed, indent=0)  

with open('test.json', 'w') as f:
    json.dump(result, f)


test_data = pd.read_json('test.json')

