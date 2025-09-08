#' Construye la función objetivo para el problema de optimización
#'
#' @param foods_df Dataframe con los alimentos seleccionados
#' @param objective_nutrients Vector de nombres de nutrientes a minimizar
#' @param weights Vector de pesos para cada nutriente
#' @return Vector numérico con valores de la función objetivo
build_objective_function <- function(foods_df, objective_nutrients, weights) {
  # Inicializar con ceros
  f.obj <- rep(0, nrow(foods_df))
  
  # Añadir contribución ponderada de cada nutriente
  for (nutrient in objective_nutrients) {
    if (nutrient %in% colnames(foods_df)) {
      weight_value <- weights[[paste0("peso_", nutrient)]]
      if (!is.null(weight_value) && !is.na(weight_value)) {
        f.obj <- f.obj + weight_value * foods_df[[nutrient]]
      }
    }
  }
  
  return(f.obj)
}

#' Optimiza la dieta utilizando programación lineal
#'
#' @param foods_df Dataframe con los alimentos disponibles
#' @param objective_nutrients Vector de nutrientes a minimizar
#' @param weights Vector de pesos para cada nutriente
#' @param constraints Lista de restricciones nutricionales
#' @return Dataframe con los resultados de la optimización o NULL si no hay solución
optimize_diet <- function(foods_df, objective_nutrients, weights, constraints) {
  # Construir función objetivo
  f.obj <- build_objective_function(foods_df, objective_nutrients, weights)
  
  # Construir matriz de restricciones nutricionales
  nutrition_constraints <- matrix(c(
    foods_df$Energia,      # Energía mínima
    foods_df$Energia,      # Energía máxima
    foods_df$Proteina,     # Proteína mínima
    foods_df$Proteina,     # Proteína máxima
    foods_df$Lipidos,      # Lípidos mínimos
    foods_df$Lipidos,      # Lípidos máximos
    foods_df$Carbohidratos, # Carbohidratos mínimos
    foods_df$Carbohidratos, # Carbohidratos máximos
    foods_df$Fibra,        # Fibra mínima (>=)
    foods_df$Vitamina_A,   # Vitamina A mínima (>=)
    foods_df$Acido_Ascorbico, # Ácido ascórbico mínimo (>=)
    foods_df$Acido_Folico, # Ácido fólico mínimo (>=)
    foods_df$Hierro,       # Hierro mínimo (>=)
    foods_df$Potasio,      # Potasio mínimo (>=)
    foods_df$Calcio,       # Calcio mínimo (>=)
    foods_df$Selenio,      # Selenio mínimo (>=)
    foods_df$Fosforo,      # Fósforo mínimo (>=)
    foods_df$Sodio,        # Sodio máximo (<=)
    foods_df$Colesterol    # Colesterol máximo (<=)
  ), nrow = 19, byrow = TRUE)
  
  # Direcciones de las restricciones (corregidas según la tabla de nutrientes)
  f.dir <- c(">=","<=", ">=","<=", ">=","<=", ">=","<=", 
             ">=", ">=", ">=", ">=", ">=", ">=", ">=", ">=", ">=", "<=", "<=")
  
  # Valores límite para las restricciones
  f.rhs <- c(
    constraints$energy$min, constraints$energy$max,        # Rango de energía
    constraints$protein$min, constraints$protein$max,      # Rango de proteínas
    constraints$fat$min, constraints$fat$max,              # Rango de lípidos
    constraints$carbs$min, constraints$carbs$max,          # Rango de carbohidratos
    30,      # Mínimo de fibra (30g)
    730,     # Mínimo de vitamina A (730 μg RE)
    60,      # Mínimo de ácido ascórbico (60 mg)
    200,     # Mínimo de ácido fólico (200 μg)
    15,      # Mínimo de hierro (15 mg)
    1250,    # Mínimo de potasio (1250 mg)
    900,     # Mínimo de calcio (900 mg)
    70,      # Mínimo de selenio (70 μg)
    560,     # Mínimo de fósforo (560 mg)
    2300,    # Máximo de sodio (2300 mg)
    100      # Máximo de colesterol (100 mg)
  )
  
  # Resolver el problema de programación lineal mediante ROI
  tryCatch({
    # Usar lpSolve a través de ROI
    lp_problem <- ROI::OP(
      objective = ROI::L_objective(f.obj),
      constraints = ROI::L_constraint(
        L = nutrition_constraints,
        dir = f.dir,
        rhs = f.rhs
      ),
      maximum = FALSE  # Minimización
    )
    
    solution <- ROI::ROI_solve(lp_problem)
    
    # Verificar estado de la solución
    if (solution$status$code != 0) {
      warning("No se encontró solución óptima: ", solution$status$msg)
      return(NULL)
    }
    
    # Extraer valores de la solución
    S <- solution$solution
    
    # Procesar resultados
    result <- cbind(foods_df, S) %>%
      # Redondear raciones a valores prácticos (entero, mitad o siguiente entero)
      mutate(Racion = case_when(
        (S - trunc(S)) < 0.3 ~ floor(S),
        (S - trunc(S)) >= 0.3 & (S - trunc(S)) < 0.75 ~ floor(S) + 0.5,
        TRUE ~ ceiling(S)
      )) %>%
      # Filtrar solo alimentos con raciones mayores a cero
      filter(Racion > 0)
    
    # Calcular totales de nutrientes según las raciones asignadas
    final_result <- result %>%
      mutate(
        'Energia Total' = round((Energia * Racion), 1), 
        'Proteina Total' = round((Proteina * Racion), 1),
        'Lipidos Totales' = round((Lipidos * Racion), 1), 
        'Carbohidratos Totales' = round((Carbohidratos * Racion), 1),
        'Colesterol Total' = round((Colesterol * Racion), 1),
        'Sodio Total' = round((Sodio * Racion), 1),
        'CG Totales' = round((CG * Racion), 1)
      ) %>% 
      # Seleccionar columnas para mostrar
      select(
        Alimento, Cantidad_sugerida, Unidad, Racion, 'Energia Total', 
        'Proteina Total', 'Lipidos Totales', 'Carbohidratos Totales',
        'Colesterol Total', 'Sodio Total', 'CG Totales'
      ) %>% 
      # Añadir fila de totales
      adorn_totals()
    
    return(final_result)
    
  }, error = function(e) {
    warning("Error en la optimización: ", e$message)
    return(NULL)
  })
}