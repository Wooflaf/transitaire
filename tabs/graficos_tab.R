graficos_tab <- fluidPage(
  # Show a plot of the generated distribution
  tabsetPanel(
    tabPanel("Graficos", 
             sidebarLayout(
               sidebarPanel(
                 h4("Elementos de entrada"), #header de tama?o 3 x eso es m?s grande
                 
                 hr(), # crea una linea horizontal, horizontal rule
                 
                 selectInput("ID_Estacion1",
                             "Selecciona la estación",
                             unique(datos_diarios$Estacion),
                             selected = "Viveros"),
                 dateRangeInput("ID_Fecha1",
                                "Selecciona las fechas",
                                start = "2018-06-27", 
                                end = "2020-07-09",
                                min = min(datos_diarios$Fecha),
                                max = max(datos_diarios$Fecha), format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "a"),
                 selectInput("ID_Calidad1",
                             "Selecciona los parámetros",
                             names(datos_diarios[c("PM2.5", "PM10","NO2", "O3", "SO2")]),
                             selected = "NO2")
               ),
               mainPanel(
                 h3("Grafico de calor"),
                 plotlyOutput("heatmap")
               ))),
    tabPanel("Graficos varias estaciones", 
             sidebarLayout(
               sidebarPanel(
                 h4("Elementos de entrada"), #header de tama?o 3 x eso es m?s grande
                 
                 hr(), # crea una linea horizontal, horizontal rule
                 
                 selectInput("ID_Estacion2",
                             "Selecciona la estación",
                             unique(datos_diarios$Estacion),multiple = TRUE),
                 dateRangeInput("ID_Fecha2",
                                "Selecciona las fechas",
                                start = min(datos_diarios$Fecha), end = max(datos_diarios$Fecha), min = min(datos_diarios$Fecha),
                                max = max(datos_diarios$Fecha), format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "a"),
                 selectInput("ID_Calidad2",
                             "Selecciona los parámetros",
                             names(datos_diarios[c("PM2.5", "PM10","NO2", "O3", "SO2")]))
               ),
               mainPanel(
                 h4("Grafico de barras apiladas"),
                 plotlyOutput("apilados"),
                 h4("Graficos de tarta"),
                 plotlyOutput("tarta2"),
                 h4("Grafico semanal"), 
                 plotOutput("semanal")
               ))),
    tabPanel("Tabla",  
             sidebarLayout(
               sidebarPanel(
                 h4("Elementos de entrada"), #header de tama?o 3 x eso es m?s grande
                 
                 hr(), # crea una linea horizontal, horizontal rule
                 
                 selectInput("ID_Estacion3",
                             "Selecciona la estación",
                             unique(datos_diarios$Estacion),multiple = TRUE),
                 dateRangeInput("ID_Fecha3",
                                "Selecciona las fechas",
                                start = min(datos_diarios$Fecha), end = max(datos_diarios$Fecha), min = min(datos_diarios$Fecha),
                                max = max(datos_diarios$Fecha), format = "yyyy-mm-dd", weekstart = 1,
                                language = "es", separator = "a"),
                 selectInput("ID_Calidad3",
                             "Selecciona los parámetros",
                             names(datos_diarios[c("PM2.5", "PM10","NO2", "O3", "SO2")]),multiple = TRUE)
               ),
               mainPanel(
                 h3("Tabla Interactiva"), 
                 hr(), 
                 hr(),
                 DT::dataTableOutput("tabla")
               )))))