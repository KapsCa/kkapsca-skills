---
name: request-triage
description: >
  Enrutador opt-in y ultra-delgado que decide si un request va a SDD, a una skill existente
  o a issue/discussion. NO aclara contenido ni parte trabajo; solo decide el destino.
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/core"
---

# Request Triage — Ultra-Thin Router

> **Input:** prompt del usuario, `.atl/skill-registry.md`, Engram reciente
> **Output:** recomendación inline (ej. "ve a sdd-propose", "usa Flutter skill", "crea issue")
> **Modo:** opt-in, solo enrutamiento

---

## When to Use

Usa esta skill cuando:
- el usuario haga una pregunta ambigua sobre qué hacer a continuación,
- exista duda entre usar SDD, una skill específica o crear un issue,
- quieras una recomendación rápida sin entrar en aclaración de contenido.

## When NOT to Use

- el usuario ya haya dado un comando `/sdd-*` explícito (gana SDD, no enrutes),
- el contexto sea puramente técnico de stack (usa skill de stack correspondiente),
- busques aclarar o estructurar el contenido del request (usa `clarify-with-artifacts`),
- quieras partir trabajo (usa `sdd-tasks` o `sdd-to-issues`).

---

## Principio Rector

**Ultra-delgado, solo router.** Esta skill es un semáforo, no un taller. Decide el destino y se detiene. No aclara, no implementa, no parte trabajo.

---

## Lógica de Enrutamiento

```text
Request llega
      │
      ▼
¿Comando /sdd-* explícito?
      ├─ SÍ → Redirigir a fase SDD correspondiente (STOP)
      │
      ▼ NO
¿Es pregunta técnica de stack (Flutter/Firebase/Supabase/Genkit)?
      ├─ SÍ → Usar skill de stack correspondiente (STOP)
      │
      ▼ NO
¿Hay artifact SDD previo relevante en Engram?
      ├─ SÍ → Sugerir continuar con SDD (sdd-continue / sdd-verify)
      │
      ▼ NO
¿El request implica una tarea nueva?
      ├─ SÍ → Sugerir `sdd-new` o `issue-creation`
      │
      ▼ NO
→ Sugerir discussion / clarification
```

---

## Ejemplos de Output

| Request | Recomendación |
|---------|---------------|
| "Quiero añadir auth" | Ve a SDD: `/sdd-new auth-feature` |
| "Arregla el bug en login" | Usa `diagnose` o crea issue vía `issue-creation` |
| `/sdd-apply auth-feature` | Comando SDD explícito → ejecutar `sdd-apply` directamente |
| "¿Qué stack elijo para mi app?" | Usa `tech-feasibility` |
| "Quiero reportar un error" | Usa `issue-creation` para crear bug report |

---

## Qué NO hace esta skill

- NO aclara el contenido del request (eso es `clarify-with-artifacts`),
- NO parte trabajo en tareas (eso es `sdd-tasks`),
- NO escribe artifacts canónicos (ni en Engram ni archivos),
- NO reemplaza fases SDD ni skills de stack,
- NO es obligatoria: es opt-in y vive como helper lateral.

---

## Nota de Persistencia

Opcionalmente puede dejar una nota breve en Engram (`mem_save`) con la recomendación dada, pero **NUNCA** escribe artifacts canónicos. El destino final (SDD, issue, discussion) es quien persiste.

---

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| `sdd-*` (todas) | Ganan si hay comando explícito; `request-triage` cede |
| `clarify-with-artifacts` | `request-triage` decide destino; `clarify` estructura contenido |
| `issue-creation` | Canal de salida si se decide crear issue |
| Skills de stack | Ganan si el request es técnico específico de ese stack |
