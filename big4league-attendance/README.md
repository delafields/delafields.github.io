# Big 4 League Attendance 🏒🏀🏈⚾

Data on attendance figures Big 4 US sports leagues from 2001-2019 (NBA, NFL, MLB, NHL). 

All data scraped from ESPN. See 2018 for [NHL](http://www.espn.com/nhl/attendance/_/year/2018) [NBA](http://www.espn.com/nba/attendance/_/year/2018) [MLB](http://www.espn.com/mlb/attendance/_/year/2018) [NFL](http://www.espn.com/nfl/attendance/_/year/2018).

See [attendance_scraper.r]('attendance_scraper.r') for scraping code.

## Data
Attendance figures can be found in the `data/` folder, there's an excel doc for each league. Also of note, each excel contains a matrix that is comprised of a dataframe for each year i.e., it's all horizontally stacked (due to some stupid `openxlsx` error). Because of this, there's a header row for each year (on top of a master header row). It ain't the cleanest.
* `Season`: year of season (Ex: 2000-2001)
* `Rank`: rank by attendance
* `Team_Name`: *usually* the city of the team
* For `Home`, `Road` and `Overall`
    * `GMS`: num games
    * `TOTAL`: total attendance num
    * `AVG`: average attendance per game
    * `PCT`: percent compacity  