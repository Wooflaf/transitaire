graficos_tab <- fluidPage(
  # Show a plot of the generated distribution
  tabsetPanel(
    tabPanel("Gráfico sobre una estación", 
             sidebarLayout(
               sidebarPanel(
                 selectInput("ID_Estacion1",
                             "Selecciona la estación",
                             unique(datos_diarios$Estacion),
                             selected = "Viveros"),
                 dateRangeInput("ID_Fecha1",
                                "Selecciona las fechas",
                                start = "2020-01-01", 
                                end = "2022-12-31",
                                min = "2020-01-01",
                                max = "2022-12-31", format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "hasta"),
                 selectInput("ID_Calidad1",
                             "Selecciona el parámetro",
                             choices = c("Partículas PM2.5" = "PM2.5",
                                         "Partículas PM10" = "PM10", 
                                         "NO2 (Dióxido de Nitrógeno)" = "NO2",
                                         "O3 (Ozono)" = "O3",
                                         "SO2 (Dióxido de Azufre)" = "SO2"),
                             selected = "NO2")
               ),
               mainPanel(
                 h3("Mapa de calor"),
                 plotlyOutput("heatmap")
               ))),
    tabPanel("Gráfico sobre varias estaciones", 
             sidebarLayout(
               sidebarPanel(
                 selectInput("ID_Estacion2",
                             "Selecciona las estaciones",
                             unique(datos_diarios$Estacion),multiple = TRUE),
                 dateRangeInput("ID_Fecha2",
                                "Selecciona las fechas",
                                start = min(datos_diarios$Fecha), end = max(datos_diarios$Fecha), min = min(datos_diarios$Fecha),
                                max = max(datos_diarios$Fecha), format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "hasta"),
                 selectInput("ID_Calidad2",
                             "Selecciona el parámetro",
                             choices = c("Partículas PM2.5" = "PM2.5",
                                         "Partículas PM10" = "PM10", 
                                         "NO2 (Dióxido de Nitrógeno)" = "NO2",
                                         "O3 (Ozono)" = "O3",
                                         "SO2 (Dióxido de Azufre)" = "SO2"),
                             selected = "NO2")
               ),
               mainPanel(
                 plotlyOutput("apilados")
               )
               )
             ),
    tabPanel("Datos",  
             sidebarLayout(
               sidebarPanel(
                 selectInput("ID_Estacion3",
                             "Selecciona las estaciones",
                             unique(datos_diarios$Estacion),multiple = TRUE),
                 dateRangeInput("ID_Fecha3",
                                "Selecciona las fechas",
                                start = min(datos_diarios$Fecha), end = max(datos_diarios$Fecha), min = min(datos_diarios$Fecha),
                                max = max(datos_diarios$Fecha), format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "hasta"),
                 selectInput("ID_Calidad3",
                             "Selecciona los parámetros",
                             names(datos_diarios[c("PM2.5", "PM10","NO2", "O3", "SO2")]),multiple = TRUE)
               ),
               mainPanel(
                 h3("Tabla Interactiva"),
                 DT::dataTableOutput("tabla")
               )))))