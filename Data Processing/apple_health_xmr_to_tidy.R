library(xml2)
library(tidyverse)
library(magrittr)
library(lubridate)

# parse xml object
healthxml = read_xml("Data/export.xml")
healthxml_cda = read_xml("Data/export_cda.xml")

# get all the <record>s, as 'Record' is how the data are structured by Apple
recs <- xml_find_all(healthxml, "//Record") 
recs_cda <- xml_find_all(healthxml, "//Record")

# convert object into dataframe
library(purrr)
df = recs %>% 
  map(xml_attrs) %>% 
  map_df(~as.list(.)) %>% # map items to dataframe
  select(-sourceVersion, -device) # remove extraneous data

df_cda = recs %>% 
  map(xml_attrs) %>% 
  map_df(~as.list(.)) %>% # map items to dataframe
  # remove extraneous string data
  mutate(type = gsub("HKQuantityTypeIdentifier", "", type),
         type = gsub("HKDataType", "", type),
         type = gsub("HKCategoryTypeIdentifier", "", type),
         type = gsub("Apple", "", type))

# convert to dates
df_cda %<>% 
  mutate(startDate = as_datetime(startDate, tz = "America/Chicago"),
         endDate = as_datetime(endDate, tz = "America/Chicago"))

# stand hours are blank, so drop them
df_cda %<>%
  mutate(value = as.numeric(value)) %>%
  filter(type != "StandHour")

# reorder variables
df_cda %<>%
  select(type, sourceName, unit, value, startDate, endDate)

# determine what is measured in the dataset
variables = df_cda %>% distinct(type)
sources = df_cda %>% distinct(sourceName)

# get rid of data from phone (not reliable)
df_cda %<>%
  filter(sourceName != "Derek’s iPhone") %>%
  filter(sourceName != 'iPhone')

#### Aggregate and analyze data ######
df_cda %<>%
  mutate(day = wday(startDate, label=TRUE, abbr = FALSE),
         month = month(startDate, label=TRUE, abbr = FALSE),
         date = date(startDate))

steps_daily = df_cda %>%
  filter(type == "StepCount") %>%
  group_by(date) %>%
  summarise(Steps = sum(value))

rest_heart_daily = df_cda %>%
  filter(type == "RestingHeartRate") %>%
  group_by(date) %>%
  summarise(RestHR = mean(value, na.rm=TRUE))

flights_daily = df_cda %>%
  filter(type == "FlightsClimbed") %>%
  group_by(date) %>%
  summarise(Floors = sum(value, na.rm=TRUE))

exercise_daily = df_cda %>%
  filter(type == "ExerciseTime") %>%
  group_by(date) %>%
  summarise(ExerciseMinutes = sum(value, na.rm=TRUE))

stand_daily = df_cda %>%
  filter(type == "StandTime") %>%
  group_by(date) %>%
  summarise(StandMinutes = sum(value, na.rm=TRUE))

walk_hr_daily = df_cda %>%
  filter(type == "WalkingHeartRateAverage") %>%
  group_by(date) %>%
  summarise(WalkHR = sum(value, na.rm=TRUE))

apple = steps_daily %>%
  full_join(rest_heart_daily, by='date') %>%
  full_join(flights_daily, by = 'date') %>%
  full_join(exercise_daily, by = 'date') %>%
  full_join(stand_daily, by = 'date') %>%
  full_join(walk_hr_daily, by = 'date') %>%
  filter(date != "2019-11-05") %>%
  filter(date != "2020-10-05") # get rid of first and last date without full data

write_csv(apple, 'Data/apple_clean.csv')



