library(cfbfastR)
library(tidyverse)
library(stringr)
library(cfbplotR)
library(cfb4th)


# check on returns - these should be rare!!!
# wut <- pbp_one %>% filter(play_type == "Missed Field Goal Return" | play_type == "Blocked Field Goal Touchdown") 

### latest pbp from week 0 and week 1 
pbp_one <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 1,
  epa_wpa = TRUE
)

# load full pbp of last year of only made and missed field goals and adjust weeks
field_goals <- pbp_one %>% 
       filter(play_type == "Field Goal Good" | play_type == "Field Goal Missed" | play_type == "Blocked Field Goal") %>%
       mutate(Week = if_else(wallclock < "2022-08-31T01:06:19.000Z", 0, 1))

# combine with future weeks
pbp_two <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 2,
  epa_wpa = TRUE
)

# load full pbp of last year of only made and missed field goals and adjust weeks
field_goals_two <- pbp_two %>% 
       filter(play_type == "Field Goal Good" | play_type == "Field Goal Missed" | play_type == "Blocked Field Goal") %>%
       mutate(Week = 2)

 week_dos <- list(field_goals, field_goals_two)      

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


# kicks between 0-19 yards
fgs_dist_one <- fgs_clean %>%          
             mutate(`0-19` = if_else(yds_fg < 20 & fgm == 1, 1, sum(fga))
             group_by(kicker_player_name, pos_team) %>% 
             filter(between(yds_fg, 0, 19)) %>%    
             summarise(`0-19` = paste(sum(fgm), "-", sum(fga)))

# kicks between 20-29 yards 
fgs_dist_two <- fgs_clean %>%          
             group_by(kicker_player_name, pos_team) %>% 
             filter(between(yds_fg, 20, 29)) %>%    
             summarise(`20-29` = paste(sum(fgm), "-", sum(fga)))

# kicks between 30-39 yards 
fgs_dist_three <- fgs_clean %>%          
             group_by(kicker_player_name, pos_team) %>% 
             filter(between(yds_fg, 30, 39)) %>%    
             summarise(`30-39` = paste(sum(fgm), "-", sum(fga)))

# kicks between 40-49 yards 
fgs_dist_four <- fgs_clean %>%          
             group_by(kicker_player_name, pos_team) %>% 
             filter(between(yds_fg, 40, 49)) %>%    
             summarise(`40-49` = paste(sum(fgm), "-", sum(fga)))

# kicks between 50 plus yards 
fgs_dist_five <- fgs_clean %>%          
             group_by(kicker_player_name, pos_team) %>% 
             filter(between(yds_fg, 50, 99)) %>%    
             summarise(`50plus` = paste(sum(fgm), "-", sum(fga)))

# long make 
fgs_long <- fgs_clean %>% 
            filter(fg_made == TRUE) %>%
            group_by(kicker_player_name, pos_team) %>% 
            summarise(Long = max(yds_fg, na.rm=TRUE))
 
 # clutch kicks
 fgs_clutch <- fgs_clean %>% 
            filter(period == 4 & clock.minutes <= 2 & (pos_team_score - def_pos_team_score == 0)) %>%
            group_by(kicker_player_name, pos_team) %>% 
            summarise(Clutch =  paste(sum(fgm), "-", sum(fga)))

# group by player and show leaderboard 
by_kicker <- fgs_clean %>% 
                group_by(kicker_player_name, pos_team) %>% 
                summarise(FGM = sum(fgm), 
                          FGA = sum(fga),
                          `FG%` = (FGM/FGA * 100),
                          Points = sum(pts_scored),
                          `Yds/A` = (sum(yds_fg) / FGA))

# list and join data 
fg_list <- list(by_kicker, fgs_dist_one, fgs_dist_two, fgs_dist_three, fgs_dist_four, fgs_dist_five, fgs_long, fgs_clutch)

#merge all data and generate main table 
main <- fg_list %>% 
        reduce(full_join, by='kicker_player_name') %>% 
        select(kicker_player_name, pos_team.x, FGM, FGA, `FG%`, Points, Long, `Yds/A`, Clutch, `0-19`, `20-29`, `30-39`, `40-49`, `50plus`) 



# add logos
final <- main %>% 
        mutate(logo = pos_team.x) 

# fix blanks
final_b <- sapply(final, as.character) 

final_b[is.na(final_b)] <- "0-0"  

# make a table 
library(gt)
library(gtExtras)

final  %>% 
  select(pos_team.x, logo, kicker_player_name, FGM, FGA, `FG%`, Points, Long, `Yds/A`, Clutch, `0-19`, `20-29`, `30-39`, `40-49`, `50plus`) %>%
  gt() %>% 
  gt_fmt_cfb_logo(columns = 'logo') %>%
  cols_label(pos_team.x = 'School', logo = '', kicker_player_name = 'Player') %>%
  tab_source_note(source_note = "@dadgumboxscores | data via @cfbfastR") %>% 
  gt_theme_538()