# ------------------------------------------------------------------------------
# Definir UI para la aplicación
# ------------------------------------------------------------------------------
home_ui <- function() {
  # Pestaña de Inicio
  tabPanel(
    title = "Home", 
    value = "home",
    
    # Banner con logo e información introductoria
    h1(
      img(
        src = "barra.png", 
        height = '95%', 
        width = '99.9%',
        style = "margin: 0px 0px"
      ),
      strong(
        "Dieta óptima",
        style = "color: #0C5A9D"
      ),
      "con programación lineal",
      style = paste(
        "font-family: Arial;",
        "font-weight: normal;",
        "font-size: 45px;",
        "background: linear-gradient(109.6deg, rgba(255,255,255,1) 2%, rgba(199,199,199,1) 99.9%)"
      )
    ),
    
    # Información sobre la aplicación
    fluidRow(
      column(8, offset = 2,
             div(
               class = "jumbotron",
               style = "background-color: #f8f9fa; padding: 30px; border-radius: 10px;",
               h3("Este aplicativo fue construido tomando información del", 
                  strong("Sistema Mexicano de Alimentos Equivalentes",
                         style = "color: #0C5A9D")),
               h3("Utilizamos programación lineal para optimizar la dieta a consumir a través del método Simplex"),
               h3("El modelo matemático fue definido para minimizar nutrientes seleccionados mientras se cumplen los requerimientos nutricionales"),
               hr(),
               h4("Especialmente útil para personas con diabetes tipo 2", style = "color: #28a745;"),
               p(style = "font-size: 18px;",
                 "Esta aplicación ayuda a generar planes de alimentación personalizados que pueden:",
                 tags$ul(
                   tags$li("Minimizar la carga glucémica de los alimentos"),
                   tags$li("Controlar la ingesta de grasas saturadas"),
                   tags$li("Mantener niveles adecuados de nutrientes esenciales"),
                   tags$li("Ayudar al manejo del peso corporal")
                 )
               ),
               actionButton("ir_a_generar", "Generar mi dieta personalizada", 
                            class = "btn-success btn-lg", 
                            style = "margin-top: 15px;")
             )
      )
    )
  )}