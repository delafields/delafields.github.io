from googlesearch import search
import pandas as pd
import requests

# read in the logo data
logo_df = pd.read_csv('data/logo_locations.csv')

# convert to dictionary and reshape
companies = logo_df.set_index('company').T.to_dict()

# we'll save the data here
company_df = pd.DataFrame()

# loop through dictionary
for company in companies:

    company_dict = {}

    print(f'Searching for {company}\'s homepage')

    # search Google for the company - 1 result (not all correct)
    result = search(company, tld='com', lang='en', num=1, start=0, stop=0, pause=1.0)

    # the above returns a generator, so get the true result
    company_homepage = next(result)

    print(f'Homepage is {company_homepage}')

    # add data to dict
    company_dict['company'] = company
    company_dict['url'] = company_homepage

    # add to dataframe
    company_df = company_df.append(company_dict, ignore_index=True)

# save results (temp bc I have to manually fix some)
company_df.to_csv('data/company_urls_temp.csv', index=False)

# NOTE: I had to manually go back and correct a few of these
# NOTE: but it does the job for the large part
