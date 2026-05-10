# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

> **External Skills Availability**: Este registry define **orquestación lógica** (cuándo activar cada skill según contexto y fase). No garantiza disponibilidad física en el entorno. Las skills marcadas como `external-bootstrappable` residen fuera del repo en `${AGENTS_DIR}` (por defecto `$HOME/.agents/skills`, configurable vía `EXTERNAL_SKILLS_DIR` en el bootstrap) y requieren instalación manual o ejecución del bootstrap (`bash scripts/bootstrap.sh`) para estar disponibles en `~/.config/opencode/skills`. Sin instalación física, opencode no las detectará y el enrutamiento será solo lógico. Skills marcadas como `logical-only` existen como reglas de routing/candidato sin instalación garantizada.

## User Skills

| Trigger | Skill | Path | State |
|---------|-------|------|-------|
| PASO 1 de un pipeline de definición de producto | brainstorm | ./brainstorm/SKILL.md | repo-local |
| PASO 2 de un pipeline de definición de producto | product-discovery | ./product-discovery/SKILL.md | repo-local |
| Skill de transición entre discovery y factibilidad | project-init | ./project-init/SKILL.md | repo-local |
| PASO 4 de un pipeline de definición de producto | tech-feasibility | ./tech-feasibility/SKILL.md | repo-local |
| Criterio personal para proyectos Flutter | flutter-personal-standards | ./dev-skills/flutter-personal-standards/SKILL.md | repo-local |
| Skill ejecutiva para preparar un repositorio | repo-bootstrap | ./dev-skills/repo-bootstrap/SKILL.md | repo-local |
| Revisión de arquitectura de proyecto | improve-codebase-architecture | ./dev-skills/improve-codebase-architecture/SKILL.md | repo-local |
| Debugging sistemático de errores | diagnose | ./dev-skills/diagnose/SKILL.md | repo-local |
| Perspectiva de sistema antes de editar | zoom-out | ./dev-skills/zoom-out/SKILL.md | repo-local |
| Stack Supabase confirmado en tech-feasibility | supabase | ${AGENTS_DIR}/supabase/SKILL.md | external-bootstrappable |
| SQL/RLS/Postgres en fase de diseño/implementación | supabase-postgres-best-practices | ${AGENTS_DIR}/supabase-postgres-best-practices/SKILL.md | external-bootstrappable |
| Firebase confirmado en tech-feasibility / setup de proyecto | firebase-basics | ${AGENTS_DIR}/firebase-basics/SKILL.md | external-bootstrappable |
| Auth/sign-in/providers/tokens en Firebase | firebase-auth-basics | ${AGENTS_DIR}/firebase-auth-basics/SKILL.md | external-bootstrappable |
| Firestore Standard: queries, índices, SDK, reglas | firebase-firestore-standard | ${AGENTS_DIR}/firebase-firestore-standard/SKILL.md | external-bootstrappable |
| Firestore Enterprise Native Mode explícito | firebase-firestore-enterprise-native-mode | ${AGENTS_DIR}/firebase-firestore-enterprise-native-mode/SKILL.md | external-bootstrappable |
| Hosting clásico: estático/SPA sin SSR | firebase-hosting-basics | ${AGENTS_DIR}/firebase-hosting-basics/SKILL.md | external-bootstrappable |
| Next.js/Angular/SSR/App Hosting explícito | firebase-app-hosting-basics | ${AGENTS_DIR}/firebase-app-hosting-basics/SKILL.md | external-bootstrappable |
| Revisar/endurecer Security Rules de Firestore/Storage | firebase-security-rules-auditor | ${AGENTS_DIR}/firebase-security-rules-auditor/SKILL.md | external-bootstrappable |
| Data Connect / SQL Connect / GraphQL / Postgres SDK | firebase-data-connect | ${AGENTS_DIR}/firebase-data-connect/SKILL.md | external-bootstrappable |
| Firebase AI Logic / Gemini desde cliente | firebase-ai-logic-basics | ${AGENTS_DIR}/firebase-ai-logic-basics/SKILL.md | external-bootstrappable |
| Genkit en JS/TS | developing-genkit-js | ${AGENTS_DIR}/developing-genkit-js/SKILL.md | external-bootstrappable |
| Genkit en Dart/Flutter | developing-genkit-dart | ${AGENTS_DIR}/developing-genkit-dart/SKILL.md | external-bootstrappable |
| Genkit en Go | developing-genkit-go | ${AGENTS_DIR}/developing-genkit-go/SKILL.md | external-bootstrappable |
| Genkit en Python | developing-genkit-python | ${AGENTS_DIR}/developing-genkit-python/SKILL.md | external-bootstrappable |
| Advisory/warning-first sobre ramas, PRs y commits | repo-guardrails | ./dev-skills/repo-guardrails/SKILL.md | repo-local |
| Export-only de artifacts SDD a GitHub issues | sdd-to-issues | ./dev-skills/sdd-to-issues/SKILL.md | repo-local |
| Enrutador opt-in de requests a SDD/skills/issues | request-triage | ./dev-skills/request-triage/SKILL.md | repo-local |
| Clarificación opt-in usando artifacts existentes | clarify-with-artifacts | ./dev-skills/clarify-with-artifacts/SKILL.md | repo-local |
| Crear nuevas AI skills | skill-creator | ${AGENTS_DIR}/skill-creator/SKILL.md | logical-only |

