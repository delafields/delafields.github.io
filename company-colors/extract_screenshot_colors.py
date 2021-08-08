import pandas as pd
import colorgram
import os, sys
import re
from tqdm import tqdm

# path of screenshots
path = "screenshots_compressed/"
dirs = os.listdir( path )

 # saving data here
screenshot_df = pd.DataFrame()

# loop through screenshots
for item in tqdm(dirs):

    company_dict = {}

    if os.path.isfile(path+item):

        # company name & screenshot location
        company = re.sub('_WEBSITE.png', '', item)
        screenshot_location = path + item

        print(f'\nExtracting the colors from {company}\'s screenshot')

        company_dict['company'] = company
        company_dict['screenshot_location'] = screenshot_location

        print(company)
        print(screenshot_location)

        # extract 6 colors from the image
        colors = colorgram.extract(screenshot_location, 6)
        
        for idx, color in enumerate(colors):

            # get r,g,b channels
            red = color.rgb.r
            green = color.rgb.g
            blue = color.rgb.b
            # convert r,g,b vals to a hex code
            hex_code = '#%02x%02x%02x' % (red, green, blue)
            company_dict[f'color_{idx+1}'] = hex_code

            # this is the proportion of the screenshot that is this color
            company_dict[f'color_{idx+1}_proportion'] = color.proportion

        screenshot_df = screenshot_df.append(company_dict, ignore_index=True)

# save it out to data
screenshot_df.to_csv('data/screenshot_colors.csv', index=False)


