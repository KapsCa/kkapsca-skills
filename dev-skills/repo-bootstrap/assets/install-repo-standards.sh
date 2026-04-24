#!/usr/bin/env bash

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$REPO_ROOT" ]]; then
  printf 'Error: ejecuta este script dentro de un repositorio git.\n' >&2
  exit 1
fi

REPO_NAME="$(basename "$REPO_ROOT")"

mkdir -p "$REPO_ROOT/.git/hooks"
mkdir -p "$REPO_ROOT/.github/workflows"
mkdir -p "$REPO_ROOT/docs"

install -m 0755 "$SKILL_DIR/templates/pre-push" "$REPO_ROOT/.git/hooks/pre-push"
install -m 0644 "$SKILL_DIR/templates/PULL_REQUEST_TEMPLATE.md" "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md"
install -m 0644 "$SKILL_DIR/templates/release-please.yml" "$REPO_ROOT/.github/workflows/release-please.yml"
install -m 0644 "$SKILL_DIR/templates/release-please-config.json" "$REPO_ROOT/release-please-config.json"
install -m 0644 "$SKILL_DIR/templates/.release-please-manifest.json" "$REPO_ROOT/.release-please-manifest.json"
install -m 0644 "$SKILL_DIR/templates/CHANGELOG.md" "$REPO_ROOT/CHANGELOG.md"
install -m 0644 "$SKILL_DIR/templates/repository-standards.md" "$REPO_ROOT/docs/repository-standards.md"

python3 - <<PY
from pathlib import Path
path = Path(r"$REPO_ROOT/release-please-config.json")
path.write_text(path.read_text().replace('repo-name', '$REPO_NAME'))
PY

printf '✅ Repo bootstrap aplicado en %s\n' "$REPO_ROOT"
printf 'Revisa docs/repository-standards.md para confirmar el flujo operativo.\n'
printf 'Si el repo es público, puedes correr también:\n'
printf 'bash "%s/configure-public-branch-protection.sh"\n' "$SKILL_DIR"
