Tidy Data
-----------------------

Gathering and tidying health and fitness data from different sources requires interaction with `APIs` and the parsing of data in `xml` and `JSON` formats.

- Apple health data can be downloaded from the Health app in iOS which arrive in `xml` format. 

- Fitbit has an `API` which can be used to access the data, or complete health data can be downloaded from the web in `JSON` format. 

- Strava has an `API` which can be accessed for data downloading, as well.

This folder contains the code required to gather and process health data from Apple, Fitbit, Strava, and Google Sheets, using both `R` and `python` to extract and process the data into a common format - ultimately a `csv` file labeled `health_clean.csv` in the `Data` folder which is used in each of the analyses found in the `Data Analysis` folder.
