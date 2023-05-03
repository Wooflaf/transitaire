# Guardamos datos de los tramos
# tramos_trafico <- st_read("https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estat-transit-temps-real-estado-trafico-tiempo-real/exports/geojson?lang=es") %>% 
#   select(gid, denominacion, idtramo)
# save(tramos_trafico, file = "./data/tramos_trafico.RData")

load("./data/tramos_trafico.RData")

clean_date_time <- function(x){
  dt <- parse_date_time2(x, "%Y-%m-%d %H:%M:%S", tz="UTC")
  return(with_tz(dt, tzone = "Europe/Madrid"))
}

labels_estado <- c("Fluido", "Denso", "Congestionado", "Cortado", "Sin datos",
                   str_c("Paso inferior ", c("fluido", "denso", "congestionado", "cortado")),
                   "Sin datos (paso inferior)")

accum_trafico_rodado <- read_csv("./data/accum_trafico.csv") %>% 
  mutate(estado = factor(estado, levels = 0:9, labels = labels_estado),
         fecha_carga = clean_date_time(fecha_carga))

trafico <- st_as_sf(left_join(accum_trafico_rodado, tramos_trafico, by = "gid") %>% mutate(gid = as.character(gid)))