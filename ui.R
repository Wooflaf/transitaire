ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(
    sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard"),
    menuItem("Graficos", tabName = "graficos"),
    menuItem("Estadísticas", tabName = "stats"), 
    menuItem("Información", tabName = "info")
    )
  ),
  
  dashboardBody(
    tabItems( 
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                leafletjs,
                column(width = 4,
                       box(title = "Visualización temporal",
                           width = NULL, solidHeader = TRUE,
                           uiOutput(outputId = "slider"),
                           uiOutput("speed_value")
                           ),
                       box(title = "Variable a mostrar",
                           width = NULL, solidHeader = TRUE,
                           selectInput("var", NULL, 
                           choices = c("AQ_index_all", "SO2", "PM10", "O3",
                                        "NO2", "NOX as NO2", "CO", "C6H6",
                                        "NO", "PM2.5"))
                           ),
                       conditionalPanel(condition = "input.map_marker_click != null",
                                        box(
                                          title = "Estadísticas de la estación seleccionada",
                                          width = NULL, solidHeader = TRUE,
                                          uiOutput("estadisticas_ui"),
                                          plotOutput("grafico", height = 300)
                                          )
                                        )
                       ),
                column(width = 8, leafletOutput("map", height = 900))
                )),
      # Second tab content
      tabItem(tabName = "graficos",
              h2("Distribución del NO2"),
              fluidRow(
                column(width = 4,
                       box(title = "Visualización temporal",
                           width = NULL, solidHeader = TRUE,
                           actionButton("play", "Reproducir animación", icon = icon("play-circle"))
                           )
                       )
                )
              ),
    
      # Third tab content
      tabItem(tabName = "stats",
              h2("Distribución del NO2"),
              fluidPage(
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
                               plotlyOutput("tartageneral"),
                               plotlyOutput("tarta1parametro"), 
                               h4("Grafico semanal"), 
                               plotOutput("semanal"),
                               h4("Grafico semanal 2"), 
                               plotOutput("semanal2"),
                               h4("Grafico de lineas"), 
                               plotlyOutput("grafico1")
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
                      DT::dataTableOutput("tabla"),
                      h3("Estadisticas para cada variable"), 
                      verbatimTextOutput("stats")
                    )))))),
                tabItem(tabName = "info", 
                        h2("Más información"), 
                        fluidPage(
                          tabsetPanel(
                            tabPanel("Informacion",
                                     p("Este es un estudio que se lleva a cabo para documentar 
                                       la calidad del aire de la ciudad de Valencia según los 
                                       datos publicados por las estaciones de monitoreo en la ciudad.")
                            ),
                            tabPanel("Salud"),
                            tabPanel("Consejos"))
                        )) 
    )
  )
)

