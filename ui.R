ui <- dashboardPage(
  dashboardHeader(title = "Valencia AQ"),
  
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      menuItem("Tráfico y calidad del aire", tabName = "AQ_traffic"),
      menuItem("Gráficos", tabName = "graficos"),
      menuItem("Estadísticas", tabName = "stats"), 
      menuItem("Información", tabName = "info")
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

