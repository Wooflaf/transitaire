### Palettes of colors
pal_estaciones <- function(AQ_label){
  # Usar una declaración switch para asignar un color en función del nombre de la variable
  color <- switch(AQ_label,
                  "Sin Datos" = "black",
                  "Buena" = "green",
                  "Razonablemente Buena" = "blue",
                  "Regular" = "orange",
                  "Desfavorable" = "red",
                  "Muy Desfavorable" = "darkred",
                  "Extremadamente Desfavorable" = "purple",
                  "black") # Predeterminar el color negro si el nombre de la variable no coincide
  
  return(color)
  
}
pal_trafico <- colorFactor(c("#3BFF2D", "#2332BA", "red", "yellow", "#303131", "#3BFF2D", "#2332BA", "red", "yellow", "#303131"),
                           levels = levels(trafico$estado))

pal_trafico_night <- colorFactor(c("green", "blue", "red", "yellow", "white", "green", "blue", "red", "yellow", "white"),
                           levels = levels(trafico$estado))

### Icons
icon_estaciones <- awesomeIconList(
  "Sin Datos" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "#FFFFFF",
    markerColor = pal_estaciones("Sin Datos"),
    library = "fa"
  ),
  "Buena" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "black",
    markerColor = pal_estaciones("Buena"),
    library = "fa"
  ),
  "Razonablemente Buena" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "black",
    markerColor = pal_estaciones("Razonablemente Buena"),
    library = "fa"
  ),
  "Regular" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "black",
    markerColor = pal_estaciones("Regular"),
    library = "fa"
  ),
  "Desfavorable" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "black",
    markerColor = pal_estaciones("Desfavorable"),
    library = "fa"
  ),
  "Muy Desfavorable" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "#FFFFFF",
    markerColor = pal_estaciones("Muy Desfavorable"),
    library = "fa"
  ),
  "Extremadamente Desfavorable" = makeAwesomeIcon(
    icon = "cloud",
    iconColor = "black",
    markerColor = pal_estaciones("Extremadamente Desfavorable"),
    library = "fa"
  )
)

### Popups
est_popups <- function(AirPollutant, AQ_index, cause, Concentration, direccion, nombre, tipozona, tipoemision, UnitOfMeasurement){
  inbetween <- ifelse(AirPollutant == "AQ_index_all",
                      
                      ifelse(is.na(cause) | AQ_index == "Buena",
                             paste0("<strong>Calidad:</strong> ", AQ_index, "<br>"),
                             paste0("<strong>Calidad:</strong> ", AQ_index, " (debido a ", cause, ")<br>")
                      ),
                      
                      ifelse(is.na(Concentration) | AQ_index == "Sin datos",
                             paste0("<strong>Calidad:</strong> ", AQ_index, "<br>"),
                             paste0("<strong>Concentración ", AirPollutant,":</strong> ", 
                                    Concentration, " ", UnitOfMeasurement, "<br>",
                                    "<strong>Calidad:</strong> ", AQ_index, "<br>"
                             )
                      )
  )
  
  paste0("<strong>Estación:</strong> ", nombre, "<br>",
         inbetween,
         "<strong>Tipo de zona:</strong> ", tipozona, "<br>",
         "<strong>Tipo de emisión:</strong> ", tipoemision, "<br>",
         "<strong>Dirección:</strong> ", direccion, "<br>")
}

### Waiting screen
waiting_screen <- div(
  style = "color: #3d8cbc; width: 100%; height: 100%;",
  spin_loaders(14, color = "#3d8cbc"),
  br(),br(),br(),
  h4("Cargando visualización...")
)

### Cicerone guide

guide <- Cicerone$
  new(
    allow_close = FALSE,
    done_btn_text = "Hecho",
    close_btn_text = "Saltar tutorial",
    prev_btn_text = "Anterior",
    next_btn_text = "Siguiente"
  )$
  step(
    el = "box-text",
    title = "¡Bienvenido!"
  )$
  step(
    el = "map",
    title = "Dora, ¡es el mapa!",
    description = HTML("En este mapa podrás ver la calidad del aire y el estado del 
    tráfico en una hora y día determinado.<br><br>En la parte superior izquierda, tienes tres botones.
    Los dos primeros controlan el zoom del mapa y el tercero te permite volver a la vista inicial.
    <br><br>Además, en el lateral derecho, se encuentran las leyendas que te ayudarán 
    a identificar qué representa cada elemento."),
    position = "left-center"
  )$
  step(
    el = "box-time",
    title = "Línea temporal",
    description = "En esta sección podrás ajustar el día y hora que quieres visualizar,
    así como reproducirlo automáticamente con el botón de <i>play</i>."
  )$
  step(
    el = "box-var",
    title = "Selector de variable",
    description = "Aquí puedes indicar por qué variable atmosférica quieres que se coloreen las estaciones del mapa."
  )$
  step(
    el = "box-stats",
    title = "Estadísticas de la estación",
    description = "Vaya. Aquí no hay... ¿Nada? En este recuadro se mostrará un gráfico con información relevante para una estación.
    No obstante, antes deberás hacer click en alguna de las que aparece en el mapa."
  )#$
  # step(
  #   el = "sidebarCollapsed",
  #   title = "Barra lateral",
  #   description = "Pero no solo acaba ahí. A través de la barra lateral, puedes cambiar de sección. Podrás visualizar 
  #                         los datos de las estaciones, compararlas entre ellas, así como acceder a una visualización en tiempo
  #                         real de la ciudad de Valencia, y obtener información sobre cómo hemos obtenido los datos y por qué
  #                         es tan importante mantener una ciudad libre de contaminación ambiental.",
  #   position = "right-center"
  # )

### Custom styles for classes

styles <- tags$head(
  tags$style(
    HTML(
      ".irs--shiny .irs-min, .irs--shiny .irs-max {
            top: 0px;
            text-shadow: none;
            background-color: rgba(0, 0, 0, 0.1);
            font-size: 12px;
            line-height: 1.333;
            padding: 1px 3px;
            border-radius: 3px;
          }
          .irs--shiny .irs-single {
            color: #fff;
            text-shadow: none;
            padding: 1px 3px;
            background-color: #428bca;
            border-radius: 3px;
            font-size: 13px;
            line-height: 1.333;
          }
      .box-title {
            color: #3c8cbd;
            font-weight: bold;
            display: inline-block;
            font-size: 22px;
            margin: 0;
            line-height: 1;
      }"
    )
  )
)