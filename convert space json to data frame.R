
library(httr)
library(dplyr)
library(tidyjson)
library(anytime)
library(stringr)



#Get a list of the SPACE files
files <- list.files(pattern = "\\.space$")
#change filename to json
sapply(files,FUN=function(eachPath){
  file.rename(from=eachPath,to=sub(pattern="space",replacement="json",eachPath))})

#Get a list of JSON
files <- list.files(pattern = "\\.json$")


for (i in files){
  js.file<-print(subset(files, subset=files==i))
  
  json<-read_json(js.file)
  
  messages<-json %>% as.tbl_json %>% 
    enter_object("root") %>%             # Look at their cart
    enter_object("children") %>%             # Look at their cart
    gather_array %>%                              # Expand the data.frame and dive into each array element
    spread_values(type = jstring("type")) %>%     # Keep the user
    spread_values(text = jstring("text"))      # Keep the text of the message
  
  
  messages<-messages[!(is.na(messages$text) | messages$text==""), ]
  
  messages$html2<-paste("<",messages$type,">",messages$text,"</",messages$type,">",sep="")
  
  
  if(nrow(messages) == 0){
    print("data.frame is empty")
  }else{
    
    write.table(messages$html2, paste(js.file,".html",sep=""), row.names = FALSE, sep="", quote=FALSE, col.names=FALSE)
  }
}



htmltxt <- readtext("*.html")


#added the below to deal with files with more text than excel can handle in a single cell
htmltxt$text2<-str_sub(htmltxt$text,start=30000)
str_sub(htmltxt$text,start=30000)<-"";htmltxt

write.csv(htmltxt, "htmltxt.csv", row.names=T)













