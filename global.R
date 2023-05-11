# Cargar las librerías necesarias
library(shiny) # Version 1.7.4
library(shinyWidgets) # Version 0.7.6 
library(leaflet) # Version 2.1.2
library(leaflet.extras) # Version 1.0.0
library(shinydashboard) # Version 0.7.2
library(shinydashboardPlus) # Version 2.0.3
library(tidyverse) # Version 1.3.2
library(lubridate) # Version 1.9.2
library(sf) # Version 1.0-12
library(leaflegend) # Version 1.10
library(plotly) # Version 4.10.1
library(waiter) # Version 0.2.5
library(cicerone) # Version 1.0.4
library(shinyjs) # Version 2.1.0
library(DT) # Version 0.27
library(kableExtra) # Version 1.3.4
library(patchwork) # Version 1.1.2

# Cargamos los datos
source("./data_cleaning/AQ_EU_clean.R", local = TRUE, encoding = "UTF-8")
source("./data_cleaning/trafico_clean.R", local = TRUE, encoding = "UTF-8")
load("./data/datos_diarios.RData")
load("./data/datos_diarios_clean.RData")
tabla <- read_delim("data/tabla.csv", delim = ";")

# Definimos las paletas de colores
source("./functions/styling.R", local = TRUE, encoding = "UTF-8")

# Cargamos las funciones para poder aplicar estilos dinámicamente en leaflet
source("./functions/leaflet_dynamic_style.R", local = TRUE, encoding = "UTF-8")

# Cargamos otras funciones
source("./functions/others.R", local = TRUE, encoding = "UTF-8")

# Cargamos las tabs
source("./tabs/AQ_traffic_tab.R", local = TRUE, encoding = "UTF-8")
source("./tabs/graficos_tab.R", local = TRUE, encoding = "UTF-8")
source("./tabs/live.R", local = TRUE, encoding = "UTF-8")
source("./tabs/info_tabs.R", local = TRUE, encoding = "UTF-8")

####### PARTE SANDRA, WILSON, GEMA
#Funcion para crear el grafico de barras apiladas
colores <- c("Buena" = "#72ae27",
             "Razonablemente Buena" = "#37a4d7",
             "Regular" = "#f49631",
             "Desfavorable" = "#d43f2b",
             "Muy Desfavorable" = "#9c3035",
             "Extremadamente Desfavorable" = "#d253b8",
             "Sin Datos" = "#303131")

#Funcion que hace el mapa de calor
date_heatmap <- function(df){
  ggplot(df, aes(week, dia_sem, fill = Clasificacion, text = text)) + 
    geom_tile() + 
    facet_grid(year(Fecha) ~ month) +
    scale_fill_manual(values = colores) +
    scale_y_discrete(limits = rev) +
    labs(x="Semana del mes", y = "", subtitle = "")
}

#Hacerlo interactivo
interactive_date_heatmap <- function(p){
  ggplotly(p, tooltip = "text") %>% 
    config(displayModeBar = FALSE)
}

pob_afectada <- read.csv("./qgis/pob_afectada_estaciones/pob_afectada_estaciones.csv") %>% 
  mutate(objectid = as.character(objectid))
buffer_est <- read_sf("./qgis/buffer_estaciones/buffer_estaciones_bueno.shp") %>% 
  left_join(pob_afectada, by = "objectid")
