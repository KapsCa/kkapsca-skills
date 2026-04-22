---
name: tech-feasibility
description: >
  PASO 3 DE 3 del Project Kickstart Pipeline. Evalúa la factibilidad técnica de un producto
  validado, define el tech stack con justificación, identifica riesgos técnicos, estima el
  esfuerzo de desarrollo y propone la arquitectura base del MVP. Produce un Tech Spec listo
  para empezar a desarrollar.

  SIEMPRE activa esta skill cuando el usuario tenga un producto validado y quiera saber:
  qué tecnologías usar, cuánto tarda en construirse, qué tan difícil es técnicamente,
  qué puede salir mal a nivel técnico, o cómo estructurar la arquitectura del proyecto.
  También activa cuando el usuario diga "¿qué stack uso?", "¿cuánto tiempo tarda?",
  "¿es difícil construir esto?", "¿por dónde empiezo técnicamente?", o tenga un
  Discovery Report listo.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/03"
  prev: "product-discovery"
---

# Tech Feasibility — Paso 3 de 3

> **Pipeline:** `brainstorm` → `product-discovery` → `tech-feasibility`  
> **Input:** Discovery Report (output de product-discovery)  
> **Output:** Tech Spec (listo para empezar a desarrollar)

---

## When NOT to Use

- No hay Discovery Report o Product Brief previo → regresa a los pasos anteriores
- El usuario solo quiere saber qué tecnología "está de moda" → eso no es evaluación técnica
- El producto no tiene modelo de negocio definido → el stack sin contexto es una decisión ciega

---

## Filosofía

La tecnología sirve al producto. El producto sirve al usuario. El usuario sirve al negocio.
Nunca elijas un stack porque lo viste en un tutorial o porque "está trending".

**Regla de oro:**
> "El mejor tech stack es el que tu equipo puede mantener, que resuelve
> los problemas técnicos reales del producto, y que permite iterar rápido."

---

## Fase 1 — Inventario de Requisitos Técnicos

Antes de elegir tecnologías, mapea qué necesita el producto técnicamente.

### 1.1 Matriz de Requisitos por Feature (Must Haves del MVP)

Para cada feature del MVP, identifica:

```
Feature: [nombre]
─────────────────────────────────────────────────────
¿Requiere autenticación?          [ ] Sí  [ ] No
¿Requiere base de datos?          [ ] Sí  [ ] No
¿Requiere tiempo real?            [ ] Sí  [ ] No
¿Requiere almacenamiento files?   [ ] Sí  [ ] No
¿Requiere notificaciones push?    [ ] Sí  [ ] No
¿Requiere geolocalización?        [ ] Sí  [ ] No
¿Requiere pagos?                  [ ] Sí  [ ] No
¿Requiere cámara/hardware?        [ ] Sí  [ ] No
¿Requiere offline?                [ ] Sí  [ ] No
¿Requiere integración con API 3P? [ ] Sí  [ ] No → ¿Cuál?
```

### 1.2 Requisitos No Funcionales

| Requisito | Nivel para MVP | Notas |
|---|---|---|
| **Usuarios simultáneos** | [N] | Impacta infraestructura |
| **Latencia aceptable** | [ms] | Impacta arquitectura |
| **Disponibilidad** | [%] | 99% vs 99.9% es enorme diferencia de costo |
| **Regiones** | [lista] | GDPR, LATAM, global |
| **Privacidad de datos** | [nivel] | ¿Datos sensibles? ¿Financieros? ¿Salud? |
| **Cumplimiento regulatorio** | [normativas] | PCI-DSS, HIPAA, GDPR |

---

## Fase 2 — Decisión de Tech Stack

### 2.1 Framework de Decisión

Responde estas preguntas ANTES de proponer tecnologías:

1. **¿iOS + Android + Web?** → Cross-platform. ¿Solo mobile? → Nativo o cross.
2. **¿El equipo tiene base en JS?** → React Native es válido. ¿Base en Dart/mobile? → Flutter.
3. **¿Necesita hardware intensivo?** (cámara AR, BLE, sensores) → Flutter > React Native.
4. **¿El backend necesita tiempo real?** → Supabase, Firebase, o WebSockets propios.
5. **¿Cuánto presupuesto de infraestructura?** → Serverless para MVPs, containers para escala.
6. **¿Cuándo necesita estar en producción?** → BaaS para rápido, custom para control.

### 2.2 Opciones de Stack por Contexto

#### Mobile (iOS + Android)

