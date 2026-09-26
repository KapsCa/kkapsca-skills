#!/usr/bin/env bash

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$REPO_ROOT" ]]; then
  printf 'Error: ejecuta este script dentro de un repositorio git.\n' >&2
  exit 1
fi

REPO_NAME="$(basename "$REPO_ROOT")"
TEMPLATES="${SKILL_DIR}/templates"
GITIGNORE_MARKER="# >>> repo-bootstrap: secretos y credenciales >>>"

# El hook pre-push se pisa solo si se pide explicitamente, como dice el SKILL.md.
REINSTALL_HOOK=false
if [[ "${1:-}" == "--reinstall-hook" ]]; then
  REINSTALL_HOOK=true
fi

mkdir -p "$REPO_ROOT/.git/hooks"
mkdir -p "$REPO_ROOT/.github/workflows"
mkdir -p "$REPO_ROOT/docs"

# ---------------------------------------------------------------------------
# install_if_missing: copia solo si el destino no existe todavia.
#
# install(1) no tiene --no-clobber, asi que el chequeo es explicito. Se usa para
# los archivos de seguridad, porque un .gitleaks.toml o un SECURITY.md que ya
# existen pueden estar ajustados a mano y pisarlos seria peor que no hacer nada.
# ---------------------------------------------------------------------------
install_if_missing() {
  local source="$1"
  local target="$2"
  local mode="${3:-0644}"

  if [[ -e "$target" ]]; then
    printf '↷ conservado, ya existia: %s\n' "${target#"$REPO_ROOT"/}"
    return 0
  fi

  install -m "$mode" "$source" "$target"
  printf '✓ instalado: %s\n' "${target#"$REPO_ROOT"/}"
}

# ---------------------------------------------------------------------------
# repo_is_public: imprime true, false o unknown.
#
# CodeQL solo funciona gratis en repos publicos: en privados necesita una
# licencia de GitHub Code Security. Si no se puede determinar, se asume que no
# corresponde instalarlo, porque un workflow que falla siempre es peor que no
# tener el workflow.
#
# Se llama siempre dentro de $( ), asi que el cd no afecta al llamador.
# ---------------------------------------------------------------------------
repo_is_public() {
  if ! command -v gh >/dev/null 2>&1; then
    printf 'unknown'
    return 0
  fi

  local is_private=''
  if cd "$REPO_ROOT" 2>/dev/null; then
    is_private="$(gh repo view --json isPrivate --jq '.isPrivate' 2>/dev/null)" || is_private=''
  fi

  case "$is_private" in
    true)  printf 'false' ;;
    false) printf 'true' ;;
    *)     printf 'unknown' ;;
  esac
}

