# MOVIE BUDGETS 🎥
Data on the top 5,000 (about) biggest budget movies (as found on[the-numbers.com](https://www.the-numbers.com/movie/budgets/all)).

Give me a shout if you make something cool with this!

Data (pulled on 12/5/2019)
* `movie-budgets.csv` contains a dense file on data of ~5,000 movies
    * `title`: Movie Title
    * `release_date`: Release Date
    * `production_budget`: Production Budget (USD)
    * `domestic_gross`:  Domestic Gross Profit (USD)
    * `worldwide_gross`: Worldwide Gross Profit (USD)
    * `genre`: Movie Genre
    * `story_source`: Story Source (Ex. Novel, Comic Book)
    * `creative_type`: Creative Type (Ex. Super Hero)
    * `production_method`: Production Method (Ex. Live Action, Stop Motion)
    * `production_company`: Production Company
    * `MPAA_Rating`: MPAA Ratins (Ex. PG13)
    * `runtime`: Runtime (minutes)
    * `opening_theater_count`: Number of theaters the movie opened to
    * `max_theater_count`: Max number of theaters showing the movie
    * `avg_run_per_theater`: Average time in theaters (weeks)
    * `actors`: Primary Actors/Actresses in movie (pipe ( | ) delimited string of names)
    * `directors`: Director(s) (pipe ( | ) delimited string of names)

* `data/` contains gzipped json files (each holding ~100 movies, named by budget rank)

Working files
* `scrape.py` contains all scraping logic
* `main.py` executes the scrape & gzips the resulting json file into the json_data folder
* `create_csv.py` ungizps & creates a csv from all the whole of the json files 