| Stack | Cuándo usarlo | Ventaja | Riesgo |
|---|---|---|---|
| **Flutter** | Equipo nuevo en mobile, apps complejas, dashboards, Flutter Web | Rendimiento nativo, tipado fuerte, 1 codebase | Ecosistema más pequeño que RN |
| **React Native** | Equipo con base React/JS, prototipo rápido | Ecosistema JS, muchos devs disponibles | Bridge JS↔Native, performance en listas largas |
| **Swift + Kotlin** | App con hardware intensivo, experiencia nativa crítica | Máximo rendimiento, acceso completo al SO | Dos codebases, equipo más grande |

#### Backend / API

| Stack | Cuándo usarlo | Ventaja | Riesgo |
|---|---|---|---|
| **Firebase** | MVP rápido, tiempo real, equipo pequeño | Sin servidor que mantener, auth incluida | Vendor lock-in, costoso al escalar |
| **Supabase** | Firebase pero open source, SQL real | PostgreSQL, más control, autohospedable | Menos features que Firebase |
| **Node.js + Express** | Equipo con JS, API custom | Flexibilidad total, ecosistema enorme | Más configuración inicial |
| **NestJS** | Backend serio en TypeScript, equipo mediano+ | Arquitectura estructurada, escalable | Curva de aprendizaje mayor |
| **Go / Rust** | Alta concurrencia, performance crítica | Muy eficiente | Equipo especializado requerido |

#### Base de Datos

| Base | Cuándo usarlo |
|---|---|
| **PostgreSQL** | Default para casi todo — relacional, robusto, gratis |
| **MongoDB** | Datos muy variables, sin esquema fijo, documentos |
| **Redis** | Caché, sesiones, colas — siempre como complemento |
| **SQLite** | Offline-first en mobile, datos locales |

#### Infraestructura

| Opción | MVP | Escala | Costo |
|---|---|---|---|
| **Firebase / Supabase** | ✅ Ideal | ⚠️ Costoso | Pago por uso |
| **Vercel + PlanetScale** | ✅ Frontend + DB | ✅ Escala bien | Pago por uso |
| **Railway / Render** | ✅ Backend simple | ✅ Moderado | ~$5-20/mes |
| **AWS / GCP / Azure** | ⚠️ Complejo | ✅ Máxima escala | Variable |

---

## Fase 3 — Factibilidad Técnica por Feature

Para cada Must Have del MVP, evalúa:

```
Feature: [nombre]
──────────────────────────────────────────────────────────────
Complejidad técnica:   [ ] Baja  [ ] Media  [ ] Alta  [ ] Incierta
Existe solución out-of-the-box:  [ ] Sí → [librería/servicio]
                                 [ ] No → hay que construirla
Dependencia de API externa:      [ ] Sí → [nombre + confiabilidad]
                                 [ ] No
Riesgo técnico principal:        [describir]
Alternativa si falla:            [plan B]
```

---

## Fase 4 — Riesgos Técnicos

### Tipos de riesgo a identificar:

**Riesgo de integración** — APIs de terceros que pueden fallar, cambiar precios o deprecarse.
**Riesgo de escala** — Lo que funciona para 100 usuarios puede romperse con 10,000.
**Riesgo de regulación** — Datos financieros, de salud o de menores tienen requerimientos legales.
**Riesgo de plataforma** — Cambios en App Store / Play Store policies.
**Riesgo de deuda técnica** — Decisiones rápidas que harán el mantenimiento caro después.
**Riesgo de dependencia** — Un solo servicio que si cae, cae todo el producto.

### Matriz de riesgos:

```
Riesgo: [descripción]
Probabilidad: [Alta / Media / Baja]
Impacto:      [Alto / Medio / Bajo]
Mitigación:   [qué hacer para reducirlo]
Plan B:       [qué hacer si ocurre]
```

---

## Fase 5 — Estimación de Esfuerzo (T-Shirt Sizing)

No prometas fechas exactas sin código escrito. Usa rangos.

### Tabla de sizing:

| Talla | Tiempo | Ejemplo de feature |
|---|---|---|
| **XS** | 1-3 días | Pantalla estática, CRUD simple |
| **S** | 3-7 días | Auth completa, listado con filtros |
| **M** | 1-3 semanas | Carrito de compras, chat básico |
| **L** | 3-6 semanas | Sistema de pagos, mapas con lógica |
| **XL** | 6+ semanas | Motor de recomendaciones, IA, social graph |

### Estimación total del MVP:

