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

### Micro-contrato de salida (Fase 1)

```text
Captura:
  - Explicación de 30 segundos (idea cruda)
  - Al menos una pista de problema
  - Al menos una pista de usuario potencial
  - Contexto org preliminar (personal / negocio / organización)

NO responde aún:
  - ¿Quién es exactamente el usuario? (Fase 3)
  - ¿Cuál es la propuesta de valor exacta? (Fase 4)
  - ¿Qué incluye el MVP? (Fase 5)
  - Valor esperado completo (Fase 4)
  - Dudas abiertas finales (Fase 6)

Señal de avance:
  - Explicación de 30s documentada + rastro de problema/usuario identifiers
```

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

### Micro-contrato de salida (Fase 2)

```text
Captura:
  - Problema concreto identificado
  - Solución actual documentada
  - Gap detectado (qué queda mal resuelto)

NO responde aún:
  - Perfil detallado del usuario (Fase 3)
  - Propuesta de valor final (Fase 4)
  - Alcance del MVP (Fase 5)

Señal de avance:
  - Bloque "Problema / Solución actual / Gap" completado y validado
```

---

## Fase 3 — Usuario principal + Interesados (PMBOK 8)

"Para todos" no sirve.

### Regla para avanzar

Avanza a Fase 4 solo si el usuario principal ya no es genérico y puede describirse con claridad.

### Micro-contrato de salida (Fase 3)

```text
Captura:
  - Usuario principal definido (perfil, frecuencia, motivación, fricción)
  - Interesados ampliados (PMBOK 8): patrocinador, equipo, regulatorios si aplica

NO responde aún:
  - Propuesta de valor final (Fase 4)
  - Definición de MVP (Fase 5)
  - Diferenciadores (Fase 6)

Señal de avance:
  - Usuario principal con perfil no genérico + interesados mapeados
```

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

### Micro-contrato de salida (Fase 4)

```text
Captura:
  - Frase de propuesta de valor: "Ayudamos a [usuario] a [resolver problema] mediante [solución], para que pueda [resultado valioso]"
  - Valor esperado preliminar: beneficio para el usuario, valor para el negocio y señal de éxito

NO responde aún:
  - Definición de MVP (Fase 5)
  - Diferenciadores (Fase 6)

Señal de avance:
  - Frase de valor clara, específica y documentada
```

---

## Fase 5 — MVP (y alcance inicial)

Separa lo esencial de lo decorativo.

### Qué significa MVP

MVP = la versión más pequeña que todavía resuelve el problema principal y permite aprender si la idea tiene sentido.

Ejemplos cortos: una landing con formulario, una demo manual, una automatización básica, o un flujo mínimo que pruebe la idea.

#### MVP en palabras simples (para no técnicos)

> El MVP es la versión "esquelética" de tu idea: solo lo que realmente hace que alguien diga "esto me sirve".
> No es un producto terminado, es una **prueba de que el problema existe y tu solución ayuda**.
> Piénsalo como el prototipo de cartón antes de fabricar el producto real.

#### Ejemplos cotidianos (no técnicos)

- **Pizza de prueba**: antes de abrir una pizzería, cocinas 5 pizzas en tu casa y se las das a vecinos para ver si las devoran.
- **Landing page**: antes de programar una app, haces una página web que explica la idea y mides cuánta gente deja su email.
- **Demo manual**: antes de automatizar, haces el proceso a mano con 3 clientes para ver si de verdad les ahorras tiempo.
- **WhatsApp group**: antes de crear una red social, abres un grupo y ves si la gente participa activamente.

### Regla para avanzar

Avanza a Fase 6 solo cuando el MVP esté recortado y no incluya más de lo necesario para resolver el problema principal.

### Clasificación sugerida

- **Must Have** → sin esto, el producto no resuelve el problema.
- **Should Have** → importante, pero puede esperar.
- **Could Have** → nice to have.
- **Not in MVP** → explícitamente fuera de la primera versión.

### Regla del MVP

> El MVP es la versión más pequeña que resuelve el problema principal del usuario principal.

### Micro-contrato de salida (Fase 5)

```text
Captura:
  - MVP recortado (Must Have / Should Have / Could Have / Not in MVP)
  - Definición clara de qué resuelve el problema principal

NO responde aún:
  - Diferenciadores (Fase 6)

Señal de avance:
  - MVP con Must Have listados y Fuera de MVP explícito
```

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

### Micro-contrato de salida (Fase 6)

```text
Captura:
  - Máximo 2 diferenciadores claros
  - Dudas abiertas y supuestos por validar
  - Product Brief completo listo para product-discovery

NO responde aún:
  - Definición de mercado/competencia (eso es product-discovery)
  - Validación pesada (product-discovery)
  - Decisiones de stack (tech-feasibility)

Señal de avance:
  - Diferenciadores definidos + Product Brief completo generado
```

---

## Reglas de conducción

### Detector de desvío

La skill debe detectar cuándo el usuario se sale del flujo. Señales de desvío:

1. **Stack/Tech jumping**: el usuario pregunta "¿usamos React o Vue?", "¿qué base de datos?", "¿microservicios o monolito?".
2. **Feature creep**: el usuario empieza a listar 15 funcionalidades antes de definir el problema.
3. **Monetización prematura**: hablar de precios, suscripciones o modelos de negocio antes de validar el problema.
4. **Competencia distracción**: comparar con gigantes (Netflix, Uber) antes de definir su propio usuario.

### Frases de reconducción estándar

