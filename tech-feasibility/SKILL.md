---
name: tech-feasibility
description: >
  PASO 3 de un pipeline de definición de producto. Evalúa factibilidad técnica,
  aterriza requisitos, identifica riesgos, propone una arquitectura proporcional
  al alcance y ayuda a elegir stack con un framework de decisión, no con recetas.

  Usa esta skill cuando ya exista claridad suficiente del problema, usuario y MVP,
  y haga falta decidir cómo construirlo, cuánto esfuerzo implica y qué riesgos técnicos
  existen antes de arrancar el desarrollo.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "2.0"
  pipeline: "project-kickstart/03"
  prev: "product-discovery"
---

# Tech Feasibility — Step 3

> **Pipeline recomendado:** `brainstorm` → `product-discovery` → `tech-feasibility`
> **Input ideal:** Discovery Report, Product Brief o contexto suficientemente claro
> **Output:** Tech Spec listo para iniciar implementación

---

## When to Use

Usa esta skill cuando el usuario quiera responder preguntas como:

- ¿qué tan difícil es construir esto?,
- ¿qué stack tiene más sentido?,
- ¿qué riesgos técnicos trae el MVP?,
- ¿cuánto esfuerzo puede costar?,
- ¿qué arquitectura mínima conviene?

## When NOT to Use

- La idea todavía está borrosa y no hay problema/usuario definidos.
- El usuario solo quiere saber qué stack está “de moda”.
- No existe suficiente claridad funcional para distinguir qué sí entra al MVP.

---

## Pre-flight Checklist

- [ ] Existe un Product Brief o un Discovery Report suficientemente claro.
- [ ] El problema, usuario y MVP ya están definidos a nivel útil.
- [ ] El objetivo es decidir cómo construir, no explorar la idea desde cero.

Si alguna casilla falla, regresa a la skill anterior.

---

## Filosofía

La factibilidad técnica NO es escoger frameworks favoritos.
Es reducir incertidumbre técnica antes de gastar semanas construyendo.

### Regla de oro

> El mejor stack no es el más popular.
> Es el que el equipo puede mantener, que resuelve los requisitos reales del producto
> y que permite iterar con el menor costo de complejidad posible.

### Principios

1. **Problema antes que tecnología**
2. **Riesgo antes que hype**
3. **Arquitectura proporcional al alcance**
4. **Decisiones justificadas, no heredadas de un tutorial**

---

## Paso 0 — Clasifica el proyecto

Antes de hablar de stack, define qué tipo de proyecto es:

| Tipo | Señal principal | Nivel de rigor |
|---|---|---|
| **Proyecto de aprendizaje** | aprender y terminar | bajo |
| **Side project / microproducto** | velocidad y costo bajo | medio |
| **Herramienta interna** | utilidad y bajo costo de mantenimiento | medio |
| **Producto serio / negocio** | mantenibilidad y operación | alto |

### Regla de clasificación

- 1 = research / exploración muy temprana
- 2 = internal-tool
- 3 = side-project
- 4-5 = production

Si no puedes clasificar el proyecto con claridad, no sigas a Fase 1.

- **Proyecto de aprendizaje** → prioridad: entender, iterar, terminar.
- **Side project / microproducto** → prioridad: velocidad y costo bajo.
- **Producto serio / negocio** → prioridad: mantenibilidad, validación y operación.
- **Herramienta interna** → prioridad: utilidad y bajo costo de mantenimiento.

Esta clasificación cambia el nivel de complejidad aceptable.

---

## Fase 1 — Inventario técnico del MVP

Para cada feature del MVP, responde:

```text
Feature: [nombre]
────────────────────────────────────────
¿Necesita autenticación?         [ ] Sí  [ ] No
¿Necesita persistencia?          [ ] Sí  [ ] No
¿Necesita tiempo real?           [ ] Sí  [ ] No
¿Necesita archivos/media?        [ ] Sí  [ ] No
¿Necesita notificaciones?        [ ] Sí  [ ] No
¿Necesita pagos?                 [ ] Sí  [ ] No
¿Necesita geolocalización?       [ ] Sí  [ ] No
¿Necesita hardware nativo?       [ ] Sí  [ ] No
¿Necesita modo offline?          [ ] Sí  [ ] No
¿Depende de APIs de terceros?    [ ] Sí  [ ] No
```

