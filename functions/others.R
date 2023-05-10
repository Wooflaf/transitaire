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
