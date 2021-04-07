Available Data
-----------------------

Data dictionaries for the attached datasets are presented below.

### apple_clean.csv

A dataset of health metrics from Apple watch. Apple originally provides two .xml files with relevant health data when accessing your data repository: `export_cda.xml` and `export.xml`. Documentation on how to parse these files for relevant exercise and heart rate data, along with calculating daily statistics from shorter interval metrics, can be found in the file `apple_health_xmr_to_tidy.R` in the `Data Mining` folder.

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `Rank` | Integer | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `Artist` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `Track` | String | Title of song | 'til summer comes around to yours if you want it |
| `Year` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |
