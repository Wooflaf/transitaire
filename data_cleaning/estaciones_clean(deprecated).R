# Guardamos datos de las estaciones

# estaciones <- st_read("https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estacions-contaminacio-atmosferiques-estaciones-contaminacion-atmosfericas/exports/geojson?lang=es") %>%
#   select(-so2:-calidad_ambiental) %>%
#   mutate(tipozona = factor(tipozona),
#          tipoemision = factor(tipoemision))
# save(estaciones, file = "./data/estaciones.RData")
load("./data/estaciones.RData")

calidad_aire <- c("Buena", "Razonablemente Buena", "Regular",
                  "Desfavorable", "Muy Desfavorable",
                  "Extremadamente Desfavorable", "Sin datos")

accum_est_contamin <- read_csv("./data/accum_estaciones.csv", 
                               col_types = cols(so2 = col_character(), 
                                                no2 = col_character(), 
                                                o3 = col_character(), 
                                                pm10 = col_character(),
                                                pm25 = col_character()
                                                )) %>% 
  mutate(so2 = parse_number(so2, locale = locale(decimal_mark = ",")),
         no2 = parse_number(no2, locale = locale(decimal_mark = ",")),
         o3 = parse_number(o3, locale = locale(decimal_mark = ",")),
         co = parse_number(co, locale = locale(decimal_mark = ",")),
         pm10 = parse_number(pm10, locale = locale(decimal_mark = ",")),
         pm25 = parse_number(pm25, locale = locale(decimal_mark = ",")),
         calidad_ambiental = factor(calidad_ambiental, levels = calidad_aire),
         fecha_carga = trunc(ymd_hms(fecha_carga), units = "hours"))


est_contamin <- st_as_sf(left_join(accum_est_contamin, estaciones, by = "objectid") %>% 
                           mutate(objectid = as.character(objectid)))