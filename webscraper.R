library(RSelenium)

driver <- rsDriver(browser=c("firefox"))
remote_driver <- driver[["client"]]
# remote_driver$open()

remote_driver$navigate("http://www.edwaittimes.ca/WaitTimes.aspx")
master_dat <- data.frame()
count <- 1
for(i in 3:11){
  out1 <- remote_driver$findElement(using = "css", value = paste("#Others_Van > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remote_driver$findElement(using = "css", value = paste("#Others_Van > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  master_dat[count, 1]<- name_of_dept
  master_dat[count, 2]<- wait_time
  count<-count+1
}
for(i in 3:4){
  out1 <- remote_driver$findElement(using = "css", value = paste("#Others_Rich > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remote_driver$findElement(using = "css", value = paste("#Others_Rich > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  master_dat[count, 1]<- name_of_dept
  master_dat[count, 2]<- wait_time
  count<-count+1
}

for(i in 3:8){
  out1 <- remote_driver$findElement(using = "css", value = paste("#Others_Coast > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)"))
  out2 <- remote_driver$findElement(using = "css", value = paste("#Others_Coast > div:nth-child(",i,") > div:nth-child(1) > div:nth-child(3) > p:nth-child(1)"))
  name_of_dept <- as.character(out1$getElementText())
  wait_time <- as.character(out2$getElementText())
  master_dat[count, 1]<- name_of_dept
  master_dat[count, 2]<- wait_time
  count<-count+1
}

remote_driver$close()
driver$server$stop()
rm(driver, remote_driver, out1, out2)
gc()

system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

#To Kill and Free All Ports
# system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

#Example Xpath for Vanc General Hosp
/html/body/form/div[3]/div[5]/a[3]/div[2]/div/div[2]/p/a
/html/body/form/div[3]/div[5]/a[3]/div[2]/div/div[3]/p

/html/body/form/div[3]/div[5]/a[3]/div[3]/div/div[2]/p/a

# CSS Selectors
#Others_Van > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)
#Others_Van > div:nth-child(4) > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)
#Others_Rich > div:nth-child(3) > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)
#Others_Coast > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)
#Others_Coast > div:nth-child(4) > div:nth-child(1) > div:nth-child(2) > p:nth-child(1) > a:nth-child(1)