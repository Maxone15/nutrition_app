# ------------------------------------------------------------------------------
# Definir lógica del servidor
# ------------------------------------------------------------------------------
diet_server <- function(input, output, session, food_data) {
  
  # Valores reactivos para los cálculos energéticos
  energy_values <- reactive({
    # Calcular GER
    ger <- calculate_ger(
      sex = input$sex,
      weight = input$weight,
      height = input$size,
      age = input$year
    )
    
    # Calcular gasto energético total
    total_energy <- ger * as.numeric(input$act)
    
    # Calcular rangos de macronutrientes
    macro_ranges <- calculate_macro_ranges(ger, total_energy)
    
    # Devolver todos los valores calculados
    list(
      ger = round(ger, 0),
      total_energy = round(total_energy, 0),
      macro_ranges = macro_ranges
    )
  })
  
  # UI dinámica para pesos de nutrientes
  output$pesos_nutrientes <- renderUI({
    if (is.null(input$nutrientes) || length(input$nutrientes) == 0) {
      return(helpText("Seleccione al menos un nutriente para minimizar"))
    }
    
    # Crear sliders para cada nutriente seleccionado
    lapply(input$nutrientes, function(nutriente) {
      sliderInput(
        inputId = paste0("peso_", nutriente), 
        label = paste("Peso para", switch(
          nutriente,
          "CG" = "Carga Glucémica",
          "AG_saturados" = "Saturados",
          "Sodio" = "Sodio",
          "Colesterol" = "Colesterol",
          "Azúcar" = "Azúcar",
          nutriente
        )), 
        min = 0, 
        max = 1, 
        value = 1/length(input$nutrientes), 
        step = 0.05
      )
    })
  })
  
  # ValueBox para GER
  output$ger_box <- renderValueBox({
    energy <- energy_values()
    valueBox(
      paste0(energy$ger, " kcal"),
      "Gasto Energético en Reposo (GER)",
      icon = icon("fire"),
      color = "blue"
    )
  })
  
  # ValueBox para Gasto Energético Total
  output$energy_box <- renderValueBox({
    energy <- energy_values()
    valueBox(
      paste0(energy$total_energy, " kcal"),
      "Gasto Energético Total",
      icon = icon("bolt"),
      color = "green"
    )
  })
  
  # Estado de la dieta - reactivo para guardar resultados
  diet_result <- reactiveVal(NULL)
  diet_summary <- reactiveVal(NULL)
  
  # Reaccionar al botón de cálculo
  observeEvent(input$calcular, {
    # Validar entradas
    if (length(input$grupo) == 0) {
      output$mensaje_error <- renderUI({
        div(class = "error-message", "Debe seleccionar al menos un grupo de alimentos")
      })
      diet_result(NULL)
      return()
    }
    
    if (length(input$nutrientes) == 0) {
      output$mensaje_error <- renderUI({
        div(class = "error-message", "Debe seleccionar al menos un nutriente para minimizar")
      })
      diet_result(NULL)
      return()
    }
    
    # Mostrar indicador de carga
    withProgress(message = "Optimizando dieta...", {
      
      # Limpiar mensajes de error anteriores
      output$mensaje_error <- renderUI({ NULL })
      
      # Filtrar alimentos según grupos seleccionados
      alimentos_seleccionados <- M %>% filter(Grupo %in% input$grupo)
      
      # Obtener valores energéticos calculados
      energy <- energy_values()
      
      # Preparar restricciones para la optimización
      constraints <- list(
        energy = list(min = energy$ger, max = energy$total_energy),
        protein = energy$macro_ranges$protein,
        carbs = energy$macro_ranges$carbs,
        fat = energy$macro_ranges$fat
      )
      
      # Ejecutar optimización
      result <- optimize_diet(
        foods_df = alimentos_seleccionados,
        objective_nutrients = input$nutrientes,
        weights = input,
        constraints = constraints
      )
      
      # Guardar resultados
      diet_result(result)
      
      # Verificar si se encontró solución
      if (is.null(result)) {
        output$mensaje_error <- renderUI({
          div(
            class = "error-message", 
            "No se pudo encontrar una dieta que cumpla con todas las restricciones. 
            Intente seleccionar más grupos de alimentos o ajustar sus requisitos."
          )
        })
      } else {
        # Calcular resumen nutricional por grupo de alimentos
        summary_by_group <- result %>%
          filter(Alimento != "Total") %>%
          left_join(M %>% select(Alimento, Grupo), by = "Alimento") %>%
          group_by(Grupo) %>%
          summarise(
            `Calorías` = sum(`Energia Total`),
            `% Calorías` = round(sum(`Energia Total`) / sum(result$`Energia Total`[result$Alimento != "Total"]) * 100, 1),
            `Proteínas (g)` = sum(`Proteina Total`),
            `Carbohidratos (g)` = sum(`Carbohidratos Totales`),
            `Lípidos (g)` = sum(`Lipidos Totales`),
            `Número de Alimentos` = n()
          ) %>%
          arrange(desc(`Calorías`))
        
        diet_summary(summary_by_group)
      }
    })
  })
  
  # Señal reactiva para indicar si hay datos disponibles
  output$tiene_datos <- reactive({
    !is.null(diet_result())
  })
  outputOptions(output, "tiene_datos", suspendWhenHidden = FALSE)
  
  # Botones de descarga
  output$download_buttons <- renderUI({
    if (is.null(diet_result())) {
      return(NULL)
    }
    
    fluidRow(
      column(4,
             downloadButton("download_csv", "Descargar como CSV", 
                            class = "btn-download", 
                            icon = icon("file-csv"))
      ),
      column(4,
             downloadButton("download_excel", "Descargar como Excel", 
                            class = "btn-download", 
                            icon = icon("file-excel"))
      ),
      column(4,
             downloadButton("download_word", "Descargar como Word", 
                            class = "btn-download", 
                            icon = icon("file-word"))
      )
    )
  })
  
  # Handlers para descargar archivos
  output$download_csv <- downloadHandler(
    filename = function() {
      paste("dieta_optimizada_", format(Sys.Date(), "%Y%m%d"), ".csv", sep = "")
    },
    content = function(file) {
      # Extraer solo las columnas relevantes para el usuario
      diet_data <- diet_result() %>%
        select(Alimento, Cantidad_sugerida, Unidad, Racion)
      
      # Añadir una fila con información personal
      personal_info <- data.frame(
        Alimento = paste("Dieta para persona", ifelse(input$sex == "M", "masculino", "femenino"), 
                         "de", input$year, "años,", input$weight, "kg,", input$size, "cm"),
        Cantidad_sugerida = paste("GER:", energy_values()$ger, "kcal"),
        Unidad = paste("GET:", energy_values()$total_energy, "kcal"),
        Racion = format(Sys.Date(), "%d/%m/%Y")
      )
      
      # Combinar datos
      export_data <- rbind(personal_info, diet_data)
      
      # Exportar a CSV
      write.csv(export_data, file, row.names = FALSE)
    }
  )
  
  output$download_excel <- downloadHandler(
    filename = function() {
      paste("dieta_optimizada_", format(Sys.Date(), "%Y%m%d"), ".xlsx", sep = "")
    },
    content = function(file) {
      # Preparar los datos para Excel
      result_for_excel <- diet_result()
      
      # Extraer solo las columnas relevantes para el usuario
      diet_data <- result_for_excel %>%
        select(Alimento, Cantidad_sugerida, Unidad, Racion, 
               `Energia Total`, `Proteina Total`, `Lipidos Totales`, `Carbohidratos Totales`)
      
      # Añadir una hoja con información del usuario
      user_info <- data.frame(
        Variable = c("Sexo", "Edad", "Peso", "Estatura", "Nivel de actividad", 
                     "GER", "GET", "Fecha de generación"),
        Valor = c(
          ifelse(input$sex == "M", "Masculino", "Femenino"),
          paste(input$year, "años"),
          paste(input$weight, "kg"),
          paste(input$size, "cm"),
          as.character(input$act),
          paste(energy_values()$ger, "kcal"),
          paste(energy_values()$total_energy, "kcal"),
          format(Sys.Date(), "%d/%m/%Y")
        )
      )
      
      # Crear lista de hojas para Excel
      excel_data <- list("Dieta Optimizada" = diet_data, 
                         "Información del Usuario" = user_info)
      
      if (!is.null(diet_summary())) {
        excel_data[["Resumen por Grupo"]] <- diet_summary()
      }
      
      # Exportar a Excel
      writexl::write_xlsx(excel_data, file)
    }
  )
  
  output$download_word <- downloadHandler(
    filename = function() {
      paste("dieta_optimizada_", format(Sys.Date(), "%Y%m%d"), ".docx", sep = "")
    },
    content = function(file) {
      # Crear archivo temporal para el reporte
      tempReport <- file.path(tempdir(), "report.Rmd")
      
      # Escribir el contenido del reporte al archivo temporal
      writeLines(word_report_content, tempReport)
      
      # Preparar los datos para el reporte
      # Es importante que los parámetros coincidan exactamente con los declarados en el YAML
      report_params <- list(
        sex = input$sex,
        year = input$year,
        weight = input$weight,
        size = input$size,
        activity = as.character(input$act),
        ger = energy_values()$ger,
        total_energy = energy_values()$total_energy,
        diet_data = diet_result()
      )
      
      # Renderizar el reporte como Word
      rmarkdown::render(tempReport, 
                        output_file = file,
                        params = report_params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  # Texto para el reporte Rmd en formato Word con estilos profesionales
  word_report_content <- '
---
title: "Dieta Personalizada Optimizada"
date: "`r Sys.Date()`"
output:
  word_document:
    reference_docx: default
    toc: false
    toc_depth: 2
params:
  sex: "M"
  year: 30
  weight: 70
  size: 170
  activity: 1.55
  ger: 1700
  total_energy: 2000
  diet_data: NULL
---

```{r setup, include=FALSE, echo=FALSE}
knitr::opts_chunk$set(echo = FALSE)
library(knitr)
library(kableExtra)
library(dplyr)
library(flextable)
```

# Información del Usuario {.tabset}

```{r user_info, echo=FALSE}
user_info <- data.frame(
  Variable = c("Sexo", "Edad", "Peso", "Estatura", "Nivel de actividad", 
              "GER (Gasto Energético en Reposo)", "GET (Gasto Energético Total)"),
  Valor = c(
    ifelse(params$sex == "M", "Masculino", "Femenino"),
    paste(params$year, "años"),
    paste(params$weight, "kg"),
    paste(params$size, "cm"),
    as.character(params$activity),
    paste(params$ger, "kcal"),
    paste(params$total_energy, "kcal")
  )
)

ft <- flextable(user_info)
ft <- set_header_labels(ft, Variable = "Parámetro", Valor = "Valor")
ft <- theme_box(ft)
ft <- bold(ft, part = "header")
ft <- bg(ft, bg = "#f5f5f5", part = "header")
ft <- autofit(ft)
ft
```

# Dieta Recomendada

```{r diet_table, echo=FALSE}
# Verificar que diet_data no sea NULL
if (!is.null(params$diet_data)) {
  # Mostrar solo las columnas relevantes
  diet_table <- params$diet_data %>%
    select(Alimento, Cantidad_sugerida, Unidad, Racion, `Energia Total`)
  
  ft_diet <- flextable(diet_table)
  ft_diet <- set_header_labels(
    ft_diet, 
    Alimento = "Alimento", 
    Cantidad_sugerida = "Cantidad", 
    Unidad = "Unidad", 
    Racion = "Raciones",
    `Energia Total` = "Energía (kcal)"
  )
  ft_diet <- theme_box(ft_diet)
  ft_diet <- bold(ft_diet, part = "header")
  ft_diet <- bg(ft_diet, bg = "#f5f5f5", part = "header")
  ft_diet <- autofit(ft_diet)
  ft_diet
} else {
  cat("No hay datos disponibles para mostrar la dieta recomendada.")
}
```

# Recomendaciones para personas con diabetes tipo 2

1. **Distribución de comidas:** Distribuya los alimentos sugeridos en 5-6 comidas pequeñas a lo largo del día para mantener estables los niveles de glucosa.

2. **Combinación de alimentos:** Siempre combine carbohidratos con proteínas o grasas saludables para reducir el impacto en la glucemia.

3. **Fibra:** Priorice alimentos ricos en fibra para mejorar el control glucémico.

4. **Hidratación:** Consuma al menos 2 litros de agua al día.

5. **Actividad física:** Complemente esta dieta con al menos 150 minutos de actividad física moderada semanal.

6. **Monitoreo:** Verifique sus niveles de glucosa antes y después de las comidas para entender cómo su cuerpo responde a diferentes alimentos.

# Análisis Nutricional

```{r nutrient_summary, echo=FALSE}
if (!is.null(params$diet_data)) {
  # Resumen de macronutrientes
  if ("Proteina Total" %in% colnames(params$diet_data) && 
      "Lipidos Totales" %in% colnames(params$diet_data) && 
      "Carbohidratos Totales" %in% colnames(params$diet_data)) {
    
    total_protein <- sum(params$diet_data$`Proteina Total`, na.rm = TRUE)
    total_lipids <- sum(params$diet_data$`Lipidos Totales`, na.rm = TRUE)
    total_carbs <- sum(params$diet_data$`Carbohidratos Totales`, na.rm = TRUE)
    total_energy <- sum(params$diet_data$`Energia Total`, na.rm = TRUE)
    
    # Calcular distribución de macronutrientes
    protein_pct <- round(total_protein * 4 / total_energy * 100, 1)
    lipids_pct <- round(total_lipids * 9 / total_energy * 100, 1)
    carbs_pct <- round(total_carbs * 4 / total_energy * 100, 1)
    
    nutrient_summary <- data.frame(
      Nutriente = c("Proteínas", "Lípidos", "Carbohidratos"),
      Cantidad = c(
        paste(round(total_protein, 1), "g"),
        paste(round(total_lipids, 1), "g"),
        paste(round(total_carbs, 1), "g")
      ),
      `Porcentaje del total energético` = c(
        paste0(protein_pct, "%"),
        paste0(lipids_pct, "%"),
        paste0(carbs_pct, "%")
      ),
      `Calorías aportadas` = c(
        paste(round(total_protein * 4, 1), "kcal"),
        paste(round(total_lipids * 9, 1), "kcal"),
        paste(round(total_carbs * 4, 1), "kcal")
      )
    )
    
    ft_nutrients <- flextable(nutrient_summary)
    ft_nutrients <- theme_box(ft_nutrients)
    ft_nutrients <- bold(ft_nutrients, part = "header")
    ft_nutrients <- bg(ft_nutrients, bg = "#f5f5f5", part = "header")
    ft_nutrients <- autofit(ft_nutrients)
    ft_nutrients
  }
}
```

# Nota importante

Esta dieta fue generada utilizando un algoritmo de optimización basado en programación lineal. Consulte con un profesional de la salud antes de implementar cualquier cambio significativo en su alimentación.

---

*Documento generado el `r format(Sys.Date(), "%d de %B de %Y")`*
'

# Renderizar tabla de resultados
output$Tabla_equivalentes <- DT::renderDT({
  # Obtener datos de la dieta calculada
  tab_data <- diet_result()
  
  # Si no hay resultados, mostrar tabla vacía
  if (is.null(tab_data)) {
    return(NULL)
  }
  
  # Seleccionar columnas más relevantes para la primera vista
  simplified_data <- tab_data %>%
    select(Alimento, Cantidad_sugerida, Unidad, Racion, `Energia Total`)
  
  # Crear tabla interactiva con formato personalizado
  datatable(
    simplified_data, 
    rownames = FALSE, 
    colnames = c(
      'Alimento' = 'Alimento',
      'Cantidad' = 'Cantidad_sugerida',
      'Unidad' = 'Unidad',
      'Raciones' = 'Racion',
      'Calorías (kcal)' = 'Energia Total'
    ), 
    options = list(
      # JavaScript para estilizar el encabezado de la tabla
      initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({background: 'linear-gradient(111.6deg, rgba(47,169,210,1) -0.3%, rgba(9,32,67,1) 97.4%)', 'color': '#fff'});",
        "}"
      ),
      pageLength = 15,
      lengthMenu = c(10, 15, 20, 30),
      autoWidth = TRUE,
      scrollX = TRUE
    )
  ) %>%
    formatRound(
      columns = 'Calorías (kcal)',
      digits = 1
    ) %>%
    formatStyle(
      'Alimento',
      target = 'row',
      backgroundColor = styleEqual("Total", "#e6f7ff")
    )
})

# Gráfico de macronutrientes
output$grafico_macros <- renderPlot({
  # Obtener datos de la dieta calculada
  tab_data <- diet_result()
  
  # Si no hay resultados, no mostrar gráfico
  if (is.null(tab_data)) {
    return(NULL)
  }
  
  # Obtener totales de la última fila
  if (nrow(tab_data) <= 1) return(NULL)
  
  totals_row <- tab_data[nrow(tab_data), ]
  
  # Preparar datos para el gráfico
  macros_data <- data.frame(
    Nutriente = c("Proteínas", "Lípidos", "Carbohidratos"),
    Gramos = c(
      totals_row$`Proteina Total`, 
      totals_row$`Lipidos Totales`, 
      totals_row$`Carbohidratos Totales`
    ),
    Calorias = c(
      totals_row$`Proteina Total` * 4,
      totals_row$`Lipidos Totales` * 9,
      totals_row$`Carbohidratos Totales` * 4
    )
  )
  
  # Calcular porcentajes
  total_calorias <- sum(macros_data$Calorias)
  macros_data$Porcentaje <- macros_data$Calorias / total_calorias * 100
  
  # Crear gráfico de barras mejorado
  ggplot(macros_data, aes(x = "", y = Porcentaje, fill = Nutriente)) +
    geom_bar(stat = "identity", width = 1) +
    geom_text(aes(label = paste0(round(Porcentaje, 1), "%\n", Gramos, "g")), 
              position = position_stack(vjust = 0.5), color = "black", size = 6) +
    coord_polar("y", start = 0) +
    labs(title = "Distribución de Macronutrientes",
         fill = "Nutriente",
         x = NULL,
         y = NULL) +
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
      legend.position = "bottom"
    ) +
    scale_fill_manual(values = c("Proteínas" = "#5B9BD5", 
                                 "Lípidos" = "#ED7D31", 
                                 "Carbohidratos" = "#70AD47"))
})

# Gráfico de distribución por grupos de alimentos
output$grafico_grupos <- renderPlot({
  # Verificar si hay datos disponibles
  if (is.null(diet_summary())) {
    return(NULL)
  }
  
  # Crear una etiqueta para marcar grupos relevantes
  summary_with_relevance <- diet_summary() %>%
    mutate(relevante = `% Calorías` >= 5)
  
  # Crear grupo "Otros" mediante summarize
  otros <- summary_with_relevance %>%
    filter(!relevante) %>%
    summarize(
      Grupo = "Otros",
      `Calorías` = sum(`Calorías`),
      `% Calorías` = sum(`% Calorías`),
      `Proteínas (g)` = sum(`Proteínas (g)`),
      `Carbohidratos (g)` = sum(`Carbohidratos (g)`),
      `Lípidos (g)` = sum(`Lípidos (g)`),
      `Número de Alimentos` = sum(`Número de Alimentos`),
      relevante = TRUE
    )
  
  # Combinar los grupos relevantes con "Otros"
  data_para_grafico <- bind_rows(
    filter(summary_with_relevance, relevante),
    otros
  )
  
  # Crear gráfico de pay mejorado
  ggplot(data_para_grafico, aes(x = "", y = `% Calorías`, fill = Grupo)) +
    geom_bar(stat = "identity", width = 1) +
    geom_text(aes(label = paste0("\n", round(`% Calorías`, 1), "%")), 
              position = position_stack(vjust = 0.5), 
              color = "black", size = 6) +
    coord_polar("y", start = 0) +
    labs(title = "Distribución por grupos de alimentos",
         fill = "Grupo de alimentos",
         x = NULL,
         y = NULL) +
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
      legend.position = "bottom"
    ) +
    scale_fill_brewer(palette = "Set2")
})

# Tabla resumen de nutrientes
output$tabla_resumen_nutrientes <- DT::renderDT({
  # Obtener datos de la dieta calculada
  tab_data <- diet_result()
  
  # Si no hay resultados, no mostrar tabla
  if (is.null(tab_data)) {
    return(NULL)
  }
  
  # Obtener fila de totales
  totals_row <- tab_data[nrow(tab_data), ]
  
  # Crear dataframe de resumen
  resumen <- data.frame(
    Nutriente = c("Energía total", "Proteínas", "Carbohidratos", "Lípidos", "Colesterol", "Sodio", "Carga Glucémica"),
    Cantidad = c(
      paste0(round(totals_row$`Energia Total`, 0), " kcal"),
      paste0(round(totals_row$`Proteina Total`, 1), " g (", 
             round((totals_row$`Proteina Total` * 4 / totals_row$`Energia Total`) * 100, 1), "%)"),
      paste0(round(totals_row$`Carbohidratos Totales`, 1), " g (", 
             round((totals_row$`Carbohidratos Totales` * 4 / totals_row$`Energia Total`) * 100, 1), "%)"),
      paste0(round(totals_row$`Lipidos Totales`, 1), " g (", 
             round((totals_row$`Lipidos Totales` * 9 / totals_row$`Energia Total`) * 100, 1), "%)"),
      paste0(round(totals_row$`Colesterol Total`, 1), " mg"),
      paste0(round(totals_row$`Sodio Total`, 1), " mg"),
      paste0(round(totals_row$`CG Totales`, 1))
    ),
    Recomendación = c(
      paste0(energy_values()$ger, " - ", energy_values()$total_energy, " kcal"),
      "10-35% de la energía total",
      "45-65% de la energía total",
      "20-35% de la energía total",
      "< 300 mg/día",
      "< 2300 mg/día",
      "< 80 por día (menor es mejor)"
    ),
    Estado = c(
      ifelse(totals_row$`Energia Total` >= energy_values()$ger && 
               totals_row$`Energia Total` <= energy_values()$total_energy, 
             "Adecuado", "Revisar"),
      ifelse((totals_row$`Proteina Total` * 4 / totals_row$`Energia Total`) * 100 >= 10 && 
               (totals_row$`Proteina Total` * 4 / totals_row$`Energia Total`) * 100 <= 35, 
             "Adecuado", "Revisar"),
      ifelse((totals_row$`Carbohidratos Totales` * 4 / totals_row$`Energia Total`) * 100 >= 45 && 
               (totals_row$`Carbohidratos Totales` * 4 / totals_row$`Energia Total`) * 100 <= 65, 
             "Adecuado", "Revisar"),
      ifelse((totals_row$`Lipidos Totales` * 9 / totals_row$`Energia Total`) * 100 >= 20 && 
               (totals_row$`Lipidos Totales` * 9 / totals_row$`Energia Total`) * 100 <= 35, 
             "Adecuado", "Revisar"),
      ifelse(totals_row$`Colesterol Total` < 300, "Adecuado", "Revisar"),
      ifelse(totals_row$`Sodio Total` < 2300, "Adecuado", "Revisar"),
      ifelse(totals_row$`CG Totales` < 80, "Adecuado", "Revisar")
    )
  )
  
  # Crear tabla interactiva
  datatable(
    resumen,
    options = list(
      dom = 't',
      ordering = FALSE,
      paging = FALSE
    ),
    rownames = FALSE
  ) %>%
    formatStyle(
      'Estado',
      backgroundColor = styleEqual(c("Adecuado", "Revisar"), c('#c8e6c9', '#ffcdd2'))
    )
})

# Tabla de distribución sugerida de comidas
output$tabla_distribucion <- DT::renderDT({
  # Obtener datos de la dieta calculada
  tab_data <- diet_result()
  
  # Si no hay resultados, no mostrar tabla
  if (is.null(tab_data)) {
    return(NULL)
  }
  
  # Obtener totales
  totals_row <- tab_data[nrow(tab_data), ]
  
  # Crear tabla de distribución
  distribucion <- data.frame(
    Comida = c("Desayuno (7:00 - 8:00)", "Colación (10:30 - 11:00)", 
               "Comida (14:00 - 15:00)", "Colación (17:30 - 18:00)", 
               "Cena (20:00 - 21:00)"),
    `Porcentaje Calorías` = c("25%", "10%", "30%", "10%", "25%"),
    `Calorías aproximadas` = c(
      round(totals_row$`Energia Total` * 0.25),
      round(totals_row$`Energia Total` * 0.10),
      round(totals_row$`Energia Total` * 0.30),
      round(totals_row$`Energia Total` * 0.10),
      round(totals_row$`Energia Total` * 0.25)
    ),
    `Sugerencia de distribución` = c(
      "Proteína + Carbohidrato complejo + Fruta + Grasa saludable",
      "Fruta + Proteína o Grasa saludable",
      "Proteína + Verduras + Carbohidrato complejo + Grasa saludable",
      "Verduras + Proteína",
      "Proteína + Verduras + Carbohidrato complejo (menor cantidad)"
    )
  )
  
  # Crear tabla interactiva
  datatable(
    distribucion,
    options = list(
      dom = 't',
      ordering = FALSE,
      paging = FALSE
    ),
    rownames = FALSE
  ) %>%
    formatStyle(
      'Comida',
      fontWeight = 'bold',
      backgroundColor = styleEqual(
        c("Desayuno (7:00 - 8:00)", "Comida (14:00 - 15:00)", "Cena (20:00 - 21:00)"),
        c('#e3f2fd', '#e3f2fd', '#e3f2fd')
      )
    )
})
}