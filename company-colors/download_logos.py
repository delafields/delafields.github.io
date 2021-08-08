import pandas as pd
import requests
import shutil

# read in the logo data
logo_df = pd.read_csv('data/logo_locations.csv')

# convert to dictionary and reshape
logo_dictionary = logo_df.set_index('company').T.to_dict()

# loop through dictionary
for company in logo_dictionary:

    print(f'Opening {company}\'s logo')

    # open the url image, set stream to True, return the stream content
    resp = requests.get(logo_dictionary[company]['url'], stream=True)

    # Open a local file with wb permission and save it
    print(f'Downloading {company}\'s logo to: ', logo_dictionary[company]['file_name'])

    with open(logo_dictionary[company]['file_name'], 'wb') as out_file:
        shutil.copyfileobj(resp.raw, out_file)

    del resp

print('Done!')