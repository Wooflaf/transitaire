library(lubridate)
library(jsonlite)
library(tidyverse)
library(shiny)
library(leaflet)



# Cargar la librería necesaria
library(sf)
library(raster)
library(spData)
library(lubridate)
library(jsonlite)
library(tidyverse)

# Define UI
ui <- fluidPage(
  # Crear dos tabsetPanel
  tabsetPanel(
    # Tab 1
    tabPanel("Mapa qgis", leafletOutput("mapa")),
    
    # Tab 2
    tabPanel("Otra pestaña")
  )
)

# Define server
server <- function(input, output) {
  # Cargar archivo .shp
  mi_mapa <- st_read("data/qgis/buffer_estaciones_bueno.shp")
  buffer_estaciones <- st_read("data/qgis/buffer_estaciones_bueno.shp")
  mi_buffer <- st_buffer(mi_mapa, dist = 50) 
  se_interseccion_bicis <- st_read("data/qgis/se_interseccion_bicis_bueno.shp")
  # Crear mapa
  output$mapa <- renderLeaflet({
    leaflet(mi_mapa, options = leafletOptions(minZoom = 8, maxZoom = 20)) %>% 
      addProviderTiles(provider = providers$CartoDB) %>%
      addPolygons(data = mi_buffer, fillColor = "blue", fillOpacity = 0.2, color = "black", weight = 1)%>%
      addPolygons(data = se_interseccion_bicis, fillColor = "red")  %>%
      setView(lng = -0.41, lat = 39.47, zoom = 12)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
