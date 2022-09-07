unc <- pbp_one %>% filter(pos_team == "North Carolina") %>%
     filter(yards_gained > 24) %>% 
     filter(play_type != "Field Goal Missed" & play_type != "Punt" & play_type != "Field Goal Good" & play_type != "Kickoff Return (Offense)")
     count()


pbp_one <- cfbd_pbp_data(
  2022,
  season_type = "regular",
  week = 1,
  epa_wpa = TRUE
)
