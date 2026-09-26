# Detalle local de `SKILL.md` (## Flujo de Exportación).

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
