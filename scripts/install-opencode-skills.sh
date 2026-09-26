#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${OPENCODE_SKILLS_DIR:-${HOME}/.config/opencode/skills}"
PI_TARGET_ROOT="${PI_SKILLS_DIR:-${HOME}/.agents/skills}"
MODE="symlink"
EXTERNAL_SKILLS_DIR="${EXTERNAL_SKILLS_DIR:-${HOME}/.agents/skills}"

# Skills del repo que ADEMAS se instalan para Pi.
#
# No se instalan las 13. Se audito el solape de cada una contra gentle-ai y el
# resultado fue que casi ninguna se solapa: el pipeline de definicion de
# producto (brainstorm, product-discovery, project-init, tech-feasibility) cubre
# una fase ANTERIOR al SDD de gentle-ai, que arranca desde un cambio ya definido.
#
# La unica con solape real era request-triage, porque el orquestador de gentle-ai
# ya trae su propia escalera de ruteo en el prompt. Se elimino del repo.
#
# Las seis que quedan son, entonces, dos grupos:
#   - repo-bootstrap y repo-guardrails: los estandares del repo, que Pi consulta
#     antes de un push.
#   - las cuatro del pipeline de producto: Pi no tiene brainstorm, ni discovery,
#     ni project-init, ni factibilidad tecnica; gentle-ai arranca desde un cambio
#     ya definido. Sin estas cuatro, Pi no puede arrancar desde una idea vaga,
#     que es la fase ANTERIOR a todo lo que Pi ya sabe hacer.
#
# Quedan afuera las companions (clarify-with-artifacts, diagnose, zoom-out,
# improve-codebase-architecture, flutter-personal-standards, tasks-to-issues): no
# son parte del hueco detectado, y cada linea de mas en el prompt se justifica.
#
# Se puede cambiar sin editar el script: PI_SKILLS="otra-skill otra-mas"
PI_SKILL_NAMES=(repo-bootstrap repo-guardrails brainstorm product-discovery project-init tech-feasibility)
if [[ -n "${PI_SKILLS:-}" ]]; then
  read -r -a PI_SKILL_NAMES <<< "${PI_SKILLS}"
fi

# Destinos que no se pudieron instalar porque ya existian y no los creo este
# repo. Se acumulan para reportarlos al final en vez de abortar la corrida
# entera en el primer choque.
CONFLICTS=()

PI_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --pi-only) PI_ONLY=true ;;
    *)
      printf 'Uso: %s [--copy] [--pi-only]\n' "$0" >&2
      printf '  --copy     copia fisica en vez de enlaces simbolicos\n' >&2
      printf '  --pi-only  instala solo las skills de Pi, sin tocar opencode\n' >&2
      exit 1
      ;;
  esac
done

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
  local target_root="$2"
  local skill_name
  local target_dir
  local current_link

  skill_name="$(basename "${source_dir}")"
  target_dir="${target_root}/${skill_name}"

  # Si el origen y el destino son el mismo directorio, no hay nada que instalar.
  # Pasa cuando OPENCODE_SKILLS_DIR apunta al mismo lugar que EXTERNAL_SKILLS_DIR
  # (por ejemplo, ambos a "${HOME}/.agents/skills"). Sin este guard, el bloque de
  # abajo borra el origen con rm -rf y después falla al copiarlo sobre sí mismo,
  # así que una segunda corrida destruye las skills que el repo administra.
  if [[ -d "${target_dir}" ]]; then
    local resolved_source resolved_target
    resolved_source="$(cd "${source_dir}" && pwd -P)"
    resolved_target="$(cd "${target_dir}" && pwd -P)"
    if [[ "${resolved_source}" == "${resolved_target}" ]]; then
      printf '↷ Omitida (origen y destino son el mismo): %s\n' "${skill_name}"
      return 0
    fi
  fi

  if [[ -L "${target_dir}" ]]; then
    current_link="$(readlink "${target_dir}")"
    if [[ "${current_link}" != "${source_dir}" ]]; then
      CONFLICTS+=("${skill_name} (apunta a ${current_link})")
      printf '⚠ Omitida, conflicto: %s ya existe y apunta a otro lado\n' "${target_dir}" >&2
      return 0
    fi
    rm -f "${target_dir}"
  elif [[ -d "${target_dir}" ]]; then
    if [[ -f "${target_dir}/.kkapsca-skill-source" ]]; then
      rm -rf "${target_dir}"
    else
      CONFLICTS+=("${skill_name} (directorio real, no instalado por este repo)")
      printf '⚠ Omitida, conflicto: %s ya existe y no fue instalado por este repo\n' "${target_dir}" >&2
      return 0
    fi
  elif [[ -e "${target_dir}" ]]; then
    CONFLICTS+=("${skill_name} (existe y no es un directorio manejable)")
    printf '⚠ Omitida, conflicto: %s ya existe y no es un directorio manejable\n' "${target_dir}" >&2
    return 0
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

find_skill_dir() {
  local name="$1"
  local candidate

  for candidate in "${REPO_ROOT}/${name}" "${REPO_ROOT}/dev-skills/${name}"; do
    if [[ -f "${candidate}/SKILL.md" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done

  return 1
}

if [[ "$PI_ONLY" != true ]]; then
  while IFS= read -r skill_dir; do
    install_skill "${skill_dir}" "${TARGET_ROOT}"
  done < <(collect_skill_dirs | sort)
fi

# ---------------------------------------------------------------------------
# Segunda pasada: las skills que tambien tienen que estar disponibles en Pi.
#
# Pi lee ~/.agents/skills/. Sin esta pasada, Pi no ve repo-bootstrap y todo el
# sistema de estandares queda invisible cuando se trabaja desde Pi: solo lo ve
# opencode. El chequeo de "origen y destino son el mismo directorio" de
# install_skill hace que esta pasada sea segura aunque PI_TARGET_ROOT apunte al
# mismo lugar del que se leen las skills externas.
# ---------------------------------------------------------------------------
mkdir -p "${PI_TARGET_ROOT}"

for skill_name in "${PI_SKILL_NAMES[@]}"; do
  if ! skill_dir="$(find_skill_dir "${skill_name}")"; then
    printf 'Aviso: no encontre la skill "%s" en el repo; se omite para Pi.\n' "${skill_name}" >&2
    continue
  fi
  install_skill "${skill_dir}" "${PI_TARGET_ROOT}"
done

printf '\nListo.\n'
if [[ "$PI_ONLY" != true ]]; then
  printf '  opencode: %s\n' "${TARGET_ROOT}"
fi
printf '  Pi:       %s\n' "${PI_TARGET_ROOT}"
printf 'Reinicia cada agente para que refresque la lista de skills.\n'

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  printf '\n⚠ %d destino(s) omitido(s) por conflicto:\n' "${#CONFLICTS[@]}"
  for conflict in "${CONFLICTS[@]}"; do
    printf '  · %s\n' "${conflict}"
  done
  printf '\nEsos directorios ya existian y NO los creo este repo, asi que no se tocaron.\n'
  printf 'Si son copias viejas, borralos y volve a correr el instalador para que queden\n'
  printf 'como enlaces a este repositorio.\n'
  exit 1
fi
