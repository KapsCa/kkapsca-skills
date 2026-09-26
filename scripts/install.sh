#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# kkapsca-skills — universal installer
#
# Installs the skills of this repository into the skills directory of any
# agent, in any environment, WITHOUT cloning the repository.
#
# The one-liner (no clone needed — this script fetches a tarball itself):
#   curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh | bash
#
# Or download and run:
#   curl -sLO https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh
#   chmod +x install.sh
#   ./install.sh --agent claude
# ============================================================================

GITHUB_OWNER="KapsCa"
GITHUB_REPO="kkapsca-skills"
DEFAULT_REF="main"

# --dir is the universal escape hatch: agents whose skills directory is not in
# this table are served by it. These are the only verified agent locations.
KNOWN_AGENTS=(
    "agents:${HOME}/.agents/skills"
    "opencode:${HOME}/.config/opencode/skills"
    "claude:${HOME}/.claude/skills"
    "codex:${HOME}/.codex/skills"
    "gemini:${HOME}/.gemini/skills"
    "copilot:${HOME}/.copilot/skills"
    "kilo:${HOME}/.config/kilo/skills"
    "pi:${HOME}/.agents/skills"
)
DEFAULT_AGENT="agents"

# ============================================================================
# Color support — only when stdout is a terminal.
# ============================================================================

setup_colors() {
    if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        BOLD='\033[1m'
        DIM='\033[2m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' NC=''
    fi
}

# ============================================================================
# Logging helpers
# ============================================================================

info()    { echo -e "${BLUE}[info]${NC}    $*"; }
success() { echo -e "${GREEN}[ok]${NC}      $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}    $*"; }
error()   { echo -e "${RED}[error]${NC}   $*" >&2; }
fatal()   { error "$@"; exit 1; }
step()    { echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$*${NC}"; }

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat <<EOF
${BOLD}kkapsca-skills installer${NC}

Install the skills of ${GITHUB_OWNER}/${GITHUB_REPO} into the skills directory of
any agent, without cloning the repository.

Usage: install.sh [OPTIONS]

Options:
  --agent NAME   Install into the skills directory of a known agent:
                 agents, opencode, claude, codex, gemini, copilot, kilo, pi
                 (default: agents)
  --all          Install into every known agent directory that already
                 exists on this machine (none is created for you)
  --dir PATH     Install into an arbitrary directory. Use this when your
                 agent is not in the list above: any directory works
  --list         Print the known agents, their directories and which ones
                 exist; changes nothing on disk
  --copy         Make physical copies instead of symlinks
  --update       Re-download the repository into the cache before installing
  --ref REF      Branch or tag to install from (default: main)
  -h, --help     Show this help

Examples:
  curl -fsSL https://raw.githubusercontent.com/${GITHUB_OWNER}/${GITHUB_REPO}/main/scripts/install.sh | bash
  ./install.sh --agent claude
  ./install.sh --agent opencode --copy
  ./install.sh --all
  ./install.sh --dir \${HOME}/somewhere/skills   # any agent at all
  ./install.sh --update --ref a-feature-branch

The repository tarball is cached under \${XDG_DATA_HOME:-\$HOME/.local/share}/${GITHUB_REPO}/
EOF
}

# ============================================================================
# Argument parsing (no reads from stdin anywhere; see the TTY guard below)
# ============================================================================

# Colors must exist before argument parsing: a fatal in the parser itself has
# to print a readable message, not crash on unset color variables (set -u).
setup_colors

AGENT_NAME=""
ALL=false
CUSTOM_DIR=""
COPY=false
UPDATE=false
SELECTED_REF="${DEFAULT_REF}"
LIST=""

while [ $# -gt 0 ]; do
    case "$1" in
        --agent)
            [ $# -lt 2 ] && fatal "--agent requires an argument"
            AGENT_NAME="$2"; shift 2
            ;;
        --all)
            ALL=true; shift
            ;;
        --dir)
            [ $# -lt 2 ] && fatal "--dir requires an argument"
            CUSTOM_DIR="$2"; shift 2
            ;;
        --list)
            LIST=1; shift
            ;;
        --copy)
            COPY=true; shift
            ;;
        --update)
            UPDATE=true; shift
            ;;
        --ref)
            [ $# -lt 2 ] && fatal "--ref requires an argument"
            SELECTED_REF="$2"; shift 2
            ;;
        -h|--help)
            setup_colors
            show_help
            exit 0
            ;;
        *)
            fatal "Unknown option: $1. Use --help for usage."
            ;;
    esac
