# Función para determinar si es de día o de noche en base a la hora y criterio básico
is_daylight <- function(date){
  if(hour(date) >= 7 & hour(date) < 21){
    return(TRUE)
  }
  else{
    return(FALSE)
  }
}

calidad_aire <- c("Buena", "Razonablemente Buena", "Regular",
                  "Desfavorable", "Muy Desfavorable",
                  "Extremadamente Desfavorable", "Sin datos")

est_url <- "https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estacions-contaminacio-atmosferiques-estaciones-contaminacion-atmosfericas/exports/csv?lang=es"
trafico_url <- "https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/estat-transit-temps-real-estado-trafico-tiempo-real/exports/csv?lang=es"


month_eng_to_esp <- c("january" = "enero", "february" = "febrero", "march" = "marzo",
                      "april" = "abril", "may" = "mayo", "june" = "junio", "july" = "julio",
                      "august" = "agosto", "september" = "septiembre", "october" = "octubre",
                      "november" = "noviembre", "december" = "diciembre")
wday_eng_to_esp <- c("Monday" = "Lunes", "Tuesday" = "Martes",
                     "Wednesday" = "Miércoles", "Thursday" = "Jueves",
                     "Friday" = "Viernes", "Saturday" = "Sábado",
                     "Sunday" = "Domingo")

format_datetime <- function(datetime, include_sec = F){
  if (include_sec){
    datetime <- str_to_sentence(format(datetime, format = "%A, %e de %B de %Y %H:%M:%S"))
  } else{
    datetime <- str_to_sentence(format(datetime, format = "%A, %e de %B de %Y %H:%M"))
  }
  
  day_pattern <- paste0("\\b(", paste(names(wday_eng_to_esp), collapse = "|"), ")\\b")
  day_match <- str_extract(datetime, day_pattern)
  
  if (!is.na(day_match)) {
    datetime <- str_replace(datetime, day_match, wday_eng_to_esp[day_match])
  }
  
  month_pattern <- paste0("\\b(", paste(names(month_eng_to_esp), collapse = "|"), ")\\b")
  month_match <- str_extract(datetime, month_pattern)
  
  if (!is.na(month_match)) {
    datetime <- str_replace(datetime, month_match, month_eng_to_esp[month_match])
  }
  
  return(datetime)
}


### Custom function to include a sentence in dropdownMenu, taken and slightly modified from https://github.com/rstudio/shiny-gallery/blob/master/nz-trade-dash/ui.R
customSentence <- function(numItems, type) {
  paste("Comentarios y sugerencias")
}

customSentence_share <- function(numItems, type) {
  paste("¿Te gusta? ¡Compártelo!")
}
dropdownMenuCustom <-     function (..., type = c("messages", "notifications", "tasks"), 
                                    badgeStatus = "warning", icon = NULL, .list = NULL, customSentence = customSentence) 
{
  type <- match.arg(type)
  if (!is.null(badgeStatus)) shinydashboard:::validateStatus(badgeStatus)
  items <- c(list(...), .list)
  lapply(items, shinydashboard:::tagAssert, type = "li")
  dropdownClass <- paste0("dropdown ", type, "-menu")
  if (is.null(icon)) {
    icon <- switch(type, messages = shiny::icon("envelope"), 
                   notifications = shiny::icon("warning"), tasks = shiny::icon("tasks"))
  }
  numItems <- length(items)
  if (is.null(badgeStatus)) {
    badge <- NULL
  }
  else {
    badge <- tags$span(class = paste0("label label-", badgeStatus), 
                       numItems)
  }
  tags$li(
    class = dropdownClass, 
    a(
      href = "#", 
      class = "dropdown-toggle", 
      `data-toggle` = "dropdown", 
      icon, 
      badge
    ), 
    tags$ul(
      class = "dropdown-menu", 
      tags$li(
        class = "header", 
        customSentence(numItems, type)
      ), 
      tags$li(
        tags$ul(class = "menu", items)
      )
    )
  )
}

