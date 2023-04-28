# Cargar la librería necesaria
library(lubridate)
library(jsonlite)
library(tidyverse)

# Indicamos el directorio de trabajo (debes indicarlo tú, está vacío por defecto)
wd <- ""

setwd(wd)

# URL del archivo que deseamos descargar
url <- url("https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estacions-contaminacio-atmosferiques-estaciones-contaminacion-atmosfericas/exports/json?lang=es")

# Leemos los datos
est_contamin <- stream_in(url)

# Guardamos datos de las estaciones
# estaciones <- est_contamin %>% 
#   mutate(tipozona = factor(tipozona),
#          tipoemision = factor(tipoemision)) %>% 
#   select(objectid:mediciones, globalid:geo_point_2d)
# save(estaciones, file = "./data/estaciones.RData")

# Limpiamos los datos
est_contamin_clean <- est_contamin %>% 
  mutate(calidad_ambiental = factor(calidad_ambiental),
         fecha_carga = ymd_hms(fecha_carga)) %>%
  select(objectid, so2:calidad_ambiental)

# Cargamos los datos acumulados para insertar los nuevos
accum_path <- "./data/accum_est_contamin.RData"

# Si había datos, los cargamos y añadimos los nuevos. Si no, lo creamos.
if (file.exists(accum_path)){
  load(accum_path)
  accum_est_contamin <- rbind(est_contamin_clean, accum_est_contamin)
} else {
  accum_est_contamin <- est_contamin_clean
}

# Guardamos los datos 
save(accum_est_contamin, file = accum_path)

# Cerramos la sesión de R
q()