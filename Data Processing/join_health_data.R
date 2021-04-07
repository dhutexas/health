setwd('E:/fitbit')

# install library to specific source (to avoid conflicts, like tidyr with finance)
#install.packages('tidyr', lib='E:/Fitbit')
#library(tidyr, lib='E:/Fitbit')

library(readr)      # to bring in csv
library(xts)        # working with extensible time series
library(tidyverse)  # ggplot2, purrr, dplyr, tidyr, readr, tibble
library(magrittr)   # for piping function %<>%
library(ggExtra)    # for cooler plots
library(stringr)    # working with strings
library(forcats)    # working with factors
library(lubridate)  # working with dates in tibbles / data frames
library(flipTime)   # more date help
library(PerformanceAnalytics)
library(quantmod)
library(ggplot2)
library(dygraphs)
options(scipen=999) # turn-off scientific notation like 1e+48
library(knitr)      # for pretty tables
library(kableExtra) # for pretty tables
library(xtable)

# read in data from Python Fitbit API
steps = read.csv('fitbit_steps_v2.csv')
floors = read.csv('fitbit_floors_v2.csv')
heart = read.csv('fitbit_hr_v2.csv') %>% select(Date, Resting_HR)

s1 = read.csv('fitbit_sleep.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)
s2 = read.csv('fitbit_sleep2.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)
s3 = read.csv('fitbit_sleep3.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)
s4 = read.csv('fitbit_sleep4.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)
s5 = read.csv('fitbit_sleep5.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)
s6 = read.csv('fitbit_sleep6.csv') %>%
  select(dateOfSleep, duration, efficiency, isMainSleep, minutesAsleep,
         minutesAwake, restlessCount, restlessDuration, awakeningsCount,
         awakeCount, awakeDuration, startTime, endTime, timeInBed)


sleep = rbind(s1,s2,s3,s4,s5,s6) %>% rename(., Date = dateOfSleep)
sleep = sleep[sleep$isMainSleep != 'False', ] # remove potential naps
sleep = sleep[sleep$timeInBed > 250, ] # drop less than 250 minutes in bed
sleep = sleep[!duplicated(sleep$Date), ] # remove duplicate dates
sleep$hrs_in_bed = sleep$duration * 2.77778e-7
sleep$hrs_asleep = sleep$minutesAsleep / 60
sleep$startTime = gsub(".*T","",sleep$startTime)
sleep$endTime = gsub(".*T","",sleep$endTime)
sleep$startTime = gsub(".000","",sleep$startTime)
sleep$endTime = gsub(".000","",sleep$endTime)
sleep %<>% select(-isMainSleep, -duration) # get rid of these columns
sleep$startHour = substr(sleep$startTime, 1, 2) # create hour varaibles
sleep$endHour = substr(sleep$endTime, 1, 2) # create hour variables
sleep$startHour = as.factor(sleep$startHour)
sleep$endHour = as.factor(sleep$endHour)
sleep %<>% mutate(startHour = recode(startHour, "00" = "12am", "01" = "1am", "02" = "2am", "03" = "3am", "19" = "7pm",
                                    "20" = "8pm", "21" = "9pm", "22" = "10pm", "23" = "11pm"),
                  endHour = recode(endHour, "02" = "2am", "03" = "3am", "04" = "4am", "05" = "5am", "06" = "6am",
                                   "07" = "7am", "08" = "8am", "09" = "9am", "10" = "10am", "11" = "11am", "13" = "1pm"))
sleep$startHour = ordered(sleep$startHour, levels=c('7pm','8pm','9pm','10pm','11pm','12am','1am','2am','3am'))
sleep$endHour = ordered(sleep$endHour, levels=c('2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','1pm'))
sleep$awakePct = sleep$awakeDuration/sleep$minutesAsleep # create percentage variables
sleep$restlessPct = sleep$restlessDuration/sleep$minutesAsleep
sleep$notAsleepPct = sleep$minutesAwake / sleep$minutesAsleep

# combine datasets
data = merge(steps, floors, all=T) %>% select(-Date.1)
data = merge(data, heart, all=T)
data = merge(data, sleep, all=T)

# impute time-level data labels
data$Date <- as.Date(data$Date, "%Y-%m-%d") # must first turn Date to Date
data$Month <- format(data$Date,"%B") # create a month category
data$Month <- as.factor(data$Month)
data$Month = ordered(data$Month, levels=c('January','February','March','April','May','June','July',
                                          'August','September','October','November','December'))
data$Day <- format(data$Date,"%A") # create a day category
data$Day <- as.factor(data$Day)
data$Day = ordered(data$Day, levels=c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'))
data$Week = floor_date(data$Date,'week') #gives each week a unique label
data$Year = lubridate::year(data$Date)
data$MoYr = paste(data$Month,data$Year)


# add in running json data
running = read.csv('rundata_v2.csv', stringsAsFactors = F)
running$startTime = strptime(running$startTime, "%m/%d/%y %H:%M:%S")
running$startTime = running$startTime - hours(5) # for some reason fitbit is off by 5 hours from my time zone
running$Date = as.Date(running$startTime)
running = running[running$distance > 1,] # drop all distances recorded running less than 1 mile
data = left_join(data, running, by=c("Date"))
# rename columns to fit graphics better
data %<>% rename(RestHR = Resting_HR, AvgHR = averageHeartRate, MinAwake = minutesAwake, HrsAsleep = hrs_asleep,
                 ExTime = activeDuration, Distance = distance, Pace = pace, ElevGain = elevationGain, vo2Max = vo2Max.vo2Max) %>%
  select(-X, -startTime.y)

# calculate moving averages
data %<>%
  mutate(stepsYesterday = lag(Steps, n=1),
         steps7dayAvg = rollmean(stepsYesterday, k=7, fill=NA, align='right'),
         steps14dayAvg = rollmean(stepsYesterday, k=14, fill=NA, align='right'),
         steps30dayAvg = rollmean(stepsYesterday, k=30, fill=NA, align='right'),
         steps100dayAvg = rollmean(stepsYesterday, k=100, fill=NA, align='right'),
         steps200dayAvg = rollmean(stepsYesterday, k=200, fill=NA, align='right'),
         floorsYesterday = lag(Floors, n=1),
         floors7dayAvg = rollmean(floorsYesterday, k=7, fill=NA, align='right'),
         floors14dayAvg = rollmean(floorsYesterday, k=14, fill=NA, align='right'),
         floors30dayAvg = rollmean(floorsYesterday, k=30, fill=NA, align='right'),
         floors100dayAvg = rollmean(floorsYesterday, k=100, fill=NA, align='right'),
         floors200dayAvg = rollmean(floorsYesterday, k=200, fill=NA, align='right'),
         HRYesterday = lag(RestHR, n=1),
         HR7dayAvg = rollmean(HRYesterday, k=7, fill=NA, align='right'),
         HR14dayAvg = rollmean(HRYesterday, k=14, fill=NA, align='right'),
         HR30dayAvg = rollmean(HRYesterday, k=30, fill=NA, align='right'))

# interpolate missing values 
library(forecast)
data %<>%
  mutate(AvgHR_interp = na.interp(data$AvgHR),
         Pace_interp = na.interp(data$Pace),
         vo2Max_interp = na.interp(data$vo2Max),
         speed_interp = na.interp(data$speed)) %>%
  mutate(speed_lag = stats::lag(speed_interp, n=1),
         speed7day = rollmean(speed_lag, k=7, fill=NA, align='right'))

# grab temperature data from cloud
library(googlesheets)
gs_auth(key="715849066855-s5qmt0h668g5kdms8k8a35pkp67c19t2.apps.googleusercontent.com",
        secret = "-xzNzz268fmrg_JMqKZmkzfU")
#gs_auth(token = "googlesheets_token.rds")
df <- gs_title("RunTemps") # find the sheet of interest in Google Drive
runtemps <- df %>% gs_read(ws="Sheet1") %>% select(-startTime)
runtemps$Date = as.Date(runtemps$Date, "%m/%d/%Y")
data = left_join(data, runtemps, by='Date')
data %<>% filter(Date < '2019-10-27')

write.csv(data, 'fitbit_v2.csv')


# predict speed from a variety of metrics (getting importance of temp, humidity, previous exercise, etc.)
justruns = data %>% filter(Distance >1)
mod = lm(speed~HeatIndex+Humidity+floors14dayAvg+ElevGain,
         data=justruns)
summary(mod)

# so basic speed estimated at 7.49, lose a bit as heat index goes up, gain a bit as humidity goes up
# gain a bit as most recently climbed floors, and lose a fair amount when go up hills
# could perhaps estimate my speed without hills (flat course) using these data, as well

############## STEPWISE REGRESSION ####################
# Feature Selection

# write for loop to capture all rolling means between specific values
# see MLB HR function I wrote, then do for series of i from - to -

# check shape of some variables against speed
plot(y=justruns$speed, x=justruns$HeatIndex) # don't see any gaussian or clear non-linear trends

# might consider mean centering the variables, though as is leaves pretty easy interpretation

features = justruns %>% select(speed, Temp, HeatIndex, Humidity, DewPoint, floorsYesterday, floors7dayAvg, floors14dayAvg, 
                               floors30dayAvg, stepsYesterday, steps7dayAvg, steps14dayAvg, steps30dayAvg, HRYesterday,
                               HR7dayAvg, HR14dayAvg, HR30dayAvg) %>% drop_na()

library(caret)
set.seed(123) # Set seed for reproducibility
train.control <- trainControl(method = "cv", number = 10) # Set up repeated k-fold cross-validation
step.model <- train(speed ~., data = features,
                    method = "leapBackward", 
                    tuneGrid = data.frame(nvmax = 1:10),
                    trControl = train.control
)
step.model$results
summary(step.model$finalModel)
coef(step.model$finalModel, 7) # get model coefficients (must specify winning model number)
# get a quick estimate with made up common values for these outputs
2.68+(80*.011)+(80*.007)+(15*-.01)+(30*.001)+(10500*.00004)+(56*-.025)+(58*.08)




library(car)
step.chosen = glm(speed ~ HeatIndex+Humidity+DewPoint+floors30dayAvg+steps14dayAvg+HR14dayAvg+HR30dayAvg, data=features)
summary(step.chosen)
xtable(step.chosen)
avPlots(step.chosen)



##### MOVING AVERAGES ######
# function to compute rolling averages for a variable over multiple periods
rolling = function(df, x, i) {
  df %>%
    mutate(Yesterday = lag(x, n=1),
           iMA = rollmean(Yesterday, k=i, fill=NA, align='right'))
}




# apply HR_stadium to all seasons at once
stad_data = list(sc2010,sc2011,sc2012,sc2013,sc2014,sc2015,sc2016,sc2017,sc2018) %>%
  lapply(HR_stadium) %>%
  map_df(., extract, c("Game", "Stadium","Visitor","HRs","Year"))








#################### DESCRIPTIVE STATS #############################

# calculate weekly averages, removing empty data
data %>% group_by(Week) %>% 
  summarise(steps_avg = mean(Steps, na.rm=T),
            floors_avg = mean(Floors, na.rm=T),
            HR_avg = mean(RestHR, na.rm=T),
            steps_sum = sum(Steps),
            floors_sum = sum(Floors)) %>%
  add_tally() -> weekly_data

# calcuate monthly averages
data %>% group_by(Month, Year) %>% 
  summarise(steps_avg = mean(Steps, na.rm=T),
            floors_avg = mean(Floors, na.rm=T),
            HR_avg = mean(RestHR, na.rm=T),
            steps_sum = sum(Steps),
            floors_sum = sum(Floors)) %>%
  add_tally() %>%
  arrange(Year) -> monthly_data 
#monthly_data$Date = AsDate(monthly_data$MoYr) back when used MoYr instead of Month, Year to organize

                           
# create xts object with data
weekly_xts = xts(weekly_data[,2:6], order.by = weekly_data$Week) # can't have double dates or throws off, must drop non-index
#monthly_xts = xts(monthly_data[,2:6], order.by = monthly_data$Date)
daily = as.xts(data[,2:4], order.by=as.Date(data$Date, format="%Y-%m-%d")) # turn into xts for analysis


# Plot results --------------------------------------------------------------------------------
library(TTR)
steps30 = SMA(daily[,"Steps"], n=30) # 30 day moving average of steps
plot(steps30)

plot(daily[,"Steps"])
plot(weekly_xts[,"steps_avg"])
plot(monthly_xts[,"steps_avg"])
plot(monthly_xts[,"steps_sum"])

plot(daily[,"Floors"])
plot(weekly_xts[,"floors_avg"])
plot(monthly_xts[,"floors_avg"])
plot(monthly_xts[,"floors_sum"])

plot(daily[,"Resting_HR"])
plot(weekly_xts[,"HR_avg"])
plot(monthly_xts[,"HR_avg"])

# steps moving averages, can see single day or 7 day has too much variation, complicates graph
library(plotly)
plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~steps14dayAvg, name='14 Day MA') %>%
  add_lines(y= ~steps30dayAvg, name='30 Day MA') %>%
  layout(title = 'Fitness Trends Become Visible with Moving Averages',
         yaxis = list(title = 'Steps Walked Per Day - Avg.'),
         xaxis = list(title = '')) 

plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~steps100dayAvg, name='100 Day MA') %>%
  add_lines(y= ~steps200dayAvg, name='200 Day MA')

plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~floors14dayAvg, name='14 Day MA') %>%
  add_lines(y= ~floors30dayAvg, name='30 Day MA') %>%
  layout(title = 'Fitness Trends Become Visible with Moving Averages',
         yaxis = list(title = 'Floors Climbed Per Day - Avg.'),
         xaxis = list(title = ''))

plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~floors100dayAvg, name='100 Day MA') %>%
  add_lines(y= ~floors200dayAvg, name='200 Day MA') %>%
  layout(title = 'Long-Term Moving Averages',
    yaxis = list(title = 'Floors Climbed Per Day - Avg.'),
    xaxis = list(title = ''))

# plot running data, filling in the gaps
plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~Pace_interp)

plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~speed7day) %>% 
  layout(title = 'As I Lose Weight, I Am Running Faster',
         yaxis = list(title = 'Average Speed, in MPH'),
         xaxis = list(title = ''))

