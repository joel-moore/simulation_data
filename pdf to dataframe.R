#Get list of all PDFs

## Set director to location of pdfs

library(stringr)
library(readtext)
library(anytime)



pdftxt <- readtext("*.pdf")



pdftxt$ts<-str_sub(pdftxt$doc_id, end=10)
pdftxt$name<-str_sub(pdftxt$doc_id, start=12)


pdftxt$group<-rm_between(pdftxt$name, 'grn_', '_nam_', extract=TRUE)
pdftxt$title<-rm_between(pdftxt$name, '_nam_', '.pdf', extract=TRUE)


pdftxt$text<-iconv(pdftxt$text, "utf-8", "ASCII", sub = "")

pdftxt$ts<-as.numeric(pdftxt$ts)
#create dates and times column from timestamp
pdftxt$date<-anydate(pdftxt$ts)
pdftxt$time<-anytime(pdftxt$ts)

pdftxt$name.x<-pdftxt$group

pdftxt<-pdftxt[c(2,3,6,7,8,9)]

#added the below to deal with files with more text than excel can handle in a single cell
pdftxt$text2<-str_sub(pdftxt$text,start=30000)
str_sub(pdftxt$text,start=30000)<-"";pdftxt

write.csv(pdftxt, "pdftxt.csv", row.names=T)