done

# ============================================================================
# TTY guard: under `curl | bash`, stdin IS the script itself. Any read on
# stdin would silently consume the program that is still being executed, so
# this installer never reads stdin. The interactive menu reads its answer
# from /dev/tty and is offered only when stdout is a terminal.
# ============================================================================

IS_TTY=false
if [ -t 0 ] && [ -t 1 ]; then
    IS_TTY=true
fi

# Menu entries: "agent:label" (dir: acts as the escape-hatch hint).
INTERACTIVE_MENU=(
    "agents:${HOME}/.agents/skills  (cross-agent convention, recommended)"
    "opencode:${HOME}/.config/opencode/skills"
    "claude:${HOME}/.claude/skills"
    "codex:${HOME}/.codex/skills"
    "gemini:${HOME}/.gemini/skills"
    "copilot:${HOME}/.copilot/skills"
    "kilo:${HOME}/.config/kilo/skills"
    "pi:${HOME}/.agents/skills"
    "dir:custom directory — run with --dir <path> for any other agent"
)

# ============================================================================
# Target directory resolution
# ============================================================================

# Prints the directory of the current AGENT_NAME; non-zero when unknown.
resolve_agent_dir() {
    local entry name path
    for entry in "${KNOWN_AGENTS[@]}"; do
        name="${entry%%:*}"
        path="${entry#*:}"
        if [ "$name" = "$AGENT_NAME" ]; then
            printf '%s\n' "$path"
            return 0
        fi
    done
    return 1
}

# Prints "name:path" for every known agent whose directory already exists.
collect_existing_dirs() {
    local entry name path
    for entry in "${KNOWN_AGENTS[@]}"; do
        name="${entry%%:*}"
        path="${entry#*:}"
        if [ -d "$path" ]; then
            printf '%s:%s\n' "$name" "$path"
        fi
    done
}

# Builds TARGET_DIRS from the selected mode: --dir, --agent, --all or default.
resolve_targets() {
    TARGET_DIRS=()

    # --dir is the universal escape hatch; it wins over --agent.
    if [ -n "$CUSTOM_DIR" ]; then
        TARGET_DIRS+=("$CUSTOM_DIR")
        return 0
    fi

    if [ -n "$AGENT_NAME" ]; then
        if ! resolve_agent_dir; then
            error "Unknown agent: ${AGENT_NAME}"
            error "Known agents: agents, opencode, claude, codex, gemini, copilot, kilo, pi"
            error "Any other agent is served by its skills directory: --dir <path>"
            fatal "Fix the target or use --help."
        fi
        TARGET_DIRS+=("$(resolve_agent_dir)")
        return 0
    fi

    if [ "$ALL" = true ]; then
        local entry dir count=0
        while IFS= read -r entry; do
            [ -n "$entry" ] || continue
            dir="${entry#*:}"
            TARGET_DIRS+=("$dir")
            count=$((count + 1))
        done < <(collect_existing_dirs)
        if [ "$count" -eq 0 ]; then
            fatal "No known agent directory exists on this machine. Check --list, or point at any path with --dir <path>."
        fi
        return 0
    fi

    # No flag: offer a menu only on a real terminal, reading the answer from
    # /dev/tty (never stdin — see the TTY guard above).
    if [ "$IS_TTY" = true ]; then
        echo ""
        echo -e "${BOLD}Where should the skills be installed?${NC}"
        local i desc
        for i in "${!INTERACTIVE_MENU[@]}"; do
            desc="${INTERACTIVE_MENU[$i]}"
            echo -e "  ${CYAN}$((i + 1)))${NC} ${desc%%:*}  ${desc#*:}"
        done
        local answer=""
        printf 'Choose 1-%d [default: 1]: ' "${#INTERACTIVE_MENU[@]}"
        if [ -r /dev/tty ]; then
            read -r answer < /dev/tty || true
        fi
        case "$answer" in
            '')
                AGENT_NAME="$DEFAULT_AGENT"
                ;;
            *[!0-9]*|0)
                fatal "Not a menu number: ${answer}. Run again and choose 1-${#INTERACTIVE_MENU[@]}, or use --agent/--dir/--all."
                ;;
            *)
                if [ "$answer" -ge 1 ] && [ "$answer" -le "${#INTERACTIVE_MENU[@]}" ]; then
                    local choice="${INTERACTIVE_MENU[$((answer - 1))]}"
                    choice="${choice%%:*}"
                    if [ "$choice" = "dir" ]; then
                        fatal "--dir <path> cannot be answered here; run again with the path: --dir \${HOME}/myagent/skills"
                    fi
                    AGENT_NAME="$choice"
                else
                    fatal "Out of range: ${answer}. Choose 1-${#INTERACTIVE_MENU[@]}."
                fi
                ;;
        esac
        if ! resolve_agent_dir; then
            fatal "Resolved agent has no configured directory: ${AGENT_NAME}"
        fi
        TARGET_DIRS+=("$(resolve_agent_dir)")
        return 0
    fi

    # Non-interactive default (the normal `curl | bash` case). Saying clearly
    # what it installs and where is a hard requirement.
    TARGET_DIRS+=("$(resolve_agent_dir)")
    echo ""
    echo -e "${BOLD}No --agent/--all/--dir given and stdout is not a terminal:${NC}"
    echo -e "${BOLD}installing into the default '${DEFAULT_AGENT}' directory: ${TARGET_DIRS[0]}${NC}"
    echo -e "Use --agent <name>, --all or --dir <path> to choose another destination."
}

