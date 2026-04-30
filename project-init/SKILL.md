---
name: project-init
description: >
  Skill para cerrar la brecha entre product-discovery y tech-feasibility.
  Transforma hallazgos de discovery en un plan ejecutable para desarrollo.
  Recibe como entrada el Discovery Report y produce un Project Framing Doc.

  Usa esta skill cuando ya exista un Discovery Report con:
  - Usuario principal identificado
  - Problema validado
  - Hipótesis de riesgos
  - Señal de enfoque de desarrollo

  El output principal es el Project Framing Doc (Project Charter como alias).

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/03"
  prev: "product-discovery"
  next: "tech-feasibility"
---

# project-init — Skill de Transición

> **Pipeline recomendado:** `brainstorm` → `product-discovery` → `project-init` → `tech-feasibility`
> **Input:** Discovery Report de `product-discovery` (o Product Brief por bypass)
> **Output:** Project Framing Doc (Project Charter como alias)

---

## When to Use

Usa esta skill cuando el usuario necesite:

- Decidir el enfoque de desarrollo (predictivo, adaptativo o híbrido)
- Definir una secuencia de trabajo ligera para el proyecto
- Estructurar el alcance inicial en épics y stories
- Establecer acuerdos mínimos para avanzar sin ambigüedad

## When NOT to Use

- El proyecto ya es pequeno y el alcance ya está claro
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias u organizacionales
- En este caso, se puede usar el bypass: `brainstorm → product-discovery → tech-feasibility`

---

## Pre-flight Checklist

- [ ] Existe un Discovery Report con enfoque sugerido
- [ ] El problema y usuario ya están validados
- [ ] Ya hay una señal clara del tipo de proyecto

Si no hay suficiente claridad, volver a `product-discovery`.

---

## Filosofía

project-init no es burocracia.
Es el puente entre entender el problema y saber cómo construirlo.

### Regla de oro

> El mejor plan no es el más detallado.
> Es el que permite avanzar sin bloquearse y que cabe en un sprint.

---

## Fase 1 — Selección de Enfoque de Desarrollo

**Objetivo**: Decidir cómo se construirá el proyecto.

**Pregunta clave**:
> ¿Los requisitos son claros y estables, o van a evolucionar con feedback?

**Marco de decisión**:

| Señal | Enfoque recomendado | Justificación |
|-------|---------------------|---------------|
| Requisitos claros, entregable definido, cambio costoso | **Predictivo** | El alcance es fijo y los riesgos de cambio son altos |
| Requisitos evolucionan, feedback continuo es clave | **Adaptativo (Ágil)** | El valor se entrega iterativamente, los cambios son baratos |
| Mix de estable y evolutivo | **Híbrido** | Componentes regulatorios (predictivo) + desarrollo iterativo |

**Output**:
- `enfoque`: Predictivo / Adaptativo / Híbrido
- `justificación`: Razón técnica y de negocio

**Restricción**: No se puede continuar sin esta decisión.

---

## Fase 2 — Fases del Proyecto y Cadencia

**Objetivo**: Definir el camino temporal del proyecto de manera ligera.

**Actividades**:
1. Definir fases del proyecto (máximo 4):
   - Usa nombres que tengan sentido para el contexto real del proyecto
   - Ejemplos válidos: descubrimiento → construcción → validación → release
   - No fuerces un modelo universal si el proyecto no lo necesita

2. Establecer cadencia (opcional para proyectos pequeños):
   - Duración de iteración: 1, 2 o 4 semanas
   - Quién revisa: decisor responsable / owner del backlog
   - La revisión puede ser por iteración, por entregable o por milestone ligero

3. Priorización:
   - Método: backlog priorizado por valor
   - Talla: S/M/L

**Output**:
- `fases`: Lista de fases
- `cadencia`: Duración y frecuencia (opcional)
- `quien_revisa`: Rol responsable

---

## Propagación de Stack

Si el stack elegido en `tech-feasibility` es **Supabase**, esta señal debe propagarse a fases siguientes:

- **tech-feasibility** confirma Supabase → señal de stack guardada
- **sdd-design/apply**: activar `supabase` para integración general
- **sdd-design/apply** (con SQL/RLS/Postgres): activar `supabase-postgres-best-practices`
- El orquestador resuelve estas activaciones vía `.atl/skill-registry.md`

> **Nota**: Las skills de Supabase requieren instalación previa en `~/.config/opencode/skills/` para estar disponibles realmente. El registry define orquestación, no instala.

Si el stack elegido en `tech-feasibility` es **Firebase**, esta señal debe propagarse a fases siguientes:

- **tech-feasibility** confirma Firebase → señal de stack guardada
- **sdd-design/apply**: activar `firebase-basics` para configuración general
- **sdd-design/apply** (con Auth específico): activar `firebase-auth-basics`
- **sdd-design/apply** (con Firestore Standard): activar `firebase-firestore-standard`
- **sdd-design/apply** (con Firestore Enterprise Native Mode explícito): activar `firebase-firestore-enterprise-native-mode`
- **sdd-design/apply** (con Hosting clásico/estático): activar `firebase-hosting-basics`
- **sdd-design/apply** (con Next.js/Angular/SSR/App Hosting): activar `firebase-app-hosting-basics`
- **sdd-design/apply** (con Security Rules): activar `firebase-security-rules-auditor`
- **sdd-design/apply** (con Data Connect/SQL/GraphQL): activar `firebase-data-connect`
- **sdd-design/apply** (con Firebase AI Logic/Gemini): activar `firebase-ai-logic-basics`
- **sdd-design/apply** (con Genkit JS/TS): activar `developing-genkit-js`
- El orquestador resuelve estas activaciones vía `.atl/skill-registry.md` y sus compact rules.

