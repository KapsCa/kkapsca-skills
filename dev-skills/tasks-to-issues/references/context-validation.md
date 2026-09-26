# Detalle local de `SKILL.md` (## Activation Contract y ## Decision Gates).

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
