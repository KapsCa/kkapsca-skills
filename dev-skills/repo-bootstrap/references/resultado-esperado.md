# Resultado esperado — Repo Bootstrap

Detalle local de `SKILL.md` (## Output Contract).

## Resultado Esperado

Cuando esta skill se aplica bien, el repo debe quedar con:

**Gobernanza:**

- `PULL_REQUEST_TEMPLATE.md`
- workflow de `release-please`
- `release-please-config.json`
- `.release-please-manifest.json`
- `CHANGELOG.md`
- `docs/repository-standards.md`
- hook local `pre-push`
- al menos un workflow funcional de validación del stack
- branch protection clásica en públicos, si aplica
- `allow_auto_merge=true` en el repo, habilitado por
  `configure-public-branch-protection.sh` (idempotente y fail-soft)
- el workflow de `release-please` con el paso que pide el auto-merge del
  release PR (`gh pr merge --auto --squash --repo ...`)
- el secret `RELEASE_PLEASE_TOKEN` (PAT dedicado) cargado en el repo: sin
  él, el release PR no corre los checks y el auto-merge espera para siempre

**Seguridad:**

- `.github/workflows/gitleaks.yml` y `.gitleaks.toml`
- `.github/workflows/audit.yml`
- `.github/workflows/codeql.yml` (solo si el repo es público)
- `.github/dependabot.yml`
- `SECURITY.md`
- bloque de secretos fusionado dentro del `.gitignore`

**Etiquetas canónicas:**

- las seis del conjunto canónico: cuatro `type:*` y dos `status:*`
- `type:feature` `#A2EEEF`, `type:chore` `#D4C5F9`, `type:docs` `#0E8A16`, `type:bug` `#D73A4A`, `status:approved` `#0E8A16`, `status:needs-review` `#FBCA04`
- se crean con `gh label create --force`, así que re-logear no duplica: refresca color y descripción
- no toca los defaults de GitHub ni los labels que el proyecto ya tenga
- si `gh` no está instalado o autenticado (o el CLI devuelve un error), el bootstrap lo reporta como omitido y sigue; nunca aborta por etiquetas
- una tarea de bootstrap previa que recoloreó una etiqueta canónica la vuelve al color canónico

---

