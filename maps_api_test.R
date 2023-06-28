library(mapsapi)
library(xml2)
library(ggthemes)
library(RSelenium)
library(netstat)
library(tidyverse)

# Grabbing waiting times and names
rs_driver_object <- rsDriver(browser = 'firefox',
                             port = free_port(),
                             verbose = F)
remDr <- rs_driver_object$client
remDr$quit()
remDr$open()
remDr$navigate("http://www.edwaittimes.ca/WaitTimes.aspx")
temp <- data.frame()
count <- 1
Sys.sleep(10)
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


# Inputting Google Maps API Key
key = read.delim("C:/Users/suder/Documents/google_maps_api_key.txt")

# PUT IN KEY HERE DIRECTLY
key <- colnames(key)


temp<- arrange(temp, V1)
locations <- temp$V1
# Adding ", Vancouver" to "Richmond Hospital" to clarify for Google Distance Matrix API
locations[9] <- "Richmond Hospital, Vancouver"


final <- data.frame()

# Creating Long data frame while pulling data with Distance Matrix API used for duration
for(i in 1:17){
  df_temp <- data.frame(matrix(NA,nrow=17,ncol=3))
  for(j in 1:17){
    xml_api_return = mp_matrix(
      origins = locations[i],
      destinations = locations[j],
      mode = "driving",
      key = key,
      quiet = T
    )
    df_temp[j,1] <- locations[i]
    df_temp[j,2] <- locations[j]
    df_temp[j,3] <- as.numeric(mp_get_matrix(doc = xml_api_return, value = "duration_s"))
  }
  colnames(df_temp) <- c("Origin","Destination","Trip_Duration_s")
  final<-rbind(final, df_temp)
}

# Cleaning up
rm(i,locations,xml_api_return,df_temp,j)
gc()

# Turning all origins and destinations which are closed to NA
for(i in 1:length(temp$V1)){
  time_list <- strsplit(x=temp$V2[i], split = ":")
  hours <- as.numeric(time_list[[1]][1])
  if(is.na(hours)){
    for(j in 1:length(final$Origin)){
      if(final$Origin[j]==temp$V1[i] || final$Destination[j]==temp$V1[i]){
        final$Trip_Duration_s[j] <- NA
      }
    }
  }
}

# Changing Richmond Hospital, Vancouver back to original
for(i in 1:length(final$Origin)){
  if(final$Origin[i]=="Richmond Hospital, Vancouver"){
    final$Origin[i] <- temp$V1[9]
  }
  if(final$Destination[i]=="Richmond Hospital, Vancouver"){
    final$Destination[i] <- temp$V1[9]
  }
}

# Adding destination waiting times to 'final' data frame
for(i in 1:length(final$Origin)){
  for(j in 1:length(temp$V1)){
    if(final$Destination[i]==temp$V1[j]){
      time_list <- strsplit(x=temp$V2[j], split = ":")
      hours <- as.numeric(time_list[[1]][1])
      if(!is.na(hours)){
        minutes <- as.numeric(time_list[[1]][2])
        final$Trip_Duration_s[i] = final$Trip_Duration_s[i]+hours*60*60+minutes*60
      }
    } 
  }
}

# Removing origin waiting times from 'final' data frame
for(i in 1:length(final$Origin)){
  for(j in 1:length(temp$V1)){
    if(final$Origin[i]==temp$V1[j]){
      time_list <- strsplit(x=temp$V2[j], split = ":")
      hours <- as.numeric(time_list[[1]][1])
      minutes <- as.numeric(time_list[[1]][2])
      final$Trip_Duration_s[i] = final$Trip_Duration_s[i]-hours*60*60-minutes*60
    } 
  }
}

# Converting time save in seconds to an identifier if time was saved or not
final<- mutate(final, Time_Save_m = Trip_Duration_s/60)
for(i in 1:length(final$Origin)){
  if(is.na(final$Time_Save_m[i])){
    final[i,5] <- NA
  }
  else{
    if(final$Time_Save_m[i]==0){
      final[i,5] <- 0
    }
    if(final$Time_Save_m[i]>0){
      final[i,5] <- 1
    }
    if(final$Time_Save_m[i]<0){
      final[i,5] <- -1
    }
  }
}

#
tidy_name <- function(name, n_char) {
  ifelse(nchar(name) > (n_char - 2), 
         {substr(name, 1, n_char) %>% paste0(., "..")},
         name)
}
final$Origin<- tidy_name(final$Origin, 17)
final$Destination <- tidy_name(final$Destination, 17)
count(final$V5)
ggplot(final, aes(x = Origin, y = Destination)) +
  geom_tile(data = subset(final, !is.na(V5)), aes(fill = V5), alpha = 1, color = "#00000010") +
  geom_tile(data = subset(final,  is.na(V5)), linetype = 0, fill = "black", alpha = 0.5)+
  labs(fill = "Efficient Transfer")+
  ggtitle("Would Hospital Transfers Be Efficient?")+
  theme_solarized()+
  theme(panel.grid.major = element_blank(),axis.line.x = element_blank(), axis.text.x = element_text(angle=+90,vjust = 0.5, hjust=1))+
  scale_fill_gradientn(colors = c("#3078FF",NA,"#FFB730"), labels=c("Yes"," ", "No"), breaks = c(-1,0,1))

# Calculating total time to be saved if the transfer were executed THIS moment
total_timesave_m <- 0
for(i in 1:289){
  if(!is.na(final$Time_Save_m[i])){
    if(final$V5[i]<0){
      total_timesave_m <- total_timesave_m+final$Time_Save_m[i]
    }
  }
}
total_timesave_hr <- total_timesave_m/60