## Compact Rules

### brainstorm
- Convierte idea vaga en Product Brief; no saltes al stack.
- Orden: problema → usuario → propuesta de valor → MVP → diferenciadores → dudas.
- Pide una explicación de 30 segundos y desafía "para todos".
- El MVP debe ser lo mínimo que resuelve el problema principal.
- Termina con output útil y listo para pasar a discovery.

### product-discovery
- Valida si el problema existe, quién lo sufre y qué alternativa usa hoy.
- Usa ruta ligera para side projects; no fuerces discovery pesado.
- Busca competencia directa, indirecta y sustitutos.
- Resume usuario + JTBD + propuesta de valor con claridad.
- Antes de construir, define la forma más barata de validar interés.

### project-init
- Skill de transición entre product-discovery y tech-feasibility.
- Recibe Discovery Report → produce Project Framing Doc.
- Enfoque: predictivo (requisitos claros) / adaptativo (evolucionan) / híbrido.
- Define fases ligeras según el contexto real del proyecto; no impone un modelo universal.
- Gobernanza mínima: decisiones, cambios y criterios de avance hacia factibilidad técnica.
- **Bypass**: salto opcional a tech-feasibility cuando el proyecto es pequeño.

### tech-feasibility
- Evalúa factibilidad técnica, no gustos por frameworks.
- Inventaría features del MVP y marca auth, persistencia, tiempo real, offline, etc.
- Propón alternativas con tradeoffs; no digas "usa X" sin contexto.
- Estima con rangos y señala incertidumbre; prototipa lo incierto.
- La arquitectura debe ser proporcional al alcance.
- **Input aceptados**: Project Framing Doc (principal) o Discovery Report (bypass).

### flutter-personal-standards
- Empieza simple y escala solo cuando el alcance lo pida.
- Elige estado según alcance real: local → setState, compartido → Provider/ChangeNotifier, escalable → Riverpod/Bloc.
- No impongas GetX si el proyecto no lo exige.
- Separa UI, estado e IO; no mezcles todo en un widget.
- Si el caso ya es específico, enruta a la skill oficial de Flutter correspondiente.

### repo-bootstrap
- No push directo a main; todo entra por PR.
- `release-please` y Conventional Commits son obligatorios en proyectos nuevos.
- Ningún merge sin checks funcionales reales del stack.
- Auto-merge solo después de PR validation + checks verdes.
- En repos privados Free personales, el hook local `pre-push` es parte de la protección.

### improve-codebase-architecture
- Revisión de arquitectura enfocada en deuda, acoplamiento y violaciones.
- Integra con SDD: úsala antes de `sdd-propose` o `sdd-design`.
- No la uses para debugging puntual; para eso usa `diagnose`.
- Produce un resumen ejecutivo breve, no un tratado.
- Si el proyecto es pequeño, di "acoplado / sin estructura" y recomienda pasos mínimos.
- **Main skill** para revisión arquitectónica transversal; `improve-codebase-architecture` es la primaria de las tres.
- **Precedencia**: skills de stack (Flutter/Firebase/Supabase/Genkit) ganan si el problema es específico de ese stack.
- **Fallback**: si no hay código suficiente o el usuario está en `brainstorm`/`discovery`, no activar; usar fase upstream.
- **SDD explícito gana**: si hay comando `/sdd-*`, usarlo en lugar de esta skill.

