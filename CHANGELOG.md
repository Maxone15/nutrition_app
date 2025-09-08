# 📝 Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere al [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Sin liberar]

### Añadido
- Documentación completa del proyecto
- Guías de contribución e instalación
- Licencia MIT
- README detallado con instrucciones

## [2.0.0] - 2024-03-15

### Añadido
- ✨ Nueva interfaz de usuario v2 (`diet_ui_v2.R`)
- ✨ Algoritmo de optimización mejorado (`optimization_v2.R`) 
- ✨ Soporte para exportación a Excel con múltiples hojas
- ✨ Análisis comparativo entre dieta actual y optimizada
- ✨ Dashboard consolidado con métricas nutricionales
- 📊 79+ escenarios de optimización pre-calculados
- 🔍 Sistema de logging para debugging
- 📱 Interfaz responsiva para dispositivos móviles

### Cambiado
- 🔄 Reestructuración completa del código en módulos
- 🔄 Base de datos nutricional expandida y validada
- 🔄 Algoritmo de cálculo de TMB mejorado para mayor precisión
- 🔄 Interfaz más intuitiva con mejor UX/UI
- 🔄 Optimización de rendimiento - tiempo de cálculo reducido 60%

### Corregido
- 🐛 Error en cálculo de micronutrientes para adultos mayores
- 🐛 Problema de encoding en nombres de alimentos con acentos
- 🐛 Validación incorrecta de pesos extremos (< 30kg, > 200kg)
- 🐛 Error de redondeo en distribución de macronutrientes

### Eliminado
- ❌ Funciones deprecated de la v1.x
- ❌ Dependencias innecesarias que afectaban rendimiento

## [1.5.2] - 2024-01-28

### Corregido
- 🐛 Corrección crítica en algoritmo de optimización para diabéticos
- 🐛 Error en exportación CSV con caracteres especiales
- 🐛 Problema de memoria en cálculos con datasets grandes

### Añadido
- 📋 Validación mejorada de parámetros de entrada
- 🔐 Sanitización de inputs del usuario

## [1.5.1] - 2024-01-15

### Cambiado
- 🔄 Actualización de dependencias por seguridad
- 🔄 Mejoras menores de rendimiento

### Corregido
- 🐛 Error en carga de datos al inicio de la aplicación
- 🐛 Problema de compatibilidad con R 4.3.x

## [1.5.0] - 2023-12-20

### Añadido
- ✨ Soporte para perfiles de actividad física personalizados
- ✨ Calculadora de Índice de Masa Corporal integrada
- ✨ Recomendaciones específicas para adultos mayores (65+)
- 📊 Gráficos interactivos con Plotly
- 🎨 Tema visual personalizado con branding

### Cambiado
- 🔄 Migración de gráficos estáticos a interactivos
- 🔄 Reorganización del código en estructura modular
- 🔄 Base de datos actualizada con alimentos mexicanos

### Corregido
- 🐛 Cálculos erróneos para mujeres embarazadas
- 🐛 Error en conversión de unidades métricas/imperiales

## [1.4.0] - 2023-10-30

### Añadido
- ✨ Módulo de optimización para diabetes tipo 2
- ✨ Restricciones alimentarias por alergias
- ✨ Exportación de menús semanales
- 📱 Primera versión de interfaz móvil

### Cambiado
- 🔄 Algoritmo de optimización más robusto con manejo de infactibilidad
- 🔄 Interfaz rediseñada para mejor usabilidad

### Corregido
- 🐛 Error en cálculo de fibra dietética
- 🐛 Problema con decimales en cantidades de alimentos

## [1.3.1] - 2023-09-15

### Corregido
- 🐛 Hotfix: Error crítico en servidor que impedía la carga
- 🐛 Corrección en validación de edad (aceptar 0-120 años)

## [1.3.0] - 2023-09-01

### Añadido
- ✨ Sistema de equivalentes alimentarios mexicanos completo
- ✨ Cálculo automático de requerimientos nutricionales por edad/sexo
- ✨ Soporte para objetivos de pérdida/ganancia de peso
- 📊 Dashboard con métricas de calidad nutricional

### Cambiado
- 🔄 Migración de CSV a base de datos estructurada
- 🔄 Interfaz completamente rediseñada con Shinydashboard

### Corregido
- 🐛 Multiple correcciones menores de estabilidad
- 🐛 Mejoras en manejo de errores

## [1.2.0] - 2023-07-20

### Añadido
- ✨ Primera versión del algoritmo de optimización lineal
- ✨ Interfaz web básica con Shiny
- ✨ Cálculo de Tasa Metabólica Basal (TMB)
- 📊 Visualizaciones básicas de distribución nutricional

### Cambiado
- 🔄 Refactorización completa del código R base

## [1.1.0] - 2023-06-15

### Añadido
- ✨ Base de datos inicial de alimentos mexicanos
- ✨ Funciones básicas de cálculo nutricional
- ✨ Validación de parámetros de entrada

### Corregido
- 🐛 Corrección en cálculos de proteínas por kg de peso

## [1.0.0] - 2023-05-01

### Añadido
- ✨ Versión inicial del proyecto
- ✨ Estructura básica de la aplicación Shiny
- ✨ Funcionalidades core de optimización dietética
- 📚 Documentación básica
- 🧪 Casos de prueba iniciales

---

## 🏷️ Tipos de Cambios

- `✨ Añadido`: Para nuevas funcionalidades
- `🔄 Cambiado`: Para cambios en funcionalidades existentes  
- `❌ Eliminado`: Para funcionalidades eliminadas
- `🐛 Corregido`: Para corrección de bugs
- `📊 Datos`: Para cambios en datasets o bases de datos
- `📚 Docs`: Para cambios solo en documentación
- `🔒 Seguridad`: Para correcciones relacionadas con seguridad
- `🎨 Estilo`: Para cambios de formato, CSS, o estilo visual
- `⚡ Performance`: Para mejoras de rendimiento
- `🧪 Tests`: Para añadir o modificar tests

## 📋 Convenciones

### Formato de Versiones
- **MAJOR.MINOR.PATCH** (ej: 2.1.3)
- **MAJOR**: Cambios incompatibles en API
- **MINOR**: Nueva funcionalidad compatible hacia atrás  
- **PATCH**: Correcciones de bugs compatibles

### Fechas
- Formato: YYYY-MM-DD
- Zona horaria: UTC

### Enlaces
- Cada versión debe tener enlaces a commits relevantes
- Issues y PRs referenciados cuando sea aplicable

---

## 🤝 Contribuciones

Para contribuir al changelog:
1. Añade entradas en la sección `[Sin liberar]`
2. Sigue las convenciones de formato establecidas
3. Incluye enlaces a PRs/issues cuando sea relevante
4. Al hacer release, mueve entradas a nueva sección versionada