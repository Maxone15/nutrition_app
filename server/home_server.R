# Lógica del servidor para la página de inicio
home_server <- function(input, output, session) {
  # Manejar el botón de navegación a la página de generación de dietas
  observeEvent(input$ir_a_generar, {
    updateTabsetPanel(session, "mainTabset", selected = "generar_dieta")
  })
}