# Assets y política de instalación — Repo Bootstrap

Detalle local de `SKILL.md` (## Execution Steps).

## Assets

- **Instalador**: [assets/install-repo-standards.sh](assets/install-repo-standards.sh)
- **Etiquetas canónicas**: el instalador crea o actualiza las seis etiquetas del módulo con `gh label create --force` (`type:feature` `#A2EEEF`, `type:chore` `#D4C5F9`, `type:docs` `#0E8A16`, `type:bug` `#D73A4A`, `status:approved` `#0E8A16`, `status:needs-review` `#FBCA04`); solo-agrega, no toca los demás labels, y omite la sección si `gh` no está o no está autenticado
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

### Plantillas de validación

| Plantilla | Destino en el repo |
|---|---|
| `pr-validation.yml` | `.github/workflows/pr-validation.yml` — referencia a issue aprobada, un label `type:*`, Conventional Commits y rutas de host fuera del diff. El job de rutas no tiene allowlist por archivo: un doc que necesite nombrar esos paths los escribe con marcadores (`/home/<usuario>/`, `/mnt/<disco>/...`), que el check acepta |

### Política de instalación

Los archivos de **contenido del proyecto** (`CHANGELOG.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/repository-standards.md`) y todos los de **seguridad** se crean **solo si faltan**. Nunca se pisan: un `CHANGELOG.md` tiene el historial real y un `.gitleaks.toml` puede estar ajustado a mano.

Los archivos de **configuración de release-please** sí se sobrescriben: los genera la herramienta y no deberían editarse a mano.

El hook `pre-push` solo se reinstala si se pide explícitamente con `--reinstall-hook`.

Las etiquetas canónicas no son un archivo: se crean o actualizan con `gh label create --force`.

---


### Brand assets (KapsCa)

- Bundle: `assets/kapsca-brand/` (`banner.png`, `kapsca-512.png`, `kapsca-mono-white.svg`, `kapsca-favicon.ico`, `readme-header.html.part`, `BRAND_BUNDLE.txt`). Resuelve desde `SKILL_DIR` (no desde templates).
- `install_brand_assets()` copia el set a `<repo>/assets/brand/` (install_if_missing) y hace prepend de `readme-header.html.part` al README si el marcador `kapsca-brand` esta ausente; si falta el README, lo crea. Fail-soft si el bundle no existe.
- Source of truth: `KapsCa/kapsca-brand` (SOT, release-based). Refresh: copiar los 4 media + fragment desde el nuevo release (ver `BRAND_BUNDLE.txt`).
