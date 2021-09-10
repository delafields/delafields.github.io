library(tidyverse)
library(rvest)

html_page <- read_html("https://fbref.com/en/comps/9/10728/schedule/2020-2021-Premier-League-Scores-and-Fixtures")

epl <- html_page %>% 
  html_table(fill = TRUE) %>% 
  .[1] %>% 
  as.data.frame() %>% 
  select(home = Home,
         home_xg = xG,
         score = Score,
         away_xg = xG.1,
         away = Away) %>% 
  separate(score, c("home_goals", "away_goals"), sep="–") %>% 
  na.omit() %>% 
  mutate_at(vars(home_goals, away_goals), list(as.numeric))

all_clubs <- unique(c(epl$away, epl$home))

all_club_stats <- all_clubs %>% 
  
  map_dfr(function(club, epl_data){
    
    home_games <- epl_data$home == club
    away_games <- epl_data$away == club
    
    goals_for <- mean(
      c(epl_data$home_goals[home_games],
        epl_data$away_goals[away_games])
    )
    
    goals_for_sd <- sd(
      c(epl_data$home_goals[home_games],
        epl_data$away_goals[away_games])
    )
    
    goals_against <- mean(
      c(epl_data$away_goals[home_games],
        epl_data$home_goals[away_games])
    )
    
    xg_for <- mean(
      c(epl_data$home_xg[home_games],
        epl_data$away_xg[away_games])
    )
    
    xg_for_sd <- sd(
      c(epl_data$home_xg[home_games],
        epl_data$away_xg[away_games])
    )
    
    xg_against <- mean(
      c(epl_data$away_xg[home_games],
        epl_data$home_xg[away_games])
    )
    
    data.frame(
      club = club,
      gf = goals_for,
      gf_sd = goals_for_sd,
      ga = goals_against,
      xgf = xg_for,
      xgf_sd = xg_for_sd,
      xga = xg_against,
      n_games = sum(c(home_games,away_games))
    )
  }, epl)

#### Example of the simulation ####
## Get Pts For, Pts Against, and SD of Pts For, for the two teams of interest

team1 <- "Arsenal"
team2 <- "Tottenham"

tm1_gf <- all_club_stats[all_club_stats$club == team1, "gf"]
tm1_ga <- all_club_stats[all_club_stats$club == team1, "ga"]
tm1_sd_gf <- all_club_stats[all_club_stats$club == team1, "gf_sd"]
tm1_xgf <- all_club_stats[all_club_stats$club == team1, "xgf"]
tm1_xga <- all_club_stats[all_club_stats$club == team1, "xga"]
tm1_sd_xgf <- all_club_stats[all_club_stats$club == team1, "xgf_sd"]

tm2_gf <- all_club_stats[all_club_stats$club == team2, "gf"]
tm2_ga <- all_club_stats[all_club_stats$club == team2, "ga"]
tm2_sd_gf <- all_club_stats[all_club_stats$club == team2, "gf_sd"]
tm2_xgf <- all_club_stats[all_club_stats$club == team2, "xgf"]
tm2_xga <- all_club_stats[all_club_stats$club == team2, "xga"]
tm2_sd_xgf <- all_club_stats[all_club_stats$club == team2, "xgf_sd"]