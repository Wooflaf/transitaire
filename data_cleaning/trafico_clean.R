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
  mutate(
    gid = as.integer(gid),
    estado = factor(estado, levels = 0:9, labels = labels_estado),
    fecha_carga = clean_date_time(fecha_carga))

first_datetime <- min(accum_trafico_rodado$fecha_carga)
last_datetime <- max(accum_trafico_rodado$fecha_carga)

traffic_changed <- accum_trafico_rodado %>% 
  mutate(fecha_carga_next = fecha_carga + hours(1)) %>% 
  left_join(accum_trafico_rodado, 
            by = c("gid" = "gid",
                   "fecha_carga_next" = "fecha_carga"),
            suffix = c("", "_next"), keep = T) %>% 
  filter(estado != estado_next, fecha_carga_next != last_datetime) %>% 
  select(gid_next, estado_next, fecha_carga_next) %>% 
  rename_with(~str_replace(.x, "_next", ""))

traffic_first_last <- accum_trafico_rodado %>%
  filter(fecha_carga == first_datetime | fecha_carga == last_datetime)

# Calculamos los tramos que cambian de estado para no sobrecargar el renderizado del leaflet
traffic_variation <- rbind(traffic_first_last, traffic_changed)

trafico <- st_as_sf(left_join(traffic_variation, tramos_trafico, by = "gid") %>%
                      mutate(gid = as.character(gid)) %>% 
                      select(-denominacion, -idtramo))
