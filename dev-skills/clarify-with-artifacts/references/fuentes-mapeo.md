# Detalle local de `SKILL.md` (## Fuentes que Consulta, ## Relación con Otras Skills).

## Fuentes que Consulta

| Fuente | Qué aporta |
|--------|------------|
| `docs/` | Estándares, governance, docs de ODD y SDD |
| Engram (`mem_search`) | Decisiones, discoveries, session summaries previos |
| `odd/tasks/<feature>.md` | Documento de feature de ODD: intención, alcance y tareas |
| `sdd/{change}/explore` | Hallazgos de exploración previa (rama SDD) |
| `sdd/{change}/proposal` | Intención y scope ya delineados |
| `docs/skill-registry.md` | Triggers y reglas de routing actuales |

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| `sdd-propose` / `sdd-spec` | Aguas abajo solo si SDD fue seleccionado; `clarify` alimenta, no reemplaza |
| `brainstorm` | Upstream; si no hay nada claro, usa `brainstorm` primero |
| `explore` (SDD) | `explore` es fase SDD; `clarify` es helper opt-in previo |