### diagnose
- Debugging canónico: repro → minimiza → instrumenta → fix → regresión.
- Úsala para errores concretos, no para revisiones amplias de arquitectura.
- No hagas refactors mientras debuggeas; enfócate en el fix mínimo.
- Integra con SDD: si el bug revela necesidad de cambio estructural, luego enruta a `sdd-propose`.
- Output: reporte breve con reproducción, causa raíz, fix y regresión.
- **Companion skill** para debugging puntual; no es reemplazo de `improve-codebase-architecture`.
- **Precedencia**: si el bug es puramente de framework (Flutter/Firebase), usar skill oficial de stack en su lugar.
- **Fallback**: si no hay error reproducible o el usuario está en fase diseño/propuesta, no activar.
- **SDD explícito gana**: si hay comando `/sdd-*`, usarlo en lugar de esta skill.

### zoom-out
- Perspectiva de sistema antes de editar código desconocido.
- Mapea dependencias, flujo de datos y riesgos de edición.
- Úsala antes de `sdd-apply` o `sdd-design` en módulos que no dominas.
- No hagas cambios aquí; solo mapa y diagnóstico de riesgos.
- Output súper breve: dependencias, flujo, riesgos y recomendación.
- **Companion skill** para contexto previo a edición; no es análisis arquitectónico profundo.
- **Precedencia**: omitir si el módulo ya es conocido o el cambio es mecánico.
- **Fallback**: si no hay código suficiente o el usuario apenas inicia, no activar.
- **SDD explícito gana**: si hay comando `/sdd-*`, usarlo en lugar de esta skill.

### supabase
- Activar tras decisión de stack en `tech-feasibility`; no antes.
- Incluye integración general: auth, realtime, storage, database.
- Si la skill no está instalada en `~/.config/opencode/skills`, el routing es solo lógico y requiere bootstrap manual desde `${AGENTS_DIR}/supabase/`.

### supabase-postgres-best-practices
- Activar solo en fases de diseño/apply con contexto SQL, RLS, migrations o esquema Postgres.
- No activar solo por haber elegido Supabase como stack.
- Requiere trabajo técnico específico: performance, índices, políticas RLS, esquema relacional.

### skill-creator
- Solo referencia documental para crear nuevas AI skills.
- NO participa en routing normal ni en el pipeline de desarrollo estándar.
- No está incluida en el bootstrap por defecto; requiere instalación manual desde `.claude/skills/` si se necesita.

### firebase-basics
- Activar tras decisión de stack en `tech-feasibility` o cuando la conversación pida inicialización/CLI/proyecto Firebase.
- Incluye configuración general: autenticación, proyectos, comandos CLI, reglas base.
- Si la skill no está instalada en `~/.config/opencode/skills`, el routing es solo lógico y requiere bootstrap manual desde `${AGENTS_DIR}/firebase-basics/`.

### firebase-auth-basics
- Activar con trabajo específico de Auth: sign-in, providers, tokens, reglas con `request.auth`.
- No activar solo por haber elegido Firebase; debe haber contexto de autenticación.
- Requiere `firebase-basics` confirmado o implícito.

### firebase-firestore-standard
- Activar con trabajo específico de Firestore Standard: modelo documento, queries, índices, SDK, reglas de seguridad.
- NO activar por mencionar Firebase genéricamente.
- Requiere contexto técnico de base de datos documental.

### firebase-firestore-enterprise-native-mode
- Activar SOLO si el usuario confirma explícitamente Enterprise Native Mode.
- Es mutuamente excluyente con `firebase-firestore-standard`; no mezclar guías.
- No activar por default ni por solo mencionar Firestore.

### firebase-hosting-basics
- Activar para hosting clásico: sitio estático, Single Page Apps (SPA) sin SSR.
- NO activar para Next.js/Angular SSR; usar `firebase-app-hosting-basics` en su lugar.
- Requiere distinción clara entre hosting estático y App Hosting.

### firebase-app-hosting-basics
- Activar para Next.js/Angular/full-stack con SSR, ISR o App Hosting explícito.
- NO activar para hosting clásico/estático; usar `firebase-hosting-basics` en su lugar.
- Requiere confirmación de framework con SSR o App Hosting.

### firebase-security-rules-auditor
- Activar cuando se creen, revisen o endurezcan Security Rules de Firestore o Storage.
- Ideal como auditoría/review, no como skill umbrella para todo Firebase.
- No activar prematuramente; requiere reglas concretas que auditar.

