ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(),
  
  dashboardBody(
    fluidRow(
      leafletjs,
      column(width = 4,
             box(title = "Visualización temporal",
                 width = NULL, solidHeader = TRUE,
                 sliderInput("time","Time",
                             min = min(trafico$fecha_carga),
                             max =  max(trafico$fecha_carga),
                             value = min(trafico$fecha_carga), step = 3600,
                             timezone = "+0000", animate = animationOptions(interval = 1500))
             ),
             box(title = "Variable a mostrar",
                 width = NULL, solidHeader = TRUE,
                 selectInput("var", NULL, 
                             choices = c("Índice de Calidad del Aire" = "AQ_index_all",
                                         "Partículas PM2.5" = "PM2.5",
                                         "Partículas PM10" = "PM10", 
                                         "NO2 (Dióxido de Nitrógeno)" = "NO2",
                                         "O3 (Ozono)" = "O3",
                                         "SO2 (Dióxido de Azufre)" = "SO2")
                 )
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
    )
  )
)