### Requisitos no funcionales mínimos

- usuarios esperados al inicio,
- latencia tolerable,
- sensibilidad de datos,
- regiones o idiomas,
- restricciones regulatorias si existen,
- presupuesto y tiempo disponibles.

Sin este inventario, elegir stack es disparar a ciegas.

---

## Fase 2 — Framework de decisión de stack

No propongas tecnología todavía. Primero responde estas preguntas:

### Stack Selection Gate

Solo puedes recomendar stack si ya sabes:

- qué plataforma o plataformas soportará,
- qué sabe ya el equipo,
- qué dependencias nativas o de terceros son críticas,
- y si la prioridad es velocidad, control o costo operativo.

### Cliente / frontend

1. ¿La app será mobile, web, desktop o varias?
2. ¿Qué sabe ya el equipo?
3. ¿El producto depende mucho de hardware o integraciones nativas?
4. ¿La prioridad es velocidad de salida o control fino de plataforma?

### Backend

1. ¿Necesita tiempo real o solo CRUD estándar?
2. ¿La lógica de negocio es simple o compleja?
3. ¿El equipo puede operar infraestructura propia?
4. ¿El producto necesita salir rápido con bajo costo operativo?

### Datos e infraestructura

1. ¿Los datos son relacionales o muy variables?
2. ¿Hace falta almacenamiento local/offline?
3. ¿Hace falta escalar desde el día 1 o solo validar?
4. ¿Qué dependencia externa sería riesgosa?

---

## Fase 3 — Opciones, no recetas

Presenta alternativas con contexto y tradeoffs.

### Frontend mobile

| Opción | Cuándo considerar | Ventaja principal | Tradeoff principal |
|---|---|---|---|
| **Flutter** | Quieres una codebase fuerte para varias plataformas y buena consistencia UI | Productividad alta, tipado fuerte, UI controlada | Requiere aprender Dart/ecosistema Flutter |
| **React Native** | El equipo domina React/JS y prioriza reaprovechar ese conocimiento | Menor fricción para equipos web | Integración nativa y performance dependen más del caso |
| **Nativo** | El producto depende fuerte de plataforma, rendimiento extremo o integraciones profundas | Máximo control | Más costo de desarrollo y mantenimiento |

### Backend

| Opción | Cuándo considerar | Ventaja principal | Tradeoff principal |
|---|---|---|---|
| **Firebase** | MVP rápido, poco equipo, auth/real-time listos | Velocidad de salida | Vendor lock-in y costos variables |
| **Supabase** | Quieres velocidad con SQL real y más control | PostgreSQL, simple para MVP y productos chicos-medianos | Menos ecosistema cerrado que Firebase |
| **Node/Nest** | Requieres backend custom o lógica más seria | Flexibilidad y control | Más código y operación |
| **Otro backend propio** | Hay requisitos específicos fuertes o experiencia previa sólida | Diseño a medida | Más complejidad inicial |

### Base de datos

| Opción | Cuándo considerar |
|---|---|
| **PostgreSQL** | Default fuerte para la mayoría de productos con datos estructurados |
| **SQLite** | Estado/datos locales o modo offline en cliente |
| **MongoDB** | Documentos y estructura cambiante, si el caso realmente lo pide |
| **Redis** | Caché, colas o sesiones; no reemplaza tu base principal en la mayoría de casos |

### Regla

No digas “usa X”.
Di: **“Dado A, B y C, X parece mejor que Y por estas razones.”**

---

## Fase 4 — Complejidad y riesgos por feature

Para cada Must Have, documenta:

```text
Feature: [nombre]
Complejidad: [Baja / Media / Alta / Incierta]
Riesgo principal: [descripción]
Dependencia externa: [sí/no + cuál]
Qué la vuelve difícil: [razón concreta]
Plan B: [alternativa realista]
```

### Tipos de riesgo a buscar

- riesgo de integración,
- riesgo de escala,
- riesgo regulatorio,
- riesgo de dependencia de terceros,
- riesgo de deuda técnica,
- riesgo de incertidumbre no investigada.

