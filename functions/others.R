# Función para determinar si es de día o de noche en base a la hora y criterio básico
is_daylight <- function(date){
  if(hour(date) >= 7 & hour(date) < 21){
    return(TRUE)
  }
  else{
    return(FALSE)
  }
}