library(RSelenium)
library(netstat)
library(taskscheduleR)
library(tidyverse)

# Creating server
rs_driver_object <- rsDriver(browser = 'firefox',
                             port = free_port(),
                             verbose = F)

# Creating client object
remDr <- rs_driver_object$client
remDr$quit()

# Repeat this every time to scrape
remDr$open()
remDr$navigate("http://www.edwaittimes.ca/WaitTimes.aspx")

temp <- data.frame()
count <- 1
# Adding buffer to make sure webpage is dynamically loaded
Sys.sleep(10)

# Building temp dataframe to add to master csv
for(i in 3:11){
  out1 <- remDr$findElement(using = "css", value = paste("#Others_Van > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remDr$findElement(using = "css", value = paste("#Others_Van > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  temp[count, 1]<- name_of_dept
  temp[count, 2]<- wait_time
  count<-count+1
}
for(i in 3:4){
  out1 <- remDr$findElement(using = "css", value = paste("#Others_Rich > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remDr$findElement(using = "css", value = paste("#Others_Rich > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  temp[count, 1]<- name_of_dept
  temp[count, 2]<- wait_time
  count<-count+1
}

for(i in 3:8){
  out1 <- remDr$findElement(using = "css", value = paste("#Others_Coast > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remDr$findElement(using = "css", value = paste("#Others_Coast > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  temp[count, 1]<- name_of_dept
  temp[count, 2]<- wait_time
  count<-count+1
}

remDr$quit()

rs_driver_object$server$stop()
rm(rs_driver_object, remDr, out1, out2, count, i, name_of_dept, wait_time)
gc()
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

# Adding to master csv file
setwd("~/GitHub/Vancouver-Hospital-Project")
master_data <- read.csv("master_data.csv")
temp<- arrange(temp, V1)
temp<- mutate(temp, Date=as.character(Sys.time()))
colnames(temp) <- c("Hospital_or_ER_Room","Estimated_Time","DateTime")
master_data<-rbind(master_data, temp)
master_data <- arrange(master_data, Hospital_or_ER_Room)
write.csv(master_data, "master_data.csv", row.names = F)
rm(temp, master_data)
