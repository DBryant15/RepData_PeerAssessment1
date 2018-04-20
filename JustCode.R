#call in libraries
library("sqldf")
library("ggplot2")
library("lubridate")
#library("scales")

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

UPDATE_ActTbl <- sqpdf::sqldf("UPDATE ")

