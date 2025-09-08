# 4. Un modelo de optimización de la dieta para personas con diabetes

## 4.1 Planteamiento del problema y propuesta de solución

### Definición del problema

El manejo nutricional de personas con diabetes tipo 2 representa un desafío complejo que requiere la optimización simultánea de múltiples objetivos nutricionales conflictivos. Los profesionales de la salud deben considerar:

- **Control glucémico**: Minimización de la carga glucémica (CG) total
- **Prevención cardiovascular**: Reducción del sodio y ácidos grasos saturados
- **Calidad nutricional**: Cumplimiento de requerimientos de micronutrientes
- **Practicidad**: Viabilidad de implementación en la vida cotidiana

### Propuesta de solución

El sistema implementa un **modelo de programación lineal multiobjetivo** que transforma este problema complejo en un problema de optimización matemática solucionable. La propuesta integra:

1. **Función objetivo ponderada** que incorpora múltiples criterios nutricionales
2. **Restricciones nutricionales** basadas en normativas mexicanas (PROY-NOM-015-SSA2-2018)
3. **Restricciones de calidad** derivadas de guías alimentarias internacionales
4. **Restricciones de practicidad** basadas en patrones de consumo realistas

## 4.2 Obtención de datos

### 4.2.1 Recolección de información alimentaria y normativa

El sistema utiliza como fuente primaria el **Sistema Mexicano de Alimentos Equivalentes (SMAE)**, que proporciona:

- **Base estandarizada**: 1,500+ alimentos categorizados en 11 grupos principales
- **Composición nutricional**: 19 nutrientes por alimento
- **Porciones equivalentes**: Cantidades normalizadas por intercambio

**Grupos de alimentos incluidos:**
- Verduras
- Frutas  
- Cereales (sin grasa y con grasa)
- Leguminosas
- Alimentos de origen animal (muy bajo, bajo, moderado y alto en grasa)
- Leche (descremada, semidescremada, entera, con azúcar)
- Aceites y grasas
- Azúcares (sin grasa, con grasa)

### 4.2.2 Depuración, normalización y transformación

El proceso de limpieza implementado en la función `load_food_data()` realiza:

```r
# Manejo de valores faltantes
data <- data %>%
  mutate(across(all_of(num_columns), ~ na_if(.x, "ND"))) %>%
  mutate(across(all_of(num_columns), as.numeric)) %>%
  drop_na(all_of(num_columns))
```

**Criterios de depuración:**
- Eliminación de registros con valores "ND" (No Determinado)
- Conversión a tipos numéricos apropiados
- Exclusión de alimentos con información incompleta de nutrientes críticos

### 4.2.3 Base de datos final (estructura, atributos y normalización)

**Estructura principal:**
- **Identificadores**: Alimento, Grupo, Cantidad_sugerida, Unidad
- **Macronutrientes**: Energía, Proteína, Lípidos, Carbohidratos
- **Micronutrientes**: Fibra, Vitamina_A, Ácido_Ascórbico, Ácido_Fólico, Hierro, Potasio, Calcio, Selenio, Fósforo
- **Componentes específicos para diabetes**: Sodio, Colesterol, Azúcar, IG (Índice Glucémico), CG (Carga Glucémica)

**Normalización:**
- Todos los valores nutricionales expresados por porción estándar
- Unidades homogéneas (g, mg, kcal, mmol/L)
- Codificación categórica consistente para grupos alimentarios

### 4.2.4 Almacenamiento

El sistema utiliza un enfoque de **memoria en sesión** con capacidad de exportación:
- Carga dinámica desde CSV
- Procesamiento en estructuras de datos R (data.frames)
- Exportación opcional a múltiples formatos (CSV, HTML)

## 4.3 Generación del modelo

### 4.3.1 Planteamiento de supuestos

**Supuestos fundamentales:**

1. **Linealidad nutricional**: La contribución nutricional de cada alimento es proporcional a su cantidad consumida
2. **Intercambiabilidad**: Los alimentos dentro del mismo grupo pueden sustituirse manteniendo equivalencia nutricional
3. **Optimización diaria**: El modelo optimiza para un período de 24 horas
4. **Disponibilidad completa**: Todos los alimentos en la base están disponibles para el usuario
5. **Cumplimiento total**: El usuario seguirá exactamente la dieta prescrita

**Supuestos específicos para diabetes:**
- Prioritar control glucémico sobre otros objetivos nutricionales
- Considerar interacciones sinérgicas entre fibra y control glucémico
- Limitar alimentos de alto índice glucémico independientemente de su valor nutricional

### 4.3.2 Definición de la función objetivo

La función objetivo implementa un **enfoque de programación por metas ponderada**:

$$\min Z = \sum_{j=1}^{n} \left( w_1 \cdot CG_j + w_2 \cdot Na_j + w_3 \cdot AGS_j \right) \cdot x_j$$

