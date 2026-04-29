---
name: product-discovery
description: >
  PASO 2 de un pipeline de definición de producto. Sirve para validar una idea o
  Product Brief con análisis de usuario, problema, competencia, mercado, propuesta
  de valor, monetización y métodos de validación. Incluye una ruta completa y una
  ruta ligera para side projects, aprendizaje o microproductos.

  Usa esta skill cuando ya exista una idea más aterrizada y haga falta responder si
  realmente vale la pena construirla, para quién, contra qué compite y cómo validarla
  antes de gastar tiempo fuerte en desarrollo.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "3.0"
  pipeline: "project-kickstart/02"
  prev: "brainstorm"
  next: "project-init"
---

# Product Discovery — Step 2

> **Pipeline recomendado:** `brainstorm` → `product-discovery` → `project-init` → `tech-feasibility`
> **Input ideal:** Product Brief o idea ya suficientemente definida
> **Output:** Discovery Report

---

## When to Use

Usa esta skill cuando el usuario quiera responder cosas como:

- ¿hay una necesidad real aquí?,
- ¿quién usaría esto de verdad?,
- ¿qué alternativas ya existen?,
- ¿cómo podría validarse sin construir de más?,
- ¿esto tiene sentido como negocio, side project o herramienta?

## When NOT to Use

- La idea sigue siendo demasiado vaga y todavía no hay claridad mínima del problema.
- El usuario ya validó mercado y solo quiere aterrizar stack y arquitectura.
- El objetivo es solo comparar tecnologías sin pensar en el producto.

---

## Pre-flight Checklist

- [ ] Existe al menos un Product Brief o una idea ya suficientemente aterrizada.
- [ ] Ya se puede nombrar el problema principal sin hablar de solución.
- [ ] Ya hay una pista mínima de usuario o nicho.

Si alguna casilla falla, no uses esta skill todavía; vuelve a `brainstorm`.

---

## Filosofía

Discovery no es burocracia.
Es el filtro que evita construir algo que nadie necesita.

### Regla de oro

> Antes de invertir semanas en desarrollo, confirma que existe una necesidad,
> un usuario concreto y una razón real para que alguien use —o incluso pague— por lo que estás imaginando.

---

## Paso 0 — Identifica el tipo de proyecto

No todos los proyectos requieren el mismo nivel de discovery.

Clasifica primero:

- **Aprendizaje** → prioridad: entender problema, usuario y utilidad.
- **Side project / microproducto** → prioridad: validar interés rápido (lanzar `project-init` tras discovery).
- **Producto serio / negocio** → prioridad: mercado, monetización y viabilidad.
- **Herramienta interna** → prioridad: utilidad clara y ahorro de tiempo/costo.

---

## Dos modos de trabajo

| Condición | Modo | Pipeline resultante |
|---|---|---|
| Quieren lanzar un producto serio | Modo A — Discovery completo | `brainstorm → product-discovery → project-init → tech-feasibility` |
| Planean monetizar | Modo A — Discovery completo | `brainstorm → product-discovery → project-init → tech-feasibility` |
| Hay inversión importante de tiempo o dinero | Modo A — Discovery completo | `brainstorm → product-discovery → project-init → tech-feasibility` |
| Necesitan justificar la idea ante otras personas | Modo A — Discovery completo | `brainstorm → product-discovery → project-init → tech-feasibility` |
| Es side project | Modo B — Discovery ligero | `brainstorm → product-discovery → project-init (opcional) → tech-feasibility` |
| Es herramienta personal o interna | Modo B — Discovery ligero | `brainstorm → product-discovery → project-init (opcional) → tech-feasibility` |
| Están aprendiendo | Modo B — Discovery ligero | `brainstorm → product-discovery → project-init (opcional) → tech-feasibility` |
| Quieren validar interés rápido | Modo B — Discovery ligero | `brainstorm → product-discovery → project-init (opcional) → tech-feasibility` |

### Modo A — Discovery completo

Si ninguna fila aplica claramente, pregunta al usuario antes de continuar.

### Modo B — Discovery ligero

Si ninguna fila aplica claramente, pregunta al usuario antes de continuar.

### Transición a `project-init`

**Desde `product-discovery`**: El Discovery Report debe incluir:
- Usuario principal identificado
- Problema validado
- Hipótesis de riesgos
- Enfoque sugerido (enlace a la señal de Paso 0)
- Estos son los insumos para `project-init`

**Nota**: `project-init` recibe el output de `product-discovery` y produce el Project Framing Doc que `tech-feasibility` consume.

---

## Discovery ligero (ruta rápida)

Si el proyecto no requiere análisis pesado, responde estas 5 cosas:

1. **Problema**
   - ¿Qué frustración o tarea concreta existe?

2. **Usuario**
   - ¿Quién lo necesita más?

3. **Alternativa actual**
   - ¿Cómo lo resuelve hoy sin tu producto?

4. **Señal de valor**
   - ¿Qué tendría que pasar para decir “sí vale la pena seguir”? 
   - Ejemplo: 10 personas interesadas, 3 usuarios activos, 1 cliente que pague, etc.

5. **Validación mínima**
   - ¿Cuál es la forma más barata de comprobar interés?
   - entrevista, landing, mockup, demo manual, pre-venta.

### Salida del modo ligero

Si estas 5 respuestas están claras, puedes pasar a `project-init` (opcional) → `tech-feasibility` sin hacer discovery completo.

---

## Discovery completo

### Fase 1 — Mercado y contexto

No necesitas sonar a consultor. Necesitas orden.

#### Tamaño de oportunidad (si aplica)

Usa TAM / SAM / SOM solo cuando el proyecto realmente lo amerite.

