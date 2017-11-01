#docx


DATA_DIR <- system.file("C:\\Users\\JoelD\\Dropbox\\COURSES\\WIC2017\\FINAL SLACK CONTENT\\WEDNESDAY\\FILES_v2", package = "readtext")


DocxTXT<-readtext(paste0(DATA_DIR, "*.docx"))



DocxTXT$ts<-str_sub(DocxTXT$doc_id, end=10)
DocxTXT$name<-str_sub(DocxTXT$doc_id, start=12)


DocxTXT$group<-rm_between(DocxTXT$name, 'grn_', '_nam_', extract=TRUE)
DocxTXT$title<-rm_between(DocxTXT$name, '_nam_', '.pdf', extract=TRUE)


DocxTXT$text<-iconv(DocxTXT, "utf-8", "ASCII", sub = "")

DocxTXT$ts<-as.numeric(DocxTXT$ts)
#create dates and times column from timestamp
DocxTXT$date<-anydate(DocxTXT$ts)
DocxTXT$time<-anytime(DocxTXT$ts)

DocxTXT$name.x<-DocxTXT$group

DocxTXT<-DocxTXT[c(2,3,6,7,8,9)]

DocxTXT$text2<-str_sub(DocxTXT$text,start=30000)
str_sub(DocxTXT$text,start=30000)<-"";DocxTXT

write.csv(DocxTXT, "DocxTXT.csv", row.names=T, col.names=TRUE)

#DocxTXT$col2 <- nchar(as.character(DocxTXT$text))

library(xlsx)
write.xlsx(DocxTXT, "DocTXT.xlsx", row.names=TRUE, col.names=TRUE)