### firebase-data-connect
- Activar solo con trabajo de SQL Connect, Data Connect, PostgreSQL, GraphQL o SDKs generados.
- No activar por solo elegir Firebase o mencionar base de datos.
- Requiere contexto de SQL/Postgres/GraphQL.

### firebase-ai-logic-basics
- Activar cuando el trabajo sea Firebase AI Logic / Gemini desde cliente (web/app).
- Complementa a Genkit, no lo sustituye; puede coexistir.
- Requiere contexto de IA generativa en Firebase.

### developing-genkit-js
- Activar cuando haya trabajo Genkit en JS/TS (Node.js/TypeScript).
- Para Flutter/Dart usar `developing-genkit-dart`; para Go usar `developing-genkit-go`; para Python usar `developing-genkit-python`.
- No activar para otros lenguajes; requiere stack JS/TS confirmado.
- State: external-bootstrappable — requiere bootstrap desde `${AGENTS_DIR}` o instalación manual.

### developing-genkit-dart
- Activar cuando haya trabajo Genkit en Dart/Flutter.
- Para JS/TS usar `developing-genkit-js`; para Go usar `developing-genkit-go`; para Python usar `developing-genkit-python`.
- No activar para otros lenguajes; requiere stack Dart/Flutter confirmado.
- State: external-bootstrappable — requiere bootstrap desde `${AGENTS_DIR}` o instalación manual.

### developing-genkit-go
- Activar cuando haya trabajo Genkit en Go.
- Para JS/TS usar `developing-genkit-js`; para Dart/Flutter usar `developing-genkit-dart`; para Python usar `developing-genkit-python`.
- No activar para otros lenguajes; requiere stack Go confirmado.
- State: external-bootstrappable — requiere bootstrap desde `${AGENTS_DIR}` o instalación manual.

### developing-genkit-python
- Activar cuando haya trabajo Genkit en Python.
- Para JS/TS usar `developing-genkit-js`; para Dart/Flutter usar `developing-genkit-dart`; para Go usar `developing-genkit-go`.
- No activar para otros lenguajes; requiere stack Python confirmado.
- State: external-bootstrappable — requiere bootstrap desde `${AGENTS_DIR}` o instalación manual.

### repo-guardrails
- Capa advisory/warning-first; NO bloquea ni reemplaza `repo-bootstrap`.
- Input: estado rama/PR/repo + reglas `repo-bootstrap` / `docs/governance.md`.
- Output: warnings/checklist inline; referir a `repo-bootstrap` para normas.
- Si hay comando `/sdd-*`, gana SDD; `repo-guardrails` cede.

### sdd-to-issues
- Export-only: convierte artifacts SDD (spec/design/tasks) en issues GitHub vía `issue-creation`.
- NO descompone trabajo; eso es territorio exclusivo de `sdd-tasks`.
- Fallback: sin artifacts SDD → no genera nada, sugiere usar SDD primero.
- `issue-creation` / `branch-pr` ganan para crear/aprobar issues y PRs.

### request-triage
- Enrutador opt-in y ultra-delgado; solo decide destino (SDD/skill/issue).
- NO aclara contenido (usa `clarify-with-artifacts` para eso).
- NO parte trabajo; solo da recomendación inline.
- Comando `/sdd-*` explícito gana siempre; `request-triage` cede.

### clarify-with-artifacts
- Helper opt-in que estructura contexto usando docs/artifacts existentes.
- NO sustituye `sdd-propose` ni `sdd-spec`; output mínimo inline.
- NO escribe artifacts canónicos; SDD manda en eso.
- Fallback: sin artifacts previos → sugerir `brainstorm` o `sdd-init`.

## Anti-Solape

**Regla general**: Si el trigger coincide con una skill de stack (Flutter/Firebase/Supabase/Genkit) Y también coincide con una de las 3 skills de arquitectura (`improve-codebase-architecture`, `diagnose`, `zoom-out`), **gana la skill de stack**.

### Precedencia General

| Escenario | Skill que gana | Razón |
|-----------|----------------|-------|
| Bug en Flutter + `diagnose` | Skill oficial Flutter (ej. `flutter-architecting-apps`) | El problema es específico de ese stack |
| Revisión arquitectónica + proyecto Flutter | `improve-codebase-architecture` (transversal) O `flutter-architecting-apps` | Según si el problema es de arquitectura general o específico de Flutter |
| Contexto previo a editar + módulo Supabase | `supabase` o `supabase-postgres-best-practices` | El problema es específico de ese stack |
| Comando `/sdd-*` explícito | Fase SDD correspondiente | SDD manda; estas 3 skills son solo companions previos |

### Precedencia: Skills Derivadas vs Flujo Existente

| Escenario | Skill que gana | Razón |
|-----------|----------------|-------|
| Comando `/sdd-*` explícito | Fase SDD (`sdd-propose`, `sdd-spec`, etc.) | SDD es fuente de verdad para planificación |
| Partición de trabajo | `sdd-tasks` | `sdd-to-issues` solo exporta, no descompone |
| Crear/aprobar issues y PRs | `issue-creation` / `branch-pr` | `sdd-to-issues` es canal de salida, no dueño |
| Normas del repo | `repo-bootstrap` | `repo-guardrails` es capa advisory lateral |
| Aclaración de contenido profundo | `sdd-propose` / `sdd-spec` | `clarify-with-artifacts` es helper opt-in |
| Request ambiguo | `request-triage` decide; si hay `/sdd-*` gana SDD | `request-triage` es solo router |

**Ownership claro**:
- SDD planea y escribe artifacts canónicos.
- Engram persiste memoria y artifacts SDD.
- `issue-creation` / `branch-pr` gobiernan issues/PRs.
- `repo-bootstrap` fija guardrails normativos del repo.
- Las 4 skills derivadas son helpers/advisory/export-only y NO reemplazan a los anteriores.

**Principio**: Las 3 skills arquitectónicas son **herramientas tácticas transversales**. Si el problema tiene un stack definido, la skill de stack tiene prioridad porque conoce los patrones específicos.

**Fallback de no disponibilidad**: Las skills `improve-codebase-architecture`, `diagnose` y `zoom-out` residen en `dev-skills/` y están disponibles localmente. Para skills externas (ej. Firebase, Supabase, Genkit en `${AGENTS_DIR}`), si no están instaladas en `~/.config/opencode/skills`, el routing es solo lógico y requiere bootstrap manual.

## Project Conventions

No se detectaron archivos de convención de proyecto en la raíz (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `GEMINI.md`, `copilot-instructions.md`).

## Pipeline

```
brainstorm → product-discovery → project-init → tech-feasibility
```

**Bypass (ruta ligera)**:
```
brainstorm → product-discovery → tech-feasibility
```

**Condiciones para bypass de project-init**:
- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con Discovery Report directo

**Outputs por etapa**:
- brainstorm → Product Brief v4.0
- product-discovery → Discovery Report v3.0
- project-init → Project Framing Doc v1.0 (Project Charter como alias temporal)
- tech-feasibility → Tech Spec v3.0

## External Adaptation Gate

This section documents external skill candidates (e.g., from awesome-copilot) that are being considered for future adoption. These candidates are **non-routable** and **not available for installation** in the current release.

### Candidate Table

| Candidate | Source | Status | Blocked By | Future Entry Criteria |
|-----------|--------|--------|------------|----------------------|
| `agent-governance` | awesome-copilot (external) | deferred | `repo-bootstrap`, `branch-pr`, `issue-creation` | Unique scope sentence, explicit "When NOT to Use", precedence row, availability disclaimer, real native `SKILL.md` |
| `agentic-eval` | awesome-copilot (external) | deferred | `sdd-verify` | Unique scope sentence, explicit "When NOT to Use", precedence row, availability disclaimer, real native `SKILL.md` |

### Ownership Deny-List

The following domains are explicitly out of scope for this change. External-derived ideas cannot own these flows:

- **`agent-governance`**: blocked while overlap exists with `repo-bootstrap`, `branch-pr`, `issue-creation`.
- **`agentic-eval`**: blocked while overlap exists with `sdd-verify`.

### Routing Rule

**Only entries under `## User Skills` are routable.** Entries in this section are logical-only candidates and will NOT trigger skill loading or routing until they are formally migrated to `## User Skills` with a physical `SKILL.md` file.

### Scope Isolation (Change: adapt-awesome-copilot-skills-to-our-flow)

This change modifies **only** the following files:
- `.atl/skill-registry.md` (this file)
- `README.md`
- `docs/installation.md`

Any other diffs present in the branch (e.g., `.github/workflows/release-please.yml`) belong to separate changes and are **out of scope** for this adaptation. The ownership deny-list (`agent-governance` blocked by `repo-bootstrap`/`branch-pr`/`issue-creation`; `agentic-eval` blocked by `sdd-verify`) is reiterated in all three files for cross-document consistency.
