Available Data
-----------------------

This repository contains all of the cleaned data files, though the main file of interest is `health_clean.csv` as this is the fully-merged data file which incorporates all of the data in a single file.

### apple_clean.csv

A dataset of health metrics from Apple watch. Apple originally provides two .xml files with relevant health data when accessing your data repository: `export_cda.xml` and `export.xml`. Documentation on how to parse these files for relevant exercise and heart rate data, along with calculating daily statistics from shorter interval metrics, can be found in the file `apple_health_xmr_to_tidy.R` in the `Data Mining` folder.

### fitbit_clean.csv

A dataset of health metrics from Fitbit wearable device. Fitbit provides access to an individual's complete data file upon request. The zip folder you can download contains a series of different folders with the majority of the data in JSON format in various intervals (day, 15 minute, minute). Documentation on how to parse these files for relevant exercise and heart rate data, along with calculating daily summary statistics from shorter interval metrics can be found in the file `fitbit_health_json_to_tidy.ipynb` in the `Data Mining` folder.

### running_clean.csv

A dataset of tracked runs from Strava app along with historic weather conditions for the date (and time) of the run from DarkSky.

### health_clean.csv

The complete dataset containing all variables of interest from each source (Apple, Fitbit, Strava, DarkSky).

| Column Name | Data Type | Description |
|-------------|-----------|-----------|
| `date` | Date | Date, in (YYYY-MM-DD) |  
| `steps` | Numeric | Total steps walked during the day | 
| `floors` | Numeric | Total floors climbed during the day | 
| `rest_hr` | Numeric | Calculated resting heart rate for the day, in beats per minute | 
| `exercise_minutes` | Numeric | Total minutes of exercise during the day |
| `stand_minutes` | Numeric | Total minutes standing during the day | 
| `walk_hr` | Numeric | Average heart rate when walking, for the day, in beats per minute | 
| `run_start_time` | Numeric | Start time of the run, in 24 hour clock time | 
| `run_distance` | Numeric | Distance covered during the run, in miles | 
| `mi_min_pace` | Numeric | Pace of the run, in miles per minute | 
| `run_duration` | Numeric | Duration of the run activity, in seconds |
| `run_active_duration` | Numeric | Duration of the run when actually running (excludes time when activity paused), in seconds | 
| `max_heartrate` | Numeric | Maximum heart rate achieved during the run | 
| `mi_min_max_pace` | Numeric | Quickest recorded pace during the run, in miles per minute | 
| `strava_elev_gain` | Numeric | Total elevation gain during the run, in feet |
| `sleep_start_time` | Numeric | Total elevation gain during the run, in feet |
| `sleep_end_time` | Numeric | Total elevation gain during the run, in feet |
| `sleep_duration` | Numeric | Total elevation gain during the run, in feet |
| `sleep_efficiency` | Numeric | Total elevation gain during the run, in feet |
| `asleep_min` | Numeric | Total elevation gain during the run, in feet |
| `awake_min` | Numeric | Total elevation gain during the run, in feet |
| `time_in_bed` | Numeric | Total elevation gain during the run, in feet |
| `hours_asleep` | Numeric | Total elevation gain during the run, in feet |
| `sleep_start_hour` | Numeric | Total elevation gain during the run, in feet |
| `sleep_end_hour` | Numeric | Total elevation gain during the run, in feet |
| `awake_pct` | Numeric | Total elevation gain during the run, in feet |
| `month` | Numeric | Total elevation gain during the run, in feet |
| `day` | Numeric | Total elevation gain during the run, in feet |
| `week` | Numeric | Total elevation gain during the run, in feet |
| `year` | Numeric | Total elevation gain during the run, in feet |
| `mo_yr` | Numeric | Total elevation gain during the run, in feet |