```
Feature 1: [nombre] → [talla] → [rango en días]
Feature 2: [nombre] → [talla] → [rango en días]
Feature 3: [nombre] → [talla] → [rango en días]
─────────────────────────────────────────────
Total optimista:    [N] días / [N] semanas
Total realista:     [N × 1.5] días (agrega 50% siempre)
Total pesimista:    [N × 2] días (imprevistos, bugs, scope creep)
```

**Regla del 50%:** Siempre multiplica tu estimación inicial por 1.5.
No es pesimismo — es experiencia acumulada de todos los proyectos de software de la historia.

---

## Fase 6 — Arquitectura Base del MVP

Propón la arquitectura mínima que soporte el MVP y permita escalar después.

### Plantilla de arquitectura:

```
[CLIENTE]
├── Mobile App (iOS + Android)
│   └── [framework elegido]
└── Web App (si aplica)
    └── [framework elegido]
         │
         ▼ HTTPS / REST / GraphQL / WebSocket
[BACKEND]
├── API Layer
│   └── [tecnología]
├── Auth
│   └── [solución: Firebase Auth / Supabase Auth / custom JWT]
├── Business Logic
│   └── [descripción de capas]
└── Storage
    ├── Base de datos: [tecnología]
    ├── Files/Media: [tecnología]
    └── Caché: [tecnología, si aplica]
         │
         ▼
[INFRAESTRUCTURA]
└── [proveedor + tier]
```

### Principios de arquitectura para MVP:

- **YAGNI** (You Aren't Gonna Need It) — no sobre-ingenierices para escala que no tienes
- **Separación de capas** — presentation / business logic / data desde el inicio
- **Feature flags** — mecanismo para activar/desactivar features sin deployar
- **Observabilidad mínima** — logging y monitoreo desde el día 1, no después

---

## Reglas de Conducción

- Si un requisito técnico es "incierto", investígalo antes de estimar — la incertidumbre técnica es el mayor riesgo
- Si el costo de infraestructura supera el modelo de negocio proyectado, el producto tiene un problema económico, no técnico
- Un MVP técnicamente perfecto que nadie usa es un fracaso — prioriza velocidad de validación sobre calidad de código en la primera versión
- Documenta las decisiones técnicas y sus razones — tu yo del futuro lo agradecerá

---

## Output Final — Tech Spec

Genera este documento al terminar. Es el punto de partida del desarrollo.

```markdown
# [Nombre del Producto] — Tech Spec
**Generado por:** KkapsCa / tech-feasibility skill v1.0
**Fecha:** [fecha]

## Resumen Técnico
[3-4 oraciones: qué se construye, con qué tecnologías, en cuánto tiempo]

## Tech Stack Decisión

### Frontend / Mobile
**Tecnología:** [nombre]
**Justificación:** [por qué esta y no otra]

### Backend
**Tecnología:** [nombre]
**Justificación:** [por qué esta y no otra]

### Base de Datos
**Tecnología:** [nombre]
**Justificación:** [por qué esta y no otra]

### Infraestructura
**Proveedor:** [nombre + tier]
**Costo estimado/mes:** $[X]

## Factibilidad por Feature

| Feature | Complejidad | Talla | Días estimados | Riesgo |
|---|---|---|---|---|
| [Feature 1] | Media | M | 10-15 | Bajo |

## Estimación Total
**Optimista:** [N] semanas
**Realista:** [N × 1.5] semanas
**Pesimista:** [N × 2] semanas

## Riesgos Técnicos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| [Riesgo 1] | Alta | Alto | [mitigación] |

## Arquitectura Base
[Diagrama ASCII o descripción de capas]

## Decisiones Técnicas Clave
[Lista de decisiones importantes con su justificación]

## Deuda Técnica Aceptada en MVP
[Qué se hace "rápido ahora" y se refactoriza después, y cuándo]

## Próximos Pasos
1. [ ] Setup del repositorio y estructura base
2. [ ] Configurar CI/CD mínimo
3. [ ] Implementar autenticación
4. [ ] [Feature crítica 1]
5. [ ] [Feature crítica 2]

---
**Pipeline completado.** Tienes Product Brief + Discovery Report + Tech Spec.
Estás listo para desarrollar con claridad.
```

---

> 🎉 **¡Pipeline completo!**
> Con los tres documentos (Product Brief + Discovery Report + Tech Spec)
> tienes todo lo necesario para empezar a desarrollar con claridad,
> contratar talento, presentar a inversores, o simplemente no perderte
> cuando empieces a escribir código.
