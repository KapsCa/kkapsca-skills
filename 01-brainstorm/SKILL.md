---
name: brainstorm
description: >
  PASO 1 DE 3 del Project Kickstart Pipeline. Convierte una idea vaga en un Product Brief
  estructurado y accionable. Guía al usuario a través de definición de problema, usuario
  objetivo, features del MVP y diferenciadores.

  SIEMPRE activa esta skill cuando el usuario diga: "tengo una idea", "quiero hacer una app",
  "quiero construir algo", "no sé por dónde empezar", "ayúdame a definir mi idea", "quiero
  validar mi idea", "brainstorm", o cualquier variación de querer explorar o definir un
  concepto de producto — aunque no use la palabra "brainstorm" explícitamente. Carga esta
  skill ANTES de cualquier sesión de ideación.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "2.0"
  pipeline: "project-kickstart/01"
  next: "product-discovery"
---

# Brainstorm — Paso 1 de 3

> **Pipeline:** `brainstorm` → `product-discovery` → `tech-feasibility`  
> **Input:** Idea vaga  
> **Output:** Product Brief (feed para product-discovery)

---

## When NOT to Use

- La idea ya está definida con problema y usuario claros → empieza en `product-discovery`
- El usuario pide mejoras a un proyecto existente → eso es refinamiento, no brainstorm
- El usuario quiere explorar tecnologías sin un producto en mente → eso es research técnico

---

## Filosofía

Una buena sesión de brainstorm NO es tirar ideas al aire.
Es una **entrevista estructurada** que termina con un documento de producto claro.

El orden importa — nunca lo rompas:
1. **Problema primero** — si no hay problema real, no hay producto
2. **Usuario segundo** — sin saber quién lo usa, no puedes priorizar nada
3. **Features tercero** — solo después de entender 1 y 2
4. **Tech stack al final** — la tecnología sirve al producto, no al revés

---

## Fase 1 — Captura la Idea Cruda

Pídele al usuario que describa su idea en 2-3 oraciones, sin filtros.
No corrijas todavía. Escucha y observa:

- ¿Menciona un problema concreto o solo una solución?
- ¿Hay un usuario específico o es "para todos"?
- ¿Tiene referentes? ("como Uber pero para X")

**Pregunta de arranque:**
> "Descríbeme tu idea como si me la contaras a un amigo en 30 segundos."

---

## Fase 2 — Definición del Problema

El paso más importante. Muchas apps fallan porque resuelven el problema equivocado.

Haz estas preguntas **una a la vez**, nunca todas juntas:

**1. ¿Qué problema concreto resuelve?**
- Fuerza al usuario a articular el dolor, no la solución
- Si dice "quiero una app de recetas" → pregunta: "¿qué problema tiene la gente con las recetas hoy?"

**2. ¿Cómo se resuelve ese problema HOY sin tu app?**
- WhatsApp grupos, Excel, papel, otra app — siempre hay un workaround
- Si no hay workaround, probablemente no es un problema real

**3. ¿Por qué la solución actual no es suficiente?**
- Acá está el espacio para el producto

**Output de esta fase:**
```
Problema:         [Descripción concreta del dolor]
Solución actual:  [Cómo lo resuelven hoy]
Gap:              [Por qué eso no es suficiente]
```

---

## Fase 3 — Usuario Objetivo

"Para todos" es la trampa más común. Un producto para todos no sirve a nadie bien.

| Campo | Pregunta |
|---|---|
| **Perfil** | ¿Quién es? (edad, ocupación, contexto de vida) |
| **Frecuencia** | ¿Cada cuánto usaría la app? |
| **Motivación** | ¿Qué gana concretamente usando tu app? |
| **Fricción** | ¿Qué lo haría NO usarla o desinstalarla? |

**Técnica — El Usuario Más Exigente:**
> "¿Quién es la persona que MÁS necesita esto y que pagaría por ello mañana mismo?"

Ese es tu usuario primario. Diseña el MVP para él primero.

---

## Fase 4 — Features: Core vs Nice-to-Have

Técnica **MoSCoW** adaptada a MVP:

| Categoría | Criterio | Ejemplo |
|---|---|---|
| **Must Have** | Sin esto la app no existe | Login, funcionalidad principal |
| **Should Have** | Importante pero no bloqueante | Notificaciones, filtros |
| **Could Have** | Deseable pero postergable | Dark mode, gamificación |
| **Won't Have (MVP)** | Explícitamente fuera del MVP | IA avanzada, social features |

**Regla del MVP:**
> El MVP es la versión más pequeña del producto que le resuelve el problema
> al usuario más exigente. Si puedes resolver el problema sin una feature,
> esa feature NO es Must Have.

Cuando el usuario quiera agregar features, pregunta:
> "¿El usuario primario no puede vivir sin esto en la primera versión?"

---

## Fase 5 — Diferenciadores

¿Por qué alguien usaría ESTA app sobre lo que ya existe?
Elige **máximo 2** de la siguiente lista:

- **Velocidad** — lo hace más rápido que la competencia
- **Simplicidad** — menos pasos para llegar al resultado
- **Nicho** — sirve a un segmento que otros ignoran
- **Integración** — conecta cosas que hoy están separadas
- **Precio** — modelo de negocio distinto (freemium, suscripción, pago único)
- **Offline-first** — funciona sin internet cuando otros no

Si el usuario no puede elegir 2 claros diferenciadores, el producto no está listo
para pasar a la siguiente fase.

---

## Reglas de Conducción

- Haz **UNA pregunta a la vez** — bombardear al usuario lo paraliza
- **No sugieras features** en las primeras 3 fases — escucha primero
- **Desafía el "para todos"** — siempre redirige a un usuario específico
- **Termina con un próximo paso accionable** — sin siguiente paso, el brainstorm fue inútil

---

## Output Final — Product Brief

Genera este documento al terminar. Es el input para `product-discovery`.

```markdown
# [Nombre Tentativo] — Product Brief
**Generado por:** KkapsCa / brainstorm skill v2.0
**Fecha:** [fecha]

## Problema
[1-2 oraciones del dolor real y concreto]

## Solución Actual y su Gap
[Cómo lo resuelven hoy y por qué no es suficiente]

## Propuesta de Valor
[Cómo tu app resuelve el problema — 1 oración]

## Usuario Primario
**Perfil:** [descripción concreta, no genérica]
**Frecuencia de uso:** [diario / semanal / mensual]
**Motivación principal:** [qué gana]
**Mayor fricción:** [qué lo haría no usarla]

## MVP — Must Haves
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

## Fuera del MVP
- Feature X → v2
- Feature Y → v3

## Diferenciadores Clave (máx. 2)
1. [Diferenciador 1]
2. [Diferenciador 2]

## Notas para Product Discovery
[Preguntas abiertas, supuestos a validar, áreas de incertidumbre]

---
**Siguiente paso:** Ejecuta `product-discovery` con este brief como input.
```

---

> ℹ️ **¿Ya tienes este output?**  
> Pasa directamente a la skill `product-discovery` con el Product Brief como contexto.
