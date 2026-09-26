---
name: tasks-to-issues
description: "Trigger: plan de trabajo ya aprobado (feature de ODD o artifacts SDD), exportar a issues o crear issues desde el plan. Exporta el plan a issues GitHub vía issue-creation, sin reescribir ni partir el trabajo."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/core"
---

# Tasks-to-Issues — Export-Only Wrapper

> **Input:** `odd/tasks/<feature>.md` (ODD, por defecto) o `sdd/{change}/spec`, `design`, `tasks` (rama SDD, solo cuando SDD fue seleccionado explícitamente)
> **Output:** issue drafts o issues GitHub vía `issue-creation`
> **Modo:** Export-only; NO particiona trabajo

---

## Activation Contract

Usa esta skill cuando:
- ya exista un plan de trabajo aprobado — el documento de feature de ODD (`odd/tasks/<feature>.md`) o, si SDD fue seleccionado, `sdd/{change}` con spec/design/tasks,
- el usuario pida "exportar a issues" o "crear issues desde el plan",
- necesites pasar el plan al sistema de issues sin reescribir nada.

**NO la actives cuando:**
- estés todavía definiendo el plan,
- busques partir el trabajo en tareas,
- no exista ningún plan previo (sin plan → no genera nada),
- el usuario pida crear issues desde cero.

(rutas en **Decision Gates**)

---

## Hard Rules

**Export-only.** Esta skill lee un plan de trabajo ya aprobado y lo traduce a issues; no decide qué hacer, no parte trabajo, no valida contenido. La partición de trabajo es responsabilidad del flujo que la produjo: ODD (paso 5, documento de feature) por defecto, o `sdd-tasks` si SDD fue seleccionado.

- NO corre cuando no hay ningún plan que leer.
- NO usa `gh` manualmente; delega a `issue-creation`.

---

## Decision Gates

| Gate | Ruta |
| --- | --- |
| El usuario pida crear issues desde cero | Usar `issue-creation` directamente |
| Estés todavía definiendo el plan | ODD: primero el documento de feature; SDD: `sdd-propose` / `sdd-design` |
| Busques partir el trabajo en tareas | Partición de trabajo: territorio del flujo que produjo el plan |
| No exista ningún plan previo | Fallback exacto: `references/fallback.md` |

---

## Execution Steps

1. Verifica que existe un plan aprobado: `odd/tasks/<feature>.md` (ODD, por defecto) o `sdd/{change}` con spec/design/tasks (rama SDD, si SDD fue seleccionado). Sin plan: aplica el fallback (`references/fallback.md`).
2. **Leer el plan de trabajo** — ODD: intención, alcance y tareas; SDD: spec → contexto, design → decisiones, tasks → checklists.
3. **Mapear a issue draft** — Título: basado en el plan · Body: resumen del alcance + tareas como checklist · Labels: según tipo de cambio (feat, fix, chore). Formato: `references/formato-issue.md`.
4. **Crear issue via `issue-creation`** — NO usa `gh` manualmente; delega a `issue-creation`.

---

## Output Contract

Issue draft en el formato canónico (Summary / Technical Approach / Tasks / Acceptance Criteria), mapeado desde el plan de entrada: ODD = intención/alcance/tareas del documento de feature; SDD = spec → Summary, design → Technical Approach, tasks → Tasks, spec scenarios → Acceptance Criteria. Plantilla y mapeo exacto: `references/formato-issue.md`.

---

## References

- `references/flujo-export.md` — flujo por pasos y mapeo ODD/SDD del plan de entrada.
- `references/context-validation.md` — When to Use y When NOT to Use originales (verbatim).
- `references/formato-issue.md` — plantilla exacta del issue draft (Summary / Technical Approach / Tasks / Acceptance Criteria).
- `references/no-hace-limites.md` — Qué NO hace esta skill.
- `references/fallback.md` — mensaje exacto cuando no hay plan de trabajo.
- `references/relacion-skills.md` — relación con ODD, `sdd-tasks`, `issue-creation`, `branch-pr`, `sdd-propose` / `sdd-spec`.
- `references/comandos.md` — bloques de comandos verbatim de exportación y fallback.
