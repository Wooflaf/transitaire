live <- fluidRow(
  use_hover(),
  leafletjs,
  column(width = 3,
         div(
           id = "box-text-live",
           box(title = HTML("Relación del tráfico con la calidad del aire <i>en tiempo real</i>"),
               width = NULL, solidHeader = F,
               div(
                 style = 'font-size: 16px; font-family: system-ui;',
                 HTML("Esta visualización es muy similar a la principal. Aunque
                 esta también permite ver la calidad del aire en Valencia y su relación
                 con el estado del tráfico, no podemos avanzar en el tiempo. Porque estamos
                 viendo los datos <i>en tiempo real</i>.<br><br>Los datos se 
                 recargan automáticamente cada 3 minutos. Puedes dar al botón inferior
                 para hacerlo manualmente.
                        ")
               )
           )
         ),
         hover_action_button(
           inputId = "refresh",
           label = "Recargar",
           icon = icon("refresh"),
           icon_animation = "spin",
           style = 'width: 40%; font-size: 125%; background: #1d89ff;
           color: #fff; border-radius: 6px;',
         )
         
         
  ),
  column(width = 9,
         leafletOutput("map_live", height = 900),
         absolutePanel(
           bottom = 10, left = 50,
           div(
             id = "box-time-live",
             tags$style("#fecha_live {font-size:24px;
                              font-family: system-ui;}"),
             uiOutput("fecha_live")
           )
         )
  )
)