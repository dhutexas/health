options(scipen=999)

library(tidyverse)
library(magrittr)
library(lubridate)
library(zoo)

# read in data files
apple = read.csv('Data/apple_clean.csv', stringsAsFactors = F)
fitbit = read.csv('Data/fitbit_clean.csv', stringsAsFactors = F)
run_fit = read.csv('Data/running_fitbit.csv', stringsAsFactors = F)
run_strav = read.csv('Data/running_strava.csv', stringsAsFactors = F)
run_temps = read.csv('Data/running_temps.csv', stringsAsFactors = F)

# make modifications to datasets to aid with joining and analysis
apple %<>%
  mutate(date = as.Date(date)) %>%
  rename(apple_steps = steps,
         apple_floors = floors,
         apple_rest_hr = rest_hr)

fitbit %<>%
  rename(fitbit_steps = steps,
         fitbit_floors = floors,
         fitbit_rest_hr = rest_avg_hr,
         time_in_bed = timeInBed,
         sleep_efficienty = efficiency) %>%
  mutate(date = as.Date(date),
         sleep_duration = sleep_duration / 60000) %>%
  # filter out later dates when no longer worn
  filter(date >= '2018-02-10') %>%
  filter(date < '2019-10-27') %>%
  # remove naps and broken sleeps
  mutate(sleep_duration = ifelse(sleep_duration >= 300, sleep_duration, NA),
         sleep_start_time = ifelse(sleep_duration > 1, sleep_start_time, NA),
         sleep_end_time = ifelse(sleep_duration >1, sleep_end_time, NA),
         hours_asleep = asleep_min / 60,
         hours_asleep = ifelse(hours_asleep > 4.5, hours_asleep, NA)) %>%
  # pull out and clean time data went to bed, awoke from sleep
  separate(sleep_start_time, into=c('sleep_day1','sleep_start_time'), sep = 'T') %>%
  separate(sleep_end_time, into=c('sleep_day2','sleep_end_time'), sep = 'T') %>%
  select(-c(sleep_day1, sleep_day2)) %>%
  mutate(sleep_start_time = gsub('.000', '', sleep_start_time),
         sleep_end_time = gsub('.000', '', sleep_end_time),
         sleep_start_hour = as.factor(substr(sleep_start_time, 1, 2)),
         sleep_end_hour = as.factor(substr(sleep_end_time, 1, 2)),
         sleep_start_hour = recode(sleep_start_hour, "00" = "12am", "01" = "1am", "02" = "2am", "03" = "3am", "19" = "7pm",
                            "20" = "8pm", "21" = "9pm", "22" = "10pm", "23" = "11pm"),
         sleep_end_hour = recode(sleep_end_hour, "02" = "2am", "03" = "3am", "04" = "4am", "05" = "5am", "06" = "6am",
                          "07" = "7am", "08" = "8am", "09" = "9am", "10" = "10am", "11" = "11am", "13" = "1pm"),
         sleep_start_hour = ordered(sleep_start_hour, levels=c('7pm','8pm','9pm','10pm','11pm','12am','1am','2am','3am')),
         sleep_end_hour = ordered(sleep_end_hour, levels=c('2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','1pm'))) %>%
  # create percentage sleep variables
  mutate(awake_pct = awake_min / asleep_min)

run_fit %<>%
  mutate(date = as.Date(date)) %>%
  # remove runs less than 1 mile
  filter(fitbit_distance > 1) %>%
  # running times are +5 hours from local time, adjusting here
  mutate(start_time = lubridate::hms(run_start_time) - hours(5),
         run_start_time = sprintf("%02d:%02d:%02d", hour(start_time), minute(start_time), second(start_time))) %>%
  # match variable names for merging with Strava
  rename(run_duration_fitbit = duration,
         active_duration_fitbit = active_duration) %>%
  # convert pace to miles per minute (from seconds per minute)
  mutate(mi_min_pace_fitbit = pace / 60)

run_strav %<>%
  # split out time from date
  separate(start_date_local, into = c('date','time'), sep = 'T') %>%
  mutate(date = as.Date(date),
         time = gsub('Z', '', time)) %>%
  rename(strava_elev_gain = total_elevation_gain,
         strava_distance = distance,
         run_start_time = time,
         strava_avg_speed = average_speed,
         mi_min_pace_strava = mi_min_pace) %>%
  # match variables to fitbit metrics
  mutate(run_duration_strava = elapsed_time / 60,
         active_duration_strava = moving_time / 60)

