info_tab <- fluidPage(
  tabPanel("Informacion",
           p("Este es un estudio que se lleva a cabo para documentar 
          la calidad del aire de la ciudad de Valencia según los 
            datos publicados por las estaciones de monitoreo en la ciudad."),
           p("Para ello, se han tenido en cuenta once estaciones distribuidas 
            por la ciudad y cinco contaminantes 
            del aire relevantes:"),
           p("    •	El dióxido de azufre (SO2), es un gas reactivo incoloro, se produce cuando se 
            queman combustibles que contienen azufre, como el carbón y el petróleo. Con 
            una exposición muy breve de SO2 puede causar estrechamiento de las vías respiratorias."),
           p("    •	El dióxido de nitrogeno (NO2), es un gas que se forma como subproducto en los procesos 
            de combustión a altas temperaturas, como en los vehículos motorizados y las plantas eléctricas. La exposición 
            al NO2 provoca efectos respiratorios adversos."),
           p("    •	El monóxido de carbono (CO) es un gas inodoro e incoloro que se forma cuando el carbono 
            de los combustibles no se quema por completo. El CO ingresa al torrente 
            sanguíneo a través de los pulmones y reduce la cantidad de oxígeno en sangre."),
           p("    •	Las Particulate matter (PM) son partículas que se encuentran en el aire, incluido el 
            polvo, la suciedad, el hollín y el humo. Son altamente peligrosas 
            debido a que pueden alojarse profundamente en los pulmones por su pequeño tamaño."),
           p("Todas estos contaminantes estan registrados bajo la misma unidad de medida, µm/m3."),
           p("Para más información sobre los tipos de contaminantes y sus efectos en la salud, visita la página de la", 
             a("Organización Mundial de la Salud (OMS)", 
               href = "https://www.who.int/teams/environment-climate-change-and-health/air-quality-and-health/health-impacts/types-of-pollutants"),"."),
           hr(),
           h3(strong("Clasificación:")), 
           h4("Extremadamente desfavorable"),
           p("Activar advertencias sanitarias de condiciones de emergencia. Es aún más probable que toda 
          la población se vea afectada por efectos graves para la salud."), 
           h4("Muy desfavorable "),
           p("Activar una alerta de salud, lo que significa que todos pueden experimentar efectos de salud más graves."),
           h4("Desfavorable "),
           p("Todo el mundo puede comenzar a experimentar efectos en la salud. Los grupos sensibles pueden experimentar 
          efectos de salud más graves. Insalubre para un grupo sensible."),
           h4("Regular"),
           p("Los grupos sensibles pueden experimentar efectos en la salud, pero es 
          poco probable que el público en general se vea afectado."),
           h4("Razonablemente buena "),
           p("La calidad del aire es aceptable; sin embargo, la contaminación en este rango puede representar 
          un problema de salud moderado para un número muy pequeño de personas."),
           h4("Buena"),
           p("La calidad del aire es satisfactoria y presenta poco o ningún riesgo para la salud."),
           # como la tabla la hacemos con kable nos devuelve la tabla en lenguaje html
           # y por eso en lugar de tableOutput tenemos que usar htmlOutput()
           # en el server en lugar de renderTable utilizamos renderText
           htmlOutput("tabla2")
  )
)

salud_tab <- fluidPage(
  tabPanel("Salud",
           p("La contaminación del aire representa uno de los mayores peligros para el medio ambiente y la salud humana.
          Si los países logran reducir los niveles de contaminación atmosférica, podrían disminuir significativamente 
          la incidencia de enfermedades como accidentes cerebrovasculares, enfermedades cardíacas, cánceres de pulmón y 
          neumopatías crónicas y agudas, incluyendo el asma.Se trata de un efecto equivalente al de fumar tabaco."),
           p("Cerca de 374.831 personas cuentan con diagnóstico activo de asma en la Comunitat Valenciana. 
          Por provincias: 40.829 personas en Castellón, 199.633 en Valencia y 134.369 en Alicante. 
          El ozono (O3) es uno de los principales factores que causan asma (o la empeora), y el dióxido de nitrógeno (NO2) y el dióxido 
          de azufre (SO2) también pueden causar asma, síntomas bronquiales, inflamación pulmonar e insuficiencia pulmonar. Estos son 
          algunos de los contaminantes estudiados."),
           p("Los efectos combinados de la contaminación del aire ambiente y la del aire doméstico se asocian a 6,7 millones de 
          muertes prematuras cada año. Se estima que en 2019 la contaminación del aire ambiente (exterior) provocó en todo el 
          mundo 4,2 millones de muertes prematuras."),
           p("Es esencial implementar acciones para combatir la contaminación del aire, ya que ésta constituye el segundo factor 
          de riesgo más importante para las enfermedades no transmisibles, es crucial para proteger la salud pública."),
           p("Las Directrices Mundiales de la Organización Mundial de la Salud (OMS) sobre la Calidad del Aire son un conjunto de 
          recomendaciones a nivel global que establecen umbrales y límites para los principales contaminantes atmosféricos que 
          pueden afectar la salud. Estas directrices se desarrollan mediante un proceso transparente y basado en evidencia, lo 
          que garantiza su alta calidad metodológica. Además de definir valores para los contaminantes, las Directrices Mundiales 
          de la OMS también establecen metas intermedias para fomentar una disminución gradual de las concentraciones de 
          contaminantes, pasando de niveles elevados a niveles más bajos."),
           
           p("Para más información sobre los tipos de contaminantes y sus efectos en la salud, visita la página de la", 
             a("Organización Mundial de la Salud (OMS)", 
               href = "https://www.who.int/es/news-room/fact-sheets/detail/ambient-(outdoor)-air-quality-and-health"),"."),
           p("Referencias", 
             a("Generalitat Valenciana", 
               href = "https://comunica.gva.es/va/detalle?id=371592919&site=174859789"), "."),
           p("Referencias", 
             a("Cómo la contaminación del aire está destruyendo nuestra salud (OMS)", 
               href = "https://www.who.int/es/news-room/spotlight/how-air-pollution-is-destroying-our-health"), "."),
           p()
  )
)

consejos_tab <- fluidPage(
  tabPanel("Consejos",
           h2("Políticas para reducir la contaminación en el aire."),
           p("Tomar medidas contra la contaminación del aire, que es el segundo factor de riesgo para las 
                     enfermedades no transmisibles, es crucial para proteger la salud pública."),
           p("La mayoría de las fuentes de contaminación del aire exterior están más allá del control de las personas, 
                   lo que requiere la adopción de medidas concertadas por parte de las instancias normativas locales, nacionales 
                   y regionales que trabajan en sectores tales como el de la energía, el transporte, la gestión de desechos,
                   la planificación urbana y la agricultura."),
           p("Existen numerosos ejemplos de políticas que han obtenido buenos resultados en la reducción de la contaminación del aire:"),
           
           p(" •	En la",strong("industria:"), "utilización de tecnologías limpias que reducen las emisiones de las chimeneas industriales; gestión 
                   mejorada de desechos urbanos y agrícolas, incluida la recuperación del gas metano de los vertederos como una alternativa 
                   a la incineración (para utilizarlo como biogás)"),
           p(" •	En el ",strong("sector de la energía:"),"garantizar el acceso a soluciones asequibles de energía doméstica no contaminante para cocinar, 
                   generar calor y alumbrar."),
           p(" •	En el ",strong("transporte:"),": adopción de métodos limpios de generación de electricidad; priorización del transporte urbano rápido, 
                   las sendas peatonales y los carriles para bicicletas en las ciudades, así como el transporte interurbano de cargas y 
                   pasajeros por ferrocarril; utilización de vehículos pesados de motor diésel más limpios y vehículos y combustibles 
                   de bajas emisiones, especialmente combustibles con bajo contenido de azufre"),
           p(" •	En la ",strong("planificación urbana:"),"mejoramiento de la eficiencia energética de los edificios y promoción de ciudades más 
                   compactas y con más zonas verdes para lograr una mayor eficiencia"),
           p(" •	En la ",strong("generación de electricidad:"),"aumento del uso de combustibles de bajas emisiones y fuentes de energía renovable 
                   sin combustión (solar, eólica o hidroeléctrica); generación conjunta de calor y electricidad; y generación distribuida 
                   de energía (por ejemplo, generación de electricidad mediante redes pequeñas y paneles solares"),
           p(" •	En la ",strong("gestión de desechos municipales y agrícolas:"),"estrategias de reducción, separación, reciclado y reutilización o 
                   reelaboración de desechos, así como métodos mejorados de gestión biológica de desechos tales como la digestión anaeróbica 
                   para producir biogás, que constituyen alternativas viables y de bajo costo a la incineración de desechos sólidos; cuando 
                   no se pueda evitar la incineración, será crucial la utilización de tecnologías de combustión con rigurosos controles de emisión"),
           p(" •	En las ",strong("actividades de atención de la salud:"),"situar los servicios de salud en la vía del desarrollo con bajas emisiones de 
                   carbono puede contribuir a una prestación de servicios más resiliente y costoeficaz, además de reducir los riesgos medioambientales
                   para la salud de los pacientes, los trabajadores de la salud y la comunidad. Al apoyar políticas inocuas para el clima, el sector 
                   de la salud puede hacer gala de liderazgo público y a la vez mejorar la prestación de los servicios de salud."),
           p("Para más información, visita la página de la", 
             a("Organización Mundial de la Salud (OMS)", 
               href = "https://www.who.int/es/news-room/fact-sheets/detail/ambient-(outdoor)-air-quality-and-health"), "."),
  )
)

datos_tab <- fluidPage(
  tabPanel("Obtención de datos",
           h2("Datos de tráfico"),
           HTML("<p>Los datos del estado del tráfico los hemos obtenido a partir del
           <a href = 'https://valencia.opendatasoft.com/explore/dataset/estat-transit-temps-real-estado-trafico-tiempo-real/'>conjunto de datos del estado del tráfico</a> del
           <a href = 'https://valencia.opendatasoft.com/pages/home/'>Portal de Datos Abiertos del Ayuntamiento de Valencia</a>.
           El problema para acceder a estos datos es que solo aparecen en tiempo real en la página web sin opción de acceder al hisórico;
           se actualizan cada 3 minutos. Eso complica el uso de los mismos, ya que hace que no sea posible ver su evolución temporal.
           Para solucionar este problema hemos automatizado su descarga y almacenamiento a través de un servidor en la nube (mediante Google Cloud).
           La descarga se realiza cada hora todos los días y esto nos ha permitido poder tener un histórico reducido de los datos
           (apenas 1 semana, entre el 2 y 10 de mayo). Así es como hemos podido obtener los datos para posteriormente poder visualizar
           la evolución del tráfico en distintos días y momentos.</p>"),
           h2("Datos de contaminación del aire"),
           HTML("<p>Hemos obtenido 
           <a href = 'https://valencia.opendatasoft.com/explore/dataset/rvvcca/table/'>datos de calidad del aire</a> a partir del
           <a href = 'https://valencia.opendatasoft.com/pages/home/'>Portal de Datos Abiertos del Ayuntamiento de Valencia</a>.
           De esta fuente hemos conseguido los datos diarios de calidad aire 2004-2022 en la ciudad de Valencia, así como
           los datos georreferenciados de las estaciones de medida de la contaminación atmosférica
           <br>
           Sin embargo, para mejorar la calidad de nuestros datos hemos decidido también usar
           <a href = 'https://discomap.eea.europa.eu/map/fme/AirQualityExport.htm'>datos provenientes de la Unión Europea</a>.
           Esto se debe a que en esta fuente podemos obtener los datos por horas de las estaciones hasta dos días antes del día
           de nuestra petición y, además, algunos valores faltantes están ya imputados mediante algoritmos más sofisticados de
           lo que nosotros podríamos llegar a realizar.</p>")
  )
)