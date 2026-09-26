# Detalle local de `SKILL.md` (## Formato de Issue Generado).

## Formato de Issue Generado

El mapeo depende del plan de entrada. Por defecto (ODD) el documento de feature aporta intención, alcance y tareas; los artifacts SDD (spec, design, tasks) son la alternativa cuando SDD fue seleccionado:

```markdown
## Summary
{ODD: intención + alcance de `odd/tasks/<feature>.md`; SDD: basado en spec → qué se está haciendo y por qué}

## Technical Approach
{ODD: notas técnicas del documento de feature; SDD: basado en design → cómo se hará}

## Tasks
- [ ] {ODD: tarea del documento de feature; SDD: task 1.1}
- [ ] {ODD: otra tarea; SDD: task 1.2}
...

## Acceptance Criteria
{ODD: criterios implícitos en intención y alcance; SDD: basado en spec scenarios}
```
