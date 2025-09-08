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
#' Mapea grupos de alimentos a categorías de calidad dietética
map_food_groups_to_quality_categories <- function(foods_df) {
  foods_df <- foods_df %>%
    mutate(grupo_calidad_dietetica = case_when(
      Grupo %in% c("Frutas") ~ "frutas",
      Grupo %in% c("Verduras") ~ "verduras",
      Grupo %in% c("Leguminosas") ~ "legumbres",
      Grupo %in% c("Cereales sin grasa", "Cereales con grasa") ~ "cereales",
      Grupo %in% c("Aceites y grasas", "Aceites y grasas con proteína") ~ "aceites_grasas",
      Grupo %in% c("Leche descremada", "Leche semidescremada", "Leche entera", "Leche con azúcar") ~ "lacteos",
      Grupo %in% c("AOAMBG", "AOABG", "AOAMG", "AOAAG") ~ "carnes",
      Grupo %in% c("Azúcares sin grasa", "Azúcares con grasa") ~ "azucares_procesados",
      TRUE ~ "otros"
    ))
  
  return(foods_df)
}

#' Define límites máximos por alimento individual
define_individual_food_limits <- function(foods_df) {
  default_limits <- case_when(
    foods_df$Grupo == "Aceites y grasas" ~ 4.0,
    foods_df$Grupo == "Aceites y grasas con proteína" ~ 3.0,
    foods_df$Grupo == "Verduras" ~ 8.0,
    foods_df$Grupo == "Frutas" ~ 6.0,
    foods_df$Grupo == "Cereales sin grasa" ~ 8.0,
    foods_df$Grupo == "Cereales con grasa" ~ 6.0,
    foods_df$Grupo == "Leguminosas" ~ 4.0,
    foods_df$Grupo == "AOAMBG" ~ 4.0,
    foods_df$Grupo == "AOABG" ~ 3.0,
    foods_df$Grupo == "AOAMG" ~ 2.5,
    foods_df$Grupo == "AOAAG" ~ 2.0,
    foods_df$Grupo %in% c("Leche descremada", "Leche semidescremada") ~ 4.0,
    foods_df$Grupo %in% c("Leche entera", "Leche con azúcar") ~ 3.0,
    foods_df$Grupo == "Azúcares sin grasa" ~ 2.0,
    foods_df$Grupo == "Azúcares con grasa" ~ 1.5,
    TRUE ~ 5.0
  )
  
  specific_limits <- case_when(
    grepl("aceite|aceite de oliva|mantequilla|margarina", tolower(foods_df$Alimento)) ~ pmin(default_limits, 3.0),
    grepl("cebolla|ajo|chile|especias", tolower(foods_df$Alimento)) ~ pmin(default_limits, 2.0),
    grepl("azúcar|miel|mermelada", tolower(foods_df$Alimento)) ~ pmin(default_limits, 2.0),
    grepl("sal|condimento", tolower(foods_df$Alimento)) ~ pmin(default_limits, 1.0),
    TRUE ~ default_limits
  )
  
  return(specific_limits)
}

#' Define límites máximos por grupo de alimentos
define_group_limits <- function(foods_df) {
  groups <- list(
    aceites_grasas = as.numeric(foods_df$Grupo %in% c("Aceites y grasas", "Aceites y grasas con proteína")),
    carnes_totales = as.numeric(foods_df$Grupo %in% c("AOAMBG", "AOABG", "AOAMG", "AOAAG")),
    carnes_altas_grasa = as.numeric(foods_df$Grupo %in% c("AOAMG", "AOAAG")),
    azucares = as.numeric(foods_df$Grupo %in% c("Azúcares sin grasa", "Azúcares con grasa")),
    lacteos_totales = as.numeric(foods_df$Grupo %in% c("Leche descremada", "Leche semidescremada", "Leche entera", "Leche con azúcar")),
    cereales_totales = as.numeric(foods_df$Grupo %in% c("Cereales sin grasa", "Cereales con grasa"))
  )
  
  limits <- list(
    aceites_grasas = 6.0,
    carnes_totales = 6.0,
    carnes_altas_grasa = 2.5,
    azucares = 2.5,
    lacteos_totales = 4.5,
    cereales_totales = 10.0
  )
  
  return(list(groups = groups, limits = limits))
}

