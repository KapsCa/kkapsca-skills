# Activación de skills por stack confirmado — project-init

Detalle local de SKILL.md (## Hard Rules y ## References). Incluye Supabase y Firebase.

## Propagación de Stack

Si el stack elegido en `tech-feasibility` es **Supabase**, esta señal debe propagarse a fases siguientes:

> **Fases:** por defecto el trabajo entra en **implementación** (ODD, paso 6). Si SDD fue seleccionado explícitamente, la fase equivalente es `sdd-design` seguida de `sdd-apply`.

- **tech-feasibility** confirma Supabase → señal de stack guardada
- **implementación**: activar `supabase` para integración general
- **implementación** (con SQL/RLS/Postgres): activar `supabase-postgres-best-practices`
- El orquestador resuelve estas activaciones vía `docs/skill-registry.md`

> **Nota**: Las skills de Supabase requieren instalación previa en `~/.config/opencode/skills/` (destino de opencode) o en `~/.agents/skills/` (destino de Pi) para estar disponibles realmente. El registry define orquestación, no instala.

Si el stack elegido en `tech-feasibility` es **Firebase**, esta señal debe propagarse a fases siguientes:

> **Fases:** por defecto el trabajo entra en **implementación** (ODD, paso 6). Si SDD fue seleccionado explícitamente, la fase equivalente es `sdd-design` seguida de `sdd-apply`.

- **tech-feasibility** confirma Firebase → señal de stack guardada
- **implementación**: activar `firebase-basics` para configuración general
- **implementación** (con Auth específico): activar `firebase-auth-basics`
- **implementación** (con Firestore Standard): activar `firebase-firestore-standard`
- **implementación** (con Firestore Enterprise Native Mode explícito): activar `firebase-firestore-enterprise-native-mode`
- **implementación** (con Hosting clásico/estático): activar `firebase-hosting-basics`
- **implementación** (con Next.js/Angular/SSR/App Hosting): activar `firebase-app-hosting-basics`
- **implementación** (con Security Rules): activar `firebase-security-rules-auditor`
- **implementación** (con Data Connect/SQL/GraphQL): activar `firebase-data-connect`
- **implementación** (con Firebase AI Logic/Gemini): activar `firebase-ai-logic-basics`
- **implementación** (con Genkit JS/TS): activar `developing-genkit-js`
- El orquestador resuelve estas activaciones vía `docs/skill-registry.md` y sus compact rules.

> **Nota**: Las skills de Firebase requieren instalación previa en `~/.config/opencode/skills/` (destino de opencode) o en `~/.agents/skills/` (destino de Pi) para estar disponibles realmente. El registry define orquestación lógica (cuándo activar), no garantiza disponibilidad real. No activar skills Firebase solo por mencionar Firebase genéricamente.