# ============================================================================
# Prerequisites — fail with a readable message, never a bare "command failed".
# Tarball is the primary path (curl + tar); git clone --depth 1 is only the
# fallback when curl or tar are missing.
# ============================================================================

check_prerequisites() {
    step "Checking prerequisites"
    if command -v curl &>/dev/null && command -v tar &>/dev/null; then
        success "curl and tar available (tarball fetch)"
        return 0
    fi
    if command -v git &>/dev/null; then
        warn "curl or tar unavailable; will fall back to git clone --depth 1"
        return 0
    fi
    error "Neither 'curl'+'tar' nor 'git' were found on this system."
    error "Install curl and tar (or git) with your package manager and run this script again."
    fatal "Cannot download ${GITHUB_OWNER}/${GITHUB_REPO} without one of those."
}

# ============================================================================
# Repository fetch: GitHub tarball, cached under XDG_DATA_HOME.
#
#   https://github.com/<owner>/<repo>/archive/refs/heads/<branch>.tar.gz
#   https://github.com/<owner>/<repo>/archive/refs/tags/<tag>.tar.gz
#
# A branch ref is tried first, then a tag; both failing means the ref does not
# exist. The tarball is fully downloaded and verified before the cache is
# touched, so an interrupted fetch can never destroy a good cache.
# ============================================================================

CACHE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/${GITHUB_REPO}"

# TEMP_WORK: per-download staging; never aliases CACHE_DIR.
populate_cache() {
    local tgz="$1" stage extract top inner
    stage="$(mktemp -d "${WORK_DIR}/cache.stage.XXXXXX")" || return 1
    extract="${stage}/extract"
    mkdir "$extract" || { rm -rf "$stage"; return 1; }

    if ! tar -xzf "$tgz" -C "$extract"; then
        error "Extraction of the downloaded tarball failed."
        rm -rf "$stage"
        return 1
    fi

    # GitHub tarballs wrap everything in a single top-level directory
    # (kkapsca-skills-<ref>); peel it off.
    top="$(find "$extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [ -z "$top" ]; then
        error "The archive is empty or has an unexpected layout."
        rm -rf "$stage"
        return 1
    fi
    inner="${stage}/repo"
    mv "$top" "$inner"
    rm -rf "$extract"

    if [ ! -f "$inner/scripts/install-opencode-skills.sh" ]; then
        error "The archive is broken (missing scripts/install-opencode-skills.sh)."
        rm -rf "$stage"
        return 1
    fi

    printf '%s\n' "$SELECTED_REF" > "$inner/.repo-ref"
    printf '%s\n' "$ARCHIVE_REF" > "$inner/.repo-archive-ref"

    # Swap: only now, with a fully verified copy, is the old cache replaced.
    rm -rf "$CACHE_DIR"
    mkdir -p "$(dirname "$CACHE_DIR")"
    if ! mv "$inner" "$CACHE_DIR"; then
        error "Could not move the extracted repository into ${CACHE_DIR}."
        rm -rf "$stage"
        return 1
    fi
    rm -rf "$stage"
    return 0
}