| Tipo de desvío | Frase de reconducción |
|---|---|
| Stack/Tech | "Oye, antes de elegir tech, necesitamos tener claro el problema y el usuario. Vamos a completar la Fase X primero." |
| Feature creep | "Todavía no estamos recortando features. Primero define el problema en la Fase 2, luego el MVP en la Fase 5." |
| Monetización prematura | "El dinero viene después de validar que alguien necesita esto. Terminemos la propuesta de valor en Fase 4." |
| Competencia | "Entendido, pero primero define tu usuario principal en Fase 3. Después veremos competencia en product-discovery." |

### Regla anti-desvío

> Si el usuario salta a stack/tech, responde con la frase de reconducción correspondiente y vuelve a la fase actual. No respondas la pregunta técnica hasta que el flujo lo permita.

- Una pregunta a la vez.
- No sugerir features demasiado pronto.
- Desafiar ideas difusas con respeto pero con firmeza.
- No hablar de stack si el problema aún no está bien definido.
- Terminar siempre con un output útil, no con conversación suelta.
- Mantener el orden de la skill: no saltar fases aunque el usuario pregunte algo fuera de secuencia.
- Si falta información, hacer la pregunta mínima necesaria del paso actual y volver al flujo.
- Si el usuario se desvía, reconducir con una frase corta y continuar desde la fase correcta.
- No cerrar la skill hasta completar el output final válido o dejar explícito qué fase quedó pendiente.

---

## Product Brief Parcial (salida controlada)

Cuando el usuario no completa todas las fases, la skill debe entregar un **Product Brief Parcial** en lugar de forzar el cierre o dejar conversación suelta.

### Cuándo usar Brief Parcial vs Brief Completo

| Condición | Salida |
|---|---|
| Se completaron todas las fases (1-6) + micro-contratos cumplidos | **Product Brief Completo** (usar template de Output Final) |
| Faltan fases pero hay micro-contrato de la fase actual cumplido | **Product Brief Parcial** (usar template abajo) |
| El usuario se detiene a mitad de una fase sin cumplir el micro-contrato | **No generar Brief** — reconducir a completar la fase actual |
| Faltan datos críticos pero hay suficiente para ser útil | **Product Brief Parcial** con campos "Pendientes de validación" |

### Template de Product Brief Parcial

```markdown
# [Nombre Tentativo] — Product Brief PARCIAL
**Generado por:** brainstorm skill v4.0
**Fecha:** [fecha]
**Contexto org:** [personal / negocio / organización]
**Interesados:** [lista principal si aplica]
**Fases completadas:** [lista de fases terminadas con su micro-contrato]
**Fase pendiente:** [qué falta para el Brief Completo]

## 1. Problema
[descripción concreta del dolor — si se completó Fase 2]

## 2. Solución actual
[cómo se resuelve hoy — si se completó Fase 2]

## 3. Gap detectado
[qué sigue mal resuelto — si se completó Fase 2]

## 4. Usuario principal
- Perfil: [descripción — si se completó Fase 3]
- Frecuencia del problema: [alta/media/baja]
- Motivación: [qué gana]
- Fricción principal: [qué podría frenarlo]

## 5. Propuesta de valor
[frase clara — si se completó Fase 4]

## 6. MVP
### Must Have
- [feature 1 — si se completó Fase 5]

### Should Have
- [feature 2 — si se completó Fase 5]

### Could Have
- [feature 3 — si se completó Fase 5]

### Fuera del MVP
- [feature 4 — si se completó Fase 5]

## 7. Valor esperado
- Para el usuario: [qué gana — si se completó Fase 4]
- Para el negocio: [qué valor genera — si aplica]
- Señal de éxito: [métrica o señal — si se completó Fase 4]

## 8. Diferenciadores
- [diferenciador 1 — si se completó Fase 6]

## 9. Interesados ampliados (PMBOK 8)
- Principal: [descripción — si se completó Fase 3]
- Patrocinador: [descripción - si aplica]
- Equipo: [descripción]
- Regulatorios: [descripción - si aplica]

## 10. Dudas abiertas
- [pregunta 1]
- [supuesto por validar 1]

## 11. Siguiente paso
- Volver a brainstorm para completar fase(s) faltante(s) **O** pasar a product-discovery con este Brief Parcial (solo si las fases críticas 1-4 están completas)
```

> **Regla**: El Brief Parcial solo puede pasar a `product-discovery` si al menos las fases 1-4 (Idea, Problema, Usuario, Propuesta de valor) están completas. Si falta algo crítico, el siguiente paso siempre es terminar brainstorm.

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

## Nota de transición a `product-discovery`

Este Product Brief está diseñado para ser el **input directo y compatible** con la skill `product-discovery`. Los campos clave que alimentan el siguiente paso son:

| Campo del Product Brief | Uso en `product-discovery` |
|---|---|
| 1. Problema + 2. Solución actual + 3. Gap | Valida el problema (Fase1 y Discovery ligero punto 1) |
| 4. Usuario principal | Define el usuario a validar (Fase3 y Discovery ligero punto 2) |
| 5. Propuesta de valor | Base para la propuesta de valor en discovery (Fase4) |
| 6. MVP | Referencia para no sobre-dimensionar el discovery |
| 10. Dudas abiertas | Se convierten en hipótesis de riesgos para `project-init` |
| 11. Siguiente paso | Confirma el pipeline `brainstorm → product-discovery` |

> **Nota**: Si el Brief es Parcial, `product-discovery` usará las secciones disponibles y marcará las faltantes como "pendientes de validación en discovery".

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
