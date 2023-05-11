library(tidyverse)

# valid_params <- c()
# possible_params <- c(316,449,6012,6011,6013,351,352,606,608,7018,5018,7029,5029,611,5610,5617,5480,7480,624,5623,5759,627,5626,428,443,78,431,21,20,441,475,1629,7014,5014,451,24,505,4406,6007,1631,10,7016,7073,7419,5419,1771,643,645,435,430,6008,6005,486,447,450,394,503,6009,432,25,7013,4813,656,5655,1657,464,81,1659,1668,465,1045,7015,5015,38,8,1046,9,7,1772,482,7012,5012,712,714,5,6001,715,717,1,1047,32,6006,82,33,7063)
# for(i in possible_params){
#   url <- str_c("https://fme.discomap.eea.europa.eu/fmedatastreaming/AirQualityDownload/AQData_Extract.fmw?CountryCode=ES&CityName=Valencia&Pollutant=", i, "&Year_from=2023&Year_to=2023&Station=&Samplingpoint=&Source=All&Output=TEXT&UpdateDate=&TimeCoverage=Last7days")
#   links <- readLines(url)
#   
#   if(!is_empty(links)){
#     print(i)
#     valid_params <- c(valid_params, i)
#   }
# }

valid_params <- c(1, 5, 7, 8, 9, 10, 20, 38, 6001)

urls <- c(str_c("https://fme.discomap.eea.europa.eu/fmedatastreaming/AirQualityDownload/AQData_Extract.fmw?CountryCode=ES&CityName=Valencia&Pollutant=", valid_params, "&Year_from=2023&Year_to=2023&Station=&Samplingpoint=&Source=E2a&Output=TEXT&UpdateDate=&TimeCoverage=Last7days"),
          str_c("https://fme.discomap.eea.europa.eu/fmedatastreaming/AirQualityDownload/AQData_Extract.fmw?CountryCode=ES&CityName=&Pollutant=", valid_params,"&Year_from=2023&Year_to=2023&Station=STA_ES2163A&Samplingpoint=&Source=E2a&Output=TEXT&UpdateDate=&TimeCoverage=Last7days"))

data <- data.frame()
for(url in urls){
  links <- readLines(url)
  
  for(link in links){
    station <- read.csv(link) %>% 
      select(AirQualityStationEoICode, DatetimeBegin, DatetimeEnd,
             AirPollutant, Concentration, UnitOfMeasurement, Validity, Verification)
    data <- rbind(data, station)
  }
}
write.csv(data, file = str_c("./data/AQ_EU_data_", max(as.Date(data$DatetimeEnd)), ".csv"))