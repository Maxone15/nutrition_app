# init.R - Este archivo se ejecuta cuando se inicia la aplicación en shinyapps.io

# Lista de paquetes necesarios para la generación de Word
my_packages <- c("rmarkdown", "knitr", "pagedown", "officer", "flextable", "wordcloud", "writexl")

# Instalar paquetes faltantes
.First <- function() {
  if (length(find.package(my_packages, quiet = TRUE)) != length(my_packages)) {
    install.packages(setdiff(my_packages, rownames(installed.packages())))
  }
}