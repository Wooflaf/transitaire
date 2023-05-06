ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(),
  
  dashboardBody(
    fluidRow(
      leafletjs,
      column(width = 4,
             box(title = NULL,
                 width = NULL, solidHeader = TRUE,
                 tags$style("#fecha {font-size:20px;
                              font-family:helvetica, sans-serif;}"),
                 textOutput("fecha"),
                 tags$style(
                   HTML(".slider-container { 
                        width: 85%; 
                        margin: 0 auto;
                        }")
                 ),
                 tags$br(),
                 div(class = "slider-container",
                     sliderInput("time", NULL,
                                 min = min(trafico$fecha_carga),
                                 max =  max(trafico$fecha_carga),
                                 value = min(trafico$fecha_carga), step = 3600,
                                 timezone = "+0000", timeFormat = "%d/%m/%Y %H:%M",
                                 animate = animationOptions(interval = 1500), ticks = F)
                 )
                 
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
                                plotlyOutput("est_plotly", height = 300)
                              )
             )
      ),
      column(width = 8, leafletOutput("map", height = 900))
    )
  )
)