plot_ly(data=data, x= ~Date) %>%
  add_lines(y= ~speed_interp) %>% 
  layout(title = 'As I Lose Weight, I Am Running Faster',
         yaxis = list(title = 'Average Speed, in MPH'),
         xaxis = list(title = ''))


# Basic Descriptives -----
library(psych)
describe(data) %>%
  kable("html") %>%
  kable_styling(bootstrap_options = "striped")

library(GGally)
data %>%
  select(Steps,Floors,RestHR,AvgHR,MinAwake,HrsAsleep,ExTime,Distance,Pace,ElevGain,vo2Max) %>%
  ggpairs(use="complete.obs")

library(corrr)
data %>%
  select(Steps,Floors,RestHR,AvgHR,MinAwake,HrsAsleep,ExTime,Distance,Pace,ElevGain,vo2Max) %>%
  correlate() %>% 
  network_plot(min_cor=0.3)

library("PerformanceAnalytics")
data %>%
  select(Steps,Floors,RestHR,AvgHR,MinAwake,HrsAsleep,ExTime,Distance,Pace,ElevGain,vo2Max) -> cordata
chart.Correlation(cordata, histogram=TRUE, pch=19)

# basic correlation matrix with top half removed
mcor = round(cor(cordata, use="complete.obs"),2) 
upper = mcor
upper[upper.tri(mcor)] <- ""
upper = as.data.frame(upper)
upper %>% 
  kable("html") %>%
  kable_styling(bootstrap_options = "striped", full_width=F)

# predictors with outcome (restingHR)
data %>%
  select(RestHR,AvgHR,floors7dayAvg,floors14dayAvg,floors30dayAvg,
         steps7dayAvg,steps14dayAvg,steps30dayAvg) -> corpred
pcor = round(cor(corpred, use="complete.obs"),2) 
pper = pcor
pper[pper.tri(pcor)] <- ""
pper = as.data.frame(pper)
pper

library(apaTables)
apa.cor.table(corpred, filename = "Example3.doc", show.conf.interval = F)

