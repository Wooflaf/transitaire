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

# Cargamos los datos
source("./data_cleaning/AQ_EU_clean.R", local = TRUE, encoding = "UTF-8")
source("./data_cleaning/trafico_clean.R", local = TRUE, encoding = "UTF-8")

# Definimos las paletas de colores
source("./functions/styling.R", local = TRUE, encoding = "UTF-8")

# Cargamos las funciones para poder aplicar estilos dinámicamente en leaflet
source("./functions/leaflet_dynamic_style.R", local = TRUE, encoding = "UTF-8")

# Cargamos otras funciones
source("./functions/others.R", local = TRUE, encoding = "UTF-8")

# Cargamos las tabs
source("./tabs/AQ_traffic_tab.R", local = TRUE, encoding = "UTF-8")
source("./tabs/live.R", local = TRUE, encoding = "UTF-8")