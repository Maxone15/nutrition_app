#' Calcula el Gasto Energético en Reposo (GER) usando la fórmula de Harris-Benedict
#'
#' @param sex Sexo (F/M)
#' @param weight Peso en kg
#' @param height Altura en cm
#' @param age Edad en años
#' @return Valor numérico del GER en kcal
calculate_ger <- function(sex, weight, height, age) {
  if (sex == 'F') {
    return((10 * height) + (6.25 * weight) - (5 * age) - 161)
  } else {
    return((10 * height) + (6.25 * weight) - (5 * age) + 5)
  }
}

#' Calcula rangos de macronutrientes basados en necesidades energéticas
#'
#' @param ger Gasto Energético en Reposo
#' @param total_energy Gasto energético total
#' @return Lista con rangos mínimos y máximos para carbohidratos, proteínas y grasas
calculate_macro_ranges <- function(ger, total_energy) {
  # Distribución de macronutrientes (50% carbohidratos, 25% proteínas, 25% grasas)
  list(
    carbs = list(
      min = as.integer((ger * 0.5) / 4),      # Calorías de carbohidratos / 4 kcal por gramo
      max = as.integer((total_energy * 0.5) / 4)
    ),
    protein = list(
      min = as.numeric((ger * 0.25) / 4),     # Calorías de proteínas / 4 kcal por gramo
      max = as.numeric((total_energy * 0.25) / 4)
    ),
    fat = list(
      min = as.integer((ger * 0.25) / 9),     # Calorías de grasas / 9 kcal por gramo
      max = as.integer((total_energy * 0.25) / 9)
    )
  )
}