- **TAM** → tamaño total del mercado
- **SAM** → segmento al que realmente puedes llegar
- **SOM** → porción realista que podrías capturar

Si el proyecto es pequeño o interno, puedes sustituir esto por:

- tamaño del nicho,
- número estimado de usuarios potenciales,
- intensidad del problema.

#### Regla de avance

Solo usa TAM / SAM / SOM si el proyecto es un producto serio o un negocio.
Si es side project, aprendizaje o herramienta interna, usa nicho + usuarios potenciales + intensidad del problema.

#### Preguntas clave

- ¿Este problema ocurre con suficiente frecuencia?
- ¿A cuántas personas afecta en el nicho relevante?
- ¿Es un dolor real o solo una idea curiosa?

---

### Fase 2 — Competencia y alternativas

No busques solo competidores directos.
Busca también sustitutos.

```text
Competidor o alternativa: [nombre]
Qué resuelve: [descripción]
Fortaleza: [qué hace bien]
Debilidad: [qué deja mal resuelto]
Oportunidad: [qué podrías hacer mejor o distinto]
```

### Tipos de competencia

- **Directa** → hace algo muy parecido
- **Indirecta** → resuelve el mismo problema de otra forma
- **Sustituto actual** → Excel, WhatsApp, Notion, papel, procesos manuales

---

### Fase 3 — Usuario y Jobs To Be Done

La skill debe aterrizar máximo 1 o 2 perfiles centrales.

```text
Persona: [nombre ficticio]
Perfil: [ocupación, contexto, comportamiento]
Problema principal: [dolor real]
Motivación: [qué espera ganar]
Fricciones: [qué lo haría no usar tu producto]

Job to be done:
"Cuando [situación], quiero [motivación], para [resultado esperado]"
```

### Regla

Si el usuario responde “esto es para todos”, hay que empujarlo a elegir un usuario primario.

### Regla para avanzar

No avances si el usuario principal sigue siendo genérico o difuso.

---

### Fase 4 — Propuesta de valor

Obliga a resumir la propuesta así:

```text
Ayudamos a [usuario] a [resolver problema] mediante [solución],
para que pueda [resultado valioso].
```

Si esto no se puede escribir con claridad, el producto sigue borroso.

---

### Fase 5 — Modelo de valor y monetización

No todos los proyectos necesitan modelo de negocio fuerte desde el día 1.

Primero define cuál de estos aplica:

- **Negocio** → sí necesita monetización clara.
- **Side project** → puede empezar sin monetizar, pero debe tener una hipótesis.
- **Aprendizaje** → monetización opcional.
- **Herramienta interna** → el valor puede ser ahorro de tiempo o costo, no ventas.

### Si sí aplica monetización

Explora opciones como:

- freemium,
- suscripción,
- pago único,
- comisión,
- B2B,
- consultoría/servicio asociado.

### Pregunta correcta

No preguntes solo “¿cómo ganará dinero?”
Pregunta también:

> “¿Qué tipo de valor genera este producto y cómo se podría capturar?”

### Regla para avanzar

No avances a la siguiente fase si la propuesta de valor todavía no se puede escribir con claridad.

---

### Fase 6 — Estrategia de validación

Siempre busca primero la validación más barata posible.

| Método | Qué valida | Costo relativo |
|---|---|---|
| Entrevistas | problema y lenguaje del usuario | bajo |
| Landing page | interés inicial | bajo |
| Mockup / prototipo | flujo y comprensión | bajo |
| Demo manual | utilidad real | bajo-medio |
| Pre-venta | intención de compra | medio |
| MVP técnico | experiencia real completa | alto |

### Regla

No construyas un MVP técnico si todavía puedes aprender lo mismo con algo más barato.

### Regla para avanzar

No avances a `tech-feasibility` si la validación mínima todavía puede hacerse con algo más barato.

---

## Reglas de conducción

- Una pregunta a la vez.
- Desafía suposiciones no comprobadas.
- Si el usuario no conoce el mercado, ayúdalo a investigarlo; no inventes.
- Si el proyecto es pequeño, usa la ruta ligera y no lo asfixies con formalismo.
- Si el proyecto busca negocio serio, sí mete más rigor.

---

## Criterio de salida

Esta skill está suficientemente bien resuelta cuando ya existe:

- un usuario principal claro,
- una necesidad entendible,
- una alternativa actual identificada,
- una propuesta de valor concreta,
- un método realista de validación,
- y contexto suficiente para tomar decisiones técnicas con sentido.

---

## Output Final — Discovery Report

```markdown
# [Nombre del Producto] — Discovery Report
**Generado por:** product-discovery skill v2.0
**Fecha:** [fecha]

## 1. Tipo de proyecto
[aprendizaje / side project / producto / herramienta interna]

## 2. Problema validado
[qué problema existe y por qué importa]

## 3. Usuario principal
[perfil concreto]

## 4. Alternativas actuales
- [alternativa 1]
- [alternativa 2]

## 5. Propuesta de valor
[frase clara de valor]

## 6. Competencia / contexto
[competidores, sustitutos, oportunidad]

## 7. Hipótesis de valor o negocio
[cómo genera valor y, si aplica, cómo podría monetizar]

## 8. Estrategia de validación
- método 1
- método 2
- señal esperada de validación

## 9. Riesgos o dudas abiertas
- [duda 1]
- [duda 2]

## 10. Siguiente paso
- Pasar a project-init (o tech-feasibility por bypass)
```

---

## Criterio de salida

Esta fase está suficientemente bien resuelta cuando ya existe:

- un usuario principal claro,
- una necesidad entendible,
- una alternativa actual identificada,
- una propuesta de valor concreta,
- un método realista de validación,
- y contexto suficiente para tomar decisiones técnicas con sentido.