# ---------------------------------------------------------------------------
# install_dependabot: arma .github/dependabot.yml con un bloque por ecosistema.
#
# Un ecosistema declarado sin archivos de dependencias hace FALLAR su trabajo de
# Dependabot. Por eso se declara github-actions siempre, y el resto solo si el
# repo tiene los archivos correspondientes.
# ---------------------------------------------------------------------------
install_dependabot() {
  local target="$REPO_ROOT/.github/dependabot.yml"
  local ecosystems=()
  local ecosystem

  if [[ -f "$REPO_ROOT/package-lock.json" ]]; then
    ecosystems+=(npm)
  fi
  if [[ -f "$REPO_ROOT/go.mod" ]]; then
    ecosystems+=(gomod)
  fi
  if [[ -f "$REPO_ROOT/requirements.txt" || -f "$REPO_ROOT/poetry.lock" || -f "$REPO_ROOT/Pipfile.lock" ]]; then
    ecosystems+=(pip)
  fi
  if [[ -f "$REPO_ROOT/pubspec.yaml" ]]; then
    ecosystems+=(pub)
  fi

  install -m 0644 "$TEMPLATES/dependabot.yml" "$target"

  if [[ ${#ecosystems[@]} -gt 0 ]]; then
    for ecosystem in "${ecosystems[@]}"; do
      cat "$TEMPLATES/dependabot-ecosystems/${ecosystem}.yml" >> "$target"
    done
    printf '✓ instalado: .github/dependabot.yml (github-actions, %s)\n' "$(IFS=', '; printf '%s' "${ecosystems[*]}")"
  else
    printf '✓ instalado: .github/dependabot.yml (solo github-actions: no detecte otros ecosistemas)\n'
  fi
}

# ---------------------------------------------------------------------------
# merge_gitignore: agrega el fragmento de secretos una sola vez.
#
# No reemplaza el .gitignore existente: le suma un bloque marcado. Si el marcador
# ya esta, no hace nada. Es idempotente y no toca lo que el proyecto ya tenia.
# ---------------------------------------------------------------------------
merge_gitignore() {
  local target="$REPO_ROOT/.gitignore"

  if [[ -f "$target" ]] && grep -qF "$GITIGNORE_MARKER" "$target"; then
    printf '↷ conservado, ya existia: .gitignore (bloque de secretos presente)\n'
    return 0
  fi

  # El separador se decide ANTES de abrir el archivo para escritura, para no
  # leer y escribir el mismo archivo en la misma operacion.
  local separator=''
  if [[ -s "$target" ]]; then
    separator=$'\n'
  fi

  {
    printf '%s' "$separator"
    printf '%s\n' "$GITIGNORE_MARKER"
    cat "$TEMPLATES/gitignore-security.txt"
  } >> "$target"

  printf '✓ fusionado: .gitignore (bloque de secretos agregado)\n'
}

# ---------------------------------------------------------------------------
# 1. Gobernanza.
#
# Los archivos de CONTENIDO del proyecto (plantilla de PR, changelog, estandares)
# se crean solo si faltan. Pisarlos borra trabajo del proyecto: un CHANGELOG.md
# tiene el historial real, y la plantilla de PR puede estar adaptada.
#
# Esto es lo que manda el SKILL.md normativo ("created if missing; if present,
# left untouched") y lo que el script no cumplia: sobrescribia los tres.
#
# Los archivos de CONFIGURACION de release-please si se sobrescriben: son
# canonicos, los genera la herramienta y no deberian editarse a mano.
# ---------------------------------------------------------------------------
if [[ "$REINSTALL_HOOK" == true ]]; then
  install -m 0755 "$TEMPLATES/pre-push" "$REPO_ROOT/.git/hooks/pre-push"
  printf '✓ reinstalado: .git/hooks/pre-push (--reinstall-hook)\n'
else
  install_if_missing "$TEMPLATES/pre-push" "$REPO_ROOT/.git/hooks/pre-push" 0755
fi

install -m 0644 "$TEMPLATES/release-please.yml" "$REPO_ROOT/.github/workflows/release-please.yml"
install -m 0644 "$TEMPLATES/release-please-config.json" "$REPO_ROOT/release-please-config.json"
install -m 0644 "$TEMPLATES/.release-please-manifest.json" "$REPO_ROOT/.release-please-manifest.json"

install_if_missing "$TEMPLATES/PULL_REQUEST_TEMPLATE.md" "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md"
install_if_missing "$TEMPLATES/CHANGELOG.md" "$REPO_ROOT/CHANGELOG.md"
install_if_missing "$TEMPLATES/repository-standards.md" "$REPO_ROOT/docs/repository-standards.md"

python3 - <<PY
from pathlib import Path
path = Path(r"$REPO_ROOT/release-please-config.json")
path.write_text(path.read_text().replace('repo-name', '$REPO_NAME'))
PY

# ---------------------------------------------------------------------------
# 2. Seguridad. Crear-si-falta: nunca pisa algo ya configurado.
# ---------------------------------------------------------------------------
install_if_missing "$TEMPLATES/gitleaks.yml" "$REPO_ROOT/.github/workflows/gitleaks.yml"
install_if_missing "$TEMPLATES/gitleaks.toml" "$REPO_ROOT/.gitleaks.toml"
install_if_missing "$TEMPLATES/audit.yml" "$REPO_ROOT/.github/workflows/audit.yml"
install_if_missing "$TEMPLATES/SECURITY.md" "$REPO_ROOT/SECURITY.md"

case "$(repo_is_public)" in
  true)
    install_if_missing "$TEMPLATES/codeql.yml" "$REPO_ROOT/.github/workflows/codeql.yml"
    ;;
  false)
    printf '↷ omitido: .github/workflows/codeql.yml (el repo es privado y CodeQL necesita licencia de GitHub Code Security)\n'
    printf '  Si el repo pasa a ser publico, volve a correr este script.\n'
    ;;
  *)
    printf '↷ omitido: .github/workflows/codeql.yml (no pude determinar si el repo es publico)\n'
    printf '  Causas posibles: no hay remote, o gh no esta instalado o autenticado.\n'
    printf '  Cuando el repo sea publico, volve a correr este script.\n'
    ;;
esac

install_dependabot
merge_gitignore

printf '\n✅ Repo bootstrap aplicado en %s\n' "$REPO_ROOT"
printf 'Revisa docs/repository-standards.md para confirmar el flujo operativo.\n'
printf 'Para reinstalar el hook pre-push a proposito: %s --reinstall-hook\n' "$0"
printf 'Si el repo es publico, puedes correr tambien:\n'
printf 'bash "%s/configure-public-branch-protection.sh"\n' "$SKILL_DIR"
