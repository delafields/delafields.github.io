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
## Get goals for, goals against, xg for, xg against, and SD of goals/xg for, for the two teams of interest

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

# adjust goals and xG for both clubs based on opponent points against
tm1_adj_goals <- sqrt(tm1_gf * tm2_ga)
tm2_adj_goals <- sqrt(tm2_gf * tm1_ga)

tm1_adj_xg <- sqrt(tm1_xgf * tm2_xga)
tm2_adj_xg <- sqrt(tm2_xgf * tm1_xga)

# SIMULATIONS

# TODO: plot goals and xg to see correct distribution to sample from

# simulated goals for club 1
qnorm(
  runif(1), # maybe poisson here
  mean = tm1_adj_goals,
  sd = tm1_sd_gf
)

# run the simulation 10,000 times to get the probability that one team outscores the other
N <- 10000
outcome <- vector("character", length = N)

for (i in 1:N) {
  d <- qnorm(runif(1), mean = tm1_adj_goals, sd = tm1_sd_gf) - qnorm(runif(1), mean = tm2_adj_goals, sd = tm2_sd_gf)
  d <- ifelse(d > 0, team1, team2)
  
  outcome[i] <- d
}

# plot outcomes
table(outcome)
prop.table(table(outcome))
barplot(prop.table(table(outcome)))

# RUN SIMULATION WITH GOAL SPREAD
simulate_game <- function(tm1_mean, tm1_sd, tm2_mean, t2_sd) {
  tm1 <- qnorm(runif(1), mean = tm1_adj_goals, sd = tm1_sd_gf)
  tm2 <- qnorm(runif(1), mean = tm2_adj_goals, sd = tm2_sd_gf)
  
  data.frame(
    tm1 = tm1,
    tm2 = tm2,
    goal_diff = tm1 - tm2,
    winner = ifelse(tm1 > tm2, "tm1", "tm2")
  )
}

# run simulation N times
simulated_games <- seq_len(N) %>% 
  map_dfr(
    ~simulate_game(
      tm1_adj_goals, tm1_sd_gf,
      tm2_adj_goals, tm2_sd_gf
    )
  )

head(simulated_games)

hist(simulated_games$goal_diff, col = "blue")
abline(v = mean(simulated_games$goal_diff), col = "red", lty = "dashed", lwd = 4)

quantile(simulated_games$goal_diff)

mean(simulated_games$goal_diff)
