# load data directory path
dw <- config::get("datawarehouse_health")
filepath = dw$json_filepath

library(jsonlite)
library(tibble)
library(tidyverse)
library(magrittr)

# read in JSON, flatten and turn into a tibble
exjson1 = fromJSON(paste0(filepath, 'exercise-0.json')) %>% flatten() %>% as_tibble()
exjson2 = fromJSON(paste0(filepath, 'exercise-100.json')) %>% flatten() %>% as_tibble()
exjson3 = fromJSON(paste0(filepath, 'exercise-200.json')) %>% flatten() %>% as_tibble()
exjson4 = fromJSON(paste0(filepath, 'exercise-300.json')) %>% flatten() %>% as_tibble()
exjson5 = fromJSON(paste0(filepath, 'exercise-400.json')) %>% flatten() %>% as_tibble()
exjson6 = fromJSON(paste0(filepath, 'exercise-500.json')) %>% flatten() %>% as_tibble()
exjson7 = fromJSON(paste0(filepath, 'exercise-600.json')) %>% flatten() %>% as_tibble()
exjson8 = fromJSON(paste0(filepath, 'exercise-700.json')) %>% flatten() %>% as_tibble()
exjson9 = fromJSON(paste0(filepath, 'exercise-800.json')) %>% flatten() %>% as_tibble()
exjson10 = fromJSON(paste0(filepath, 'exercise-900.json')) %>% flatten() %>% as_tibble()
exjson11 = fromJSON(paste0(filepath, 'exercise-1000.json')) %>% flatten() %>% as_tibble()
exjson12 = fromJSON(paste0(filepath, 'exercise-1100.json')) %>% flatten() %>% as_tibble()

# bind rows of flattened JSON
rundata <- bind_rows(exjson1,exjson2,exjson3,exjson4,exjson5,exjson6,exjson7,
                   exjson8,exjson9,exjson10,exjson11,exjson12) %>%
  select(startTime,activityName,logType,hasGps,duration,activeDuration,steps,calories,distance,
                   speed,pace,elevationGain,vo2Max.vo2Max,averageHeartRate) %>%
  # limit data to just tracked runs
  filter(logType == 'tracker') %>%
  # turn exercise start time into single-day date variable
  mutate(date = as.Date(lubridate::mdy_hms(startTime, tz=Sys.timezone()))) %>%
  janitor::clean_names() %>%
  select(-c(log_type, has_gps)) %>%
  rename(vo2max = vo2max_vo2max,
         avg_hr = average_heart_rate,
         elev_gain = elevation_gain) %>%
  # convert milliseconds to minutes
  mutate(duration = duration / 60000,
         active_duration = active_duration / 60000) %>%
  # convert time to local time (-5 hours)
  mutate(start_time = (strptime(start_time, "%m/%d/%y %H:%M:%S")) - hours(5)) %>%
  separate(start_time, into = c('date', 'start_time'), sep = ' ') %>%
  # drop all distances recorded running less than 1 mile
  filter(distance > 1)

write.csv(rundata, 'running_fitbit.csv', row.names = FALSE)

