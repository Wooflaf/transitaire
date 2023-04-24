# Cargar la librería necesaria
library(lubridate)
library(jsonlite)
library(tidyverse)

# URL del archivo que deseamos descargar
url <- url("https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estacions-contaminacio-atmosferiques-estaciones-contaminacion-atmosfericas/exports/json?lang=es")

est_contamin <- stream_in(url)

# Limpiamos los datos
est_contamin_clean <- est_contamin %>% 
  mutate(nombre = factor(nombre),
         direccion = factor(direccion),
         tipozona = factor(tipozona),
         tipoemision = factor(tipoemision),
         calidad_ambiental = factor(calidad_ambiental),
         fecha_carga = ymd_hms(fecha_carga))

# Cargamos los datos acumulados para insertar los nuevos
accum_path <- "./data/accum_est_contamin.RData"

# Si había datos, los cargamos y añadimos los nuevos. Si no, lo creamos.
if (file.exists(accum_path)){
  load(accum_path)
  accum_est_contamin <- rbind(est_contamin_clean, accum_est_contamin)
  
} else {
  accum_est_contamin <- est_contamin_clean
}

save(accum_est_contamin, file = accum_path)