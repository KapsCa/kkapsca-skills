# Detalle local de `SKILL.md` (## Relación con Otras Skills).

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| Flujo por defecto (ODD) | Produce el plan que esta skill exporta: `odd/tasks/<feature>.md` |
| `sdd-tasks` | Manda en partición de trabajo cuando SDD fue seleccionado; esta skill solo exporta |
| `issue-creation` | Canal de creación de issues; esta skill lo invoca |
| `branch-pr` | NO se solapan; esta skill no abre PRs |
| `sdd-propose` / `sdd-spec` | Upstream solo en la rama SDD; esta skill vive downstream |
