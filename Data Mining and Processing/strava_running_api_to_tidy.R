# requires custom package from GitHub - 
#devtools::install_github('fawda123/rStrava')
library(rStrava)
library(tidyverse)
library(magrittr)

# load keys
dw <- config::get("datawarehouse_health")
app_name = dw$strava_app_name
app_client_id = dw$strava_client_id
app_secret = dw$strava_app_secret

# get api authorization via oauth 
stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, app_scope="activity:read_all"))
select(average_heartrate, average_speed, elapsed_time, elev_high, elev_low, max_heartrate, max_speed, moving_time,
       start_date_local, total_elevation_gain, type)

# pull activity and compile
strava <- get_activity_list(stoken) %>%
  compile_activities(., units = 'imperial') %>%
  filter(type == 'Run') %>%
  # note that average_speed, max_speed in mph; distance in miles, elevation in feet
  select(start_date_local, distance, elapsed_time, moving_time, average_speed, max_speed, max_heartrate, average_heartrate, 
         elev_high, elev_low, total_elevation_gain) %>%
  # convert mph avg_speed to miles/min pace, same with max_speed
  mutate(mi_min_pace = 60 / average_speed,
         mi_min_max_pace = 60 / max_speed) %>%
  # convert durations from seconds to minutes
  mutate(duration_minutes = seconds_to_period(elapsed_time),
         run_duration_minutes = seconds_to_period(moving_time))

#strava %>%
#  # convert mph avg_speed to miles/min pace, same with max_speed
#  mutate(mi_min_pace = 60 / average_speed,
#          mi_min_max_pace = 60 / max_speed) %>%
#  mutate(seconds = paste0('.', gsub('^.\\.', '', mi_min_pace))) %>%
#  mutate(seconds = as.numeric(seconds) * 60)

write.csv(strava, 'running_strava.csv', row.names = FALSE)