Donde:
- $x_j$ = cantidad del alimento $j$ (en porciones)
- $CG_j$ = carga glucémica por porción del alimento $j$
- $Na_j$ = contenido de sodio por porción del alimento $j$ (mg)
- $AGS_j$ = ácidos grasos saturados por porción del alimento $j$ (g)
- $w_1, w_2, w_3$ = pesos relativos de cada criterio

**Implementación computacional:**
```r
build_objective_function <- function(foods_df, objective_nutrients, weights) {
  f.obj <- rep(0, nrow(foods_df))
  
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
```

### 4.3.3. Formulación de la matriz de restricciones

El modelo incorpora **tres niveles de restricciones**:

#### Nivel 1: Restricciones nutricionales básicas

**Restricciones energéticas:**
$$GER \leq \sum_{j=1}^{n} E_j \cdot x_j \leq GET$$

**Restricciones de macronutrientes:**
$$0.25 \cdot GER \leq \sum_{j=1}^{n} P_j \cdot x_j \leq 0.25 \cdot GET$$ (Proteínas)

$$0.25 \cdot GER \leq \sum_{j=1}^{n} L_j \cdot x_j \leq 0.25 \cdot GET$$ (Lípidos)

$$0.50 \cdot GER \leq \sum_{j=1}^{n} CHO_j \cdot x_j \leq 0.50 \cdot GET$$ (Carbohidratos)

**Restricciones de micronutrientes:**
$$\sum_{j=1}^{n} \mu_{ij} \cdot x_j \geq RDA_i \quad \forall i \in \{Fibra, VitA, VitC, Folato, Fe, K, Ca, Se, P\}$$

$$\sum_{j=1}^{n} \mu_{ij} \cdot x_j \leq UL_i \quad \forall i \in \{Na, Colesterol\}$$

#### Nivel 2: Restricciones de calidad dietética

**Restricciones por grupos alimentarios:**
$$\sum_{j \in G_k} x_j \geq MG_k \quad \forall k \in \{frutas, verduras, legumbres, cereales, aceites, lácteos\}$$

$$\sum_{j \in G_k} x_j \leq MXG_k \quad \forall k \in \{lácteos, carnes, azúcares\}$$

Donde $G_k$ representa el conjunto de alimentos del grupo $k$.

#### Nivel 3: Restricciones de practicidad

**Límites individuales por alimento:**
$$x_j \leq L_j \quad \forall j$$

**Límites agregados por categorías:**
$$\sum_{j \in C_k} x_j \leq LC_k \quad \forall k$$

**Implementación matricial:**
```r
nutrition_constraints <- matrix(c(
  foods_df$Energia, foods_df$Energia, 
  foods_df$Proteina, foods_df$Proteina,
  foods_df$Lipidos, foods_df$Lipidos, 
  foods_df$Carbohidratos, foods_df$Carbohidratos,
  foods_df$Fibra, foods_df$Vitamina_A, foods_df$Acido_Ascorbico, 
  foods_df$Acido_Folico, foods_df$Hierro, foods_df$Potasio, 
  foods_df$Calcio, foods_df$Selenio, foods_df$Fosforo, 
  foods_df$Sodio, foods_df$Colesterol
), nrow = 19, byrow = TRUE)
```

### 4.3.4. Definición vector de recursos

El vector de recursos se fundamenta en la **PROY-NOM-015-SSA2-2018** y estándares internacionales:

#### Requerimientos energéticos (Ecuación de Mifflin-St Jeor)

**Para hombres:**
$$GER = 10 \times peso + 6.25 \times altura - 5 \times edad + 5$$

**Para mujeres:**
$$GER = 10 \times peso + 6.25 \times altura - 5 \times edad - 161$$

**Gasto energético total:**
$$GET = GER \times FA$$

Donde $FA$ es el factor de actividad física (1.2-1.9).

#### Ingestas Dietéticas de Referencia (IDR)

**Micronutrientes críticos para diabetes:**
- Fibra: ≥30 g/día (ADA, 2019)
- Vitamina A: ≥730 μg/día
- Vitamina C: ≥60 mg/día
- Ácido fólico: ≥200 μg/día
- Hierro: ≥15 mg/día
- Potasio: ≥1250 mg/día
- Calcio: ≥900 mg/día
- Selenio: ≥70 μg/día
- Fósforo: ≥560 mg/día

**Límites superiores tolerables:**
- Sodio: ≤2300 mg/día (PROY-NOM-015-SSA2-2018)
- Colesterol: ≤100 mg/día (ADA)

**Vector de recursos implementado:**
```r
f.rhs <- c(
  constraints$energy$min, constraints$energy$max,      # Energía
  constraints$protein$min, constraints$protein$max,    # Proteínas  
  constraints$fat$min, constraints$fat$max,           # Lípidos
  constraints$carbs$min, constraints$carbs$max,       # Carbohidratos
  30, 730, 60, 200, 15, 1250, 900, 70, 560,          # Micronutrientes mínimos
  2300, 100                                           # Límites máximos Na, Colesterol
)
```

