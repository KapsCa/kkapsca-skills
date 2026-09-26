# Delegación y GitHub Actions — Repo Bootstrap

Detalle local de `SKILL.md` (## Hard Rules).

## Delegación de Acciones (GitHub Actions)

### Orchestrator Behavior
- The orchestrator loads this SKILL.md as dead data to extract configuration.
- For **new repos**: orchestrator creates all assets from embedded templates.
- For **existing repos**: orchestrator preserves existing workflows/templates and appends only missing configurations.
- Delegation is handled by the orchestrator; this file defines what to create/overwrite.

### Preservation/Overwrite Guidance
- **Preserve**: Any existing workflow files that are NOT `release-please.yml` are preserved as-is.
- **Overwrite**: If `release-please.yml`, `release-please-config.json`, or `.release-please-manifest.json` exist but are malformed, they are overwritten with canonical versions.
- **Preserve with append**: `PULL_REQUEST_TEMPLATE.md` and `docs/repository-standards.md` are created if missing; if present, they are left untouched.
- **Hook preservation**: Local `pre-push` hook is overwritten only if the user explicitly requests reinstallation.

---

