---
name: clarify-with-artifacts
description: >
  Helper opt-in que estructura la intención del usuario usando artifacts existentes
  (docs, Engram, proposal, spec, explore). NO sustituye el trabajo formal (ODD, ni `sdd-propose` / `sdd-spec` si SDD fue seleccionado);
  output mínimo inline o checklist para alimentar el trabajo formal.
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/core"
---

# Clarify with Artifacts — Opt-in Context Helper

> **Input:** prompt del usuario + docs/Engram/proposal/spec/explore existentes
> **Output:** resumen inline o checklist para alimentar proposal/spec
> **Modo:** opt-in, output mínimo, NO reemplaza el trabajo formal

---

## When to Use

Usa esta skill cuando:
- el usuario tenga una idea vaga y ya existan docs/artifacts relevantes,
- quieras estructurar contexto rápidamente antes de empezar el trabajo formal (ODD), o de `sdd-propose` / `sdd-spec` si SDD fue seleccionado,
- necesites un resumen breve que recoja lo que ya se sabe del proyecto.

## When NOT to Use

- el usuario ya esté en fase SDD (`/sdd-*`) — usa la fase correspondiente,
- busques escribir artifacts canónicos (usa `sdd-propose` / `sdd-spec`),
- el request sea puramente técnico de stack (usa skill de stack),
- no existan artifacts previos y la idea sea muy temprana (usa `brainstorm`).

---

## Principio Rector

**No reemplaza el trabajo formal.** Esta skill es un puente ligero que junta lo que ya se sabe (docs, Engram, explore) para que el usuario entre a `sdd-propose` o `sdd-spec` con más contexto. Nunca genera artifacts fuente de verdad.

---

## Fuentes que Consulta

| Fuente | Qué aporta |
|--------|------------|
| `docs/` | Estándares, governance, docs de ODD y SDD |
| Engram (`mem_search`) | Decisiones, discoveries, session summaries previos |
| `odd/tasks/<feature>.md` | Documento de feature de ODD: intención, alcance y tareas |
| `sdd/{change}/explore` | Hallazgos de exploración previa (rama SDD) |
| `sdd/{change}/proposal` | Intención y scope ya delineados |
| `docs/skill-registry.md` | Triggers y reglas de routing actuales |

---

## Output Esperado

Una de estas dos opciones (la más ligera posible):

**1. Resumen inline breve:**
```text
📋 Clarify Summary:
- Proyecto: KkapsCa-project-kickstart
- Stack confirmado: Flutter + Supabase (ver tech-feasibility)
- Intención: Adaptar 4 skills derivadas de matt
- Artifacts previos: proposal ✅, spec ✅, design ✅, tasks ✅
- Siguiente paso sugerido: implementación (ODD, paso 6)
```

**2. Checklist de entrada para el trabajo formal:**
```markdown
## Checklist de entrada (ODD, o `sdd-propose` si SDD fue seleccionado)
- [ ] Problema claro: {resumen}
- [ ] Usuario identificado: {quién}
- [ ] Propuesta de valor: {qué aporta}
- [ ] MVP definido: {alcance mínimo}
```

---

## Qué NO hace esta skill

- NO escribe artifacts canónicos (el trabajo formal manda en eso),
- NO reemplaza el trabajo formal: ni ODD ni `sdd-propose` / `sdd-spec`,
- NO aclara contenido profundo (para eso está el flujo formal),
- NO es obligatoria: es opt-in y vive como helper lateral,
- NO compite con `brainstorm` (ese es para ideas muy tempranas sin artifacts).

---

## Límite Estricto

Esta skill puede leer y resumir, pero **NUNCA** debe:
1. Crear un artifact con topic_key en Engram (eso es del flujo formal),
2. Sobrescribir proposal o spec existentes,
3. Convertirse en un paso obligatorio del pipeline.

---

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| `sdd-propose` / `sdd-spec` | Aguas abajo solo si SDD fue seleccionado; `clarify` alimenta, no reemplaza |
| `brainstorm` | Upstream; si no hay nada claro, usa `brainstorm` primero |
| `explore` (SDD) | `explore` es fase SDD; `clarify` es helper opt-in previo |
