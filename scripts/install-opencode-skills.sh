#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${OPENCODE_SKILLS_DIR:-${HOME}/.config/opencode/skills}"
MODE="symlink"
EXTERNAL_SKILLS_DIR="${EXTERNAL_SKILLS_DIR:-${HOME}/.agents/skills}"

if [[ "${1:-}" == "--copy" ]]; then
  MODE="copy"
elif [[ -n "${1:-}" ]]; then
  printf 'Uso: %s [--copy]\n' "$0" >&2
  exit 1
fi

mkdir -p "${TARGET_ROOT}"

collect_skill_dirs() {
  local candidate

  # Skills del repo (raíz y dev-skills/)
  for candidate in "${REPO_ROOT}"/* "${REPO_ROOT}"/dev-skills/*; do
    [[ -d "${candidate}" ]] || continue
    [[ -f "${candidate}/SKILL.md" ]] || continue
    printf '%s\n' "${candidate}"
  done

  # Skills externas (ej. Firebase en ~/.agents/skills/)
  if [[ -d "${EXTERNAL_SKILLS_DIR}" ]]; then
    for candidate in "${EXTERNAL_SKILLS_DIR}"/*; do
      [[ -d "${candidate}" ]] || continue
      [[ -f "${candidate}/SKILL.md" ]] || continue
      printf '%s\n' "${candidate}"
    done
  fi
}

install_skill() {
  local source_dir="$1"
  local skill_name
  local target_dir
  local current_link

  skill_name="$(basename "${source_dir}")"
  target_dir="${TARGET_ROOT}/${skill_name}"

  if [[ -L "${target_dir}" ]]; then
    current_link="$(readlink "${target_dir}")"
    if [[ "${current_link}" != "${source_dir}" ]]; then
      printf 'Conflicto: %s ya existe y apunta a %s\n' "${target_dir}" "${current_link}" >&2
      exit 1
    fi
    rm -f "${target_dir}"
  elif [[ -d "${target_dir}" ]]; then
    if [[ -f "${target_dir}/.kkapsca-skill-source" ]]; then
      rm -rf "${target_dir}"
    else
      printf 'Conflicto: %s ya existe y no fue instalado por este repo\n' "${target_dir}" >&2
      exit 1
    fi
  elif [[ -e "${target_dir}" ]]; then
    printf 'Conflicto: %s ya existe y no es un directorio manejable\n' "${target_dir}" >&2
    exit 1
  fi

  if [[ "${MODE}" == "copy" ]]; then
    mkdir -p "${target_dir}"
    cp -R "${source_dir}/." "${target_dir}/"
    printf '%s\n' "${source_dir}" > "${target_dir}/.kkapsca-skill-source"
    printf '✔ Skill copiada: %s -> %s\n' "${skill_name}" "${target_dir}"
  else
    ln -s "${source_dir}" "${target_dir}"
    printf '✔ Skill enlazada: %s -> %s\n' "${skill_name}" "${target_dir}"
  fi
}

while IFS= read -r skill_dir; do
  install_skill "${skill_dir}"
done < <(collect_skill_dirs | sort)

printf '\nListo. Reinicia opencode para refrescar las skills disponibles.\n'
printf 'Directorio objetivo: %s\n' "${TARGET_ROOT}"
