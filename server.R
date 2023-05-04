# Crear el servidor
server <- function(input, output) {
  
  air_data_var <- reactive({
    est_contamin %>%
      filter(AirPollutant == input$var) 
  })
  
  air_data <- reactive({
    air_data_var() %>%
      filter(fecha_carga == input$time)
  })
  
  traffic_data <- reactive({
    trafico %>% 
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
  
  observeEvent(air_data(), {
    leafletProxy("map") %>%
      setCircleMarkerStyle(layerId = ~objectid,
                           color = ~pal(AQ_index),
                           data = air_data())
  })
  
  observeEvent(traffic_data(),{ 
    # adding day and night section --------------------------------------------
    
    if (hour(input$time) >= 7 & hour(input$time) < 21) {
      
      leafletProxy("map") %>%
        addTiles() %>%
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      data = traffic_data())
      
    } else {
      leafletProxy("map") %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      data = traffic_data())
    }
    
  })
  
}