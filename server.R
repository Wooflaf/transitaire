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
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolylines(data = trafico, layerId = ~gid, label = ~denominacion) %>% 
      addAwesomeMarkers(data = est_contamin, layerId = ~objectid) %>% 
      setView(lng = "-0.36139126257400377", lat = "39.469993930673834",  zoom = 13.6) %>% 
      setMaxBounds(lng1 = "-0.5017152868950778", lat1 = "39.55050724348406",
                   lng2 = "-0.24762442378004983", lat2 = "39.389409229115124") %>% 
      addResetMapButton() %>% 
      addLegendAwesomeIcon(iconSet = icon_estaciones,
                           orientation = 'vertical',
                           position = 'topright',
                           title = htmltools::tags$div(
                             style = 'font-size: 14px;',
                             'Estaciones de Contaminación'),
                           labelStyle = 'font-size: 14px;') %>%
      addLegendImage(images = list("./icons/line.png", "./icons/dash.png"),
                     labels = c("Exterior", "Subterráneo"),
                     labelStyle = "font-size: 12px; vertical-align: middle;",
                     height = c(30, 30),
                     width = c(30, 30),
                     orientation = 'horizontal',
                     title = 'Tipo de tramo',
                     position = 'bottomright') %>%
      addLegend(colors = c("#2CC121", "#2332BA", "#C91616", "#E2D43C", "#303131"),
                labels = levels(trafico$estado)[1:5], opacity = 0.8,
                title = 'Tráfico', position = 'bottomright')
    
    # Retornar el mapa
    return(map)
    
  })
  
  observeEvent(air_data(), {
    leafletProxy("map") %>%
      clearMarkers() %>% 
      addAwesomeMarkers(data = air_data(), layerId = ~objectid,
                        icon = ~icon_estaciones[AQ_index],
                        popup = ~est_popups(AirPollutant, AQ_index, cause,
                                            Concentration, direccion, nombre,
                                            tipozona, tipoemision, UnitOfMeasurement)
                        )
  })
  
  
  observeEvent(traffic_data(),{ 
    # En función de la hora, cambio entre cartografía clara/oscura
    
    if (hour(input$time) >= 7 & hour(input$time) < 21) {
      
      leafletProxy("map") %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                      data = traffic_data())
    } else {
      leafletProxy("map") %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico_night(estado),
                      dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                      data = traffic_data())
    }
    
  })
  
}