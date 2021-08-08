# Company Colors 🎨
I was inspired by the research done by [bold.](https://boldwebdesign.com.au/) web design on their [Fortune 500 palettes site](https://boldwebdesign.com.au/colour-palettes/) to compile a dataset around company logo/brand/website colors.

This repo contains brand palettes for said companies, palettes extracted from said companies homepages, as well as each company's logo & a screenshot of their homepage. Do with it what you may (I have some links at the bottom for possible analysis tools).

## Scraping Scripts (listed in order of execution)
* `logo&palette_scraper.py`: hits the bold. site, looping over various industries and scrapes company name/industy/brand palette, and logo location
* `download_logos.py`: downloads the logos from the last bullet into `logos/`
* `get_urls.py`: takes the company names and does a quick Google search for their homepage urls
* `take_screenshots.py`: pops open a headless Chrome browser and screenshots the urls from above. Saves them to a hidden `screenshots/` folder. Hidden because ~see next bullet~
* `bulk_resize_images.py`: resizes the screenshots to 512x512 images
* `extract_screenshot_colors.py`: takes said screenshots and uses the [colorgram](https://github.com/obskyr/colorgram.py) package to extract the top 6 colors in the screenshot

## Data
`logo_colors.csv` (sourced from the bold. site)
* `company`: company name, hypen separated
* `category`: industry
* `color_{1-8}`: contains 1-8 hex codes of brand colors (as determined by bold.)

`screenshot_colors.csv` (extracted from website screenshots using [colorgram](https://github.com/obskyr/colorgram.py))
* `company`: company name, hypen separated
* `color_{1-6}`: contains 1-6 hex codes of colors in the screenshot
* `color_{1-6}_proportion`: proportion of the screenshot that contains said color.
    * *Note this may over-index in whites or space-filler colors. [WIP]*
* `screenshot_location`: where the screenshot is saved 

`company_urls.csv`
* `company`: company name, hypen separated
* `url`: the company's homepage to be screenshotted

`logo_locations.csv`
* `company`: company name, hypen separated
* `file_name`: where the logo is saved 
* `url`: the url of the logo to be downloaded 


#### Links to helpers/tutorials
* How to website screenshot: https://dev.to/bilal_io/website-screenshots-with-selenium-in-python-kcn
* Color extractor package: https://github.com/obskyr/colorgram.py
* Color namer: https://graphicdesign.stackexchange.com/questions/5120/how-can-i-get-the-closest-color-word-for-a-hex-color
* Calculating color similarity: https://stats.stackexchange.com/questions/109618/computing-image-similarity-based-on-color-distribution
* Making a color histogram: https://stackoverflow.com/questions/12182891/plot-image-color-histogram-using-matplotlib/12183468
