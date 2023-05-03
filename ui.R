ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(),
  
  dashboardBody(
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
                                         "NO", "PM2.5")
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