#' Añade restricciones de calidad y practicidad
add_quality_constraints_improved <- function(foods_df, base_constraints, base_dir, base_rhs, 
                                             apply_practicality_limits = TRUE) {
  
  foods_df <- map_food_groups_to_quality_categories(foods_df)
  
  frutas_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "frutas")
  verduras_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "verduras")
  legumbres_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "legumbres")
  cereales_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "cereales")
  aceites_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "aceites_grasas")
  lacteos_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "lacteos")
  carnes_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "carnes")
  azucares_indicator <- as.numeric(foods_df$grupo_calidad_dietetica == "azucares_procesados")
  
  quality_constraints <- rbind(
    frutas_indicator,
    verduras_indicator,
    legumbres_indicator,
    cereales_indicator,
    aceites_indicator,
    lacteos_indicator,
    lacteos_indicator,
    carnes_indicator,
    azucares_indicator
  )
  
  quality_dir <- c(">=", ">=", ">=", ">=", ">=", ">=", "<=", "<=", "<=")
  quality_rhs <- c(2.0, 2.5, 0.3, 1.0, 1.0, 1.5, 4.5, 4.0, 2.0)
  
  combined_constraints <- rbind(base_constraints, quality_constraints)
  combined_dir <- c(base_dir, quality_dir)
  combined_rhs <- c(base_rhs, quality_rhs)
  
  if (apply_practicality_limits) {
    individual_limits <- define_individual_food_limits(foods_df)
    individual_constraints <- diag(nrow(foods_df))
    
    group_setup <- define_group_limits(foods_df)
    
    group_constraints <- rbind(
      group_setup$groups$aceites_grasas,
      group_setup$groups$carnes_totales,
      group_setup$groups$carnes_altas_grasa,
      group_setup$groups$azucares,
      group_setup$groups$lacteos_totales,
      group_setup$groups$cereales_totales
    )
    
    final_constraints <- rbind(
      combined_constraints,
      individual_constraints,
      group_constraints
    )
    
    individual_dir <- rep("<=", nrow(foods_df))
    group_dir <- rep("<=", 6)
    
    final_dir <- c(combined_dir, individual_dir, group_dir)
    
    group_rhs <- unlist(group_setup$limits)
    final_rhs <- c(combined_rhs, individual_limits, group_rhs)
    
  } else {
    final_constraints <- combined_constraints
    final_dir <- combined_dir
    final_rhs <- combined_rhs
  }
  
  return(list(
    constraints = final_constraints,
    directions = final_dir,
    rhs = final_rhs,
    foods_df = foods_df,
    individual_limits = if(apply_practicality_limits) individual_limits else NULL,
    practicality_applied = apply_practicality_limits
  ))
}

# ==============================================================================
# FUNCIONES DE EVALUACIÓN DE CALIDAD
# ==============================================================================

#' Calcula puntuación de practicidad
calculate_practicality_score <- function(result_df) {
  excessive_portions <- result_df %>%
    mutate(
      is_excessive = case_when(
        grepl("aceite|mantequilla|margarina", tolower(Alimento)) & Racion > 3 ~ TRUE,
        grepl("cebolla|ajo|chile", tolower(Alimento)) & Racion > 2 ~ TRUE,
        grepl("azúcar|miel", tolower(Alimento)) & Racion > 2 ~ TRUE,
        Racion > 8 ~ TRUE,
        TRUE ~ FALSE
      )
    ) %>%
    filter(is_excessive == TRUE)
  
  penalty <- nrow(excessive_portions) * 2
  practicality_score <- pmax(0, 10 - penalty)
  
  return(practicality_score)
}

