AQ_traffic_tab <- fluidRow(
  leafletjs,
  column(width = 3,
         div(
           id = "box-text",
           box(title = "Relación del tráfico con la calidad del aire",
               width = NULL, solidHeader = F,
               div(
                 style = 'font-size: 16px; font-family: system-ui;',
                 HTML("Esta visualización te permitirá ver de una manera
                     sencilla e intuitiva la calidad del aire en Valencia y su relación con el estado del tráfico
                     rodado.<br><br>
                        ")
               )
           )
         ),
         div(
           id = "box-var",
           box(title = "Variable a visualizar",
               width = NULL, solidHeader = F,
               selectInput("var", NULL, 
                           choices = c("Índice de Calidad del Aire" = "AQ_index_all",
                                       "Partículas PM2.5" = "PM2.5",
                                       "Partículas PM10" = "PM10", 
                                       "NO2 (Dióxido de Nitrógeno)" = "NO2",
                                       "O3 (Ozono)" = "O3",
                                       "SO2 (Dióxido de Azufre)" = "SO2")
               )
           )
         ),
         div(
           id = "box-stats",
           box(
             title = "Estadísticas de la estación",
             width = NULL, solidHeader = F,
             plotlyOutput("est_plotly", height = 300)
           )
         ),
         div(style="display:inline-block",
             actionBttn('guide', 'Ver tutorial de nuevo',
                        style = "fill", color = "primary"
             ))
  ),
  column(width = 9,
         leafletOutput("map", height = 900),
         absolutePanel(
           bottom = 10, left = 50,
           div(
             id = "box-time",
             tags$style("#fecha {font-size:20px;
                              font-family: system-ui;}"),
             uiOutput("fecha"),
             uiOutput("color"),
             tags$style(
               HTML(".slider-container {
                        display:inline-flex;
                        margin: 0 auto;
                        }")
             ),
             div(
               style = "width: 85%;",
               class = "slider-container",
               sliderInput("time", NULL,
                           min = first_datetime,
                           max =  last_datetime,
                           value = first_datetime, step = 3600,
                           timeFormat = "%d/%m/%Y %H:%M",
                           ticks = F, timezone = "+0000",
                           animate = animationOptions(interval = 1500, loop = F,
                                                      playButton = actionButton(
                                                        "play",
                                                        "",
                                                        icon = icon("play"),
                                                        width = "50px",
                                                        style = "margin-top: 10px; color: #fff; background-color: #337ab7; border-color: #2e6da4"
                                                      ),
                                                      pauseButton = actionButton(
                                                        "pause",
                                                        "",
                                                        icon = icon("pause"),
                                                        width = "50px",
                                                        style = "margin-top: 10px; color: #fff; background-color: #337ab7; border-color: #2e6da4"
                                                      )
                           )
               )
             ),
             div(
               style = "width: 40%;",
               class = "slider-container",
               sliderInput("speed", NULL,
                           min = 1, max =  4, 
                           value = 1, step = 1,
                           ticks = FALSE),
               actionBttn("speed_button",
                          label = "Cambiar velocidad",
                          style = "jelly",
                          color = "primary")
             ),
             
           )
         )
  )
)