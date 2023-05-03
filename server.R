# Crear el servidor
server <- function(input, output) {
  output$slider <- renderUI({
    sliderInput("time","Time",
                min = min(trafico$fecha_carga),
                max =  max(trafico$fecha_carga),
                value = min(trafico$fecha_carga),step = 3600,
                timezone = "+0000", animate = animationOptions(interval = input$speed))
  })
  
  output$speed_value <- renderUI({
    numericInput("speed","Speed Value :",value = 100)
  })
  
  air_data_var <- reactive({
    est_contamin %>% 
      filter(AirPollutant == input$var)
  })
  
  air_data <- reactive({
    air_data_var() %>% 
      filter(fecha_carga == input$time)
  })
  
  # Función para crear el mapa con Leaflet
  output$map <- renderLeaflet({
    
    # Crear el mapa con Leaflet
    map <- leaflet() %>%
      addTiles() %>% 
      addPolylines(data = trafico, layerId = ~gid) %>% 
      addCircleMarkers(data = est_contamin, layerId = ~objectid)
    
    
    # Retornar el mapa
    return(map)
    
  })
  
  observeEvent(input$time,{ 
    # adding day and night section --------------------------------------------
    
    if (hour(input$time) >= 7 & hour(input$time) < 17 ) {
      
      leafletProxy("map") %>%
        addTiles() %>%
        setCircleMarkerStyle(layerId = ~objectid,
                             color = ~pal(AQ_index),
                             data = air_data()) %>% 
        setShapeStyle(layerId = ~gid, color = ~pal_trafico(estado), data = trafico %>% 
                        filter(trunc(fecha_carga, units = "mins") == input$time))
      
    } else {
      leafletProxy("map") %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        setCircleMarkerStyle(layerId = ~objectid,
                             color = ~pal(AQ_index),
                             data = air_data()) %>% 
        setShapeStyle(layerId = ~gid, color = ~pal_trafico(estado), data = trafico %>% 
                        filter(trunc(fecha_carga, units = "mins") == input$time))
    }
    
  })
  
}