#' Calcula el índice de calidad dietética
calculate_diet_quality_index_improved <- function(result_df, foods_df) {
  result_clean <- result_df %>%
    filter(Alimento != "Total")
  
  if (!"grupo_calidad_dietetica" %in% colnames(foods_df)) {
    foods_df <- map_food_groups_to_quality_categories(foods_df)
  }
  
  result_with_groups <- result_clean %>%
    left_join(foods_df %>% select(Alimento, grupo_calidad_dietetica), by = "Alimento")
  
  group_portions <- result_with_groups %>%
    group_by(grupo_calidad_dietetica) %>%
    summarise(total_portions = sum(Racion, na.rm = TRUE), .groups = "drop")
  
  get_group_portions <- function(group_name) {
    result <- group_portions %>% 
      filter(grupo_calidad_dietetica == group_name) %>% 
      pull(total_portions)
    if(length(result) == 0) 0 else result
  }
  
  frutas_portions <- get_group_portions("frutas")
  verduras_portions <- get_group_portions("verduras")
  legumbres_portions <- get_group_portions("legumbres")
  cereales_portions <- get_group_portions("cereales")
  aceites_portions <- get_group_portions("aceites_grasas")
  lacteos_portions <- get_group_portions("lacteos")
  carnes_portions <- get_group_portions("carnes")
  azucares_portions <- get_group_portions("azucares_procesados")
  
  frutas_score <- pmin(10, (frutas_portions / 2.0) * 10)
  verduras_score <- pmin(10, (verduras_portions / 2.5) * 10)
  legumbres_score <- pmin(10, (legumbres_portions / 0.3) * 10)
  cereales_score <- pmin(10, (cereales_portions / 1.0) * 10)
  aceites_score <- pmin(10, (aceites_portions / 1.0) * 10)
  
  lacteos_score <- if (lacteos_portions >= 1.5 && lacteos_portions <= 4.5) {
    10
  } else if (lacteos_portions < 1.5) {
    (lacteos_portions / 1.5) * 10
  } else {
    pmax(0, 10 - ((lacteos_portions - 4.5) * 2))
  }
  
  carnes_score <- if (carnes_portions <= 4.0) {
    10
  } else {
    pmax(0, 10 - ((carnes_portions - 4.0) * 2))
  }
  
  azucares_score <- if (azucares_portions <= 2.0) {
    10 - (azucares_portions * 2)
  } else {
    pmax(0, 10 - (azucares_portions * 5))
  }
  
  variety_score <- (sum(c(frutas_portions, verduras_portions, legumbres_portions, 
                          cereales_portions, aceites_portions, lacteos_portions) > 0) / 6) * 10
  
  practicality_score <- calculate_practicality_score(result_clean)
  
  quality_index <- (
    frutas_score * 0.12 + verduras_score * 0.12 + legumbres_score * 0.08 +
      cereales_score * 0.10 + aceites_score * 0.08 + lacteos_score * 0.10 +
      carnes_score * 0.10 + azucares_score * 0.10 + variety_score * 0.10 +
      practicality_score * 0.10
  )
  
  quality_summary <- data.frame(
    Componente = c("Frutas", "Verduras", "Legumbres", "Cereales", "Aceites/Grasas", 
                   "Lácteos", "Carnes", "Azúcares", "Variedad", "Practicidad"),
    Porciones_Actuales = c(frutas_portions, verduras_portions, legumbres_portions,
                           cereales_portions, aceites_portions, lacteos_portions,
                           carnes_portions, azucares_portions, NA, NA),
    Recomendacion = c("≥2.0", "≥2.5", "≥0.3", "≥1.0", "≥1.0", "1.5-4.5", "≤4.0", "≤2.0", "Máxima", "Alta"),
    Puntuacion = round(c(frutas_score, verduras_score, legumbres_score, cereales_score,
                         aceites_score, lacteos_score, carnes_score, azucares_score, 
                         variety_score, practicality_score), 1),
    Estado = c(
      ifelse(frutas_portions >= 2.0, "✓ Cumple", "⚠ Insuficiente"),
      ifelse(verduras_portions >= 2.5, "✓ Cumple", "⚠ Insuficiente"),
      ifelse(legumbres_portions >= 0.3, "✓ Cumple", "⚠ Insuficiente"),
      ifelse(cereales_portions >= 1.0, "✓ Cumple", "⚠ Insuficiente"),
      ifelse(aceites_portions >= 1.0, "✓ Cumple", "⚠ Insuficiente"),
      ifelse(lacteos_portions >= 1.5 && lacteos_portions <= 4.5, "✓ Cumple", 
             ifelse(lacteos_portions < 1.5, "⚠ Insuficiente", "⚠ Excesivo")),
      ifelse(carnes_portions <= 4.0, "✓ Cumple", "⚠ Excesivo"),
      ifelse(azucares_portions <= 2.0, "✓ Cumple", "⚠ Excesivo"),
      paste0(sum(c(frutas_portions, verduras_portions, legumbres_portions, 
                   cereales_portions, aceites_portions, lacteos_portions) > 0), "/6 grupos"),
      ifelse(practicality_score >= 7, "✓ Práctica", "⚠ Poco práctica")
    )
  )
  
  return(list(
    indice_calidad = round(quality_index, 2),
    resumen_componentes = quality_summary,
    interpretacion = case_when(
      quality_index >= 8.5 ~ "Excelente calidad dietética y practicidad",
      quality_index >= 7.0 ~ "Buena calidad dietética y practicidad",
      quality_index >= 5.5 ~ "Calidad dietética moderada",
      TRUE ~ "Calidad dietética y practicidad deficiente"
    )
  ))
}

