# Crear el servidor
server <- function(input, output) {
  output$slider <- renderUI({
    sliderInput("time","Time",
                min = min(est_contamin$fecha_carga),
                max =  max(est_contamin$fecha_carga),
                value = min(est_contamin$fecha_carga),step = 3600,
<<<<<<< HEAD
                timezone = "+0000", animate = animationOptions(interval = input$speed))
  })
  
  output$speed_value <- renderUI({
    numericInput("speed","Speed Value :",value = 100)
=======
                timezone = "+0000", animate = T)
>>>>>>> fef81847bc943c0bbd1ed71ade18092ea26889e2
  })
  
  air_data <- reactive({
    est_contamin
  })
  
  # Función para crear el mapa con Leaflet
  output$map <- renderLeaflet({
    
    # Crear el mapa con Leaflet
<<<<<<< HEAD
    map <- leaflet() %>%
      addTiles() %>% 
      addPolylines(data = trafico, layerId = ~gid)
    
=======
    map <- leaflet(air_data()) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~lon, lat = ~lat, color = ~pal(calidad_ambiental),
                       popup = ~paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                       "NO2: ", no2, " µg/m3<br>",
                                       "PM10: ", pm10, " µg/m3<br>",
                                       "O3: ", o3, " µg/m3<br>",
                                       "SO2: ", so2, " µg/m3<br>",
                                       "Calidad: ", calidad_ambiental)
      )
>>>>>>> fef81847bc943c0bbd1ed71ade18092ea26889e2
    
    # Retornar el mapa
    return(map)
    
  })
  
  observeEvent(input$time,{ 
    # adding day and night section --------------------------------------------
    
    if (hour(input$time) >= 7 & hour(input$time) < 17 ) {
      
<<<<<<< HEAD
      leafletProxy("map") %>% 
        clearMarkers() %>% 
        addTiles() %>%
        addCircleMarkers(color = ~pal(calidad_ambiental),
=======
      leafletProxy("map", data= air_data()  %>% 
                     filter(fecha_carga == input$time)) %>% 
        clearMarkers() %>% 
        addTiles() %>%
        addCircleMarkers(lng = ~lon, lat = ~lat, color = ~pal(calidad_ambiental),
>>>>>>> fef81847bc943c0bbd1ed71ade18092ea26889e2
                         popup = ~paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                         "NO2: ", no2, " µg/m3<br>",
                                         "PM10: ", pm10, " µg/m3<br>",
                                         "O3: ", o3, " µg/m3<br>",
                                         "SO2: ", so2, " µg/m3<br>",
<<<<<<< HEAD
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
=======
                                         "Calidad: ", calidad_ambiental)
        )
    } else {
      leafletProxy("map", data= air_data()  %>% 
                     filter(fecha_carga == input$time) ) %>% 
        clearMarkers() %>% 
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        addCircleMarkers(lng = ~lon, lat = ~lat, color = ~pal(calidad_ambiental),
>>>>>>> fef81847bc943c0bbd1ed71ade18092ea26889e2
                         popup = ~paste0("<strong>Estación:</strong> ", nombre, "<br>",
                                         "NO2: ", no2, " µg/m3<br>",
                                         "PM10: ", pm10, " µg/m3<br>",
                                         "O3: ", o3, " µg/m3<br>",
                                         "SO2: ", so2, " µg/m3<br>",
<<<<<<< HEAD
                                         "Calidad: ", calidad_ambiental),
                         data = air_data() %>% 
                           filter(fecha_carga == input$time)
        ) %>%
        setShapeStyle(layerId = ~gid, color = ~pal_trafico(estado), data = trafico %>% 
                        filter(trunc(fecha_carga, units = "mins") == input$time))
    }
    
=======
                                         "Calidad: ", calidad_ambiental)
        )}
>>>>>>> fef81847bc943c0bbd1ed71ade18092ea26889e2
  })
  
}