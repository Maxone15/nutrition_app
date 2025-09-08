# Líneas 199-461 del script original: UI de la página de generación de dietas
diet_ui <- function() {
# Pestaña de Generación de Dietas
tabPanel(
  title = "Generación de dietas", 
  value = "generar_dieta",
  
  # Activar shinyjs para funcionalidades dinámicas de UI
  useShinyjs(),
  
  fluidPage(
    tags$head(
      tags$style(
        HTML('
            #sidebar {
                background-color: #dec4de;
                border-radius: 10px;
                padding: 15px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }
            
            body, label, input, button, select { 
                font-family: "Arial";
            }
            
            .nutrition-summary {
                font-family: Arial;
                font-weight: bolder;
                background: radial-gradient(circle 985px at 2.1% 50.7%, #bde676 0%, rgba(61,212,186,1) 99.7%);
                padding: 10px;
                border-radius: 5px;
                margin-top: 15px;
            }
            
            .main-title {
                font-family: Arial;
                font-size: 25px;
                color: #fff;
                text-align: center;
                background: linear-gradient(111.6deg, rgba(47,169,210,1) -0.3%, rgba(9,32,67,1) 97.4%);
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 15px;
            }
            
            .error-message {
                color: #d9534f;
                font-weight: bold;
                padding: 10px;
                background-color: #f2dede;
                border: 1px solid #ebccd1;
                border-radius: 4px;
                margin: 10px 0;
            }
            
            .value-box {
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                margin-bottom: 20px;
                overflow: hidden;
            }
            
            .btn-download {
                background-color: #28a745;
                color: white;
                border: none;
                padding: 10px 15px;
                border-radius: 5px;
                font-weight: bold;
                margin: 15px 0;
                cursor: pointer;
                box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            }
            
            .btn-download:hover {
                background-color: #218838;
                box-shadow: 0 4px 8px rgba(0,0,0,0.3);
            }
            
            /* Estilo para las pestañas de dieta sugerida */
            .diet-tabs {
                margin-top: 20px;
            }
            
            .diet-tabs .nav-tabs {
                border-bottom: 2px solid #0C5A9D;
            }
            
            .diet-tabs .nav-tabs > li > a {
                margin-right: 2px;
                color: #555;
                background-color: #f8f9fa;
                border: 1px solid #ddd;
                border-radius: 4px 4px 0 0;
            }
            
            .diet-tabs .nav-tabs > li.active > a {
                color: #0C5A9D;
                background-color: #fff;
                border: 1px solid #0C5A9D;
                border-bottom-color: transparent;
                font-weight: bold;
            }
            
                        /* Estilos para métricas de calidad */
            .quality-metrics {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 10px;
                padding: 15px;
                margin: 15px 0;
                color: white;
            }
            
            .quality-metrics h4 {
                color: white;
                margin-bottom: 15px;
                text-align: center;
            }
            
            .quality-info {
                background-color: #f8f9fa;
                border-left: 4px solid #28a745;
                padding: 15px;
                margin: 15px 0;
                border-radius: 5px;
            }
            
            .quality-info ul {
                margin-bottom: 0;
            }
            
            .quality-info li {
                margin-bottom: 8px;
            }
            
            /* Estilos para controles de calidad */
            .quality-controls {
                background-color: #e8f4f8;
                border-radius: 8px;
                padding: 15px;
                margin: 10px 0;
                border: 1px solid #bee5eb;
            }
            
            .quality-controls h4 {
                color: #2c3e50;
                margin-bottom: 10px;
            }
          ')
      )
    ),
    
    # Estructura principal: panel lateral + panel principal
    sidebarLayout(
      # Panel lateral con controles de usuario
      sidebarPanel(
        id = "sidebar",
        width = 3,
        
        h3(
          strong("Ingrese sus datos"), 
          align = "center",
          style = "font-family: Arial; font-size: 20px;"
        ),
        
        # Datos personales
        selectInput(
          "sex", 
          "Seleccionar sexo", 
          selected = "M", 
          choices = c('Femenino' = 'F', 'Masculino' = 'M')
        ),
        
        numericInput(
          "size", 
          "Inserte su estatura en centímetros", 
          165, 
          min = 120, 
          max = 220
        ),
        
        numericInput(
          "weight", 
          "Inserte su peso en kilogramos", 
          65, 
          min = 50, 
          max = 200
        ),
        
        numericInput(
          "year",
          "Inserte su edad en años", 
          31, 
          min = 18, 
          max = 70
        ),
        
        selectInput(
          "act", 
          "Seleccione su nivel actividad física",
          choices = list(
            "Sedentario" = 1.2,
            "Actividad leve: 1 - 3 veces a la semana" = 1.375,
            "Ejercicio moderado: 3 - 5 veces a la semana" = 1.55,
            "Entrenamiento completo: 6 - 7 veces a la semana" = 1.725,
            "Trabajo de impacto, entrenos 2 veces a la semana y entrenamiento de fuerza" = 1.9
          ), 
          selected = 1.55
        ),
        
        hr(),
        
        # Selector de grupos de alimentos
        pickerInput(
          "grupo", 
          "Seleccionar grupo de alimentos", 
          choices = grupos_alimentos, 
          multiple = TRUE, 
          selected = grupos_alimentos,
          options = list(
            `actions-box` = TRUE,
            `selected-text-format` = "count > 3"
          )
        ),
        
        hr(),
        
        # Selector de nutrientes a minimizar
        pickerInput(
          "nutrientes", 
          "Seleccionar nutrientes a minimizar",
          choices = list(
            "Carga Glucémica" = "CG",
            "Saturados" = "AG_saturados",
            "Sodio" = "Sodio",
            "Colesterol" = "Colesterol",
            "Azúcar" = "Azúcar"
          ),
          selected = c("CG", "AG_saturados"),
          multiple = TRUE,
          options = list(`actions-box` = TRUE)
        ),
        
        # UI generada dinámicamente para pesos de nutrientes
        uiOutput("pesos_nutrientes"),
        
        # Controles de calidad dietética
        div(
          class = "quality-controls",
          uiOutput("controles_calidad")
        ),
        
        hr(),
        
        # Botón para generar dieta
        actionButton(
          "calcular", 
          "Generar Dieta", 
          class = "btn-primary btn-block",
          style = "margin-top: 15px; font-size: 16px; padding: 10px;"
        )
      ),
      
      # Panel principal con resultados
      mainPanel(
        width = 9,
        
        # Título principal
        h3(
          strong("Tu dieta sugerida"),
          class = "main-title"
        ),
        
        # ValueBoxes para GER y Energía Total
        fluidRow(
          column(6,
                 valueBoxOutput("ger_box", width = 12)
          ),
          column(6,
                 valueBoxOutput("energy_box", width = 12)
          )
        ),
        
        # Espacio para mensajes de error
        uiOutput("mensaje_error"),
        
        # Tabbed layout para mostrar distintos aspectos de la dieta
        tabsetPanel(
          id = "diet_tabs",
          
          # Pestaña de resultados principales
          tabPanel(
            "Alimentos Recomendados",
            
            # Botones de descarga
            fluidRow(
              column(12,
                     uiOutput("download_buttons")
              )
            ),
            
            # Tabla de resultados
            DT::DTOutput('Tabla_equivalentes')
          ),
          
          # Pestaña de análisis nutricional
          tabPanel(
            "Análisis Nutricional",
            
            # Visualización de macronutrientes
            conditionalPanel(
              condition = "output.tiene_datos",
              fluidRow(
                column(6,
                       h4("Distribución de macronutrientes", align = "center"),
                       plotOutput("grafico_macros")
                ),
                column(6,
                       h4("Distribución calórica por grupo de alimentos", align = "center"),
                       plotOutput("grafico_grupos")
                )
              ),
              hr(),
              h4("Resumen nutricional", align = "center"),
              DT::DTOutput("tabla_resumen_nutrientes")
            )
          ),
          
          # Nueva pestaña para métricas de calidad
          tabPanel(
            "Métricas de Calidad",
            conditionalPanel(
              condition = "output.tiene_datos",
              
              # Métricas de calidad
              div(
                class = "quality-metrics",
                h4("Métricas de Calidad Dietética"),
                uiOutput("quality_metrics")
              ),
              
              # Información sobre las métricas
              div(
                class = "quality-info",
                uiOutput("quality_info")
              ),
              
              # Gráfico adicional de calidad
              fluidRow(
                column(12,
                       h4("Evaluación de Calidad Dietética", align = "center"),
                       plotOutput("grafico_calidad", height = "400px")
                )
              )
            )
          ),
          
          # Pestaña de recomendaciones (sin cambios)
          tabPanel(
            "Recomendaciones",
            conditionalPanel(
              condition = "output.tiene_datos",
              div(
                style = "background-color: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px;",
                h4("Recomendaciones para personas con diabetes tipo 2", 
                   style = "color: #0C5A9D; border-bottom: 1px solid #ddd; padding-bottom: 10px;"),
                tags$ul(
                  tags$li(
                    strong("Distribución de comidas:"), 
                    " Distribuya los alimentos sugeridos en 5-6 comidas pequeñas a lo largo del día para mantener estables los niveles de glucosa."
                  ),
                  tags$li(
                    strong("Combinación de alimentos:"), 
                    " Siempre combine carbohidratos con proteínas o grasas saludables para reducir el impacto en la glucemia."
                  ),
                  tags$li(
                    strong("Fibra:"), 
                    " Priorice alimentos ricos en fibra para mejorar el control glucémico."
                  ),
                  tags$li(
                    strong("Hidratación:"), 
                    " Consuma al menos 2 litros de agua al día."
                  ),
                  tags$li(
                    strong("Actividad física:"), 
                    " Complemente esta dieta con al menos 150 minutos de actividad física moderada semanal."
                  ),
                  tags$li(
                    strong("Monitoreo:"), 
                    " Verifique sus niveles de glucosa antes y después de las comidas para entender cómo su cuerpo responde a diferentes alimentos."
                  )
                ),
                
                h4("Sugerencia de distribución diaria", 
                   style = "color: #0C5A9D; border-bottom: 1px solid #ddd; padding-bottom: 10px; margin-top: 20px;"),
                
                # Tabla sugerida de distribución de comidas
                DT::DTOutput("tabla_distribucion")
              )
            )
          )
        )
      )
    )
  )
)
}