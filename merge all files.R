#MERGE ALL FILES


#Get a list of the csv files
files <- list.files(pattern = "*.csv")



tbl = lapply(c("DocxTXT.csv",     "pdftxt.csv"  ), read_csv) %>% bind_rows()
tbl<-tbl[c(2,3,5,6,7,8)]

tbl$source<-"files"



getwd()
setwd("..")
getwd()


write.csv(tbl, "alltextfiles.csv")

ALL = lapply(c("alltextfiles.csv",    "all_messages.csv"  ), read_csv) %>% bind_rows()
write.csv(tbl, "all.csv")
