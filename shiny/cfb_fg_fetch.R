# load packages --------------------------------------------------------
library(cfbfastR)
library(tidyverse)
library(stringr)

# Fetch latest week when ready --------------------------------------------------------
# load the next week 
pbp_four <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 4,
  epa_wpa = TRUE
)

# find just the field goals
field_goals <- pbp_four %>% 
       filter(play_type == "Field Goal Good" | play_type == "Field Goal Missed" | play_type == "Blocked Field Goal" | play_type == "Blocked Field Goal Touchdown") %>%
       mutate(Week = 4)

# find fgs with kicker name
fgs_clean_four <- field_goals %>%
       mutate(kicker_player_name = play_text %>%
             str_extract(".\\D+(?= )")) %>%
        mutate(fgm = if_else(fg_made == TRUE, 1, 0))  %>% 
        mutate(fga = if_else(fg_made == (TRUE | FALSE), 1, 1))  %>% 
        # columns we want
        select(id_play, Week, game_id, pos_team, def_pos_team, pos_team_score, def_pos_team_score, kicker_player_name, yds_fg, pts_scored, fgm, fga, fg_make_prob, fg_inds, FG_before, play_text, EPA, wpa, half, period, clock.minutes, clock.seconds, down, distance, yards_to_goal, fg_made, play_type)

# write csv 
write.csv(fgs_clean_four, 'fgs_clean_four.csv')

fgs_clean_three <- subset(fgs_clean_four, select = -c(...1))

# load previous weeks 
fgs_prev <- read_csv('fgs_all.csv')

# drop first row
fgs_prev <- subset(fgs_prev, select = -c(X)) 

# merge 
fgs_all <- list(fgs_prev, fgs_clean_four) %>% 
  bind_rows 

# write master file
write.csv(fgs_all, 'fgs_09192022.csv')

# This was the original query to capture week 0 and week 1
# pull the data using this function to get the wallclock and more data
pbp_one <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 1,
  epa_wpa = TRUE
)

# load full pbp of field goals and adjust for week 0
field_goals <- pbp_one %>% 
       filter(play_type == "Field Goal Good" | play_type == "Field Goal Missed" | play_type == "Blocked Field Goal" | play_type == "Missed Field Goal Return" | play_type == "Blocked Field Goal Touchdown") %>%
       mutate(Week = if_else(wallclock < "2022-08-31T01:06:19.000Z", 0, 1)) %>% 
       # fix game with no clock 
       mutate(Week = case_when(
         game_id == 401420846 ~ 1,
         TRUE ~ Week))

# Run this each week to collect kicker stats and include XPs
ck <- cfbd_stats_season_player(2022, category = "kicking") %>% 
rename(kicker_player_name = player, pos_team = team) %>% 
select(pos_team, athlete_id, kicker_player_name, category, kicking_fgm, kicking_fga, kicking_xpa, kicking_xpm, kicking_pts, kicking_long)

write.csv(ck, 'ck_xp.csv')

# Pull in team stats for touchdowns 
team <- cfbd_stats_season_team(year = 2022) %>%
        rename(pos_team = team) %>%
        select(season, pos_team, pass_TDs, rush_TDs, turnovers)

write.csv(team, 'team_stats.csv')

# This is for future exploration 
# kicks between a certain yardage - might use in the future
# fgs_dist_one <- fgs_clean %>%          
#             mutate(`0-19` = if_else(yds_fg < 20 & fgm == 1, 1, sum(fga))
#             group_by(kicker_player_name, pos_team) %>% 
#             filter(between(yds_fg, 0, 19)) %>%    
#             summarise(`0-19` = paste(sum(fgm), "-", sum(fga)))