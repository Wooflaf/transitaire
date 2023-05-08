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
  
  # Función para filtrar los datos
  datos_filtrados <- reactive({
    datos_diarios %>%
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2],
             Estacion %in% input$ID_Estacion2)
  })
  
  
  #AÑADIMOS LA TABLA
  estaciones <- reactive({
    input$ID_Estacion3 
  })
  
  #Datos para varias estaciones y todos los parametros
  datos_filtrados1 <- reactive({
    datos_diarios_clean %>% 
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2], #Fecha >= "2019-02-06" & Fecha <= "2019-02-09"
             Estacion == input$ID_Estacion2)  
  })
  
  
  #Funcion para crear el grafico de barras apiladas
  colores <- c("Buena" = "#2E8B57", "Razonablemente  buena" = "darkgreen", 
               "Regular" = "#FF8C00", "Desfavorable" = "#4169E1", 
               "Muy Desfavorable" = "#A9A9A9", "Extremadamente Desfavorable" = "black")
  
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
  output$tartageneral <- renderPlotly({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    #pie(x = datos_filtrados1()[[Valores]], labels = datos_filtrados1()[[Parametros]],  main = "Gráfico de tarta para todos los parametros")
    data <- datos_diarios_clean %>%
      filter(Estacion %in% input$ID_Estacion2) %>% 
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
      group_by(Clasificacion) %>% 
      summarise(suma=n()) %>% 
      ungroup()
    
    fig <- plot_ly(data, labels = ~Clasificacion, values = ~suma, type = 'pie')
    fig %>% layout(title = 'Para varias estaciones y todos los parámetros',
                          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    

  })
  
  #Funcion para crear el grafico de tarta para varias estaciones y 1 parametro
  output$tarta1parametro <- renderPlotly({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    #pie(x = datos_filtrados1()[[Valores]], labels = datos_filtrados1()[[Parametros]],  main = "Gráfico de tarta para todos los parametros")
    data <- datos_diarios_clean %>%
      filter(Estacion %in% input$ID_Estacion2) %>% 
      filter(Fecha >= input$ID_Fecha2[1] & Fecha <= input$ID_Fecha2[2]) %>%
      filter(Parametros == input$ID_Calidad2) %>% 
      group_by(Clasificacion) %>% 
      summarise(suma=n()) %>% 
      ungroup()
    
    fig <- plot_ly(data, labels = ~Clasificacion, values = ~suma, type = 'pie')
    fig %>% layout(title = 'Para varias estaciones y el parámetro seleccionado',
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  })
  
  # Función para crear el gráfico semanal 
  output$semanal <- renderPlot({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    ggplot(datos_diarios_clean %>% 
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
  })
  
  # Función para crear el gráfico semanal 2 para cada estacion seleccionada
  output$semanal2 <- renderPlot({
    shiny::validate(need(input$ID_Estacion2, "Elige una o varias estaciones"))
    ggplot(datos_diarios_clean %>% 
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
  
  output$Imagen <- renderImage({
    
    list(src = "www/Clasificacion.jpeg",
         width = "100%",
         height = 330)
    
  }, deleteFile = F)

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
