# CFB FGs

This project tracks the play-by-play of field goals during the 2022 college football season. The goal is to practice gathering data, communicating with data, and learning some things along the way.

It's built using [quarto](https://quarto.org/docs/websites), the [cfbfastR](https://github.com/sportsdataverse/cfbfastR) package, and [fly.io](https://fly.io/).

A few beliefs about field goals:

-   a missed field goal is a turnover
-   6 points is greater than 3 points and 3 points is greater than 0 points
-   can't be a clutch kicker without clutch attempts

#### Glossary

-   `Pr`: kick probability, does NOT include weather or skill data, model is from cfbfastR
-   `WPA`: win probability added
-   `EPA`: expected points added
-   `YTG`: yards to goal (end zone)
-   `Avg_Yds`: average yards per field goal attempt
-   `CFGM`: made **clutch** field goal defined as any field goal made in the 4th quarter or overtime with under two minutes remaining that could tie the game or take the lead.
-   `CFGM`: attempted **clutch** field goal defined as any field goal attempted in the 4th quarter or overtime with under two minutes remaining that could tie the game or take the lead.
-   `XPM`: made extra point
-   `XPA`: missed extra point
-   `Pts/A`: points per field goal attempt 
-   `RZ_FGs`: field goals attempted in the red zone or attempts under 38 yards
-   `TVs`: turnovers plus missed field goals  


#### What this project includes: 

-   play-by-play for every field goal in college football for the 2022 FBS season
-   field goals and extra points by player 
-   field goals by team, including touchdowns and turnovers 

#### What it does NOT include:

-   any other play-by-play data (no punts, extra points, kickoffs, or blocked returns)
-   any previous seasons of data (only 2022 right now)
-   any proprietary models (only raw observed data)
-   the player and team page is only for FBS schools 