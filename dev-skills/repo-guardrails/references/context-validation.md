# Contexto y validación de activación — Repo Guardrails

Detalle local de `SKILL.md` (## Activation Contract).

## When to Use

Usa esta skill cuando:
- el usuario esté por hacer push, crear PR o mergear,
- quieras una revisión rápida de cumplimiento antes de ejecutar,
- necesites recordatorios sobre convenciones del repo sin imponer nuevas reglas.

## When NOT to Use

- ya estés ejecutando `repo-bootstrap` (esa skill manda en normas),
- el usuario esté en la rama SDD (`/sdd-*`) — usa la fase correspondiente. ODD es el flujo por defecto, y en ODD esta capa sí aplica,
- busques bloquear acciones: esta skill SOLO advierte, no bloquea.
