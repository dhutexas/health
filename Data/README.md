Available Data
-----------------------

Data dictionaries for the attached datasets are presented below.

### apple_clean.csv

A dataset of health metrics from Apple watch. Apple originally provides two .xml files with relevant health data when accessing your data repository: `export_cda.xml` and `export.xml`. Documentation on how to parse these files for relevant exercise and heart rate data, along with calculating daily statistics from shorter interval metrics, can be found in the file `apple_health_xmr_to_tidy.R` in the `Data Mining` folder.

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `date` | Integer | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `steps` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `rest_hr` | String | Title of song | 'til summer comes around to yours if you want it |
| `floors` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |
| `exercise_minutes` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |
| `stand_minutes` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |
| `walk_hr` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |

### fitbit_clean.csv

A dataset of health metrics from Fitbit wearable device. Fitbit provides access to an individual's complete data file upon request. The zip folder you can download contains a series of different folders with the majority of the data in JSON format in various intervals (day, 15 minute, minute). Documentation on how to parse these files for relevant exercise and heart rate data, along with calculating daily summary statistics from shorter interval metrics can be found in the file `fitbit_health_json_to_tidy.ipynb` in the `Data Mining` folder.

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `date` | Integer | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `steps` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |


### running_clean.csv

A dataset of tracked runs from Strava app along with historic weather conditions for the date (and time) of the run from DarkSky.

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `date` | Date | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `temp` | Integer | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `heat_index` | Integer | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `humidity` | Integer | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `dew_point` | Integer | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `activity_name` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `duration` | Numeric | Time of run, in minutes | a thousand horses to zac brown band featuring jimmy buffett  |
| `steps` | Integer | Number of steps taken during the run | a thousand horses to zac brown band featuring jimmy buffett  |
| `calories` | Integer | Estimated number of calories burned during the run | a thousand horses to zac brown band featuring jimmy buffett  |
| `distance` | Numeric | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `speed` | Numeric | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `pace` | Numeric | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `elev_gain` | Numeric | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `vo2max` | Numeric | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `avg_hr` | Integer | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |



### runkeeper.csv

A dataset of health metrics from the Runkeeper app. 

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `date` | Integer | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `steps` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |




