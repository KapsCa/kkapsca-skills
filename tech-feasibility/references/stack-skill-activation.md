# Activación de skills por stack confirmado — Tech Feasibility

Detalle local de SKILL.md (## Decision Gates). Incluye Supabase, Firebase y la matriz Genkit.

## Stack Confirmado — Activación de Skills

Cuando el stack elegido sea **Supabase**, se activarán las siguientes skills en fases posteriores:

### `supabase`
- **Cuándo activar**: Solo después de confirmar Supabase como backend en esta fase (`tech-feasibility`).
- **Qué incluye**: Integración general (auth, realtime, storage, database).
- **Fase de activación**: implementación (ODD, paso 6), o `sdd-design` / `sdd-apply` si SDD fue seleccionado.
- **⚠️ Disponibilidad**: external-bootstrappable vía `${AGENTS_DIR}/supabase/`. Requiere bootstrap (`bash scripts/bootstrap.sh`) o instalación manual. Sin instalación física en `~/.config/opencode/skills`, el routing es solo lógico.

### `supabase-postgres-best-practices`
- **Cuándo activar**: Durante la implementación (ODD, paso 6) o, si SDD fue seleccionado, en `sdd-design` / `sdd-apply`, cuando el trabajo entre en contexto SQL, RLS, migrations, performance o esquema Postgres.
- **Qué incluye**: Mejores prácticas de PostgreSQL, políticas RLS, índices, optimización de consultas.
- **NO activar**: Solo por haber elegido Supabase; debe haber trabajo técnico específico de base de datos.
- **⚠️ Disponibilidad**: external-bootstrappable vía `${AGENTS_DIR}/supabase-postgres-best-practices/`. Misma dependencia que `supabase`.

### Propagación de señal
Al confirmar Supabase, la señal debe pasar a fases siguientes (`project-init` → implementación (ODD, paso 6); si SDD fue seleccionado, `sdd-design` → `sdd-apply`) para que el orquestador active las skills correspondientes en su momento, según el contexto técnico específico.

---

## Stack Confirmado — Activación de Skills (Firebase)

Cuando el stack elegido sea **Firebase**, se activarán las siguientes skills en fases posteriores:

### `firebase-basics`
- **Cuándo activar**: Solo después de confirmar Firebase como backend/BaaS en esta fase (`tech-feasibility`) o cuando la conversación pida inicialización/CLI/proyecto Firebase.
- **Qué incluye**: Configuración general (auth, proyectos, CLI, reglas base).
- **Fase de activación**: implementación (ODD, paso 6), o `sdd-design` / `sdd-apply` si SDD fue seleccionado.
- **⚠️ Disponibilidad**: external-bootstrappable vía `${AGENTS_DIR}/firebase-basics/`. Requiere bootstrap (`bash scripts/bootstrap.sh`) o instalación manual. Sin instalación física en `~/.config/opencode/skills`, el routing es solo lógico.

### `firebase-auth-basics`
- **Cuándo activar**: Durante la implementación (ODD, paso 6) o, si SDD fue seleccionado, en `sdd-design` / `sdd-apply`, cuando el trabajo sea específico de Auth (sign-in, providers, tokens, reglas con `request.auth`).
- **Qué incluye**: Integración de autenticación, proveedores, manejo de tokens.
- **NO activar**: Solo por haber elegido Firebase; debe haber trabajo técnico específico de autenticación.

### `firebase-firestore-standard`
- **Cuándo activar**: Durante la implementación (ODD, paso 6) o, si SDD fue seleccionado, en `sdd-design` / `sdd-apply`, cuando el trabajo entre en contexto de Firestore Standard (modelo documento, queries, índices, SDK, reglas).
- **Qué incluye**: Guía completa de Firestore Standard Edition.
- **NO activar**: Solo por mencionar Firebase; requiere contexto técnico de base de datos documental.

### `firebase-firestore-enterprise-native-mode`
- **Cuándo activar**: SOLO si el usuario confirma explícitamente Enterprise Native Mode.
- **Qué incluye**: Guía de Firestore Enterprise con Native mode.
- **NO activar**: Por default, ni solo por mencionar Firestore; es mutuamente excluyente con `firebase-firestore-standard`.

### `firebase-hosting-basics`
- **Cuándo activar**: Para hosting clásico de sitio estático/SPA sin SSR.
- **Qué incluye**: Despliegue de static web apps, SPAs.
- **NO activar**: Para Next.js/Angular SSR; usar `firebase-app-hosting-basics` en su lugar.

### `firebase-app-hosting-basics`
- **Cuándo activar**: Para Next.js/Angular/full-stack con SSR/ISR o App Hosting explícito.
- **Qué incluye**: Deploy de apps con backends usando Firebase App Hosting.
- **NO activar**: Para hosting clásico/estático; usar `firebase-hosting-basics` en su lugar.

### `firebase-security-rules-auditor`
- **Cuándo activar**: Cuando se creen, revisen o endurezcan Security Rules de Firestore o Storage.
- **Qué incluye**: Auditoría de reglas de seguridad para Firebase.
- **NO activar**: Como skill umbrella para todo Firebase; debe haber reglas concretas que auditar.

### `firebase-data-connect`
- **Cuándo activar**: Solo cuando el trabajo sea SQL Connect/Data Connect/PostgreSQL GraphQL/SDKs generados.
- **Qué incluye**: Esquema, queries/mutations GraphQL, autorización, generación de SDKs.
- **NO activar**: Solo por elegir Firebase o mencionar base de datos; requiere contexto SQL/Postgres/GraphQL.

### `firebase-ai-logic-basics`
- **Cuándo activar**: Cuando el trabajo sea Firebase AI Logic / Gemini desde cliente (web/app).
- **Qué incluye**: Integración de Gemini API en aplicaciones web.
- **NO activar**: Como reemplazo de Genkit; puede coexistir con `developing-genkit-js`.

### `developing-genkit-js`
- **Cuándo activar**: Cuando haya trabajo Genkit en JS/TS (Node.js/TypeScript).
- **Qué incluye**: Desarrollo de features con Genkit en JavaScript/TypeScript.
- **NO activar**: Para otros lenguajes; usar la skill específica según la matriz Genkit multi-lenguaje (ver sección más abajo).
- **⚠️ Disponibilidad**: external-bootstrappable vía `${AGENTS_DIR}/developing-genkit-js/`. Ver [skill-registry](../../docs/skill-registry.md) para la matriz completa.

### Propagación de señal (Firebase)
Al confirmar Firebase, la señal debe pasar a fases siguientes (`project-init` → implementación (ODD, paso 6); si SDD fue seleccionado, `sdd-design` → `sdd-apply`) para que el orquestador active las skills correspondientes en su momento, según el contexto técnico específico y el registry (`docs/skill-registry.md`).

---

## Genkit (independiente del stack)

Cuando el producto requiera features de IA generativa con Genkit, la activación debe hacerse por lenguaje. Genkit no está atado a un stack específico (puede coexistir con Supabase, Firebase o backend propio).

| Skill | Trigger | Disponibilidad |
|-------|---------|----------------|
| `developing-genkit-js` | Trabajo Genkit en JS/TS (Node.js/TypeScript) | external-bootstrappable |
| `developing-genkit-dart` | Trabajo Genkit en Dart/Flutter | external-bootstrappable |
| `developing-genkit-go` | Trabajo Genkit en Go | external-bootstrappable |
| `developing-genkit-python` | Trabajo Genkit en Python | external-bootstrappable |

> **Routing lógico**: La matriz completa con triggers detallados y reglas anti-solape está en el [skill-registry](../../docs/skill-registry.md). Todas las skills Genkit son external-bootstrappable: requieren bootstrap (`bash scripts/bootstrap.sh`) o instalación manual desde `${AGENTS_DIR}` para activación real en opencode.
>
> Genkit NO se activa por defecto al elegir un stack. Requiere que el trabajo entre explícitamente en contexto de IA generativa con el lenguaje correspondiente.

---

