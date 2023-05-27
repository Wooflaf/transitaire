ui <- dashboardPage(
  title = "VLC TrànsitAire",
  options = list(sidebarExpandOnHover = TRUE),
  dashboardHeader(title = div(icon("cloud"), "VLC TrànsitAire"),
                  dropdownMenu_contact, dropdownMenu_share),
  
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      id = "tabs",
      menuItem("Tráfico y calidad del aire", tabName = "AQ_traffic", icon = icon("car-side", class = "fa-lg")),
      menuItem("Gráficos", tabName = "graficos", icon = icon("chart-column", class = "fa-lg")),
      menuItem("En directo", tabName = "live",
               icon = icon("refresh",
                           class = "fa-solid fa-circle fa-fade fa-lg",
                           style = "color: #e14747;")
               ),
      menuItem("Información", tabName = "info", icon = icon("circle-info", class = "fa-lg"),
               menuSubItem("Más Información", tabName = "info"),
               menuSubItem("Salud", tabName = "salud"),
               menuSubItem("Consejos", tabName = "consejos"),
               menuSubItem("Obtención de datos", tabName = "datos"))
    )),
  
  dashboardBody(
    useWaiter(),
    autoWaiter(id = c("heatmap"),
               html = div(style = "color: #37a4d7;",
                          spin_loaders(14, color = "#3d8cbc"),
                          br(), br(),
                          h4("Cargando...")),
               color = "#ecf0f5"),
    waiter_show_on_load(html = waiting_screen, color = "#edf1f5"),
    use_cicerone(),
    styles,
    tabItems(
      tabItem(tabName = "AQ_traffic", AQ_traffic_tab),
      tabItem(tabName = "graficos",
              h2("Visualización de los contaminantes en Valencia"),
              graficos_tab),
      tabItem(tabName = "live", live), 
      tabItem(tabName = "info", h2("Más información"), info_tab),
      tabItem(tabName = "salud", h2("Salud"), salud_tab),
      tabItem(tabName = "consejos", h2("Consejos"), consejos_tab),
      tabItem(tabName = "datos", h2("Obtención de datos"), datos_tab)
    )
  )
)