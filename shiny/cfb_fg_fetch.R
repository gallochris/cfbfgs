library(cfbfastR)
library(tidyverse)
library(stringr)
library(cfbplotR)
library(cfb4th)

### latest pbp from week 0 and week 1 
pbp_one <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 1,
  epa_wpa = TRUE
)


# load full pbp of last year of only made and missed field goals and adjust weeks
field_goals <- pbp_one %>% 
       filter(play_type == "Field Goal Good" | play_type == "Field Goal Missed" | play_type == "Blocked Field Goal" | play_type == "Missed Field Goal Return" | play_type == "Blocked Field Goal Touchdown") %>%
       mutate(Week = if_else(wallclock < "2022-08-31T01:06:19.000Z", 0, 1)) %>% 
       # fix game with no clock 
       mutate(Week = case_when(
         game_id == 401420846 ~ 1,
         TRUE ~ Week))

# find fgs with kicker name
fgs_clean <- field_goals %>%
       mutate(kicker_player_name = play_text %>%
             str_extract(".\\D+(?= )")) %>%
        mutate(fgm = if_else(fg_made == TRUE, 1, 0))  %>% 
        mutate(fga = if_else(fg_made == (TRUE | FALSE), 1, 1))  %>% 
        # columns we want
        select(id_play, Week, game_id, pos_team, def_pos_team, pos_team_score, def_pos_team_score, kicker_player_name, yds_fg, pts_scored, fgm, fga, fg_make_prob, fg_inds, FG_before, play_text, EPA, wpa, half, period, clock.minutes, clock.seconds, down, distance, yards_to_goal, fg_made, play_type)

# write csv 
write.csv(fgs_clean, 'fgs_clean.csv')

# extra point by kicker
ck <- cfbd_stats_season_player(2022, category = "kicking") %>% 
rename(kicker_player_name = player, pos_team = team) %>% 
select(pos_team, athlete_id, kicker_player_name, category, kicking_fgm, kicking_fga, kicking_xpa, kicking_xpm, kicking_pts, kicking_long)

write.csv(ck, 'ck_xp.csv')

# combine with future weeks
# pbp_two <- cfbd_pbp_data(
#  2022,
#  season_type = "regular",
#  week = 2,
#  epa_wpa = TRUE
# )


# kicks between a certain yardage - might use in the future
# fgs_dist_one <- fgs_clean %>%          
#             mutate(`0-19` = if_else(yds_fg < 20 & fgm == 1, 1, sum(fga))
#             group_by(kicker_player_name, pos_team) %>% 
#             filter(between(yds_fg, 0, 19)) %>%    
#             summarise(`0-19` = paste(sum(fgm), "-", sum(fga)))