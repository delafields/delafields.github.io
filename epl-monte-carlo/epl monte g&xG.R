library(tidyverse)
library(rvest)

# scrape last year's fixtures
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

# create vector of all teams
all_clubs <- unique(c(epl$away, epl$home))

# for each team, get their goals/xg for/against & goals for SD
all_club_stats <- all_clubs %>% 
  
  map_dfr(function(club, epl_data){
    
    home_games <- epl_data$home == club
    away_games <- epl_data$away == club
    
    goals_for_stat <- mean(c(epl_data$home_goals[home_games], epl_data$away_goals[away_games],
                             epl_data$home_xg[home_games], epl_data$away_xg[away_games]))
    
    goals_for_sd_stat <- sd(c(epl_data$home_goals[home_games], epl_data$away_goals[away_games],
                              epl_data$home_xg[home_games], epl_data$away_xg[away_games]))
    
    goals_against_stat <- mean(c(epl_data$away_goals[home_games], epl_data$home_goals[away_games],
                                 epl_data$away_xg[home_games], epl_data$home_xg[away_games]))
    
    data.frame(
      club = club,
      gf_stat = goals_for_stat,
      gf_sd_stat = goals_for_sd_stat,
      ga_stat = goals_against_stat,
      n_games = sum(c(home_games,away_games))
    )
  }, epl)

## Gets goals/xG for, goals/xG against, and SD of goals/xg for, for the two teams of interest
get_club_stats <- function(team1, team2, club_stats) {
  
  tm1_gf <- club_stats[club_stats$club == team1, "gf_stat"]
  tm1_ga <- club_stats[club_stats$club == team1, "ga_stat"]
  tm1_sd_gf <- club_stats[club_stats$club == team1, "gf_sd_stat"]
  
  tm2_gf <- club_stats[club_stats$club == team2, "gf_stat"]
  tm2_ga <- club_stats[club_stats$club == team2, "ga_stat"]
  tm2_sd_gf <- club_stats[club_stats$club == team2, "gf_sd_stat"]
  
  tm1_adj_goals <- sqrt(tm1_gf * tm2_ga)
  tm2_adj_goals <- sqrt(tm2_gf * tm1_ga)
  
  return (c("tm1_gf" = tm1_gf, "tm1_ga" = tm1_ga, "tm1_sd_gf" = tm1_sd_gf, 
            "tm2_gf" = tm2_gf, "tm2_ga" = tm2_ga, "tm2_sd_gf" = tm2_sd_gf,
            "tm1_adj_goals" = tm1_adj_goals, "tm2_adj_goals" = tm2_adj_goals))
}

# Choose two teams, get their stats
team1 <- "Arsenal"
team2 <- "Tottenham"
club_stats <- get_club_stats(team1 = team1, team2 = team2, club_stats = all_club_stats)

club_stats

# SIMULATIONS
set.seed(420)

# Run simulation 10000 times
simulate_game <- function(tm1_mean, tm2_mean) {
  tm1 <- mean(rpois(38, lambda = tm1_mean))
  tm2 <- mean(rpois(38, lambda = tm2_mean))
  
  data.frame(
    tm1 = tm1,
    tm2 = tm2,
    goal_diff = tm1 - tm2,
    winner = ifelse(tm1 > tm2, team1, team2)
  )
}

# run simulation N times
simulated_games <- seq_len(N) %>% 
  map_dfr(
    ~simulate_game(
      club_stats["tm1_adj_goals"],
      club_stats["tm2_adj_goals"]
    )
  )

head(simulated_games)

summary(simulated_games)

hist(simulated_games$goal_diff, col = "blue")
abline(v = mean(simulated_games$goal_diff), col = "red", lty = "dashed", lwd = 4)

quantile(simulated_games$goal_diff)

mean(simulated_games$goal_diff)