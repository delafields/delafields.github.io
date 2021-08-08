# EPL TRANSFERS ⚽

Data on English Premier League transfers and season-end position from the 1992-93 season through 2018-19. Season-end tables scraped from wikipedia. Transfer data from [@ewenme](https://github.com/ewenme)'s awesome [repo](https://github.com/ewenme/transfers) (<- that data is from [Transfermarkt](https://www.transfermarkt.co.uk/)).

A brief visual analysis can be found in the [Overall Analysis](OverallAnalysis.md) file.

An in depth analysis of the modern transfer market can be found in the [Analysis](Analysis.md) file.

See [epl_table_scraper.r]('epl_scraper.r') for the results-table scraper code.

## Data
Season-end tables can be found in the `data/epl-results/` folder. Filenames follow the format `year_EPL_results.csv`; ex: `1992-93_EPLResults.csv`.
* `year`: season (1992-93)
* `Pos`: standing end-of-year (1, 2, etc) 
* `Team`: team name
* `Pld`: num games played 
* `W`: num games won
* `D`: num games drawn
* `L`: num games lost
* `GF`: goals for (scored)
* `GA`: goals against
* `GD`: goal differential
* `Pts`: num pts from W/L/D
* `Qualification or relegation`: qualification for European cups, relegated

Transfer data can be found in the `data/transfer-data` folder. 
* `club_name`: the club who made the transfer 
* `player_name`: the player being transferred 
* `age`: player age 
* `position`: player position 
* `club_involved`: the club the player is going to/from 
* `fee`: fee in pounds (£). Could be k, m, or loan info
* `transfer_movement`: in or out 
* `fee_cleaned`: the fee cleaned up a bit (Ex: `fee`= £61.02m, `fee_cleaned` = 61.02) 
* `league_name`: league name (always Premier League here)
* `year`: year the deal was made
* `season`: season name (Ex: 2018/2019)