#!/usr/bin/env bash
set -euo pipefail

# Compute repo root based on this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

INSTALLER="${REPO_ROOT}/scripts/install-opencode-skills.sh"

# Fail fast if installer is missing
if [[ ! -f "${INSTALLER}" ]]; then
  printf 'ERROR: No se encontró el instalador en %s\n' "${INSTALLER}" >&2
  exit 1
fi

# Pass --copy if requested
if [[ "${1:-}" == "--copy" ]]; then
  bash "${INSTALLER}" --copy
else
  bash "${INSTALLER}"
fi

printf '\n✅ Bootstrap completado.\n'
printf '👉 Reinicia opencode para que refresque la lista de skills disponibles.\n'
