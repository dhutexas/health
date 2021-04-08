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

# pull activity
my_acts <- get_activity_list(stoken) 

# compile activities from nested list
strava <- compile_activities(my_acts) %>%
  # ensure actually was moving ;p
  filter(average_heartrate > 1) %>% 
  select(start_date,distance,elapsed_time,moving_time,elev_high,elev_low,
                             total_elevation_gain,max_heartrate,average_speed,max_speed) %>%
  # convert distance to miles, time to minutes
  mutate(elapsed_time = elapsed_time / 60,
         distance = distance * 0.621371)

write.csv(strava, 'running_strava.csv', row.names = FALSE)
