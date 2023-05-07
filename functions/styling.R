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
    tráfico en una hora y día determinado.<br><br>Los datos que vas a visualizar
    comienzan el 2 de mayo de 2023 y acaban el 9 de mayo de 2023."),
    position = "left-center"
  )$
  step(
    el = "[class = 'leaflet-top leaflet-left']",
    title = "Zoom y reset",
    description = "Con los dos primeros botones puedes controlar el zoom 
    (también lo puedes hacer con la rueda del ratón).<br>
    Con el último puedes volver a la vista inicial.",
    is_id = FALSE
  )$
  step(
    el = "[class = 'info legend leaflet-control']",
    title = "Leyenda para las estaciones",
    position = "left-center",
    is_id = FALSE
  )$
  step(
    el = "[class = 'leaflet-bottom leaflet-right']",
    title = "Leyenda para el tráfico",
    position = "left-center",
    is_id = FALSE
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
    No obstante, antes deberás hacer click en alguna de las que aparece en el mapa.",
    on_next = "function(){
    var body = document.body
    body.classList.remove('sidebar-collapse')
    }",
    next_btn_text = "Abrir barra lateral"
  )$
  step(
    el = "sidebarCollapsed",
    title = "Barra lateral",
    description = "Si mueves el ratón hacia el lateral izquierdo, o haces click en las tres líneas horizontales,
    se abre esta barra lateral.<br>Aquí podrás cambiar de sección.",
    position = "right-center",
    next_btn_text = "Ver secciones"
  )$
  step(
    el = "[data-value = 'graficos']",
    title = "Gráficos sobre las estaciones",
    description = "Podrás visualizar los datos de las estaciones, así como
    compararlas entre ellas.",
    is_id = FALSE,
    position = "right-center"
  )$
  step(
    el = "[data-value = 'live']",
    title = "Visualización en tiempo real",
    description = "En esta sección habrá una visualización geográfica en tiempo real
    de los datos de las estaciones y de otras entidades",
    is_id = FALSE,
    position = "right-center"
  )$
  step(
    el = "[data-value = 'info']",
    title = "Información",
    description = "Información sobre cómo hemos obtenido los datos
    y por qué es tan importante mantener una ciudad con una buena calidad del aire",
    is_id = FALSE,
    on_next = "function(){
    var body = document.body
    body.classList.add('sidebar-collapse')
    }",
    position = "right-center"
  )

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
      }
      .box {
            position: relative;
            border-radius: 3px;
            background: #fff;
            border-top: 3px solid #3c8cbd;
            margin-bottom: 20px;
            width: 100%;
            box-shadow: 0 1px 1px rgb(0 0 0 / 10%);
      }
      .bttn-jelly.bttn-primary {
            margin-left: 20px;
            height: 10%;
            width: 50%;
            font-size: 16px;
      }
      "
    )
  )
)