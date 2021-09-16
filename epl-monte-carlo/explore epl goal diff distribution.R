library(tidyverse)
library(rvest)

# test data pull
test_url <- "https://fbref.com/en/comps/9/10728/schedule/2020-2021-Premier-League-Scores-and-Fixtures"

html_page <- read_html(test_url)

test <- html_page %>% 
  html_table(fill = TRUE) %>% 
  .[1] %>% 
  as.data.frame() %>% 
  select(Score) %>% 
  separate(Score, c("home_goals", "away_goals"), sep="–") %>% 
  na.omit() %>% 
  mutate_at(vars(home_goals, away_goals), list(as.numeric)) %>% 
  mutate(avg_goals_per_team = (home_goals + away_goals) / 2)

mean(test$avg_goals_per_team)

# pull avg goals per game per team over the last 10 epl seasons
num_seasons <- 10
yearly_goal_averages <- vector("character", length = num_seasons)

get_goal_average <- function(season_url) {
  
  html_page <- read_html(season_url)
  
  html_page %>% 
    html_table(fill = TRUE) %>% 
    .[1] %>% 
    as.data.frame() %>% 
    select(Score) %>% 
    separate(Score, c("home_goals", "away_goals"), sep="–") %>% 
    na.omit() %>% 
    mutate_at(vars(home_goals, away_goals), list(as.numeric)) %>% 
    mutate(avg_goals_per_team = (home_goals + away_goals) / 2)
  
}

# prem goals per game
urls <- c("https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures#sched_11160_1",
          "https://fbref.com/en/comps/9/10728/schedule/2020-2021-Premier-League-Scores-and-Fixtures#sched_10728_1",
          "https://fbref.com/en/comps/9/3232/schedule/2019-2020-Premier-League-Scores-and-Fixtures#sched_3232_1",
          "https://fbref.com/en/comps/9/1889/schedule/2018-2019-Premier-League-Scores-and-Fixtures#sched_1889_1",
          "https://fbref.com/en/comps/9/1631/schedule/2017-2018-Premier-League-Scores-and-Fixtures#sched_1631_1",
          "https://fbref.com/en/comps/9/1526/schedule/2016-2017-Premier-League-Scores-and-Fixtures#sched_1526_1",
          "https://fbref.com/en/comps/9/1467/schedule/2015-2016-Premier-League-Scores-and-Fixtures#sched_1467_1",
          "https://fbref.com/en/comps/9/733/schedule/2014-2015-Premier-League-Scores-and-Fixtures#sched_733_1",
          "https://fbref.com/en/comps/9/669/schedule/2013-2014-Premier-League-Scores-and-Fixtures#sched_669_1",
          "https://fbref.com/en/comps/9/602/schedule/2012-2013-Premier-League-Scores-and-Fixtures#sched_602_1",
          "https://fbref.com/en/comps/9/534/schedule/2011-2012-Premier-League-Scores-and-Fixtures#sched_534_1")


prem_goals <-  urls %>% 
  map_dfr(
    ~get_goal_average(.x)
  )

par(mfrow=c(2, 1))
par(mar=c(1,1,1,1))

# plot average goal distribution
hist(prem_goals$avg_goals_per_team, breaks=12, col="red")

# the above almost certainly points to a poisson distribution

#create plot of probability mass function
plot(dpois(x=0:5, lambda = 1), type="l")
