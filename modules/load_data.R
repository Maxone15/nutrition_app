# ------------------------------------------------------------------------------
# Funciones auxiliares
# ------------------------------------------------------------------------------

#' Carga y preprocesa los datos de alimentos
#'
#' @param file_path Ruta al archivo CSV con datos de alimentos
#' @return DataFrame con datos de alimentos preprocesados
load_food_data <- function(file_path) {
  # Importar datos
  data <- read.csv(file_path, header = TRUE, encoding = 'utf-8')
  
  # Definir columnas numéricas que pueden contener valores "ND" (No Disponible)
  #num_columns <- c("Fibra", "Vitamina_A", "Acido_Ascorbico", "Acido_Folico", "Hierro", 
  #                 "Potasio", "Azucar", "IG", "CG")
  
  # Limpiar los datos: convertir "ND" a NA y luego a numérico, eliminar filas con NA
  #data <- data %>%
  #  mutate(across(all_of(num_columns), ~ na_if(.x, "ND"))) %>%
  #  mutate(across(all_of(num_columns), as.numeric)) %>%
  #  drop_na(all_of(num_columns))
  
  return(data)
}

# Inicialización de datos que puede moverse desde el cuerpo principal
# Líneas 133-136 del script original
initialize_food_data <- function() {
  M <- load_food_data('www/Equivalentes_completo.csv')
  grupos_alimentos <- unique(M$Grupo)
  return(list(data = M, grupos_alimentos = grupos_alimentos))
}

