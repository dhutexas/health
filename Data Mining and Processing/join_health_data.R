options(scipen=999)

library(tidyverse)
library(magrittr)
library(lubridate)
library(zoo)

# read in data files
apple = read.csv('Data/apple_clean.csv', stringsAsFactors = F)
run_fit = read.csv('Data/running_fitbit.csv', stringsAsFactors = F)
run_strav = read.csv('Data/running_strava.csv', stringsAsFactors = F)
fitbit = read.csv('Data/fitbit_clean.csv', stringsAsFactors = F)
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
         fitbit_rest_hr = rest_avg_hr) %>%
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
  filter(fitbit_distance > 1)

run_strav %<>%
  separate(start_date, into = c('date','time'), sep = 'T') %>%
  mutate(date = as.Date(date),
         time = gsub('Z', '', time)) %>%
  rename(strava_elev_gain = total_elevation_gain,
         strava_distance = distance,
         run_start_time = time,
         strava_avg_speed = average_speed) 

run_temps %<>%
  janitor::clean_names() %>%
  mutate(date = as.Date(date))

# have double-date data in running
running <- full_join(run_fit, run_strav, run_temps, by = c('date','run_start_time')) %>%
  select(date, run_start_time, everything()) %>%
  arrange(date)

health <- full_join(apple, running, by = 'date') %>%
  arrange(date)

# need fitbit data and weather data
health %<>% full_join(fitbit, by = c('date')) %>%
  mutate(steps = rowSums(cbind(apple_steps, fitbit_steps), na.rm = T),
         floors = rowSums(cbind(apple_floors, fitbit_floors), na.rm = T),
         rest_hr = rowSums(cbind(apple_rest_hr, fitbit_rest_hr), na.rm = T)) %>%
  select(-c(fitbit_steps, apple_steps, 
            fitbit_floors, apple_floors,
            fitbit_rest_hr, apple_rest_hr)) %>%
  select(date, steps, floors, rest_hr, everything()) %>%
  arrange(date)

# add run prefix to running columns to clarify what they contain
run_cols = c('fitbit_distance', 'calories', 'fitbit_elev_gain','avg_speed','pace','duration',
             'active_duration','avg_hr', 'strava_distance', 'elapsed_time', 'moving_time', 'elev_high',
             'elev_low', 'strava_elev_gain', 'max_heartrate', 'strava_avg_speed', 'max_speed')
health %<>% 
  rename_with( ~ paste("run", .x, sep = "_"), .col=all_of(run_cols))

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
