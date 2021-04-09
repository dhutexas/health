# grab temperature data from cloud
library(googlesheets)
dw <- config::get("datawarehouse_health")
key <- dw$sheets_key
secret <- dw$sheets_secret
gs_auth(key=key, secret=secret)

df <- gs_title("RunTemps") # find the sheet of interest in Google Drive
runtemps <- df %>% gs_read(ws="Sheet1") %>% select(-startTime)
runtemps$Date = as.Date(runtemps$Date, "%m/%d/%Y")

write.csv(runtemps, 'running_temps.csv', row.names = FALSE)