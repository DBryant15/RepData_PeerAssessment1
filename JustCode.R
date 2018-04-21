#call in libraries


library("sqldf")
library("ggplot2")
library("lubridate")
#library("scales")

#open connection to sqldf database
#sqldf()

ActTbl <- read.csv(unzip("activity.zip","activity.csv"), header = TRUE, stringsAsFactors = FALSE)
ActTbl$ConvertedToDate <- ymd(ActTbl$date)

#Question1 - total steps per day
TotalDailySteps <- sqldf::sqldf("SELECT ConvertedToDate, sum(steps) as 'SumOfSteps' 
             FROM ActTbl
             WHERE steps IS NOT NULL
             GROUP BY ConvertedToDate")

hist(TotalDailySteps$SumOfSteps)
mean(TotalDailySteps$SumOfSteps)
median(TotalDailySteps$SumOfSteps)

# Question 2 - Daily pattern
AverageStepsInInterval <- sqldf::sqldf("SELECT interval, avg(steps) as 'AvgOfSteps' 
            FROM ActTbl
            WHERE steps IS NOT NULL
            GROUP BY interval")

dailyAvg_MaxSteps <- sqldf::sqldf("SELECT interval, max(AvgOfSteps) as 'MaxOfSteps' 
            FROM AverageStepsInInterval")

# Question 3 - Inputting missing values
MissingStepsDataRows <- sqldf::sqldf("SELECT * 
             FROM ActTbl
             WHERE steps IS NULL
             ") #GROUP BY ConvertedToDate

CountOf_MissingStepsDataRows <- sqldf::sqldf("SELECT count(ConvertedToDate) 
             FROM MissingStepsDataRows
             ") #GROUP BY ConvertedToDate

#create a new dataframe where the missing values are updated
# with the average for the 5 minute interval

#create copy of ActTbl to update
UPDATED_ActTbl_missingAreIntervalAVG <- sqldf::sqldf("SELECT * FROM ActTbl")
#20180421 1038 DWB - below failed with error: 
#"Error in result_create(conn@ptr, statement) : near ".": syntax error"

#moved away from this to try different methods...
# sqldf::sqldf(c("UPDATE UPDATED_ActTbl_missingAreIntervalAVG 
#              SET UPDATED_ActTbl_missingAreIntervalAVG.Interval = 
# ((SELECT * FROM AverageStepsInInterval) as B) 
#              WHERE UPDATED_ActTbl_missingAreIntervalAVG.Interval = B.Interval 
#              AND UPDATED_ActTbl_missingAreIntervalAVG.steps IS NULL", 
#              "SELECT * FROM main.UPDATED_ActTbl_missingAreIntervalAVG"), method = "raw")

#20180421 1119 DWB accorfing to the following stack overflow 
#SQLite may not be able to do inner join with updates:
#https://stackoverflow.com/questions/19270259/update-with-join-in-sqlite

#20180421 1045 DWB second attempt to replace NULL step values with 
#the average in that interval
#using no inner join in UPDATE
#look to the post for an example that may work

#test simple update
UPDATED_ActTbl_missingAreIntervalAVG <- sqldf::sqldf(
"UPDATE UPDATED_ActTbl_missingAreIntervalAVG  
SET steps = 1 
WHERE steps = 'NA'")

#Question #4: Activity different pattern wkdy vs. wknd

#Close sqldf connection
#sqldf()

