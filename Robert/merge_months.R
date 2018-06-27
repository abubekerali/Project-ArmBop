
setwd("~/PythonStuff/Project ArmBop/Robert/Raw_Data/CSVs")

library(tidyverse)
# Set working directory
#read.csv('04_2017.csv')

#numbs <- as.data.frame(column = NA)
numbs = as.list(1:12)
CSVs=as.data.frame(number=numbs)
CSVs$month=as.character(CSVs$numbs)
CSVs$month=str_pad(CSVs$month, 2, pad="0")

for(month in CSVs$numbs){
	temp<-read_csv(paste0(CSVs$month,"_2017.csv"))
	paste0("df_",month,"_17")<-temp
 	if(month == '12'){df_2017=rbind(df_05_17,df_06_17,df_07_17,df_08_17,df_09_17,df_10_17,df_11_17,df_12_17)}}

for(month in CSVs$numbs){
 	if(month == '12'){
	temp<-read_csv(paste0(CSVs$month,"_2017.csv"))
	paste0("df_",month,"_17")<-temp
 	if(month == '12'){df_2017=rbind(df_05_17,df_06_17,df_07_17,df_08_17,df_09_17,df_10_17,df_11_17,df_12_17)}}

	
	temp<-read_csv(paste0(month,"_2018.csv"))
 	paste0("df_",month,"_18")<-temp
 	if(month == '12'){df_2018=rbind(df_01_18,df_02_18,df_03_18,df_04_18,  #18
 							  df_05_17,df_06_17,df_07_17,df_08_17,df_09_17,df_10_17,df_11_17,df_12_17)} #17
 	}

merge()
# set save path
#write.csv(airplane_df, "final_data")


