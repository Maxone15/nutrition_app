# Archivo principal que junta todo
source("global.R")  # Cargar bibliotecas y configuración global

# Cargar módulos
source("modules/load_data.R")
source("modules/calculations.R")
source("modules/optimization_v2.R")
#source("modules/reporting.R")

# Cargar componentes de UI
source("ui/home_ui.R")
source("ui/diet_ui_v2.R")

# Cargar lógica del servidor
source("server/home_server.R")
source("server/diet_server_v2.R")

# Inicializar datos
food_data <- initialize_food_data()

# Definir UI completa
ui <- navbarPage(
  title = " ",
  theme = shinytheme("cosmo"),
  id = "mainTabset",
  home_ui(),
  diet_ui()
)

# Definir servidor
server <- function(input, output, session) {
  # Iniciar módulos de servidor
  home_server(input, output, session)
  diet_server(input, output, session, food_data)
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)