download_cache() {
    if command -v curl &>/dev/null && command -v tar &>/dev/null; then
        local tgz try_ref
        tgz="$(mktemp "${WORK_DIR}/kkapsca.tarball.XXXXXX")" || return 1

        for try_ref in "refs/heads/${SELECTED_REF}" "refs/tags/${SELECTED_REF}"; do
            info "Trying https://github.com/${GITHUB_OWNER}/${GITHUB_REPO} (${try_ref})"
            if curl -fsSL --proto '=https' --tlsv1.2 \
                    -o "$tgz" "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/archive/${try_ref}.tar.gz"; then
                ARCHIVE_REF="$try_ref"
                break
            fi
            try_ref=""
        done
        if [ -z "${ARCHIVE_REF:-}" ]; then
            error "Ref '${SELECTED_REF}' not found as branch or tag on ${GITHUB_OWNER}/${GITHUB_REPO}."
            error "Check the ref name and your network; try --ref main."
            rm -f "$tgz"
            return 1
        fi
        if ! tar -tzf "$tgz" >/dev/null 2>&1; then
            error "The downloaded tarball is corrupt."
            rm -f "$tgz"
            return 1
        fi
        if ! populate_cache "$tgz"; then
            rm -f "$tgz"
            return 1
        fi
        rm -f "$tgz"
        success "Downloaded tarball (${ARCHIVE_REF})"
        return 0
    fi

    if command -v git &>/dev/null; then
        warn "curl or tar unavailable; falling back to git clone --depth 1"
        local stage="${WORK_DIR}/clone.XXXXXX"
        stage="$(mktemp -d "${WORK_DIR}/clone.XXXXXX")" || return 1
        rmdir "$stage"
        if ! git clone --depth 1 --branch "$SELECTED_REF" \
                "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}.git" "$stage"; then
            error "git clone of ref '${SELECTED_REF}' failed. Check the ref name and your network; try --ref main."
            return 1
        fi
        printf '%s\n' "$SELECTED_REF" > "$stage/.repo-ref"
        printf 'refs/heads/%s\n' "$SELECTED_REF" > "$stage/.repo-archive-ref"
        rm -rf "$CACHE_DIR"
        mkdir -p "$(dirname "$CACHE_DIR")"
        if ! mv "$stage" "$CACHE_DIR"; then
            error "Could not move the cloned repository into ${CACHE_DIR}."
            return 1
        fi
        success "Cloned ref ${SELECTED_REF} (shallow)"
        return 0
    fi

    error "Neither 'curl'+'tar' nor 'git' were found. Install them and run this script again."
    return 1
}

refresh_cache() {
    step "Fetching ${GITHUB_OWNER}/${GITHUB_REPO} (ref: ${SELECTED_REF})"

    # The cache remembers which ref it holds. Same ref: reuse it verbatim;
    # --update forces a re-download. Different ref: download it, normal flow.
    if [ "$UPDATE" != true ] && [ -f "$CACHE_DIR/scripts/install-opencode-skills.sh" ] \
        && [ -f "$CACHE_DIR/.repo-ref" ] \
        && [ "$(cat "$CACHE_DIR/.repo-ref")" = "$SELECTED_REF" ]; then
        info "Reusing cached copy of ref ${SELECTED_REF} (use --update to re-download)"
        return 0
    fi

    if [ "$UPDATE" = true ] && [ -d "$CACHE_DIR" ]; then
        info "Re-downloading the repository (--update)"
    fi

    if ! download_cache; then
        error "Could not fetch ${GITHUB_OWNER}/${GITHUB_REPO} (ref: ${SELECTED_REF})."
        error "Install curl and tar (or git), or run again with --ref main."
        exit 1
    fi
}

# ============================================================================
# Per-target install
#
# The inner installer (install-opencode-skills.sh) manages two destinations:
# the target directory (OPENCODE_SKILLS_DIR) and a second pass (PI_SKILLS_DIR),
# and it also loads skills from EXTERNAL_SKILLS_DIR.
#
# This universal wrapper reuses it verbatim:
#   - OPENCODE_SKILLS_DIR -> the target directory
#   - PI_SKILLS_DIR       -> a throwaway directory under WORK_DIR, deleted after
#   - EXTERNAL_SKILLS_DIR -> an empty throwaway, so the external pass brings in
#                           nothing
# Conflict handling stays with the inner installer: a destination this repo did
# not create is reported and left untouched.
# ============================================================================

