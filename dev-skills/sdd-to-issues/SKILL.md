---
name: sdd-to-issues
description: >
  Export-only skill que convierte artifacts SDD (spec, design, tasks) en issue drafts
  o issues GitHub reales usando issue-creation. NO descompone trabajo; eso lo hace sdd-tasks.
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/sdd"
---

# SDD-to-Issues — Export-Only Wrapper

> **Input:** `sdd/{change}/spec`, `design`, `tasks` desde Engram (o `openspec/` si aplica)
> **Output:** issue drafts o issues GitHub vía `issue-creation`
> **Modo:** Export-only; NO particiona trabajo

---

## When to Use

Usa esta skill cuando:
- ya exista un cambio SDD con spec/design/tasks aprobados,
- el usuario pida "exportar a issues" o "crear issues desde SDD",
- necesites pasar el plan SDD al sistema de issues sin reescribir nada.

## When NOT to Use

- estés en fase de propuesta o diseño (usa `sdd-propose` / `sdd-design`),
- busques partir el trabajo en tareas (usa `sdd-tasks` — eso es su territorio),
- no existan artifacts SDD previos (sin artifacts → no genera nada),
- el usuario pida crear issues desde cero (usa `issue-creation` directamente).

---

## Principio Rector

**Export-only.** Esta skill lee artifacts SDD ya aprobados y los traduce a issues; no decide qué hacer, no parte trabajo, no valida contenido. La partición de trabajo es responsabilidad exclusiva de `sdd-tasks`.

---

## Flujo de Exportación

```
1. Leer artifacts SDD
   └── spec → contexto del cambio
   └── design → decisiones técnicas
   └── tasks → checklists de implementación

2. Mapear a issue draft
   └── Título: basado en proposal/spec
   └── Body: resumen de design + tasks como checklist
   └── Labels: según tipo de cambio (feat, fix, chore)

3. Crear issue vía issue-creation
   └── NO usa gh manualmente; delega a issue-creation
```

---

## Qué NO hace esta skill

- NO descompone trabajo en tareas (eso es `sdd-tasks`)
- NO escribe artifacts canónicos nuevos
- NO reemplaza `sdd-tasks`, `sdd-spec` ni `sdd-design`
- NO corre cuando no hay artifacts SDD que leer
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

Si no hay artifacts SDD disponibles (`sdd/{change}/*` no encontrado en Engram o `openspec/`):
- NO inventes contenido,
- responde: "No se encontraron artifacts SDD para este cambio. Usa SDD primero o `issue-creation` para crear el issue manualmente."

---

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| `sdd-tasks` | Manda en partición de trabajo; `sdd-to-issues` solo exporta |
| `issue-creation` | Canal de creación de issues; `sdd-to-issues` lo invoca |
| `branch-pr` | NO se solapan; `sdd-to-issues` no abre PRs |
| `sdd-propose` / `sdd-spec` | Upstream; `sdd-to-issues` vive downstream |

---

## Comandos

### Exportar un cambio SDD a issue

```
Cargar sdd-to-issues → leer sdd/{change}/spec + design + tasks → generar issue draft → crear vía issue-creation
```

### Si no hay artifacts

```
Cargar sdd-to-issues → fallback: "No se encontraron artifacts SDD. Usa SDD primero."
```
