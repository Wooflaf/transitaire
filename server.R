# Crear el servidor
server <- function(input, output, session) {
  observeEvent(input$waiter_hidden, {guide$init()$start()})
  observeEvent(input$guide, {guide$start()})
  
  datetime <- reactive({
    return(with_tz(as.POSIXct(input$time, tz = "UTC"), tzone = "Europe/Madrid"))
  })
  
  output$fecha <- renderUI({
    fecha <- str_to_sentence(format(datetime(), format = "%A, %e de %B de %Y %H:%M"))
    if (is_daylight(datetime())) {
      fecha_color <- p(fecha, style = "color: #000000")
    }
    else{
      fecha_color <- p(fecha, style = "color: #FFFFFF")
    }
    return(HTML(as.character(fecha_color)))
  })
  
  output$color <- renderUI({
    if (is_daylight(datetime())) {
      color <- paste0(".irs-min, .irs-max {color: #000000;}")
    }
    else{
      color <- paste0(".irs-min, .irs-max {color: #FFFFFF;}")
    }
    return(tags$head(tags$style(HTML(as.character(color)))))
  })
  
  air_data_var <- reactive({
    est_contamin %>%
      filter(AirPollutant == input$var) 
  })
  
  air_data <- reactive({
    air_data_var() %>%
      filter(DatetimeBegin == datetime())
  })
  
  traffic_data <- reactive({
    trafico %>% 
      filter(fecha_carga == datetime())
  })
  
  # Función para crear el mapa con Leaflet
  output$map <- renderLeaflet({
    # Crear el mapa con Leaflet
    map <- leaflet(options = leafletOptions(minZoom = 13, maxZoom = 16, zoomSnap = 0.1)) %>%
      addProviderTiles(providers$CartoDB.DarkMatter, layerId = "tile_night", group = "day_night_tiles") %>%
      addPolylines(data = tramos_trafico, layerId = ~as.character(gid), label = ~denominacion) %>% 
      addAwesomeMarkers(data = estaciones, layerId = ~as.character(objectid)) %>% 
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
  
  # En función de la hora, cambio entre cartografía clara/oscura
  timeList <- reactiveValues(tile_historic = "tile_night1", inc = 1)
  
  observeEvent(datetime(),{
    timeList$inc <- timeList$inc+1 
    if (is_daylight(datetime())) {
      timeList$tile_historic <- c(timeList$tile_historic, paste0("tile_daylight", timeList$inc)) 
    } else{
      timeList$tile_historic <- c(timeList$tile_historic, paste0("tile_night", timeList$inc)) 
    }
  })
  
  
  observe({
    last_selected_tile <- tail(timeList$tile_historic, 1)
    last_selected_tile_class <- gsub("[0-9]", "", last_selected_tile)
    second_to_last_selected_tile <- tail(timeList$tile_historic, 2)[1]
    second_to_last_selected_tile_class <- gsub("[0-9]", "", second_to_last_selected_tile)
    
    if( last_selected_tile_class != second_to_last_selected_tile_class){
      
      if (last_selected_tile_class == "tile_daylight"){
        prov <- providers$CartoDB.Positron
      } else{
        prov <- providers$CartoDB.DarkMatter
      }
      
      leafletProxy("map") %>%
        removeTiles(layerId = second_to_last_selected_tile) %>%
        addProviderTiles(
          prov,
          layerId = last_selected_tile,
          group = "day_night_tiles")
    }
  })
  
  observeEvent(traffic_data(),{ 
    leafletProxy("map") %>%
      setShapeStyle(layerId = ~gid,
                    color = ~pal_trafico(estado),
                    dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                    data = traffic_data())
    
    waiter_hide()
  })
  
  output$est_plotly <- renderPlotly({
    validate(
      need(input$map_marker_click$id, 'Selecciona una estación de contaminación atmosférica.')
    )
    plot <- plot_ly(data = st_drop_geometry(air_data_var()) %>%
                      filter(objectid == input$map_marker_click$id) %>% 
                      group_by(AirPollutant) %>% 
                      count(AQ_index) %>% 
                      complete(AQ_index, fill = list(n = NA)) %>% 
                      ungroup() %>% 
                      arrange(factor(AQ_index, levels = c("Buena", "Razonablemente Buena",
                                                          "Regular", "Desfavorable",
                                                          "Muy Desfavorable",
                                                          "Extremadamente Desfavorable",
                                                          "Sin Datos")
                      )
                      ),
                    labels = ~AQ_index, values = ~n, type = 'pie',
                    marker = list(colors = c("Buena" = "#72ae27",
                                             "Razonablemente Buena" = "#37a4d7",
                                             "Regular" = "#f49631",
                                             "Desfavorable" = "#d43f2b",
                                             "Muy Desfavorable" = "#9c3035",
                                             "Extremadamente Desfavorable" = "#d253b8",
                                             "Sin Datos" = "#303131")),
                    sort = FALSE, direction = 'clockwise',
                    textinfo = 'percent', hoverinfo = 'text',
                    text = ~paste(n, "registros con calidad", AQ_index),
                    hole = 0.3) %>% 
      layout(title = ~ifelse(AirPollutant[1] == "AQ_index_all",
                             paste0("Calidad del aire"),
                             paste0("Porcentaje de registros de ", AirPollutant[1])),
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
  output$station_stats <- renderUI({
    if(is.null(input$map_marker_click$id)){
      box_title <- "Estadísticas de la estación"
    } else {
      estacion <- switch(input$map_marker_click$id,
                       "22" = "Centro",
                       "23" = "Francia",
                       "24" = "Boulevar Sur",
                       "25" = "Molí del Sol",
                       "26" = "Pista de silla",
                       "27" = "Univ. Politéc.",
                       "28" = "Viveros",
                       "431" = "Olivereta")
      
      box_title <- str_c("Estadísticas de la estación ", estacion)
    }
    
    return(
      div(
        id = "box-stats",
        box(
          title = box_title,
          width = NULL, solidHeader = F,
          plotlyOutput("est_plotly", height = 300)
        )
      )
    )
  })
}