### Protocolo de incertidumbre

Si una feature está marcada como `Incierta`, debes:

1. documentar qué no está claro,
2. indicar qué investigación o prototipo la resolvería,
3. evitar tratarla como simple,
4. reflejarla en el plan B o en la estimación.

### Regla crítica

Si algo es técnicamente incierto, no lo estimes como si fuera simple.
Primero hay que investigarlo o prototiparlo.

---

## Fase 5 — Estimación de esfuerzo

No prometas fechas exactas en esta fase.
Usa rangos y deja explícita la incertidumbre.

### T-Shirt sizing sugerido

| Talla | Rango orientativo |
|---|---|
| **XS** | 1–3 días |
| **S** | 3–7 días |
| **M** | 1–3 semanas |
| **L** | 3–6 semanas |
| **XL** | 6+ semanas |

### Regla práctica

- optimista,
- realista,
- pesimista.

Y si el proyecto tiene incertidumbre real, añade colchón. Punto.

---

## Fase 6 — Arquitectura mínima adecuada

La arquitectura propuesta debe ser proporcional al tipo de proyecto.

### Para aprendizaje o MVP pequeño

- estructura simple por features,
- separación básica entre UI, estado y acceso a datos,
- pocas dependencias,
- despliegue sencillo.

### Para producto serio o crecimiento probable

- separación más clara de capas,
- estrategia de testing desde temprano,
- observabilidad básica,
- manejo explícito de errores,
- decisiones documentadas.

### Principios

- **YAGNI** → no diseñes para una escala imaginaria.
- **Separación de responsabilidades** → evita mezclar todo en un solo archivo/capa.
- **Evolución progresiva** → la arquitectura debe poder crecer sin rehacer todo.

---

## Reglas de conducción

- No confundas preferencia personal con criterio técnico.
- Siempre presenta al menos una alternativa y su tradeoff.
- Si el modelo de negocio o el usuario no están claros, dilo: el problema ya no es técnico.
- Si una dependencia externa puede romper el producto, documenta esa fragilidad.

---

## Criterio de salida

Esta fase está completa cuando ya existe:

- una propuesta de stack justificada,
- un mapa claro de riesgos,
- una estimación razonable por rangos,
- una arquitectura proporcional al tamaño del proyecto,
- claridad suficiente para comenzar a desarrollar sin improvisar todo.

---

## Output Final — Tech Spec

```markdown
# [Nombre del Producto] — Tech Spec
**Generado por:** tech-feasibility skill v2.0
**Fecha:** [fecha]

## 1. Contexto
- Tipo de proyecto: [aprendizaje / side project / producto / herramienta interna]
- Objetivo del MVP: [resumen]
- Restricciones: [tiempo, presupuesto, equipo, plataforma]

## 2. Requisitos técnicos clave
- [requisito 1]
- [requisito 2]
- [requisito 3]

## 3. Decisión de stack
### Frontend
- Opción elegida: [tecnología]
- Justificación: [por qué]
- Alternativa descartada: [cuál y por qué]

### Backend
- Opción elegida: [tecnología]
- Justificación: [por qué]
- Alternativa descartada: [cuál y por qué]

### Datos / infraestructura
- Base principal: [tecnología]
- Hosting / BaaS / despliegue: [tecnología]
- Motivo: [por qué]

## 4. Riesgos técnicos
| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| [riesgo] | | | |

## 5. Estimación inicial
| Feature | Talla | Rango |
|---|---|---|
| [feature] | [S/M/L] | [tiempo] |

## 6. Arquitectura propuesta
[descripción simple del sistema y sus piezas]

## 7. Decisiones abiertas
- [pregunta pendiente]
- [riesgo por investigar]

## 8. Siguiente paso
- Crear backlog técnico inicial
- Definir estructura del repo
- Empezar implementación
```

---

## Criterio de salida

Esta fase está completa cuando ya existe:

- una propuesta de stack justificada,
- un mapa claro de riesgos,
- una estimación razonable por rangos,
- una arquitectura proporcional al tamaño del proyecto,
- claridad suficiente para comenzar a desarrollar sin improvisar todo.
