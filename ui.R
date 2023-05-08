ui <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      menuItem("Tráfico y calidad del aire", tabName = "AQ_traffic", icon = icon("car-side")),
      menuItem("Gráficos", tabName = "graficos", icon = icon("chart-column")),
      menuItem("Live", tabName = "live", icon = icon("arrows-rotate")), 
      menuItem("Información", tabName = "info", icon = icon("circle-info"))
    )),
  
  dashboardBody(
    useWaiter(),
    waiter_show_on_load(html = waiting_screen, color = "#edf1f5"),
    use_cicerone(),
    styles,
    tabItems(
      tabItem(tabName = "AQ_traffic", AQ_traffic_tab),
      tabItem(tabName = "graficos"),
      tabItem(tabName = "stats"), 
      tabItem(tabName = "info")
    )
  )
)

