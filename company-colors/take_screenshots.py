from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import pandas as pd
from os import path


# read in the logo data
company_urls = pd.read_csv('data/company_urls.csv')

# convert to dictionary and reshape
companies = company_urls.set_index('company').T.to_dict()

# location of chrome driver
driver_location = r'C:\Users\jfields\Desktop\Code\data-projects\company-colors\chromedriver.exe'

options = webdriver.ChromeOptions() # define options
options.add_argument("headless") # pass headless argument to the options

# for screenshot sizing (probably just using desktop)
desktop = {'width': 1440, 'height': 1800} # width @ 2200 was too big
tablet =  {'width': 1200, 'height': 1400}
mobile =  {'width': 680, 'height': 1200}

# run headless chrome driver (otherwise remove options param)
with webdriver.Chrome(executable_path=driver_location, chrome_options=options) as driver:

    for company in companies:
        # save location
        outfile = f'screenshots/{company}_WEBSITE.png'

        # added for broken url request
        # if file exists, move on
        if path.exists(outfile):
            print(f'{company}\'s screenshot already exists')
            continue

        # create a new Chrome session
        print(f'Opening the homepage for {company}')
        driver.implicitly_wait(5)

        url = companies[company]['url']

        # set width & height of the browser. Has to be called before using get()
        driver.set_window_size(desktop['width'], desktop['height']) 
        # get page
        driver.get(url)

        # pass location to save screenshot MUST END IN .png
        print(f'Screenshotting {company}\'s homepage')
        driver.save_screenshot(outfile)