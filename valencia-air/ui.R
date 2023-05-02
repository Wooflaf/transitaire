<<<<<<< HEAD

ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  dashboardSidebar(),
  dashboardBody(
    fluidRow(
      column(width = 4,
             box(title = "Visualización temporal",
                 width = NULL, solidHeader = TRUE,
                 actionButton("play", "Reproducir animación", icon = icon("play-circle")),
             ),
             box(title = "Variable a mostrar",
                 width = NULL, solidHeader = TRUE,
                 selectInput("var", NULL, choices = c("Índice de Calidad de Aire"))
             ),
             conditionalPanel(condition = "input.map_marker_click != null",
                              box(title = "Estadísticas de la estación seleccionada",
                                  width = NULL, solidHeader = TRUE,
                                  uiOutput("estadisticas_ui"),
                                  plotOutput("grafico", height = 300)))
      ),
      column(width = 8, leafletOutput("map", height = 900))
      
    ),
    
    
  )
)

=======
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
                             choices = c("Índice de Calidad de Aire")
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

>>>>>>> 4397e2a6837a8905909cfeae18940a9fc9e8b6ee
