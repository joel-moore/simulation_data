####################################################################################################################
############## THIS IS THE ONLY THING YOU HAVE TO CHANGE ###########################################################

#Insert slack token: replace the space between the quotation marks with the token you copied from your API page.
token<-"____________________________"

####################################################################################################################

#These are the packages you'll need to install in order to successfully run this script.


library(httr)
library(dplyr)

install.packages("devtools")
library(devtools)
devtools::install_github("sailthru/tidyjson")
library(tidyjson)

library(anytime)
library(stringr)
library(plyr)


####################################################################################################################
############## You won't have to worry about anything below here ###################################################
####################################################################################################################


##Get a list of users

usr.url<-"https://slack.com/api/users.list?token="
users.lst <- GET(paste(usr.url,token, sep=""),  verbose())
users.txt <- content(users.lst, "text")

users<-users.txt %>% as.tbl_json %>% 
  enter_object("members") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(id = jstring("id")) %>%     # Keep the date of the cart
  spread_values(name = jstring("name"))  %>%     # Keep the date of the cart
  spread_values(name = jstring("real_name"))     # Keep the date of the cart


#get list of private groups for a team

GroupsList.url <- "https://slack.com/api/groups.list?token="
slack.GL <- GET(paste(GroupsList.url,token,sep=""),  verbose())
slack.GL.txt <- content(slack.GL, "text")

groups<-slack.GL.txt %>% as.tbl_json %>% 
  enter_object("groups") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(id = jstring("id")) %>%     # Keep the date of the cart
  spread_values(name = jstring("name"))      # Keep the date of the cart




##############################################################################
##create loop for getting messages

base.url<- "https://slack.com/api/groups.history?token="

#create list of ursl
#Group.URLS <- paste0(base.url,token,"&count=1000&channel=", groups$id)


#create a dataframe that includes a list of urls
url.lst<-paste(base.url,token,"&count=1000&channel=",groups$id, sep="")

#LOOP

for (i in url.lst){
  url<-print(subset(url.lst, subset=url.lst==i))
  slack <- GET(url)
  slack.txt <- content(slack, "text")
  
  messages<-slack.txt %>% as.tbl_json %>% 
    enter_object("messages") %>%             # Look at their cart
    gather_array %>%                              # Expand the data.frame and dive into each array element
    spread_values(user = jstring("user")) %>%     # Keep the user
    spread_values(text = jstring("text")) %>%     # Keep the text of the message
    spread_values(type = jstring("type")) %>%     # Keep the type of post
    spread_values(ts = jstring("ts"))     # Keep the timestamp of the post
  
  
  if(nrow(messages) == 0){
    print("data.frame is empty")
  }else{
    
    #create column for user name
    users<-rename(users, c("id"="user"))
    messages <- (merge(users, messages, by = "user"))
    messages<-messages[c(4,5,8,10)]
    
    
    #create column for group id and name
    
    messages$id<-print(subset(url.lst, subset=url.lst==i))
    messages$id<-str_sub(messages$id, -9,-1)
    messages <- (merge(groups, messages, by = "id"))
    # messages$group_name<-groups$name
    messages<-messages[c(1,4,5,6,7,8)]
    
    
    # Write csv file with group id as filename
    write.csv(messages, paste(paste(str_sub(url, start= -9), "-message", sep=''), ".csv", sep=''), row.names=F)
  }
}








######################################################################################
################# GET ALL PUBLIC CHANNELS ###########################################

#get list of public channels for a team

ChannelsList.url <- "https://slack.com/api/channels.list?token="
channels.slack.GL <- GET(paste(ChannelsList.url,token,sep=""),  verbose())
channels.slack.GL.txt <- content(channels.slack.GL, "text")

channels<-channels.slack.GL.txt %>% as.tbl_json %>% 
  enter_object("channels") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(id = jstring("id")) %>%     # Keep the date of the cart
  spread_values(name = jstring("name"))      # Keep the date of the cart




##############################################################################
##create loop for getting messages

base.url<- "https://slack.com/api/channels.history?token="

#create list of ursl
#Group.URLS <- paste0(base.url,token,"&count=1000&channel=", groups$id)


#create a dataframe that includes a list of urls
url.lst<-paste(base.url,token,"&count=1000&channel=",channels$id, sep="")

#LOOP

for (i in url.lst){
  url<-print(subset(url.lst, subset=url.lst==i))
  slack <- GET(url)
  slack.txt <- content(slack, "text")
  
  messages<-slack.txt %>% as.tbl_json %>% 
    enter_object("messages") %>%             # Look at their cart
    gather_array %>%                              # Expand the data.frame and dive into each array element
    spread_values(user = jstring("user")) %>%     # Keep the user
    spread_values(text = jstring("text")) %>%     # Keep the text of the message
    spread_values(type = jstring("type")) %>%     # Keep the type of post
    spread_values(ts = jstring("ts"))     # Keep the timestamp of the post
  
  
  if(nrow(messages) == 0){
    print("data.frame is empty")
  }else{
    
    #create column for user name
    #    users<-rename(users, c("id"="user"))
    messages <- (merge(users, messages, by = "user"))
    #    messages<-messages[c(4,5,8,10)]
    
    
    #create column for group id and name
    
    messages$id<-print(subset(url.lst, subset=url.lst==i))
    messages$id<-str_sub(messages$id, -9,-1)
    messages <- (merge(channels, messages, by = "id"))
    # messages$group_name<-groups$name
    messages<-messages[c(1,4,8,9,12,14)]
    
    
    # Write csv file with group id as filename
    write.csv(messages, paste(paste(str_sub(url, start= -9), "-message", sep=''), ".csv", sep=''), row.names=F)
  }
}


###############################################################

#Pull all individual files into one dataframe

ALL_Messages <- list.files(pattern="*.csv",full.names = TRUE) %>% 
  lapply(read.csv) %>% 
  bind_rows 

#create dates and times column from timestamp
ALL_Messages$date<-anydate(ALL_Messages$ts)
ALL_Messages$time<-anytime(ALL_Messages$ts)

write.csv(ALL_Messages, "all_messages.csv")
