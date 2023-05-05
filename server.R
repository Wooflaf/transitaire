# Crear el servidor
server <- function(input, output) {
  
  output$fecha <- renderText({
    str_to_sentence(format(input$time, format = "%A, %e de %B de %Y %H:%M"))
  })
  
  air_data_var <- reactive({
    est_contamin %>%
      filter(AirPollutant == input$var) 
  })
  
  air_data <- reactive({
    air_data_var() %>%
      filter(DatetimeBegin == input$time)
  })
  
  traffic_data <- reactive({
    trafico %>% 
      filter(fecha_carga == input$time)
  })
  
  # Función para crear el mapa con Leaflet
  output$map <- renderLeaflet({
    
    # Crear el mapa con Leaflet
    map <- leaflet(options = leafletOptions(minZoom = 13, maxZoom = 16, zoomSnap = 0.1)) %>%
      addTiles() %>% 
      addPolylines(data = trafico, layerId = ~gid) %>% 
      addCircleMarkers(data = est_contamin, layerId = ~objectid) %>% 
      setView(lng = "-0.37219126257400377", lat = "39.468993930673834",  zoom = 13.6) %>% 
      setMaxBounds(lng1 = "-0.5017152868950778", lat1 = "39.55050724348406",
                   lng2 = "-0.24762442378004983", lat2 = "39.389409229115124") %>% 
      addResetMapButton()
    
    # Retornar el mapa
    return(map)
    
  })
  
  observeEvent(air_data(), {
    leafletProxy("map") %>%
      setCircleMarkerStyle(layerId = ~objectid,
                           color = ~pal(AQ_index),
                           data = air_data()
      ) %>% 
      setCircleMarkerPopup(layerId = ~objectid,
                           popup = ~ifelse(AirPollutant == "AQ_index_all",
                                           ifelse(is.na(cause) | AQ_index == "Buena",
                                                  paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                                         "<strong>Calidad:</strong> ", AQ_index, "<br>",
                                                         "<strong>Tipo de zona:</strong> ", tipozona, "<br>",
                                                         "<strong>Tipo de emisión:</strong> ", tipoemision, "<br>"),
                                                  paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                                         "<strong>Calidad:</strong> ", AQ_index, " (debido a ", cause, ")<br>",
                                                         "<strong>Tipo de zona:</strong> ", tipozona, "<br>",
                                                         "<strong>Tipo de emisión:</strong> ", tipoemision, "<br>")),
                                           ifelse(AQ_index == "Sin datos", 
                                                  paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                                         "<strong>Calidad:</strong> ", AQ_index, "<br>",
                                                         "<strong>Tipo de zona:</strong> ", tipozona, "<br>",
                                                         "<strong>Tipo de emisión:</strong> ", tipoemision, "<br>"),
                                                  paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                                         "<strong>Concentración ", AirPollutant,":</strong> ",
                                                         Concentration, " ", UnitOfMeasurement, "<br>",
                                                         "<strong>Calidad:</strong> ", AQ_index, "<br>",
                                                         "<strong>Tipo de zona:</strong> ", tipozona, "<br>",
                                                         "<strong>Tipo de emisión:</strong> ", tipoemision, "<br>"))
                           ),
                           data = air_data())
  })
  
  
  observeEvent(traffic_data(),{ 
    # En función de la hora, cambio entre cartografía clara/oscura
    
    if (hour(input$time) >= 7 & hour(input$time) < 21) {
      
      leafletProxy("map") %>%
        addTiles() %>%
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      data = traffic_data()) %>% 
        setShapeLabel(layerId = ~ gid, label = ~denominacion, data = traffic_data())
      
    } else {
      leafletProxy("map") %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      data = traffic_data())
    }
    
  })
  
}