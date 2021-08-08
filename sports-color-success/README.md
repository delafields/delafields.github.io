# SPORTS COLOR SUCCESS 🎨
Data around sports team's primary/secondary colors & championships won. Leagues included: NFL, NBA, MLB, NHL, EPL, La Liga, Serie A, NCAAF, NCAAB.

Give me a shout if you make something cool with this!

Data
* `data/{League}_Champions.csv` list of teams that have won championships in {League}
    * `Team`: team name
    * `Wins`: number of championship wins
    * `League`: league name
* `data/colors.csv` (scraped from [teamcolorcodes](https://teamcolorcodes.com/))
    * `Team`: team name
    * `hex_Primary_Color`: primary hex color (from [teamcolorcodes](https://teamcolorcodes.com/))
    * `hex_Secondary_Color`: secondary hex color (from [teamcolorcodes](https://teamcolorcodes.com/))
    * `League`: league name
    * `wc_Primary_Name`: primary color css3 english name (from the [webcolors](https://pypi.org/project/webcolors/) package)
    * `wc_Secondary_Name`: secondary color css3 english name (from the [webcolors](https://pypi.org/project/webcolors/) package)
    * `wa_Primary_Names`: 2 primary color english names (from the [wolframalpha api](https://www.wolframalpha.com/))
    * `wa_Secondary_Names`: 2 secondary color english names (from the [wolframalpha api](https://www.wolframalpha.com/))
    * `wa_Primary_Name_1`: 1st primary color english name (from `wa_Primary_Names`)
    * `wa_Primary_Name_2`: 2nd primary color english name (from `wa_Primary_Names`)
    * `wa_Secondary_Name_1`: 1st secondary color english name (from `wa_Secondary_Names`)
    * `wa_Secondary_Name_2`: 2nd secondary color english name (from `wa_Secondary_Names`)


Working files
* `scrape_champions.py`: scrapes various sources for teams that have won championships
* `scrape_colors.py`: scrapes team colors (hex) and gets english color names


### TODO
* do analysis
* add to overall README, portfolio, and website