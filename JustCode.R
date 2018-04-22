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

#create copy of ActTbl to update
UPDATED_ActTbl_missingAreIntervalAVG <- sqldf::sqldf("SELECT * FROM ActTbl")

#test simple update
UPDATED_ActTbl_missingAreIntervalAVG_r1 <- sqldf::sqldf(
c(
"UPDATE UPDATED_ActTbl_missingAreIntervalAVG   
SET steps = 
(SELECT AvgOfSteps 
FROM AverageStepsInInterval 
WHERE AverageStepsInInterval.interval 
= UPDATED_ActTbl_missingAreIntervalAVG.interval) 
WHERE steps IS NULL" , 
  "SELECT * FROM  main.UPDATED_ActTbl_missingAreIntervalAVG"
)
)

TotalDailySteps_r1 <- sqldf::sqldf("SELECT ConvertedToDate, sum(steps) as 'SumOfSteps' 
             FROM UPDATED_ActTbl_missingAreIntervalAVG_r1
             WHERE steps IS NOT NULL
             GROUP BY ConvertedToDate")

hist(TotalDailySteps_r1$SumOfSteps)
mean(TotalDailySteps_r1$SumOfSteps)
median(TotalDailySteps_r1$SumOfSteps)

#Question #4: Activity different pattern wkdy vs. wknd
weekdays <- c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
#Close sqldf connection
#sqldf()
UPDATED_ActTbl_missingAreIntervalAVG_r1$WeekDayClassification <- factor(
  (
    weekdays(
    TotalDailySteps_r1$ConvertedToDate
    ) %in% weekdays), 
  levels=c(FALSE, TRUE)
  , labels=c('weekend', 'weekday')
  )

#weekday average of steps in interval
AverageStepsInInterval_Weekday <- sqldf::sqldf(
"SELECT interval, avg(steps) as 'AvgOfSteps' 
            FROM UPDATED_ActTbl_missingAreIntervalAVG_r1
            WHERE steps IS NOT NULL
            AND WeekDayClassification = 'weekday' 
            GROUP BY interval")

#weekday average of steps in interval
AverageStepsInInterval_Weekend <- sqldf::sqldf(
  "SELECT interval, avg(steps) as 'AvgOfSteps' 
            FROM UPDATED_ActTbl_missingAreIntervalAVG_r1
            WHERE steps IS NOT NULL
            AND WeekDayClassification = 'weekend' 
            GROUP BY interval")
