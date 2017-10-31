####################################################################################################################
############## THIS IS THE ONLY THING YOU HAVE TO CHANGE ###########################################################

#Insert slack token: replace the space between the quotation marks with the token you copied from your API page.
token<-"____________________________"

####################################################################################################################

#These are the packages you'll need to install in order to successfully run this script.

library(tidyr)
library(qdapRegex)
library(stringr)
library(httr)


install.packages("devtools")
library(devtools)
devtools::install_github("sailthru/tidyjson")
library(tidyjson)

library(dplyr)
library(plyr)
library(googledrive)


#get list of files
files.url<-"https://slack.com/api/files.list?token="
files.lst <- GET(paste(files.url,token, sep=""),  verbose())
files.txt <- content(files.lst, "text")


#extract list from JSON
files.urls<-files.txt %>% as.tbl_json %>% 
  enter_object("files") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(id = jstring("id")) %>%     # Keep the date of the cart
spread_values(name = jstring("name")) %>%     # Keep the date of the cart
  spread_values(timestamp = jstring("timestamp")) %>%     # Keep the date of the cart
  spread_values(username = jstring("username")) %>%     # Keep the date of the cart
  spread_values(channels = jstring("channels")) %>%     # Keep the date of the cart
  spread_values(groups = jstring("groups")) %>%     # Keep the date of the cart
  spread_values(filetype = jstring("filetype")) %>%     # Keep the date of the cart
  spread_values(url_private = jstring("url_private"))# %>%     # Keep the date of the cart


files.urls$name<-gsub("[.]","",files.urls$name) 

#extract text between " "
files.urls$channels<-rm_between(files.urls$channels, '"', '"', extract=TRUE)
files.urls$groups<-rm_between(files.urls$groups, '"', '"', extract=TRUE)


#convert to character
files.urls[] <- lapply(files.urls, as.character)

#replace nas with other channel
files.urls$channel_id<-with(files.urls,ifelse(is.na(channels),groups,channels))







#get list of channels
channels.url<-"https://slack.com/api/channels.list?token="
channels.lst <- GET(paste(channels.url,token, sep=""))
channels.txt <- content(channels.lst, "text")



#extract list from JSON
channels.names<-channels.txt %>% as.tbl_json %>% 
  enter_object("channels") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(id = jstring("id")) %>%     # Keep the date of the cart
  spread_values(name = jstring("name"))      # Keep the date of the cart





####DELETE THIS
usr.url<-"https://slack.com/api/users.list?token="
users.lst <- GET(paste(usr.url,token, sep=""),  verbose())
users.txt <- content(users.lst, "text")
###############


#get list of groups
groups.url<-"https://slack.com/api/groups.list?token="
groups.lst <- GET(paste(groups.url,token, sep=""))
groups.txt <- content(groups.lst, "text")



#extract list from JSON
group.names<-groups.txt %>% as.tbl_json %>% 
  enter_object("groups") %>%             # Look at their cart
  gather_array %>%                              # Expand the data.frame and dive into each array element
  spread_values(groups = jstring("id")) %>%     # Keep the date of the cart
  spread_values(name = jstring("name"))      # Keep the date of the cart




#merge column for groups
files.urls <- (merge(group.names, files.urls, by = "groups"))
files.urls<-files.urls[c(1,4,7,8,9,12,13,14)]



#seperate Slack and other docs
otherfiles<-files.urls[grep("slack", files.urls$url_private,invert=TRUE), ]
files.urls<-files.urls[grep("slack", files.urls$url_private), ]


apply(files.urls,1,function(row){
  url_private<-row["url_private"]
  groupname<-row["name.x"]
name<-row["name.y"]
id<-row["id"]
filetype<-row["filetype"]
timestamp<-row["timestamp"]
    GET(url_private, add_headers(Authorization = paste("Bearer",token,sep=' '),
        write_disk(paste(timestamp,"_",groupname,"_",name,".",filetype, sep='')))
})


write.csv(otherfiles, "otherfiles.csv")
