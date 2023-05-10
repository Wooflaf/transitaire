ui <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      id = "tabs",
      menuItem("Tráfico y calidad del aire", tabName = "AQ_traffic", icon = icon("car-side", class = "fa-lg")),
      menuItem("Gráficos", tabName = "graficos", icon = icon("chart-column", class = "fa-lg")),
      menuItem("Live", tabName = "live", icon = icon("refresh", class = "fa-duotone fa-compass fa-spin fa-lg")), 
      menuItem("Información", tabName = "info", icon = icon("circle-info", class = "fa-lg"),
               menuSubItem("Más Información", tabName = "info"),
               menuSubItem("Salud", tabName = "salud"),
               menuSubItem("Consejos", tabName = "consejos"))
    )),
  
  dashboardBody(
    useWaiter(),
    waiter_show_on_load(html = waiting_screen, color = "#edf1f5"),
    use_cicerone(),
    styles,
    tabItems(
      tabItem(tabName = "AQ_traffic", AQ_traffic_tab),
      tabItem(tabName = "graficos",
              h2("Distribución de los contaminantes en valencia"),
              graficos_tab),
      tabItem(tabName = "live", live), 
      tabItem(tabName = "info", h2("Más información"), info_tab),
      tabItem(tabName = "salud", h2("Salud"), salud_tab),
      tabItem(tabName = "consejos", h2("Consejos"), consejos_tab)
    )
  )
)