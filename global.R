# Cargar las librerías necesarias
library(shiny)
library(shinyWidgets)
library(leaflet)
library(leaflet.extras)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(lubridate)
library(sf)
library(leaflegend)
library(plotly)
library(waiter)
library(cicerone)
library(shinyjs)


# Cargamos los datos
source("./data_cleaning/AQ_EU_clean.R", local = TRUE, encoding = "UTF-8")
source("./data_cleaning/trafico_clean.R", local = TRUE, encoding = "UTF-8")

# Definimos las paletas de colores
source("./functions/styling.R", local = TRUE, encoding = "UTF-8")

# Cargamos las funciones para poder aplicar estilos dinámicamente en leaflet
source("./functions/leaflet_dynamic_style.R", local = TRUE, encoding = "UTF-8")

# Cargamos las tabs
source("./tabs/AQ_traffic_tab.R", local = TRUE, encoding = "UTF-8")