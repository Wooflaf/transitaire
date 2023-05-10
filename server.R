# Crear el servidor
server <- function(input, output, session) {
  
  # Iniciar guía cuando se acabe animación de carga inicial
  observeEvent(input$waiter_hidden, {guide$init()$start()})
  
  # Iniciar guía al presionar botón guide en UI
  observeEvent(input$guide, {guide$start()})
  
  # Valor reactivo para obtener la fecha y hora en zona horaria correspondiente
  datetime <- reactive({
    return(with_tz(as.POSIXct(input$time, tz = "UTC"), tzone = "Europe/Madrid"))
  })
  
  ### Textos UI cambios claro/oscuro en base a la hora visualizada
  
  # Renderizar fecha y hora en mapa cambiando el color acorde a la hora
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
  
  # Cambiar color acorde a la hora de los labels mínimos y máximos del slider
  output$color <- renderUI({
    if (is_daylight(datetime())) {
      color <- paste0(".irs-min, .irs-max {color: #000000;}")
    }
    else{
      color <- paste0(".irs-min, .irs-max {color: #FFFFFF;}")
    }
    return(tags$head(tags$style(HTML(as.character(color)))))
  })
  
  ### Actualización de dataframes (reactivos)
  
  # Dataframe de estaciones filtrado por la variable seleccionada
  air_data_var <- reactive({
    est_contamin %>%
      filter(AirPollutant == input$var) 
  })
  
  # Dataframe de estaciones filtrado por la variable y hora seleccionada
  air_data <- reactive({
    air_data_var() %>%
      filter(DatetimeBegin == datetime())
  })
  
  # Dataframe de tráfico filtrado por la hora seleccionada
  traffic_data <- reactive({
    trafico %>% 
      filter(fecha_carga == datetime())
  })
  
  # Función para crear el mapa con Leaflet
  ### Mapa con Leaflet
  output$map <- renderLeaflet({
    # Crear el mapa con Leaflet
    leaflet(options = leafletOptions(minZoom = 13, maxZoom = 16, zoomSnap = 0.1)) %>%
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
                             style = 'font-size: 16px; font-weight: bold',
                             'Estaciones de Contaminación'),
                           labelStyle = 'font-size: 14px;') %>%
      addLegendImage(images = list("./icons/line.png", "./icons/dash.png"),
                     labels = c("Exterior", "Subterráneo"),
                     labelStyle = "font-size: 14px; vertical-align: middle;",
                     height = c(30, 30),
                     width = c(30, 30),
                     orientation = 'horizontal',
                     title = 'Tipo de tramo',
                     position = 'bottomright') %>%
      addLegend(colors = c("#2CC121", "#2332BA", "#C91616", "#E2D43C", "#303131"),
                labels = levels(trafico$estado)[1:5], opacity = 0.8,
                title = 'Tráfico', position = 'bottomright')
  })
  
  ### Actualizar mapa en base a cambio en los datos
  
  # Cuando cambien los datos de estaciones, eliminar los marcadores antiguos y cargar los actualizados
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
  
  # Cuando cambien los datos de tráfico, actualizamos las layers con las características que queramos
  # Método más óptimo que borrar las polylines y volver a cargarlas.
  # Además, evitamos el efecto de flash al eliminar y cargar las capas.
  # La función setShapeStyle no está implementada en leaflet, ver script leaflet_dynamic_style.R.
  observeEvent(traffic_data(),{
    last_selected_tile <- tail(timeList$tile_historic, 1)
    last_selected_tile_class <- gsub("[0-9]", "", last_selected_tile)
    
    if (last_selected_tile_class == "tile_daylight"){
      leafletProxy("map") %>%
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico(estado),
                      dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                      data = traffic_data())
    } else{
      leafletProxy("map") %>%
        setShapeStyle(layerId = ~gid,
                      color = ~pal_trafico_night(estado),
                      dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                      data = traffic_data())
    }
    
    # Cuando se carguen inicialmente en el leaflet, ocultamos la pantalla de carga
    waiter_hide()
  })
  
  ### Cambio de cartogrfía clara/oscura en función de la hora
  
  timeList <- reactiveValues(tile_historic = "tile_night1", inc = 1)
  
  # Cuando cambia la fecha y hora, guardo un histórico de las tiles que debería cargarse en base a su hora
  # Si es diurno, indico "tile_daylight" y si es nocturno, indico "tile_night"
  # Esto permite saber si hay que cambiar de tiles o no
  observeEvent(datetime(),{
    timeList$inc <- timeList$inc+1 
    if (is_daylight(datetime())) {
      timeList$tile_historic <- c(timeList$tile_historic, paste0("tile_daylight", timeList$inc)) 
    } else{
      timeList$tile_historic <- c(timeList$tile_historic, paste0("tile_night", timeList$inc)) 
    }
  })
  
  # Si las tiles que debería cargar son del mismo tipo que las anteriores (por ejemplo, ambas diurnas)
  # no cambio de tiles. No obstante, si la actual es de un tipo y las anteriores de otro
  # (por ejemplo, nocturnas y antes diurnas) cambio de tiles.
  
  # También mantengo una especie de identificador (es la variable "inc") para que se 
  # carguen de nuevo las tiles, en vez de ir cambiando entre las que están cargadas.
  
  # Esto puede no tener sentido desde un punto de vista computacional.
  # Pero es porque de esta manera, al cargarse se produce una animación "suave".
  # Si las tiles ya están cargadas, el cambio es muy brusco y molesto para el usuario,
  # sobre todo si es del color negro al blanco
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
  
  ### Gráfico de la estación
  
  # Renderizar desde server el título de estadísticas de la estación para cambiar según estación seleccionada
  output$station_stats <- renderText({
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
    return(box_title)
  })
  
  # Renderizar plotly del % de registros para una estación y variable determinada, coloreando por la calidad
  output$est_plotly <- renderPlotly({
    shiny::validate(
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
  
  ##### Elementos para sección live
  # Objetos reactivos para recargar hora actual y mapa
  
  now <- reactive({
    invalidateLater(millis = 1000*1, session) # Refresh cada segundo de la hora
    return(Sys.time()) 
  })
  
  # Variable reactiva que sirve para notificar de si hay que actualizar los datos
  reload <- reactiveVal(0)
  
  # Se actualizará si estamos en la pestaña correspondiente, así ahorramos cargas de más
  observe({
    if(!is.null(input$tabs)){
      if(input$tabs == "live"){
        invalidateLater(millis = 1000*60*3, session) # 3 minutos de timeout
        reload(isolate(reload())+1)
      }
    }
  })
  # Variable reactiva para tener el valor de la hora en que se ha actualizado
  reload_time <- reactive({
    reload()
    return(Sys.time())
  })
  
  # Fecha actual que cambia de color en base a la hora
  output$fecha_live <- renderUI({
    
    fecha <- str_to_sentence(format(now(), format = "%A, %e de %B de %Y %H:%M:%S"))
    if (is_daylight(now())) {
      fecha_color <- p(fecha, style = "color: #000000")
    }
    else{
      fecha_color <- p(fecha, style = "color: #FFFFFF")
    }
    return(HTML(as.character(fecha_color)))
  })
  
  # Fecha de la última actualización de los datos
  output$last_update <- renderText({
    fecha_reload <- str_to_sentence(format(reload_time(), format = "%A, %e de %B de %Y %H:%M"))
    return(str_c("*Última actualización: ", fecha_reload))
  })
  
  ### Mapa con Leaflet en vivo
  output$map_live <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom = 13, maxZoom = 16, zoomSnap = 0.1)) %>%
      addPolylines(data = tramos_trafico, layerId = ~as.character(gid), label = ~denominacion) %>% 
      addAwesomeMarkers(data = estaciones, layerId = ~as.character(objectid)) %>% 
      setView(lng = "-0.36139126257400377", lat = "39.469993930673834",  zoom = 13.6) %>%
      setMaxBounds(lng1 = "-0.5017152868950778", lat1 = "39.55050724348406",
                   lng2 = "-0.24762442378004983", lat2 = "39.389409229115124") %>%
      addLegendAwesomeIcon(iconSet = icon_estaciones,
                           orientation = 'vertical',
                           position = 'topright',
                           title = htmltools::tags$div(
                             style = 'font-size: 16px; font-weight: bold',
                             'Estaciones de Contaminación'),
                           labelStyle = 'font-size: 14px;') %>%
      addLegendImage(images = list("./icons/line.png", "./icons/dash.png"),
                     labels = c("Exterior", "Subterráneo"),
                     labelStyle = "font-size: 14px; vertical-align: middle;",
                     height = c(30, 30),
                     width = c(30, 30),
                     orientation = 'horizontal',
                     title = 'Tipo de tramo',
                     position = 'bottomright') %>%
      addLegend(colors = c("#2CC121", "#2332BA", "#C91616", "#E2D43C", "#303131"),
                labels = levels(trafico$estado)[1:5], opacity = 0.8,
                title = 'Tráfico', position = 'bottomright')
  })
  
  # Cargar mapa de leaflet aunque esté en una pestaña diferente a la seleccionada
  # Es para que funcione leafletProxy, que necesita que el mapa esté cargado para funcionar
  outputOptions(output, "map_live", suspendWhenHidden = FALSE) 
  
  # Datos de las estaciones de contaminación, se actualizan automáticamente
  air_data_live <- reactive({
    reload()

    est_live <- read.csv2(est_url) %>%
      select(-globalid:-geo_point_2d) %>%
      mutate(tipozona = factor(tipozona),
             tipoemision = factor(tipoemision),
             fecha_carga = with_tz(trunc(ymd_hms(fecha_carga), units = "mins"), tzone = "Europe/Madrid"),
             calidad_ambiental = factor(calidad_ambiental, levels = calidad_aire)) %>%
      mutate(across(.cols = so2:pm25, .fns = parse_number)) %>%
      select(-nombre:-mediciones)

    est_contamin_live <- st_as_sf(left_join(est_live, estaciones, by = "objectid") %>%
                                    mutate(objectid = as.character(objectid)))
  })
  
  # Datos del tráfico, se actualizan automáticamente
  traffic_data_live <- reactive({
    reload()
    
    trafico_live <- read.csv2(trafico_url) %>%
      select(-idtramo:-geo_point_2d) %>%
      mutate(estado = factor(estado, levels = 0:9, labels = labels_estado))

    trafico_live <- st_as_sf(left_join(trafico_live, tramos_trafico, by = "gid") %>%
                               mutate(gid = as.character(gid)))
  })
  
  # Cuando actualizamos los datos, también modificamos las correspondientes capas en leaflet
  observe({
    # Eliminar marcadores antiguos de estaciones y cargar los actualizados
    leafletProxy("map_live") %>%
      clearMarkers() %>% 
      addAwesomeMarkers(data = air_data_live(), layerId = ~objectid,
                        icon = ~icon_estaciones[calidad_ambiental],
                        popup = ~est_popups_live(nombre, direccion, tipozona,
                                                  tipoemision, calidad_ambiental,
                                                  pm25, pm10, no2, o3,
                                                  so2, co, fecha_carga)
      )
    
    # Actualizar layers con las características que queramos
    leafletProxy("map_live") %>%
      setShapeStyle(layerId = ~gid,
                    color = ~pal_trafico(estado),
                    dashArray = ~ifelse(grepl("(?i)paso inferior", estado), "10,15", ""),
                    data = traffic_data_live())
  })
  
  ### Cambio de cartografía clara/oscura en función de la hora
  
  timeList_live <- reactiveValues(tile_historic_live = "", inc_live = 1)
  
  # Cuando cambia la fecha y hora, guardo un histórico de las tiles que debería cargarse en base a su hora
  observeEvent(reload_time(),{
    timeList_live$inc_live <- timeList_live$inc_live+1 
    if (is_daylight(reload_time())) {
      timeList_live$tile_historic_live <- c(timeList_live$tile_historic_live, paste0("tile_daylight", timeList_live$inc_live)) 
    } else{
      timeList_live$tile_historic_live <- c(timeList_live$tile_historic_live, paste0("tile_night", timeList_live$inc_live)) 
    }
  })
  
  # Cambio de tiles ciclo día/noche
  observe({
    last_selected_tile <- tail(timeList_live$tile_historic_live, 1)
    last_selected_tile_class <- gsub("[0-9]", "", last_selected_tile)
    second_to_last_selected_tile <- tail(timeList_live$tile_historic_live, 2)[1]
    second_to_last_selected_tile_class <- gsub("[0-9]", "", second_to_last_selected_tile)
    
    if (last_selected_tile_class == "tile_daylight"){
      prov <- providers$CartoDB.Positron
    } else{
      prov <- providers$CartoDB.DarkMatter
    }
    
    if( last_selected_tile_class != second_to_last_selected_tile_class){
      leafletProxy("map_live") %>%
        removeTiles(layerId = second_to_last_selected_tile) %>%
        addProviderTiles(
          prov,
          layerId = last_selected_tile,
          group = "day_night_tiles")
    } else if (length(timeList_live$tile_historic_live) == 1){
      leafletProxy("map_live") %>%
        addProviderTiles(
          prov,
          layerId = last_selected_tile,
          group = "day_night_tiles")
    }
  })

  ########### PARTE GEMA, WILSON, SANDRA
  # Creamos el grafico
  #Añadimos el mapa de calor
  
  # Dataframe adaptado para la visualización del mapa de calor
  df_date <- reactive({
    datos_diarios_clean %>%
      filter(Fecha >= input$ID_Fecha1[1] & Fecha <= input$ID_Fecha1[2])
  })
  
  # Filtrado de medida seleccionada
  df_medida <- reactive({
    df_date() %>%
      filter(Parametros == input$ID_Calidad1)
  })
  
  # Generar dataframe para utilizar en el primer mapa de calor
  df <- reactive({
    df_medida() %>% 
      filter(Estacion == input$ID_Estacion1)
  })
  
  # Renderizar el mapa de calor
  output$heatmap <- renderPlotly({
    map <- df() %>% 
      date_heatmap() 
    #abs(title = paste("Mapa de calor para"),
    #fill=paste(input$ID_Calidad2, "(u/mg)"))
    
    interactive_date_heatmap(map)
  })
  
  
  #Funcion para crear el grafico de barras apiladas

  
  output$apilados <- renderPlotly({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    ggplot(datos_diarios_clean %>% 
             filter(Parametros == input$ID_Calidad2, Estacion %in% input$ID_Estacion2), 
           aes(x = Estacion, y = Valores, fill = Clasificacion)) +
      geom_bar(stat = "identity") +
      labs(x = "Estaciones", y = "Valores", fill = "Clasificación") +
      scale_fill_manual(values = colores) +
      theme_minimal()
  })

  
  # Funcion para crear el grafico de tarta para varias estaciones y todos los parametros
  datos_filtrados_todos <- reactive({
    datos_diarios_clean %>%
      filter(Estacion %in% input$ID_Estacion2) %>% 
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
      group_by(Clasificacion) %>% 
      summarise(suma=n()) %>%
      ungroup()
  })
  #Funcion para crear el grafico de tarta para varias estaciones y 1 parametro
  datos_filtrados1 <- reactive({
    datos_diarios_clean %>%
      filter(Estacion %in% input$ID_Estacion2) %>% 
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
      filter(Parametros == input$ID_Calidad2) %>% 
      group_by(Clasificacion) %>% 
      summarise(suma=n()) 
  })
  
  #Funcion para crear los 2 graficos de tarta 
  output$tarta2 <- renderPlotly({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    plot_ly(labels = ~Clasificacion, values = ~suma, legendgroup = ~Clasificacion, marker = list(color = colores)) %>%
      add_pie(data = datos_filtrados1(), name = paste0("Parámetro: \n", input$ID_Calidad2), domain = list(row = 0, column = 0))%>%
      add_pie(data = datos_filtrados_todos(), name = "General", domain = list(row = 0, column = 1))%>%
      layout(title = "Pie Charts in Grid", showlegend = T,
             grid=list(rows=1, columns=2),
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>% 
      add_annotations(x=c(0.05,0.55),
                      y=0.9,
                      text = c("Parámetro seleccionado", "General, todos los parámetros"),
                      xref = "paper",
                      yref = "paper",
                      xanchor = "left",
                      showarrow = FALSE)
    
    
    
  })
  
  output$semanal <- renderPlot({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    
    semana1 <- ggplot(datos_diarios_clean %>% 
                        filter(Clasificacion == "Muy Desfavorable"|Clasificacion=="Extremadamente Desfavorable") %>% 
                        filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
                        mutate(dia_sem = factor(dia_sem, levels = c("Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo"))) %>% 
                        group_by(dia_sem) %>% 
                        summarise(con=n()) %>% 
                        ungroup(),
                      aes(dia_sem, con, fill=dia_sem))+
      geom_col()+
      coord_polar()+
      theme(legend.position = "none",
            axis.text.y = element_blank(),
            axis.text.x = element_text(size=6),
            axis.ticks = element_blank())+
      labs(title="Valores desfavorables para todas las estaciones", x="", y="")
    
    
    semana2 <-  ggplot(datos_diarios_clean %>% 
                         filter(Clasificacion == "Muy Desfavorable"|Clasificacion=="Extremadamente Desfavorable") %>% 
                         filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
                         mutate(dia_sem = factor(dia_sem, levels = c("Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo"))) %>% 
                         filter(Estacion %in% input$ID_Estacion2) %>%
                         group_by(dia_sem) %>% 
                         summarise(con=n()) %>% 
                         ungroup(),
                       aes(dia_sem, con, fill=dia_sem))+
      geom_col()+
      coord_polar()+
      theme(legend.position = "none",
            axis.text.y = element_blank(),
            axis.text.x = element_text(size=6),
            axis.ticks = element_blank())+
      labs(title="Valores desfavorables para cada estacion seleccionada", x="", y="")
    
    
    # Envolver los gráficos con patchwork
    pw <- wrap_plots(semana1, semana2, ncol = 2)
    
    pw
    
  })
  
  #Datos filtrados para la pestaña de tabla
  datos_filtrados3 <- reactive({
    datos_diarios_clean %>% 
      filter(Fecha >= "2019-02-06" & Fecha <= "2019-02-09", #Fecha >= input$ID_Fecha3[1] & Fecha <= input$ID_Fecha3[2]
             Estacion %in% input$ID_Estacion3, Parametros %in% input$ID_Calidad3)  
  })
  
  #Muestra la tabla interactiva
  output$tabla <- DT::renderDataTable({
    shiny::validate(need(input$ID_Estacion3, "Selecciona la estación que quieras ver"))
    shiny::validate(need(input$ID_Calidad3, "Selecciona el parametro de calidad de aire"))
    DT::datatable(
      datos_filtrados3(), rownames = FALSE,
      extensions = 'Buttons',
      options = list(
        dom = "Bfrtip",
        buttons = c('copy', 'csv', 'excel', 'pdf'),
        pageLength = 10,
        lengthMenu = c(5, 10, 50, 100),
        paging = FALSE,
        searching = TRUE,
        fixedColumns = FALSE,
        autoWidth = TRUE,
        ordering = TRUE,
        initComplete = JS(
          "function(settings, json) {",
          "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
          "}"
        )
      )
    )
  })
  
  
  # tabla 2 parte información
  output$tabla2 <- renderText({
    tabla  %>% kable(caption = "(Si queremos poner titulo a la tabla)") %>% kable_styling() %>%
      column_spec(2, color = "white", background = "#72ae27") %>%
      column_spec(3, color = "white", background = "#37a4d7") %>%
      column_spec(4, color = "white", background = "#f49631") %>%
      column_spec(5, color = "white", background = "#d43f2b") %>%
      column_spec(6, color = "white", background = "#9c3035") %>%
      column_spec(7, color = "white", background = "#d253b8") #%>%
      #scroll_box(width = "700px", height = "400px")
  })
  
  observeEvent(input$sidebarItemExpanded, {
    if (input$sidebarItemExpanded == "MenuItem2") {
      print("updating tab items")
    }
  })
  
  ############### FIN PARTE GEMA, WILSON, SANDRA
}