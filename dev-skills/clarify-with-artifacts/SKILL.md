---
name: clarify-with-artifacts
description: "Trigger: idea vaga con artifacts ya existentes, estructurar contexto antes del trabajo formal, resumen breve de lo sabido. Helper opt-in que estructura la intención; no sustituye el trabajo formal."
license: MIT
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

## Activation Contract

Usa esta skill cuando:
- el usuario tenga una idea vaga y ya existan docs/artifacts relevantes,
- quieras estructurar contexto rápidamente antes de empezar el trabajo formal (ODD), o de `sdd-propose` / `sdd-spec` si SDD fue seleccionado,
- necesites un resumen breve que recoja lo que ya se sabe del proyecto.

**NO la actives cuando:**
- el usuario ya esté en fase SDD (`/sdd-*`),
- busques escribir artifacts canónicos,
- el request sea puramente técnico de stack,
- no existan artifacts previos y la idea sea muy temprana.

(rutas en **Decision Gates**)

---

## Hard Rules

**No reemplaza el trabajo formal.** Esta skill es un puente ligero que junta lo que ya se sabe (docs, Engram, explore) para que el usuario entre a `sdd-propose` o `sdd-spec` con más contexto. Nunca genera artifacts fuente de verdad.

- NO aclara contenido profundo (para eso está el flujo formal).
- NO es obligatoria: es opt-in y vive como helper lateral.
- Si no hay nada claro, usa `brainstorm` primero: es upstream; esta skill entra después de artifacts.

---

## Decision Gates

| Gate | Ruta |
| --- | --- |
| El usuario ya está en fase SDD (`/sdd-*`) | Usar la fase SDD correspondiente |
| Busques escribir artifacts canónicos | `sdd-propose` / `sdd-spec` |
| El request sea puramente técnico de stack | Usar skill de stack |
| No existan artifacts previos y la idea sea muy temprana | Usar `brainstorm` |

---

## Execution Steps

1. Consulta las fuentes que ya existen del proyecto: docs, memoria del proyecto (Engram, si la usás), el plan de trabajo (`odd/tasks/<feature>.md` si seguís ODD) y artifacts SDD si los hay.
2. Entrega la salida más ligera posible según el **Output Contract**.

---

## Output Contract

Entrega una de estas dos opciones, la más ligera posible: resumen inline breve o checklist de entrada para el trabajo formal. Ambas plantillas: `references/output-modes.md`.

---

## References

- `references/output-modes.md` — Output Esperado completo (resumen inline y checklist).
- `references/context-validation.md` — When to Use y When NOT to Use originales (verbatim).
- `references/fuentes-mapeo.md` — Fuentes que consulta y relación con otras skills.
- `references/no-hace-limites.md` — Qué NO hace la skill y límites estrictos.
