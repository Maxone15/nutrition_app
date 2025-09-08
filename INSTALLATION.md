# 🔧 Guía de Instalación - Generador de Dietas Optimizadas

Esta guía te llevará paso a paso para configurar el proyecto localmente o en producción.

## 📋 Tabla de Contenidos

1. [Requisitos del Sistema](#-requisitos-del-sistema)
2. [Instalación Local](#-instalación-local)
3. [Verificación de Instalación](#-verificación-de-instalación)
4. [Despliegue en Producción](#-despliegue-en-producción)
5. [Solución de Problemas](#-solución-de-problemas)

## 🖥️ Requisitos del Sistema

### Requisitos Mínimos
- **R**: Versión 4.0.0 o superior
- **RAM**: 4 GB mínimo (8 GB recomendado)
- **Almacenamiento**: 500 MB disponibles
- **SO**: Windows 10/11, macOS 10.14+, Ubuntu 18.04+

### Software Adicional
- **RStudio**: Recomendado para desarrollo (opcional)
- **Git**: Para clonar el repositorio
- **Navegador**: Chrome, Firefox, Safari o Edge (versiones recientes)

## 🚀 Instalación Local

### Paso 1: Instalar R y Dependencias Base

#### Windows
```powershell
# Descargar R desde https://cran.r-project.org/bin/windows/base/
# Ejecutar el instalador y seguir las instrucciones

# Verificar instalación
R --version
```

#### macOS
```bash
# Opción 1: Descargar desde https://cran.r-project.org/bin/macosx/
# Opción 2: Usar Homebrew
brew install r

# Verificar instalación
R --version
```

#### Ubuntu/Debian
```bash
# Actualizar repositorios
sudo apt update

# Instalar R
sudo apt install r-base r-base-dev

# Instalar dependencias del sistema para paquetes R
sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev

# Verificar instalación
R --version
```

### Paso 2: Clonar el Repositorio

```bash
# Clonar desde GitHub
git clone https://github.com/maxone-or/nutrition_app.git

# Navegar al directorio
cd nutrition_app

# Verificar estructura
ls -la
```

### Paso 3: Instalar Paquetes R Requeridos

Ejecuta R o RStudio y ejecuta el siguiente script:

```r
# Script de instalación automática
# Este script detecta y instala todas las dependencias necesarias

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
  "here",
  "config"
)

# Función para instalar paquetes faltantes
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  
  if(length(new_packages) > 0) {
    cat("Instalando paquetes faltantes:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  } else {
    cat("Todos los paquetes requeridos ya están instalados.\n")
  }
}

# Ejecutar instalación
install_if_missing(required_packages)

# Verificar instalación
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(missing_packages) > 0) {
  cat("⚠️  Los siguientes paquetes no se pudieron instalar:\n")
  cat(paste(missing_packages, collapse = ", "), "\n")
} else {
  cat("✅ Todos los paquetes se instalaron correctamente!\n")
}
```

## ✅ Verificación de Instalación

### Test Básico de Funcionalidad

```r
# Verificar que los archivos principales existen
required_files <- c(
  "app.R",
  "global.R", 
  "modules/load_data.R",
  "www/Equivalentes_completo.csv"
)

for(file in required_files) {
  if(file.exists(file)) {
    cat("✅", file, "- OK\n")
  } else {
    cat("❌", file, "- FALTANTE\n")
  }
}
```

### Ejecutar la Aplicación

```r
# Método 1: Ejecutar directamente
shiny::runApp()

# Método 2: Con configuración personalizada
shiny::runApp(
  port = 3838,
  host = "127.0.0.1",
  launch.browser = TRUE
)

# Método 3: En modo desarrollo con auto-reload
options(shiny.autoreload = TRUE)
shiny::runApp()
```

Si todo está configurado correctamente, deberías ver:
```
Listening on http://127.0.0.1:3838
```

## 🌐 Despliegue en Producción

### Shinyapps.io

```r
# 1. Instalar rsconnect
install.packages("rsconnect")

# 2. Configurar cuenta (obtener token desde shinyapps.io)
library(rsconnect)
rsconnect::setAccountInfo(
  name = 'maxone-or',
  token = 'tu-token',
  secret = 'tu-secret'
)

# 3. Desplegar aplicación
rsconnect::deployApp(
  appName = "Generador_dietas",
  appTitle = "Generador de Dietas Optimizadas",
  launch.browser = TRUE
)
```

### Docker

```dockerfile
# Dockerfile
FROM rocker/shiny-verse:latest

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar paquetes R específicos
RUN R -e "install.packages(c('shinydashboard', 'DT', 'plotly', 'lpSolve'))"

# Copiar aplicación
COPY . /srv/shiny-server/nutrition_app/

# Configurar permisos
RUN chown -R shiny:shiny /srv/shiny-server/

# Exponer puerto
EXPOSE 3838

# Comando por defecto
CMD ["/usr/bin/shiny-server"]
```

```bash
# Construir imagen
docker build -t nutrition-app .

# Ejecutar contenedor
docker run -d -p 3838:3838 --name nutrition-app nutrition-app
```

## 🔧 Solución de Problemas

### Problemas Comunes

#### Error: Paquete no encontrado
```r
# Problema: Error in library(nombre_paquete) : there is no package called 'nombre_paquete'

# Solución:
install.packages("nombre_paquete")
# Si persiste:
install.packages("nombre_paquete", dependencies = TRUE, repos = "https://cran.rstudio.com/")
```

#### Error: Datos no se cargan
```r
# Problema: Error al cargar Equivalentes_completo.csv

# Verificar ubicación del archivo
file.exists("www/Equivalentes_completo.csv")

# Verificar formato
data <- read.csv("www/Equivalentes_completo.csv", stringsAsFactors = FALSE)
head(data)

# Verificar encoding
data <- read.csv("www/Equivalentes_completo.csv", fileEncoding = "UTF-8")
```

#### Error: Puerto ya en uso
```bash
# Problema: Error in startServer: Port 3838 already in use

# Encontrar proceso usando el puerto (Windows)
netstat -ano | findstr :3838

# Encontrar proceso usando el puerto (Mac/Linux)
lsof -i :3838

# Terminar proceso
kill -9 <PID>

# Usar puerto alternativo
shiny::runApp(port = 8080)
```

#### Error de optimización: lpSolve
```r
# Problema: Error en lpSolve

# Verificar instalación
install.packages("lpSolve")

# En Ubuntu, instalar dependencias del sistema
sudo apt-get install liblpsolve55-dev

# Reinstalar paquete
remove.packages("lpSolve")
install.packages("lpSolve")
```

### Logs y Debugging

#### Habilitar logs detallados
```r
# En global.R
options(shiny.trace = TRUE)
options(shiny.error = browser)

# Logging básico
cat("Iniciando aplicación...\n")
print(sessionInfo())
```

### Contacto para Soporte

Si encuentras problemas no cubiertos en esta guía:

1. **Issues en GitHub**: [https://github.com/maxone-or/nutrition_app/issues](https://github.com/maxone-or/nutrition_app/issues)
2. **Aplicación en vivo**: [https://maxone-or.shinyapps.io/Generador_dietas/](https://maxone-or.shinyapps.io/Generador_dietas/)

---

## 📚 Recursos Adicionales

- [Documentación oficial de Shiny](https://shiny.rstudio.com/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [Guía de deployment de Shiny apps](https://shiny.rstudio.com/deploy/)
- [Troubleshooting Shiny](https://shiny.rstudio.com/articles/debugging.html)

¡La instalación debería estar completa! 🎉