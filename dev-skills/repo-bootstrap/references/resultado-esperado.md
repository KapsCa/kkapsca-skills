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

**Seguridad:**

- `.github/workflows/gitleaks.yml` y `.gitleaks.toml`
- `.github/workflows/audit.yml`
- `.github/workflows/codeql.yml` (solo si el repo es público)
- `.github/dependabot.yml`
- `SECURITY.md`
- bloque de secretos fusionado dentro del `.gitignore`

---

