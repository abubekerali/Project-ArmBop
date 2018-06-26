library(tidyverse)
# Set working directory
#read.csv('04_2017.csv')

numbs = as.data.frame(column = "")
numbs$months = as.data.frame(4:12)
numbs$months=str_pad(numbs$months, 2, pad="0")

for(month in numbs$months){
 temp<-read.csv(paste0(month,"_2017.csv"))
 paste0("df_",month)<-temp
 if(month == 12){airplane_df=rbind(df_04,df_05,df_06,df_07,df_08,df_09,df_10,df_11,df_12)}}

# set save path
write.csv(airplane_df, "final_data")


