library(mapsapi)
library(xml2)
library(ggthemes)

# Inputting Google Maps API Key
key = read.delim("C:/Users/suder/Documents/google_maps_api_key.txt")
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

# Cleaning
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

ggplot(data = final)+
  geom_tile(mapping = aes(x=final$Origin,y=final$Destination,fill=final$Trip_Duration_s))+
  scale_fill_gradient(low = "red", high = "white")+
  theme_wsj()
