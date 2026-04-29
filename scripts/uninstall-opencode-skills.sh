#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${OPENCODE_SKILLS_DIR:-${HOME}/.config/opencode/skills}"

collect_skill_names() {
  local candidate

  for candidate in "${REPO_ROOT}"/* "${REPO_ROOT}"/dev-skills/*; do
    [[ -d "${candidate}" ]] || continue
    [[ -f "${candidate}/SKILL.md" ]] || continue
    basename "${candidate}"
  done
}

while IFS= read -r skill_name; do
  target_dir="${TARGET_ROOT}/${skill_name}"

  if [[ -L "${target_dir}" ]]; then
    rm -f "${target_dir}"
    printf '✔ Skill removida: %s\n' "${skill_name}"
  elif [[ -d "${target_dir}" && -f "${target_dir}/.kkapsca-skill-source" ]]; then
    rm -rf "${target_dir}"
    printf '✔ Skill removida: %s\n' "${skill_name}"
  fi
done < <(collect_skill_names | sort)

printf '\nListo. Si opencode estaba abierto, reinícialo para refrescar la lista.\n'