# bring in data on running temps
run_temps %<>%
  janitor::clean_names() %>%
  mutate(date = as.Date(date))

# merge running data, matching variables where feasible (on same scale)
running <- full_join(run_fit, run_strav, run_temps, by = c('date','run_start_time')) %>%
  mutate(run_distance = rowMeans(cbind(fitbit_distance, strava_distance), na.rm = T),
         run_duration = rowMeans(cbind(run_duration_strava, run_duration_fitbit), na.rm = T),
         run_active_duration = rowMeans(cbind(active_duration_strava, active_duration_fitbit), na.rm = T),
         mi_min_pace = rowMeans(cbind(mi_min_pace_strava, mi_min_pace_fitbit), na.rm = T),
         run_avg_hr = rowMeans(cbind(avg_hr, average_heartrate), na.rm = T)) %>%
  select(date, run_start_time, run_distance, mi_min_pace, run_duration, run_active_duration, run_avg_hr, max_heartrate, 
         mi_min_max_pace, strava_elev_gain) %>%
  arrange(date)

# join running with health data
health <- full_join(apple, running, by = 'date') %>%
  arrange(date)

# add fitbit data and weather data
health %<>% full_join(fitbit, by = c('date')) %>%
  mutate(steps = rowSums(cbind(apple_steps, fitbit_steps), na.rm = T),
         floors = rowSums(cbind(apple_floors, fitbit_floors), na.rm = T),
         rest_hr = rowSums(cbind(apple_rest_hr, fitbit_rest_hr), na.rm = T)) %>%
  select(-c(fitbit_steps, apple_steps, 
            fitbit_floors, apple_floors,
            fitbit_rest_hr, apple_rest_hr)) %>%
  select(date, steps, floors, rest_hr, everything()) %>%
  # drop obviously incorrect observations before calculate summary stats
  mutate(steps = ifelse(steps < 300, NA, steps),
         rest_hr = ifelse(rest_hr < 40, NA, rest_hr),
         run_duration = ifelse(run_duration > 55, NA, run_duration),
         exercise_minutes = ifelse(exercise_minutes < 10, NA, exercise_minutes),
         mi_min_max_pace = ifelse(mi_min_max_pace < 3, NA, mi_min_max_pace)) %>%
  arrange(date)

# add time-level data labels
health %<>%
  mutate(month = format(date,"%B"),
         month = ordered(month, levels=c('January','February','March','April','May','June','July',
                                              'August','September','October','November','December')),
         day = format(date,"%A"),
         day = ordered(day, levels=c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
         week = floor_date(date,'week'),
         year = lubridate::year(date),
         mo_yr = paste(month, year))

# calculate moving averages
health %<>%
  mutate(steps_yesterday = lag(steps, n=1),
         steps_7_day_avg = rollmean(steps_yesterday, k=7, fill=NA, align='right'),
         steps_14_day_avg = rollmean(steps_yesterday, k=14, fill=NA, align='right'),
         steps_30_day_avg = rollmean(steps_yesterday, k=30, fill=NA, align='right'),
         steps_100_day_avg = rollmean(steps_yesterday, k=100, fill=NA, align='right'),
         steps_200_day_avg = rollmean(steps_yesterday, k=200, fill=NA, align='right'),
         floors_yesterday = lag(floors, n=1),
         floors7dayAvg = rollmean(floors_yesterday, k=7, fill=NA, align='right'),
         floors14dayAvg = rollmean(floors_yesterday, k=14, fill=NA, align='right'),
         floors30dayAvg = rollmean(floors_yesterday, k=30, fill=NA, align='right'),
         floors100dayAvg = rollmean(floors_yesterday, k=100, fill=NA, align='right'),
         floors200dayAvg = rollmean(floors_yesterday, k=200, fill=NA, align='right'),
         rest_hr_yesterday = lag(rest_hr, n=1),
         rest_hr_7_day_avg = rollmean(rest_hr_yesterday, k=7, fill=NA, align='right'),
         rest_hr_14_day_avg = rollmean(rest_hr_yesterday, k=14, fill=NA, align='right'),
         rest_hr_30_day_avg = rollmean(rest_hr_yesterday, k=30, fill=NA, align='right'))

write.csv(health, 'health_clean.csv', row.names=FALSE)

