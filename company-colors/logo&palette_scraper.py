from bs4 import BeautifulSoup
import pandas as pd
import requests
import re

################
## PARAMETERS ##
################
base_url = 'https://boldwebdesign.com.au/colour-palettes/?_button='

company_categories = ['retail', 'financial-services', 'technology', 'manufacturer', 'energy', 'food', 
                      'insurance', 'natural-resource','health-beauty', 'auto', 'pharmaceuticals', 
                      'transport-company', 'computer-electronics' 'animation-industry', 'aerospace-and-defense', 
                      'chemicals', 'construction', 'travel', 'casino-hotel', 'supplier', 'real-estate']

# where the company name, palette colors, etc is going
df = pd.DataFrame()
# where the logo image location, file name is going
logo_df = pd.DataFrame()

# got this by running the script through 
# checking for the max number of colors given
max_colors = 8

######################
## HELPER FUNCTIONS ##
######################

def get_page_html(url):
  '''Opens a url'''

  print(f'Opening {url}')

  try:
      headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36'}
      main_page = requests.get(url, headers=headers, timeout=5)
      print('Successfully opened url')
  except requests.ConnectionError as e:
      print("Connection Error. Make sure you are connected to Internet. Technical Details given below.\n")
      print(str(e))
  except requests.Timeout as e:
      print("Timeout Error")
      print(str(e))

  return (main_page)



def url_to_company_name(text):
  '''Formats a url string into a company name'''

  # finds the second to last /
  url_end =  text.rfind('/', 0, text.rfind('/')) + 1
  text = text[url_end:]

  # if `text` contains -color-palette, remove it
  if re.search('(-color-palette/)$', text):
    text = re.sub('(-color-palette/)', '', text)
  
  # remove trailing /
  text = re.sub('/', '', text)
  
  return text

# loop through each category
for category in company_categories:

    print(f'Starting category {category}')

    main_page = get_page_html(f'{base_url}{category}')

    # soupify html
    soup = BeautifulSoup(main_page.text, 'html.parser')

    # find each company card in this category
    companies = soup.find_all('a', attrs={'class': 'wpgb-card-layer-link'})

    # there are duplicate `a`'s for each company above
    companies = companies[::2]

    # for each company in this category
    for company in companies:

        company_data = {}
        logo_data = {}

        # the url of this company's palette page
        company_url = company['href']

        company_name = url_to_company_name(company_url)
        print(f'company name: {company_name}')

        # open the company's palette page and soupify the html
        company_page = get_page_html(f'{company_url}')
        company_soup = BeautifulSoup(company_page.text, 'html.parser')

        # find this company's color palette and extract the hex code
        hex_colors = company_soup.find_all('span', text=re.compile('^#(?:[0-9a-fA-F]{3}){1,2}$'))
        company_colors = [color.text for color in hex_colors]

        print(f'{company_name} colors are: {company_colors}')

        # 1 because [0] is the base url's logo
        company_logo_href = company_soup.find_all('img', attrs={'class': 'fl-photo-img'})[1]['src']

        # image name after last /
        logo_fn = company_logo_href[company_logo_href.rfind('/') + 1:]

        # push logo data to a dict, then append to DataFrame
        logo_data['company'] = company_name
        logo_data['url'] = company_logo_href
        logo_data['file_name'] = './logos/' + logo_fn

        logo_df = logo_df.append(logo_data, ignore_index=True)

        print(f'{company_name}\'s logo is @ {company_logo_href}')

        # push company data to a dict
        company_data['company'] = company_name
        company_data['category'] = category
        # if less than `max_colors`, populate with a blank string
        for i in range(1, max_colors+1):

            if i <= len(hex_colors):
                company_data[f'color_{i}'] = company_colors[i - 1]
            else:
                company_data[f'color_{i}'] = ''

        # append company data to DataFrame
        df = df.append(company_data, ignore_index = True)


###########################
## REMOVING DUPLICATIONS ##
###########################

# sort by company name
df.sort_values('company', inplace=True)
logo_df.sort_values('company', inplace=True)

# dropping duplication, keep `first`
df.drop_duplicates(subset='company', keep='first', inplace=True)
logo_df.drop_duplicates(subset='company', keep='first', inplace=True)

# rename some weird company names
df['company'] = df['company'].replace({'578': 'whirlpool', 
                                        '528': 'paccar', 
                                        '548': 'penske',
                                        '866': 'henry-schein'})
                                        
logo_df['company'] = logo_df['company'].replace({'578': 'whirlpool', 
                                                 '528': 'paccar', 
                                                 '548': 'penske', 
                                                 '866': 'henry-schein'})

###########################
## SAVE DATAFRAME TO CSV ##
###########################
df.to_csv('data/logo_colors.csv', index=False)
logo_df.to_csv('data/logo_locations.csv', index=False)