install_into() {
    local target="$1"
    local installer="${CACHE_DIR}/scripts/install-opencode-skills.sh"
    local empty_dir pi_target rc

    step "Installing skills into: ${target}"

    if [ "$COPY" != true ]; then
        info "Symlink mode: the cached copy installs links into the target."
    fi

    if [ ! -d "$target" ]; then
        mkdir -p "$target"
        info "Created ${target}"
    fi

    # Empty throwaway for the external pass: contributes no external skills.
    empty_dir="${WORK_DIR}/external-empty.$$"
    mkdir -p "$empty_dir"

    # Throwaway for the inner installer's own second pass (deleted below).
    pi_target="${WORK_DIR}/pi-throwaway.$$-${RANDOM}"

    rc=0
    if [ "$COPY" = true ]; then
        set +e
        OPENCODE_SKILLS_DIR="$target" \
            PI_SKILLS_DIR="$pi_target" \
            EXTERNAL_SKILLS_DIR="$empty_dir" \
            bash "$installer" --copy
        rc=$?
        set -e
    else
        set +e
        OPENCODE_SKILLS_DIR="$target" \
            PI_SKILLS_DIR="$pi_target" \
            EXTERNAL_SKILLS_DIR="$empty_dir" \
            bash "$installer"
        rc=$?
        set -e
    fi

    rm -rf "$empty_dir" "$pi_target"

    if [ "$rc" -ne 0 ] && [ "$rc" -ne 130 ]; then
        TARGET_FAILURES+=("$target")
        warn "Some names under ${target} were skipped as conflicts (this repo did not create them); they were left untouched."
        warn "All other skills in this target installed normally (see the per-skill results above)."
    fi
    return 0
}

# ============================================================================
# --list — prints the known agent table and nothing on disk changes.
# ============================================================================

print_list() {
    local entry name path note
    echo ""
    echo "Known agents:"
    for entry in "${KNOWN_AGENTS[@]}"; do
        name="${entry%%:*}"
        path="${entry#*:}"
        note=""
        if [ "$name" = "pi" ]; then
            note="(same directory as agents)"
        fi
        if [ -d "$path" ]; then
            printf '  %-8s %s  %s  [exists]\n' "$name" "$path" "$note"
        else
            printf '  %-8s %s  %s  [not present]\n' "$name" "$path" "$note"
        fi
    done
    echo ""
    echo "If your agent is not in this list, install into its skills directory with:"
    echo "  --dir /path/to/its/skills"
    echo ""
}

# ============================================================================
# Temporary staging area — cleaned automatically on every exit path.
# ============================================================================

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/kkapsca-work.XXXXXX")"
trap 'rm -rf -- "$WORK_DIR"' EXIT

# ============================================================================
# Summary
# ============================================================================

print_summary() {
    local target
    echo ""
    echo -e "${GREEN}${BOLD}Installation complete!${NC}"
    echo ""
    echo "  Ref:   ${SELECTED_REF}"
    echo "  Cache: ${CACHE_DIR}"
    echo ""
    echo "Installed into:"
    for target in "${TARGET_DIRS[@]}"; do
        if [ -d "$target" ]; then
            echo -e "  ${GREEN}+${NC} ${target}"
        else
            echo -e "  ${RED}-${NC} ${target} ${DIM}(missing)${NC}"
        fi
    done
    if [ "${#TARGET_FAILURES[@]}" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}${BOLD}Conflicts (already existed; this repo did not create them):${NC}"
        for target in "${TARGET_FAILURES[@]}"; do
            echo -e "  ${YELLOW}!${NC} ${target}"
        done
        echo ""
        echo "Conflict entries in these paths were left untouched; every other skill installed normally."
        echo "To adopt a conflicting name, remove it (or hand it over) and run this again."
    fi
    echo ""
    echo "Restart each agent so it picks up the new skills."
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    setup_colors

    if [ -n "$LIST" ]; then
        print_list
        exit 0
    fi

    step "kkapsca-skills installer"
    info "No clone needed; the installer fetches its own copy of the repository."

    TARGET_DIRS=()
    TARGET_FAILURES=()

    resolve_targets
    check_prerequisites
    refresh_cache

    echo ""
    local target
    for target in "${TARGET_DIRS[@]}"; do
        install_into "$target"
    done

    print_summary
}

# ============================================================================
# Execution guard: works both as a file (./install.sh) and through curl | bash,
# where BASH_SOURCE[0] is empty because the program arrives on stdin.
# ============================================================================

if [ -z "${BASH_SOURCE[0]:-}" ] || [ "${BASH_SOURCE[0]}" = "$0" ]; then
    setup_colors
    main "$@"
fi
