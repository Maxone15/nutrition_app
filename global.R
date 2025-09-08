# ==============================================================================
# Optimizador de Dietas basado en Programación Lineal
# ==============================================================================
# Este script implementa una aplicación Shiny para generar dietas optimizadas
# mediante programación lineal, minimizando nutrientes seleccionados como la
# carga glucémica, mientras cumple con requerimientos nutricionales basados en
# el Sistema Mexicano de Alimentos Equivalentes.

# ------------------------------------------------------------------------------
# Cargar bibliotecas requeridas
# ------------------------------------------------------------------------------
library(shiny)           # Framework principal para aplicaciones web interactivas
library(shinydashboard)  # Componentes de dashboard para Shiny
library(shinyWidgets)    # Widgets adicionales para la interfaz de usuario
library(shinythemes)     # Temas para mejorar la apariencia de la aplicación
library(shinyjs)         # Funcionalidad JavaScript para Shiny
library(tidyverse)       # Conjunto de paquetes para manipulación de datos
library(ROI)             # Framework de optimización (alternativa a lpSolve)
library(ROI.plugin.lpsolve) # Conector para el solucionador lpsolve
library(DT)              # Para tablas de datos interactivas
library(janitor)         # Para limpieza y tabulación de datos
library(writexl)         # Para exportar a Excel
library(bslib)
library(kableExtra)
library(tidyverse)
library(officer)
library(flextable)
library(dplyr)
library(DT)
library(ggplot2)

# Configuraciones globales que se comparten entre los módulos
options(shiny.maxRequestSize = 30*1024^2)  # Aumentar tamaño máximo de carga si es necesario

# Cargar datos globalmente
source("modules/load_data.R")
food_data <- initialize_food_data()
M <- food_data$data
grupos_alimentos <- food_data$grupos