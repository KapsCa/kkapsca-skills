# Qué NO hace y principio rector — Repo Guardrails

Detalle local de `SKILL.md` (## Hard Rules).

## Principio Rector

**Warning-first, never blocking.** Esta skill es una capa lateral que operacionaliza las reglas de `repo-bootstrap` y `docs/governance.md`, pero no añade nuevas reglas ni reemplaza el flujo normativo.

## Qué NO hace esta skill

- NO bloquea pushes ni PRs (eso lo hace `repo-bootstrap` vía hook `pre-push` y branch protection)
- NO escribe nuevas reglas (usa las de `docs/governance.md`)
- NO reemplaza `issue-creation` ni `branch-pr`
- NO crea artifacts canónicos nuevos
