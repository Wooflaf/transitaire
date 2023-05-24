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
