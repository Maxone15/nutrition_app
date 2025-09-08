# 🚀 Script de Configuración Inicial - Nutrition App
# Ejecuta este script la primera vez que clonas el repositorio

cat("🍎 Configurando Nutrition App...\n\n")

# Verificar versión de R
r_version <- R.Version()
cat("📊 Información del sistema:\n")
cat("  - R Version:", r_version$version.string, "\n")
cat("  - Platform:", r_version$platform, "\n\n")

# Lista de paquetes requeridos
required_packages <- c(
  # Shiny ecosystem
  "shiny",
  "shinydashboard", 
  "shinydashboardPlus",
  "shinyWidgets",
  "shinyjs",
  
  # Data manipulation
  "dplyr",
  "tidyr", 
  "readr",
  "readxl",
  "openxlsx",
  
  # Visualization
  "ggplot2",
  "plotly",
  "DT",
  
  # Optimization
  "lpSolve",
  "ROI",
  
  # Utilities
  "here"
)

cat("📦 Verificando dependencias...\n")

# Función para instalar paquetes faltantes
install_if_missing <- function(packages) {
  installed_packages <- installed.packages()[,"Package"]
  missing_packages <- packages[!(packages %in% installed_packages)]
  
  if(length(missing_packages) > 0) {
    cat("📥 Instalando paquetes faltantes:\n")
    for(pkg in missing_packages) {
      cat("  - Instalando", pkg, "... ")
      tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
        cat("✅\n")
      }, error = function(e) {
        cat("❌ Error:", e$message, "\n")
      })
    }
  } else {
    cat("✅ Todos los paquetes requeridos ya están instalados.\n")
  }
}

# Ejecutar instalación
install_if_missing(required_packages)

cat("\n🔍 Verificando estructura del proyecto...\n")

# Verificar archivos principales
required_files <- list(
  "Archivos principales" = c("app.R", "global.R"),
  "Módulos" = c("modules/load_data.R", "modules/calculations.R"),
  "UI/Server" = c("ui/home_ui.R", "server/home_server.R"),
  "Recursos" = c("www/Equivalentes_completo.csv"),
  "Documentación" = c("README.md", "CONTRIBUTING.md", "INSTALLATION.md")
)

for(category in names(required_files)) {
  cat("📁", category, ":\n")
  files <- required_files[[category]]
  for(file in files) {
    if(file.exists(file)) {
      cat("  ✅", file, "\n")
    } else {
      cat("  ⚠️ ", file, "- No encontrado\n")
    }
  }
}

cat("\n🧪 Ejecutando tests básicos...\n")

# Test 1: Cargar datos
cat("1️⃣ Test de carga de datos... ")
tryCatch({
  if(file.exists("www/Equivalentes_completo.csv")) {
    data <- read.csv("www/Equivalentes_completo.csv", stringsAsFactors = FALSE)
    if(nrow(data) > 0) {
      cat("✅ (", nrow(data), "registros)\n")
    } else {
      cat("⚠️ Archivo vacío\n")
    }
  } else {
    cat("⚠️ Archivo no encontrado\n")
  }
}, error = function(e) {
  cat("❌ Error:", e$message, "\n")
})

# Test 2: Verificar módulos
cat("2️⃣ Test de módulos... ")
tryCatch({
  if(file.exists("modules/load_data.R")) {
    source("modules/load_data.R")
    cat("✅\n")
  } else {
    cat("⚠️ Módulo no encontrado\n")
  }
}, error = function(e) {
  cat("❌ Error:", e$message, "\n")
})

# Test 3: Test básico de optimización
cat("3️⃣ Test de optimización... ")
tryCatch({
  library(lpSolve)
  # Test simple de lpSolve
  result <- lp("max", c(1, 2), matrix(c(1, 1, 2, 1), nrow = 2), c("<=", "<="), c(10, 15))
  if(result$status == 0) {
    cat("✅\n")
  } else {
    cat("⚠️ Solver no funciona correctamente\n")
  }
}, error = function(e) {
  cat("❌ Error:", e$message, "\n")
})

cat("\n🎯 Siguientes pasos:\n")
cat("1️⃣ Ejecutar la aplicación: shiny::runApp()\n")
cat("2️⃣ Abrir en navegador: http://localhost:3838\n") 
cat("3️⃣ Revisar documentación: README.md\n")
cat("4️⃣ Para desarrollo: ver CONTRIBUTING.md\n")

cat("\n🔗 Enlaces útiles:\n")
cat("📖 Documentación: README.md\n")
cat("🤝 Contribuir: CONTRIBUTING.md\n")
cat("🔧 Instalación: INSTALLATION.md\n") 
cat("🐛 Reportar bugs: https://github.com/maxone-or/nutrition_app/issues\n")

cat("\n✨ ¡Configuración completada! ✨\n")
cat("Ejecuta 'shiny::runApp()' para iniciar la aplicación.\n")