> **Nota**: Las skills de Firebase requieren instalación previa en `~/.config/opencode/skills/` para estar disponibles realmente. El registry define orquestación lógica (cuándo activar), no garantiza disponibilidad real. No activar skills Firebase solo por mencionar Firebase genéricamente.

---

## Fase 3 — Alcance Estructurado Inicial

**Objetivo**: Transformar el alcance en trabajo ejecutable para el primer sprint.

**Entrada**: Discovery Report

**Proceso**:
1. Extraer los MUST-HAVE del discovery
2. Convertir cada MUST-HAVE en user stories:
   ```
   Como [tipo de usuario],
   quiero [funcionalidad],
   para [resultado de valor]
   ```
3. Definir criterios de aceptación mínimos (solo para stories críticas)
4. Estimar con tamaño S/M/L
5. Limitar al primer sprint o primera iteración detallada
6. Épics de alto nivel para el resto del roadmap

**Output**:
- `backlog_inicial`: User stories con aceptación
- `epics`: Epics para desarrollo posterior
- `talla`: Distribución S/M/L del sprint inicial

**Regla**: El backlog debe ser suficiente para un sprint, pero no completo al 100%.

---

## Fase 4 — Gobernanza Mínima

**Objetivo**: Acordar lo mínimo necesario para que el proyecto avance sin confusión.

**Elementos esenciales (3 preguntas)**:

1. **¿Cómo tomamos decisiones?**
   - Consenso / Decisión del lead técnico / Autoridad única

2. **¿Cómo gestionamos cambios de alcance?**
    - Proceso informal (proyectos pequeños) o formal (proyectos grandes)

3. **¿Qué necesita estar claro antes de pasar a la siguiente fase?**
   - Ejemplo: decisión tomada / alcance suficientemente claro / backlog inicial priorizado

**Definition of Done (mínimo y opcional)**:
- Úsala solo si aporta claridad real al proyecto
- Debe ser breve, adaptable y proporcional al tamaño del trabajo
- No la conviertas en un checklist rígido si todavía están en framing

**Output**:
- `acuerdos`: Decisiones tomadas
- `criterios_de_avance`: Señales mínimas para pasar de framing a factibilidad técnica

---

## Bypass — Cuándo Saltar project-init

**Condiciones para usar bypass** (`brainstorm → product-discovery → tech-feasibility`):

- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con el Discovery Report directo

**En bypass**: `tech-feasibility` recibe el Discovery Report como input principal.

---

## Output Final — Project Framing Doc v1.0

```markdown
# [Nombre del Proyecto] — Project Framing Doc
**Generado por:** project-init skill v1.0
**Fecha:** [fecha]

## 1. Enfoque de desarrollo
- Enfoque: [Predictivo / Adaptativo / Híbrido]
- Justificación: [por qué se eligió este enfoque]

## 2. Fases del proyecto
1. [Fase 1]
2. [Fase 2]
3. [Fase 3]
4. [Fase 4]

## 3. Cadencia (opcional)
- Iteración: [1/2/4 semanas]
- Quién revisa: [rol]
- Frecuencia: [final de iteración / semanal / otro]

## 4. Alcance inicial
### User Stories del primer sprint
- US1: Como [usuario], quiero [funcionalidad], para [valor]
  - Aceptación: [criterios]
  - Talla: [S/M/L]

### Épics (resto del roadmap)
- [Épica 1]
- [Épica 2]

## 5. Gobernanza mínima
- Decisiones: [cómo se toman]
- Cambios: [cómo se gestionan]
- Criterios de avance: [qué debe estar claro para pasar a tech-feasibility]
- Nota opcional: [DoD mínima solo si aplica]

## 6. Stakeholders principales
- [Stakeholder 1]: [rol]
- [Stakeholder 2]: [rol]

## 7. Siguiente paso
- Pasar a tech-feasibility con este Project Framing Doc
```

---

## Criterio de salida

Esta skill está completa cuando ya existe:

- ✅ un enfoque de desarrollo seleccionado con justificación
- ✅ fases definidas de manera ligera
- ✅ alcance inicial en user stories (mínimo 1 sprint)
- ✅ gobernanza mínima acordada
- ✅ criterios de avance claros hacia tech-feasibility
- ✅ stakeholders principales identificados

---

## Referencias PMBOK 8

- **Gobernanza**: 1.1 Iniciar Proyecto o Fase, 1.2 Integrar y Alinear Planes
- **Alcance**: 2.1 Planificar Gestión del Alcance, 2.2 Obtener/Requisitos, 2.3-2.4 Definir Alcance
- **Interesados**: 1.1-1.2 (identificación temprana)
- **Enfoque**: 1.2 (selección adaptativa del método)
