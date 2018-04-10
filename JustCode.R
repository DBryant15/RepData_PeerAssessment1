#call in libraries
library("sqldf")
library("ggplot2")
library("lubridate")
library("scales")

ActTbl <- read.csv(unzip("activity.zip","activity.csv"), header = TRUE, stringsAsFactors = FALSE)
ActTbl$ConvertedToDate <- ymd(ActTbl$date)

#Question1 processing
TotalDailySteps <- sqldf::sqldf("SELECT ConvertedToDate, sum(steps) as 'SumOfSteps' 
             FROM ActTbl
             WHERE steps <> 'NA'
             GROUP BY date")
#20180410 1336 DWB having a lot of issue figuring out how to make a histogram 
#of the daily steps
#qplot(TotalDailySteps)
#ggplot(TotalDailySteps,aes(x = TotalDailySteps$ConvertedToDate)) +
#stat_bin(binwidth=1, position="identity") + 
#scale_x_date(breaks=date_breaks(width="1 month"))
#hist(TotalDailySteps, breaks = "days")
