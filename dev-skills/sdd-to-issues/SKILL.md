---
name: sdd-to-issues
description: >
  Export-only skill que convierte un plan de trabajo ya aprobado en issue drafts
  o issues GitHub reales usando issue-creation. Acepta el documento de feature de ODD
  (`odd/tasks/<feature>.md`) por defecto, o artifacts SDD (spec, design, tasks) si SDD
  fue seleccionado. NO descompone trabajo; eso es territorio de sdd-tasks.
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/sdd"
---

# SDD-to-Issues — Export-Only Wrapper

> **Nota sobre el nombre:** la skill conserva el nombre `sdd-to-issues`, pero su entrada
> por defecto ya no es SDD. El flujo por defecto es **ODD**, y su plan de trabajo vive en
> `odd/tasks/<feature>.md`. Los artifacts SDD son la entrada **alternativa**, y aplican
> solo cuando SDD fue seleccionado explícitamente.

> **Input:** `odd/tasks/<feature>.md` (ODD, por defecto) o `sdd/{change}/spec`, `design`, `tasks` (rama SDD)
> **Output:** issue drafts o issues GitHub vía `issue-creation`
> **Modo:** Export-only; NO particiona trabajo

---

## When to Use

Usa esta skill cuando:
- ya exista un plan de trabajo aprobado — el documento de feature de ODD (`odd/tasks/<feature>.md`) o, si SDD fue seleccionado, `sdd/{change}` con spec/design/tasks,
- el usuario pida "exportar a issues" o "crear issues desde el plan",
- necesites pasar el plan al sistema de issues sin reescribir nada.

## When NOT to Use

- estés todavía definiendo el plan (ODD: primero el documento de feature; SDD: `sdd-propose` / `sdd-design`),
- busques partir el trabajo en tareas (eso es el territorio de la partición, no de esta skill),
- no exista ningún plan previo (sin plan → no genera nada),
- el usuario pida crear issues desde cero (usa `issue-creation` directamente).

---

## Principio Rector

**Export-only.** Esta skill lee un plan de trabajo ya aprobado y lo traduce a issues; no decide qué hacer, no parte trabajo, no valida contenido. La partición de trabajo es responsabilidad del flujo que la produjo: ODD (paso 5, documento de feature) por defecto, o `sdd-tasks` si SDD fue seleccionado.

---

## Flujo de Exportación

```
1. Leer el plan de trabajo
   └── ODD (por defecto): odd/tasks/<feature>.md → intención, alcance y tareas
   └── SDD (si fue seleccionado): spec → contexto, design → decisiones, tasks → checklists

2. Mapear a issue draft
   └── Título: basado en el plan
   └── Body: resumen del alcance + tareas como checklist
   └── Labels: según tipo de cambio (feat, fix, chore)

3. Crear issue vía issue-creation
   └── NO usa gh manualmente; delega a issue-creation
```

---

## Qué NO hace esta skill

- NO descompone trabajo en tareas (eso lo hace el flujo que produjo el plan)
- NO escribe artifacts canónicos nuevos
- NO reemplaza al flujo formal: ni ODD ni `sdd-tasks` / `sdd-spec` / `sdd-design`
- NO corre cuando no hay ningún plan que leer
- NO compite con `issue-creation` / `branch-pr` para crear/aprobar issues y PRs

---

## Formato de Issue Generado

```markdown
## Summary
{Basado en spec → qué se está haciendo y por qué}

## Technical Approach
{Basado en design → cómo se hará}

## Tasks
- [ ] {task 1.1}
- [ ] {task 1.2}
...

## Acceptance Criteria
{Basado en spec scenarios}
```

---

## Fallback

Si no hay ningún plan disponible (`odd/tasks/<feature>.md` no encontrado, y `sdd/{change}/*` tampoco):
- NO inventes contenido,
- responde: "No se encontró un plan de trabajo para este cambio. Terminá el paso de planificación del flujo (ODD: documento de feature) o usá `issue-creation` para crear el issue manualmente."

---

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| Flujo por defecto (ODD) | Produce el plan que esta skill exporta: `odd/tasks/<feature>.md` |
| `sdd-tasks` | Manda en partición de trabajo cuando SDD fue seleccionado; esta skill solo exporta |
| `issue-creation` | Canal de creación de issues; esta skill lo invoca |
| `branch-pr` | NO se solapan; esta skill no abre PRs |
| `sdd-propose` / `sdd-spec` | Upstream solo en la rama SDD; esta skill vive downstream |

---

## Comandos

### Exportar el plan de trabajo a issue

```
Cargar sdd-to-issues → leer odd/tasks/<feature>.md (ODD) o sdd/{change}/* (rama SDD)
→ generar issue draft → crear vía issue-creation
```

### Si no hay plan

```
Cargar sdd-to-issues → fallback: "No se encontró un plan de trabajo. Terminá la planificación primero."
```
