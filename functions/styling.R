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
