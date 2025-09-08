# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al Generador de Dietas Optimizadas! Esta guía te ayudará a comenzar.

## 🎯 Formas de Contribuir

### 🐛 Reportar Bugs
- Usa la plantilla de issues para bugs
- Incluye pasos detallados para reproducir
- Adjunta logs de error si es posible
- Especifica versión de R y paquetes utilizados

### 💡 Proponer Features
- Describe claramente el problema que resuelve
- Proporciona ejemplos de uso
- Considera el impacto en performance
- Evalúa compatibilidad con casos existentes

### 📝 Mejorar Documentación
- Corrige errores tipográficos
- Mejora claridad de explicaciones
- Agrega ejemplos prácticos
- Traduce contenido a otros idiomas

### 🧪 Agregar Casos de Prueba
- Crea nuevos escenarios de optimización
- Valida precisión de algoritmos
- Prueba casos extremos
- Documenta resultados esperados

## 🚀 Configuración del Entorno de Desarrollo

### Prerrequisitos
```r
# R version 4.0.0 o superior
R --version

# Paquetes de desarrollo recomendados
install.packages(c(
  "devtools",
  "testthat",
  "roxygen2",
  "styler",
  "lintr"
))
```

### Setup Local
```bash
# 1. Fork y clonar
git clone https://github.com/TU_USUARIO/nutrition_app.git
cd nutrition_app

# 2. Crear rama de desarrollo
git checkout -b desarrollo

# 3. Instalar dependencias
Rscript -e "source('init.R')"

# 4. Ejecutar aplicación
Rscript -e "shiny::runApp()"
```

## 🎨 Estándares de Código

### Estilo de Código R
```r
# ✅ BUENO: Nombres descriptivos
calculate_bmr_harris_benedict <- function(weight_kg, height_cm, age_years, sex) {
  # Implementación
}

# ❌ MALO: Nombres ambiguos  
calc <- function(w, h, a, s) {
  # Implementación
}

# ✅ BUENO: Comentarios explicativos
# Calcula la Tasa Metabólica Basal usando ecuación Harris-Benedict
# Parámetros validados según estándares WHO 2010

# ✅ BUENO: Indentación consistente (2 espacios)
if (condition) {
  result <- complex_calculation(
    parameter1 = value1,
    parameter2 = value2
  )
}
```

### Organización de Archivos
```
modules/
├── calculations.R      # Una función principal por archivo
├── optimization.R      # Funciones relacionadas agrupadas
└── helpers.R          # Utilidades generales

# ✅ Nombres de funciones consistentes
calculate_*()          # Para cálculos nutricionales
optimize_*()          # Para algoritmos de optimización  
validate_*()          # Para validaciones
format_*()            # Para formateo de datos
```

## 📋 Proceso de Pull Request

### 1. Preparación
```bash
# Actualizar rama principal
git checkout main
git pull upstream main

# Crear rama específica
git checkout -b fix/calculation-precision
# o
git checkout -b feature/new-optimization-algorithm
```

### 2. Desarrollo
- Implementa cambios siguiendo estándares
- Actualiza documentación relevante
- Ejecuta la aplicación localmente para verificar

### 3. Commits
```bash
# Commits atómicos y descriptivos
git add modules/calculations.R
git commit -m "fix: Improve BMR calculation precision for edge cases

- Handle decimal weights more accurately
- Add validation for extreme age values  
- Include validation for boundary conditions
- Fixes #123"
```

### 4. Pull Request
- Título descriptivo y conciso
- Descripción detallada de cambios
- Referencia a issues relacionados
- Screenshots si afecta UI
- Lista de verificación completa

### Template de PR
```markdown
## 📝 Descripción
Breve descripción de los cambios implementados.

## 🔗 Issues Relacionados
Fixes #123
Relates to #456

## 🧪 Validación
- [ ] Aplicación ejecuta sin errores
- [ ] Cambios probados localmente
- [ ] Casos extremos validados

## 📋 Checklist
- [ ] Código sigue estándares del proyecto
- [ ] Aplicación funciona correctamente
- [ ] Documentación actualizada
- [ ] Sin conflictos de merge
```

## 🏷️ Versionado

Seguimos [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Cambios incompatibles en API
- **MINOR** (0.1.0): Nueva funcionalidad compatible
- **PATCH** (0.0.1): Bug fixes compatibles

### Changelog
Mantén `CHANGELOG.md` actualizado:

```markdown
## [1.2.0] - 2024-03-15
### Added
- Nuevo algoritmo de optimización genética
- Soporte para restricciones de alergias

### Changed  
- Mejorada precisión en cálculo de micronutrientes
- UI más intuitiva para selección de actividad física

### Fixed
- Corrección en validación de pesos extremos
- Error en exportación de resultados Excel
```

## 🌟 Reconocimiento de Contribuidores

Los contribuidores son reconocidos en:

1. **README.md** - Sección de reconocimientos
2. **CONTRIBUTORS.md** - Lista completa de contribuidores  
3. **Releases** - Notas de cada versión
4. **Código** - Comentarios de autoría en cambios significativos

## 💬 Comunicación

### Canales Disponibles
- **GitHub Issues**: Para bugs y features específicos
- **Discussions**: Para preguntas generales y brainstorming
- **Email**: Para comunicación privada con maintainers

### Mejores Prácticas
- Sé respetuoso y constructivo
- Proporciona contexto suficiente
- Usa inglés o español según preferencia
- Referencia código/issues específicos cuando sea relevante

## 🎓 Recursos de Aprendizaje

### R y Shiny
- [R for Data Science](https://r4ds.had.co.nz/)
- [Mastering Shiny](https://mastering-shiny.org/)
- [Advanced R](https://adv-r.hadley.nz/)

### Optimización Nutricional
- [WHO Nutrient Requirements](https://www.who.int/publications)
- [Mexican Food Equivalents System](https://www.imss.gob.mx/)

### Desarrollo de Software
- [Git Best Practices](https://www.git-tower.com/learn/git/ebook)
- [Code Review Guidelines](https://google.github.io/eng-practices/)

---

¡Gracias por contribuir al proyecto! 🙏 Juntos podemos hacer la nutrición personalizada más accesible para todos.