## 4.4 Modelo Dual y precios sombra

### Formulación del problema dual

**Problema primal:**
$$\min \mathbf{c}^T\mathbf{x}$$
$$\text{sujeto a: } \mathbf{A}\mathbf{x} \geq \mathbf{b}, \mathbf{x} \geq \mathbf{0}$$

**Problema dual correspondiente:**
$$\max \mathbf{b}^T\mathbf{y}$$
$$\text{sujeto a: } \mathbf{A}^T\mathbf{y} \leq \mathbf{c}, \mathbf{y} \geq \mathbf{0}$$

### Interpretación de precios sombra en el contexto nutricional

Los precios sombra ($\lambda_i$) representan el **costo marginal de oportunidad** de cada restricción nutricional:

#### Restricciones energéticas
- $\lambda_{energia}$: Cambio en la función objetivo por unidad adicional de energía requerida
- **Interpretación clínica**: Costo de satisfacer necesidades calóricas adicionales en términos de deterioro del control glucémico

#### Restricciones de micronutrientes
- $\lambda_{fibra}$: Beneficio marginal de incrementar el requerimiento de fibra
- **Interpretación clínica**: Valor de incrementar fibra dietética en el control glucémico y calidad general de la dieta

#### Restricciones de calidad dietética
- $\lambda_{frutas}$: Beneficio marginal de incrementar el requerimiento mínimo de frutas
- **Interpretación clínica**: Trade-off entre diversidad dietética y control glucémico estricto

### Aplicaciones prácticas de los precios sombra

1. **Priorización de intervenciones**: Identificar qué restricciones nutricionales ofrecen mayor beneficio marginal
2. **Análisis de sensibilidad**: Evaluar robustez de la solución ante cambios en requerimientos
3. **Personalización terapéutica**: Adaptar recomendaciones según la sensibilidad individual a diferentes nutrientes
4. **Optimización de costos**: En extensiones futuras, incorporar costos económicos de los alimentos

### Complementariedades y holguras

**Condiciones de complementariedad:**
- Si $\lambda_i > 0$, entonces la restricción $i$ está activa (se cumple con igualdad)
- Si la restricción $i$ tiene holgura, entonces $\lambda_i = 0$

**Interpretación clínica:**
- Restricciones activas ($\lambda_i > 0$): Nutrientes limitantes que requieren atención prioritaria
- Restricciones con holgura: Nutrientes que se satisfacen holgadamente con la dieta óptima

### Índice de calidad dietética integrado

El sistema complementa la optimización matemática con un **Índice de Calidad Dietética (ICD)** que evalúa la solución óptima:

$$ICD = \sum_{k=1}^{10} w_k \cdot S_k$$

Donde $S_k$ representa la puntuación del componente $k$:

1. **Frutas** (12%): $S_1 = \min(10, \frac{P_{frutas}}{2.0} \times 10)$
2. **Verduras** (12%): $S_2 = \min(10, \frac{P_{verduras}}{2.5} \times 10)$
3. **Legumbres** (8%): $S_3 = \min(10, \frac{P_{legumbres}}{0.3} \times 10)$
4. **Cereales** (10%): $S_4 = \min(10, \frac{P_{cereales}}{1.0} \times 10)$
5. **Aceites/Grasas** (8%): $S_5 = \min(10, \frac{P_{aceites}}{1.0} \times 10)$
6. **Lácteos** (10%): Función por tramos para rango óptimo 1.5-4.5 porciones
7. **Carnes** (10%): Penalización por exceso >4.0 porciones
8. **Azúcares** (10%): Penalización progresiva
9. **Variedad** (10%): Proporción de grupos alimentarios incluidos
10. **Practicidad** (10%): Evaluación de viabilidad de implementación

**Interpretación del ICD:**
- **≥8.5**: Excelente calidad dietética y practicidad
- **7.0-8.4**: Buena calidad dietética y practicidad  
- **5.5-6.9**: Calidad dietética moderada
- **<5.5**: Calidad dietética y practicidad deficiente

### Validación y robustez del modelo

El sistema implementa múltiples escenarios de validación que permiten evaluar:

1. **Consistencia interna**: Comparación entre soluciones con y sin restricciones de calidad
2. **Sensibilidad paramétrica**: Evaluación bajo diferentes perfiles demográficos
3. **Estabilidad**: Análisis de convergencia con diferentes pesos en la función objetivo
4. **Viabilidad clínica**: Evaluación por profesionales de la salud

Esta aproximación metodológica proporciona un marco robusto para la optimización de dietas en diabetes tipo 2, balanceando rigor matemático con aplicabilidad clínica práctica.