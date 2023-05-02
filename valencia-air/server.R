# Crear el servidor
server <- function(input, output) {
  output$slider <- renderUI({
    sliderInput("time","Time",
                min = min(est_contamin$fecha_carga),
                max =  max(est_contamin$fecha_carga),
                value = min(est_contamin$fecha_carga),step = 3600,
                timezone = "+0000", animate = animationOptions(interval = input$speed))
  })
  
  output$speed_value <- renderUI({
    numericInput("speed","Speed Value :",value = 100)
  })
  
  air_data <- reactive({
    est_contamin
  })
  
  # Función para crear el mapa con Leaflet
  output$map <- renderLeaflet({
    
    # Crear el mapa con Leaflet
    map <- leaflet() %>%
      addTiles() %>% 
      addPolylines(data = trafico, layerId = ~gid)
    
    
    # Retornar el mapa
    return(map)
    
  })
  
  observeEvent(input$time,{ 
    # adding day and night section --------------------------------------------
    
    if (hour(input$time) >= 7 & hour(input$time) < 17 ) {
      
      leafletProxy("map") %>% 
        clearMarkers() %>% 
        addTiles() %>%
        addCircleMarkers(color = ~pal(calidad_ambiental),
                         popup = ~paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                         "NO2: ", no2, " µg/m3<br>",
                                         "PM10: ", pm10, " µg/m3<br>",
                                         "O3: ", o3, " µg/m3<br>",
                                         "SO2: ", so2, " µg/m3<br>",
                                         "Calidad: ", calidad_ambiental),
                         data = air_data() %>% 
                           filter(fecha_carga == input$time)
        ) %>%
        setShapeStyle(layerId = ~gid, color = ~pal_trafico(estado), data = trafico %>% 
                        filter(trunc(fecha_carga, units = "mins") == input$time))
      
    } else {
      leafletProxy("map") %>% 
        clearMarkers() %>% 
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        addCircleMarkers(color = ~pal(calidad_ambiental),
                         popup = ~paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                         "NO2: ", no2, " µg/m3<br>",
                                         "PM10: ", pm10, " µg/m3<br>",
                                         "O3: ", o3, " µg/m3<br>",
                                         "SO2: ", so2, " µg/m3<br>",
                                         "Calidad: ", calidad_ambiental),
                         data = air_data() %>% 
                           filter(fecha_carga == input$time)
        ) %>%
        setShapeStyle(layerId = ~gid, color = ~pal_trafico(estado), data = trafico %>% 
                        filter(trunc(fecha_carga, units = "mins") == input$time))
    }
    
  })
  
}