---
name: brainstorm
description: >
  PASO 1 de un pipeline de definición de producto. Convierte una idea vaga en un
  Product Brief útil, enfocándose en problema, usuario, propuesta de valor, MVP y
  diferenciadores. Sirve como punto de entrada cuando todavía no existe suficiente
  claridad para pasar directo a discovery o a decisiones técnicas.

  Usa esta skill cuando alguien tenga una idea inicial, quiera aterrizarla, no sepa
  por dónde empezar o necesite transformar intuición en una hipótesis de producto más clara.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "4.0"
  pipeline: "project-kickstart/01"
  next: "product-discovery"
  prev: ""
---

# Brainstorm — Step 1

> **Pipeline recomendado:** `brainstorm` → `product-discovery` → `project-init` → `tech-feasibility`
> **Input:** idea vaga, intuición o problema mal definido
> **Output:** Product Brief

---

## When to Use

Usa esta skill cuando el usuario diga cosas como:

- "tengo una idea",
- "quiero hacer una app",
- "no sé por dónde empezar",
- "ayúdame a aterrizar esto",
- "quiero definir mejor mi producto".

## When NOT to Use

- Ya existe claridad suficiente de problema, usuario y MVP.
- El usuario ya trae un Product Brief razonable.
- El objetivo real es comparar tecnologías o planear implementación.

---

## Pre-flight Checklist

- [ ] El usuario realmente tiene una idea, no un Product Brief completo.
- [ ] Todavía no existe claridad suficiente de problema, usuario y MVP.
- [ ] El objetivo es aterrizar la idea, no decidir stack.

Si alguna casilla falla, no uses esta skill; pasa a la skill correcta.

---

## Filosofía

Brainstorm no es lanzar ideas al aire.
Es convertir intuición en una hipótesis de producto que se pueda analizar después.

### Orden correcto (PMBOK 8)

1. **Problema** — Identificar el dolor real
2. **Usuario** — Identificar el usuario principal
3. **Propuesta de valor** — Proponer solución
4. **MVP** — Definir lo mínimo necesario
5. **Diferenciadores** — Elegir 1-2 ventajas clave
6. **Preguntas abiertas** — Qué dudas quedan

La tecnología va al final, no al principio.

---

## Fase 1 — Idea cruda

Pide una explicación corta y sin filtros.

### Regla para avanzar

Avanza a Fase 2 solo cuando exista una explicación de 30 segundos y haya al menos una pista concreta de problema y usuario.

### Pregunta de arranque

> "Explícame tu idea como si me la contaras en 30 segundos."

### Qué observar

- ¿habla de un problema o solo de una solución?,
- ¿hay un usuario concreto o "todo el mundo"?,
- ¿menciona referentes?,
- ¿suena a dolor real o a ocurrencia simpática?

---

## Fase 2 — Problema real

Aquí se gana o se pierde la idea.

Haz una pregunta a la vez:

1. **¿Qué problema concreto resuelve?**
2. **¿Cómo se resuelve hoy sin tu producto?**
3. **¿Qué tiene de insuficiente la solución actual?**

### Salida de esta fase

```text
Problema: [dolor concreto]
Solución actual: [cómo lo resuelven hoy]
Gap: [qué queda mal resuelto]
```

### Regla para avanzar

No avances a Fase 3 si faltan problema, solución actual o gap.

---

## Fase 3 — Usuario principal + Interesados (PMBOK 8)

"Para todos" no sirve.

### Regla para avanzar

Avanza a Fase 4 solo si el usuario principal ya no es genérico y puede describirse con claridad.

Define un usuario primario con estas preguntas:

- ¿quién sufre más este problema?,
- ¿con qué frecuencia le pasa?,
- ¿qué ganaría usando esta solución?,
- ¿qué lo haría no usarla?

### Pregunta clave

> "¿Quién es la persona que más necesita esto y que más se beneficiaría si existiera mañana?"

**PMBOK 8 - Interesados**: amplía a:
- Usuario principal (quien sufre)
- Patrocinador/decisor (quién aprueba/invierte)
- Equipo (quién construirá)
- Interesados secundarios/regulatorios (según aplique)

---

## Fase 4 — Propuesta de valor

Condensa la idea en una frase:

```text
Ayudamos a [usuario] a [resolver problema] mediante [solución],
para que pueda [resultado valioso].
```

Si esta frase sale borrosa, todavía no hay suficiente claridad.

### Regla para avanzar

Avanza a Fase 5 solo cuando la frase de valor sea clara y específica.

---

## Fase 5 — MVP (y alcance inicial)

Separa lo esencial de lo decorativo.

### Regla para avanzar

Avanza a Fase 6 solo cuando el MVP esté recortado y no incluya más de lo necesario para resolver el problema principal.

### Clasificación sugerida

- **Must Have** → sin esto, el producto no resuelve el problema.
- **Should Have** → importante, pero puede esperar.
- **Could Have** → nice to have.
- **Not in MVP** → explícitamente fuera de la primera versión.

### Regla del MVP

> El MVP es la versión más pequeña que resuelve el problema principal del usuario principal.

---

## Fase 6 — Diferenciadores

Elige máximo 2.

- velocidad,
- simplicidad,
- especialización en un nicho,
- integración,
- precio/modelo,
- experiencia offline,
- mejor UX,
- automatización.

Si no hay diferenciador claro, todavía falta trabajo de pensamiento.

### Regla para avanzar

Si no puedes elegir máximo 2 diferenciadores claros, no cierres el brief todavía.

---

## Reglas de conducción

- Una pregunta a la vez.
- No sugerir features demasiado pronto.
- Desafiar ideas difusas con respeto pero con firmeza.
- No hablar de stack si el problema aún no está bien definido.
- Terminar siempre con un output útil, no con conversación suelta.

---

## Output Final — Product Brief v4.0

Solo genera este bloque cuando ya pasaste por todas las reglas de avance anteriores.

```markdown
# [Nombre Tentativo] — Product Brief
**Generado por:** brainstorm skill v4.0
**Fecha:** [fecha]
**Contexto org:** [personal / negocio / organización]
**Interesados:** [lista principal]

## 1. Problema
[descripción concreta del dolor]

## 2. Solución actual
[cómo se resuelve hoy]

## 3. Gap detectado
[qué sigue mal resuelto]

## 4. Usuario principal
- Perfil: [descripción]
- Frecuencia del problema: [alta/media/baja]
- Motivación: [qué gana]
- Fricción principal: [qué podría frenarlo]

## 5. Propuesta de valor
[frase clara]

## 6. MVP
### Must Have
- [feature 1]
- [feature 2]

### Fuera del MVP
- [feature 3]

## 7. Valor esperado
- Para el usuario: [qué gana]
- Para el negocio: [qué valor genera]
- Señal de éxito: [métrica o señal]

## 8. Diferenciadores
- [diferenciador 1]
- [diferenciador 2]

## 9. Interesados ampliados (PMBOK 8)
- Principal: [descripción]
- Patrocinador: [descripción - si aplica]
- Equipo: [descripción]
- Regulatorios: [descripción - si aplica]

## 10. Dudas abiertas
- [pregunta 1]
- [supuesto por validar 1]

## 11. Siguiente paso
- Pasar a product-discovery
```

---

## Criterio de salida

Esta fase está suficientemente completa cuando ya existe:

- ✅ un problema claro,
- ✅ un usuario principal identificable,
- ✅ una propuesta de valor entendible,
- ✅ un MVP recortado,
- ✅ valor esperado claro,
- ✅ interesados ampliados según PMBOK 8,
- ✅ suficientes insumos para pasar a discovery sin improvisar.
