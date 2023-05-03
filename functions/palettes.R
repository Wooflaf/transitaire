pal <- colorFactor(c("black", "green", "blue", "orange", "red", "darkred", "purple"),
                   levels = levels(est_contamin$AQ_index))

pal_trafico <- colorFactor(c("green", "blue", "red", "yellow", "black", "green", "blue", "red", "yellow", "black"),
                           levels = levels(trafico$estado))