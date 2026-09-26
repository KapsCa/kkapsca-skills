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

# Pasa todos los argumentos al instalador, para que --copy y --pi-only lleguen.
bash "${INSTALLER}" "$@"

printf '\n✅ Bootstrap completado.\n'
printf '👉 Reinicia el o los agentes para que refresquen la lista de skills disponibles.\n'
