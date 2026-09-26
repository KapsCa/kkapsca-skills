# Assets y política de instalación — Repo Bootstrap

Detalle local de `SKILL.md` (## Execution Steps).

## Assets

- **Instalador**: [assets/install-repo-standards.sh](assets/install-repo-standards.sh)
- **Protección pública**: [assets/configure-public-branch-protection.sh](assets/configure-public-branch-protection.sh)
- **Templates**: [assets/templates/](assets/templates/)

### Plantillas de seguridad

| Plantilla | Destino en el repo |
|---|---|
| `gitleaks.yml` | `.github/workflows/gitleaks.yml` |
| `gitleaks.toml` | `.gitleaks.toml` |
| `audit.yml` | `.github/workflows/audit.yml` |
| `codeql.yml` | `.github/workflows/codeql.yml` (solo público) |
| `dependabot.yml` | `.github/dependabot.yml` (base: solo `github-actions`) |
| `dependabot-ecosystems/*.yml` | se concatenan a `.github/dependabot.yml` según el stack detectado |
| `SECURITY.md` | `SECURITY.md` |
| `gitignore-security.txt` | se fusiona dentro del `.gitignore`, detrás de un marcador |

### Política de instalación

Los archivos de **contenido del proyecto** (`CHANGELOG.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/repository-standards.md`) y todos los de **seguridad** se crean **solo si faltan**. Nunca se pisan: un `CHANGELOG.md` tiene el historial real y un `.gitleaks.toml` puede estar ajustado a mano.

Los archivos de **configuración de release-please** sí se sobrescriben: los genera la herramienta y no deberían editarse a mano.

El hook `pre-push` solo se reinstala si se pide explícitamente con `--reinstall-hook`.

---

