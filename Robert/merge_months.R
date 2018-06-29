
setwd("~/PythonStuff/Project ArmBop/Robert/Raw_Data/CSVs")

library(tidyverse)
library(data.table)
# Set working directory
#read.csv('04_2017.csv')

#numbs <- as.data.frame(column = NA)
CSVs <- tibble(
    months = c(
'01_2018.csv','02_2018.csv',
'03_2018.csv',#'04_2017.csv',
'04_2018.csv',
'05_2017.csv','06_2017.csv',
'07_2017.csv','08_2017.csv',
'09_2017.csv','10_2017.csv',
'11_2017.csv','12_2017.csv'))
CSVs=as.data.frame(CSVs)

# merge all
for(i in 1:length(CSVs$months)){
	temp<-read_csv(paste0(CSVs$months[i]))
	temp=data.table(temp)
	id=as.character(i)
	(assign(paste0('df',id), temp))
 	if(i == 12){MergedDT = Reduce(function(...) merge(..., all = TRUE), list(df1,df2,df3, df4,df5,df6,df7,df8,df9,df10,df11,df12))
 		}}

# Examine
str(MergedDT)

# set save path
setwd("~/PythonStuff/Project ArmBop/Robert/Data/")
write_csv(MergedDT, "Merged_Flights.csv")
