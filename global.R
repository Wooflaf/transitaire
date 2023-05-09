# Cargar las librerías necesarias
library(shiny)
library(leaflet)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(sf)
library(DT)
library(plotly)
library(kableExtra)

# Cargamos los datos
source("./data_cleaning/AQ_EU_clean.R", local = TRUE, encoding = "UTF-8")
source("./data_cleaning/trafico_clean.R", local = TRUE, encoding = "UTF-8")

# Definimos las paletas de colores
source("./functions/palettes.R", local = TRUE, encoding = "UTF-8")

# Cargamos las funciones para poder aplicar estilos dinámicamente en leaflet
source("./functions/leaflet_dynamic_style.R", local = TRUE, encoding = "UTF-8")

####### PARTE SANDRA, WILSON, GEMA
source("./data-downloader/datos_diarios2.R")

##########
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


shinyApp(ui, server)
