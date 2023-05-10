load("./data/estaciones.RData")

clean_date_time <- function(x){
  dt <- parse_date_time2(x, "%Y-%m-%d %H:%M:%S %z", tz="UTC")
  return(with_tz(dt, tzone = "Europe/Madrid"))
}

AQ_index_lvls <- c("Sin Datos", "Buena", "Razonablemente Buena", "Regular",
                   "Desfavorable", "Muy Desfavorable",
                   "Extremadamente Desfavorable")

AQ_EU_data_path <- max(list.files(path = "./data/",
                                  pattern = "^AQ_EU_data_\\d{4}-\\d{2}-\\d{2}\\.csv$",
                                  full.names = T))

AQ_data <- read.csv(AQ_EU_data_path) %>% 
  mutate(
    DatetimeBegin = clean_date_time(DatetimeBegin),
    DatetimeEnd = clean_date_time(DatetimeEnd),
    AirPollutant = factor(AirPollutant),
    objectid = case_when(AirQualityStationEoICode == "ES1239A" ~ 26,
                         AirQualityStationEoICode == "ES1619A" ~ 28,
                         AirQualityStationEoICode == "ES1885A" ~ 27,
                         AirQualityStationEoICode == "ES1912A" ~ 23,
                         AirQualityStationEoICode == "ES1970A" ~ 24,
                         AirQualityStationEoICode == "ES2095A" ~ 22,
                         AirQualityStationEoICode == "ES1926A" ~ 25,
                         AirQualityStationEoICode == "ES2163A" ~ 431),
    AQ_index = case_when(
      AirPollutant == "PM2.5" ~ cut(Concentration, c(0, 10, 20, 25, 50, 75, 800), labels = F),
      AirPollutant == "PM10" ~ cut(Concentration, c(0, 20, 40, 50, 100, 150, 1200), labels = F),
      AirPollutant == "NO2" ~ cut(Concentration, c(0, 40, 90, 120, 230, 340, 1000), labels = F),
      AirPollutant == "O3" ~ cut(Concentration, c(0, 50, 100, 130, 240, 380, 800), labels = F),
      AirPollutant == "SO2" ~ cut(Concentration, c(0, 100, 200, 350, 500, 750, 1250), labels = F),
      TRUE ~ 0)
    ) %>% 
  select(-X)
  

AQ_index_all_hourly <- AQ_data %>% 
  group_by(AirQualityStationEoICode, DatetimeBegin, DatetimeEnd, objectid) %>% 
  summarise(cause = paste(AirPollutant[which(AQ_index == max(AQ_index))], collapse = ", "),
            AQ_index = max(AQ_index),
            AirPollutant = "AQ_index_all"
            ) %>% 
  ungroup()

AQ_data_clean <- bind_rows(AQ_data, AQ_index_all_hourly) %>%
  group_by() %>%
  complete(nesting(DatetimeBegin, DatetimeEnd),
           nesting(AirQualityStationEoICode, objectid),
           nesting(AirPollutant, UnitOfMeasurement),
           fill = list(AQ_index = 0)) %>%
  ungroup() %>% 
  mutate(AQ_index = factor(AQ_index, labels = AQ_index_lvls, levels = 0:6))

est_contamin <- st_as_sf(left_join(AQ_data_clean, estaciones, by = "objectid") %>% mutate(objectid = as.character(objectid)))
