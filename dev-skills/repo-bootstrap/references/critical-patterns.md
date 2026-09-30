# Patrones críticos — Repo Bootstrap

Detalle local de `SKILL.md` (## Hard Rules).

## Critical Patterns

### `release-please` siempre explícito

No basta con meter el workflow.
El agente debe dejar su uso explícito también en:

- la documentación del repo,
- la plantilla de PR,
- la explicación del flujo.

### Tests/checks antes de auto-merge

No basta con lint superficial.
Antes de activar auto-merge, el repo debe tener al menos un check que valide comportamiento o integridad real del stack.

### Auto-review opcional, checks obligatorios

El review automático de Copilot es deseable, pero puede depender de plan.
Los checks funcionales y PR validation sí son obligatorios como estándar.

### GO / NO-GO para auto-merge

Auto-merge solo puede recomendarse si TODO esto es verdadero:

- [ ] Existe PR validation
- [ ] Existe al menos un check funcional del stack
- [ ] La rama protegida requiere status checks
- [ ] El flujo del repo ya usa PR obligatorios

Si alguna casilla falla, NO recomiendes auto-merge todavía.

### Release PR con auto-merge explícito

- `configure-public-branch-protection.sh` habilita `allow_auto_merge=true`
  (idempotente y fail-soft): sin esa opción del repo, el `gh pr merge
  --auto` del workflow falla.
- El paso de auto-merge usa `--squash`, nunca `--merge`: la protección fija
  `required_linear_history=true`, que prohíbe merge commits.
- El comando pasa `--repo` explícito: el job de release-please no hace
  checkout y `gh` no puede inferir el repositorio.
- El release PR se crea con `RELEASE_PLEASE_TOKEN` (PAT dedicado). Con
  `GITHUB_TOKEN` el PR nunca dispara los checks del repo y el auto-merge
  espera para siempre.

### Saltos de jobs vs saltos de workflows

Con checks requeridos, cómo se saltea un trabajo decide si bloquea el
merge. GitHub cuenta `success`, `skipped` y `neutral` como aprobatorios:

- `if:` a nivel de job: reporta `skipped` y no bloquea el merge. Es la
  forma segura de saltear validaciones en los release PRs.
- Filtro a nivel de workflow (`paths:` / `branches:`): el check queda
  pending y bloquea el merge.

### No tocar git global

No modificar configuración global de Git para imponer esta convención.
La convención debe vivir en:

- el repo,
- scripts del repo,
- hooks locales por clon.

### No asumir enforcement en privados Free

Si el repo es privado personal Free:

- NO prometer que GitHub bloqueará pushes realmente,
- SÍ dejar hook local,
- SÍ explicar la limitación,
- SÍ configurar la regla en UI si el usuario lo desea, pero aclarando que puede salir como "Not enforced".

---

