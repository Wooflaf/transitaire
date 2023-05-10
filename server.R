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
    plot_ly(labels = ~Clasificacion, values = ~suma, legendgroup = ~Clasificacion) %>%
      add_pie(data = datos_filtrados1(), name = "parámetro seleccionado", domain = list(row = 0, column = 0))%>%
      add_pie(data = datos_filtrados_todos(), name = "todos los parámetros", domain = list(row = 0, column = 1))%>%
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
  ############### FIN PARTE GEMA, WILSON, SANDRA
  
  
  
  
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