# ==============================================================================
# FUNCIÓN PRINCIPAL DE OPTIMIZACIÓN
# ==============================================================================

#' Optimización de dieta con restricciones de calidad
optimize_diet_with_quality_improved <- function(foods_df, objective_nutrients, weights, constraints, 
                                                include_quality_constraints = TRUE,
                                                include_practicality_limits = TRUE) {
  
  f.obj <- build_objective_function(foods_df, objective_nutrients, weights)
  
  nutrition_constraints <- matrix(c(
    foods_df$Energia, foods_df$Energia, foods_df$Proteina, foods_df$Proteina,
    foods_df$Lipidos, foods_df$Lipidos, foods_df$Carbohidratos, foods_df$Carbohidratos,
    foods_df$Fibra, foods_df$Vitamina_A, foods_df$Acido_Ascorbico, foods_df$Acido_Folico,
    foods_df$Hierro, foods_df$Potasio, foods_df$Calcio, foods_df$Selenio,
    foods_df$Fosforo, foods_df$Colesterol
  ), nrow = 18, byrow = TRUE)
  
  f.dir <- c(">=","<=", ">=","<=", ">=","<=", ">=","<=", 
             ">=", ">=", ">=", ">=", ">=", ">=", ">=", ">=", ">=", "<=")
  
  f.rhs <- c(
    constraints$energy$min, constraints$energy$max,
    constraints$protein$min, constraints$protein$max,
    constraints$fat$min, constraints$fat$max,
    constraints$carbs$min, constraints$carbs$max,
    30, 730, 60, 200, 15, 1250, 900, 70, 560, 100
  )
  
  if (include_quality_constraints) {
    constraint_setup <- add_quality_constraints_improved(
      foods_df, nutrition_constraints, f.dir, f.rhs, 
      apply_practicality_limits = include_practicality_limits
    )
    final_constraints <- constraint_setup$constraints
    final_dir <- constraint_setup$directions
    final_rhs <- constraint_setup$rhs
    foods_df <- constraint_setup$foods_df
  } else {
    final_constraints <- nutrition_constraints
    final_dir <- f.dir
    final_rhs <- f.rhs
  }
  
  tryCatch({
    lp_problem <- ROI::OP(
      objective = ROI::L_objective(f.obj),
      constraints = ROI::L_constraint(L = final_constraints, dir = final_dir, rhs = final_rhs),
      maximum = FALSE
    )
    
    solution <- ROI::ROI_solve(lp_problem)
    
    if (solution$status$code != 0) {
      warning("No se encontró solución óptima: ", solution$status$msg)
      return(list(resultado = NULL, calidad = NULL))
    }
    
    S <- solution$solution
    
    #result <- cbind(foods_df, S) %>%
    #  mutate(Racion = case_when(
    #    (S - trunc(S)) < 0.3 ~ floor(S),
    #    (S - trunc(S)) >= 0.3 & (S - trunc(S)) < 0.75 ~ floor(S) + 0.5,
    #    TRUE ~ ceiling(S)
    #  )) %>%
    #  filter(Racion > 0)
    
    result <- cbind(foods_df, S) %>%
      mutate(Racion = S) %>%
      filter(Racion > 0)
    
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
      select(Alimento, Cantidad_sugerida, Unidad, Racion, 'Energia Total', 
             'Proteina Total', 'Lipidos Totales', 'Carbohidratos Totales',
             'Colesterol Total', 'Sodio Total', 'CG Totales') %>% 
      adorn_totals()
    
    quality_assessment <- calculate_diet_quality_index_improved(final_result, foods_df)
    
    return(list(
      resultado = final_result,
      calidad = quality_assessment,
      restricciones_calidad_aplicadas = include_quality_constraints,
      restricciones_practicidad_aplicadas = include_practicality_limits
    ))
    
  }, error = function(e) {
    warning("Error en la optimización: ", e$message)
    return(list(resultado = NULL, calidad = NULL))
  })
}