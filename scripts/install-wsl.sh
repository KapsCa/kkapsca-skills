#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# kkapsca-skills — WSL/Linux ecosystem installer
#
# Brings a fresh WSL2 Ubuntu (or a modern Linux box) to the full Gentle AI
# agent ecosystem, in execution order:
#
#   1. apt prerequisites (git, curl, tar, jq, unzip, ca-certificates, xz)
#   2. Node.js runtime (pi's own engines' requirement, no sudo path via nvm)
#   3. pi (coding agent) + CodeGraph, via npm global
#   4. Engram binary for linux, SHA256-verified against checksums.txt
#   5. gentle-ai via its upstream installer + `gentle-ai install --agent pi`
#   6. pi packages via `pi install`, idempotent by specifier: an entry in
#      settings.json that already names the same package (npm name, npm
#      name@version, or a node_modules path) is skipped, never duplicated
#   7. herdr via its upstream installer + `herdr integration install pi`
#   8. skills: this repo (scripts/install.sh), firebase/agent-skills,
#      supabase/agent-skills (via `npx skills add`)
#   9. pi config: mcp-adapter.json + subagents.json (the hybrid decision:
#      this script owns exactly the files upstream tools do not write
#      correctly; settings.json and the pi packages belong to `pi install`
#      and `gentle-ai install`)
#   10. tailscale: network reachability shared by the phone (Moshi) and a
#      future Engram Cloud — stable tailnet identity where WSL2's NAT'd IP
#      changes on every reboot
#   11. moshi: phone access — openssh-server (normal sshd), mosh, tmux,
#      moshi-hook, and the pairing/daemon steps printed as exact commands
#   12. final verification + summary table
#
# The Windows-native sibling is scripts/install-windows.ps1; the skills-only
# installer is scripts/install.sh (this file's log/UX conventions come from
# there; do not restyle them here).
#
# One-liner (curl | bash safe):
#   curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install-wsl.sh | bash
#
# Design rules (enforced in every phase):
#   - never reads stdin: any prompt comes from /dev/tty and only when one is
#     readable, so `curl | bash` can never eat the script text
#   - never lets sudo read stdin: `sudo -n` first; when a password would be
#     needed and no TTY is readable, the phase fails with the exact command
#     for the user to run; unprivileged phases continue
#   - idempotent: existing, working tools are reported, not reinstalled
#   - fail-closed on every download this script performs itself: engram is
#     SHA256-verified against checksums.txt; a missing checksums file aborts
#     the phase. Third-party installers (tailscale, moshi-hook, gentle-ai)
#     verify their own downloads; each is first downloaded to a temporary
#     file and then run — never piped blindly to a shell.
#   - installs the LATEST published version of everything (user decision);
#     no version pins in this file
#   - generic and public: no personal project names, paths, or values. The
#     engram project name enters ONLY through --engram-project and is pinned
#     ONLY into user-supplied container directories (--engram-pin-dir) as
#     <dir>/.engram/config.json; never into ~/.engram (Engram's data dir)
#     and never into a tracked file
#   - never calls `pi-engram init`: that writes mcp.json, which
#     pi-mcp-adapter 3.x no longer reads (it reads mcp-adapter.json). That
#     file is owned by the pi-config phase below.
#   - phase order: Tailscale runs BEFORE Moshi on purpose. Only when the
#     --tailscale-ssh experimental flag is given (see flag documentation)
#     does Moshi skip openssh-server; the default and supported path runs
#     the tailscale phase first and then installs a normal sshd.
# ============================================================================

# ----------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------

GITHUB_OWNER="KapsCa"
GITHUB_REPO="kkapsca-skills"
DEFAULT_REF="main"
REPO_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"
ENGRAM_REPO="Gentleman-Programming/engram"
ENGRAM_RELEASES_URL="https://github.com/${ENGRAM_REPO}/releases"
GENTLE_AI_REPO="Gentleman-Programming/gentle-ai"
GENTLE_AI_INSTALL_URL="https://raw.githubusercontent.com/${GENTLE_AI_REPO}/main/scripts/install.sh"
HERDR_INSTALL_URL="https://herdr.dev/install.sh"
TAILSCALE_INSTALL_URL="https://tailscale.com/install.sh"
MOSHI_INSTALL_URL="https://getmoshi.app/install.sh"
SWITCH_TO_ROOT_HINT="/usr/bin/wsl.exe -u root"

# moshi-hook below 0.4.3 lacks 'moshi-hook doctor'; the daemon/pairing phases
# cannot report feature-level readiness on such an install.
MOSHI_HOOK_MIN_DOCTOR="0.4.3"

PI_PACKAGE="npm:@earendil-works/pi-coding-agent"
CODEGRAPH_PACKAGE="npm:@colbymchenry/codegraph"

# pi packages: installed through `pi install` (that command owns
# settings.json; this script never writes settings.json itself). The phase
# is idempotent by specifier: an already-present equivalent entry (same npm
# name with/without a version pin, or the same package as a node_modules
# path) is skipped and reported, so re-runs and upstream `gentle-ai install`
# writes cannot pile up duplicates. This inventory mirrors the machine-A
# reference (7 entries incl. gentle-pi); the pi phase in
# scripts/install-windows.ps1 manages the same set for Windows.
PI_PACKAGES=(
    "npm:gentle-pi"
    "npm:gentle-engram"
    "npm:pi-btw"
    "npm:pi-intercom"
    "npm:pi-lens"
    "npm:pi-mcp-adapter"
    "npm:pi-web-access"
)

# External skill sources installed through the `skills` CLI (see machine
# reference: firebase/agent-skills carries 13 skills, supabase/agent-skills 2).
SKILL_REPOS=(
    "firebase/agent-skills"
    "supabase/agent-skills"
)

# ~/.engram is Engram's DATA directory (DB, WAL, logs). Project pins can only
# be written for container directories, never for home itself. A pin lives in
# <container>/.engram/config.json as {"project_name": "<name>"}.

# pi installation layout (all paths are user-local; nothing runs as root).
PI_AGENT_DIR="${HOME}/.pi/agent"
PI_BIN_DIR="${PI_AGENT_DIR}/bin"
PI_BIN_ENGRAM="${PI_BIN_DIR}/engram"
MCP_ADAPTER_FILE="${PI_AGENT_DIR}/mcp-adapter.json"
SUBAGENTS_FILE="${PI_AGENT_DIR}/subagents.json"
PI_SETTINGS_FILE="${PI_AGENT_DIR}/settings.json"

NVM_VERSION="v0.40.3"
NVM_INSTALL_SH_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

# NVM_DIR default mirrors nvm's own install.sh default.
NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"

APT_PACKAGES=(curl ca-certificates git jq tar unzip xz-utils gnupg)

# pi's engines requirement (verified against @earendil-works/pi-coding-agent
# 0.87.1: engines.node >= 22.19.0). Used only when the requirement cannot be
# resolved from the registry (e.g. npm missing); keep in sync with upstream.
NODE_MIN_VERSION="22.19.0"

# ----------------------------------------------------------------------------
# Global state
# ----------------------------------------------------------------------------

MODE_UPDATE=0
MODE_STATUS=0
MODE_DRYRUN=0

ARG_REF="${DEFAULT_REF}"
ARG_ENGRAM_PROJECT=""
ENGRAM_PIN_DIRS=()
OPT_SKIP_SKILLS=0
OPT_SKIP_HERDR=0
OPT_SKIP_EXTERNAL_SKILLS=0
OPT_SKIP_TAILSCALE=0
OPT_SKIP_MOSHI=0
OPT_TAILSCALE_SSH=0

ASSUME_YES=0
TTY_OK=0
IS_WSL=0
ARCH=""
OS_TOTAL_FAILED=0

# Per-phase results: parallel arrays (portable, no associative arrays).
declare -a PHASE_ORDER=()   # ids in execution order
declare -a PHASE_LABEL=()   # "id|label" aligned with PHASE_ORDER
declare -a PHASE_STATE=()   # ok|skip|fail aligned with PHASE_ORDER
declare -a PHASE_NOTE=()    # aligned with PHASE_ORDER

# ----------------------------------------------------------------------------
# Colors and logging — same conventions as scripts/install.sh
# ----------------------------------------------------------------------------

setup_colors() {
    if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        BOLD='\033[1m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
    fi
}

info()    { echo -e "${BLUE}[info]${NC}    $*"; }
success() { echo -e "${GREEN}[ok]${NC}      $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}    $*"; }
error()   { echo -e "${RED}[error]${NC}   $*" >&2; }
fatal()   { error "$@"; exit 1; }
step()    { echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$*${NC}"; }

# ----------------------------------------------------------------------------
# Phase bookkeeping
# ----------------------------------------------------------------------------

phase_register() {
    # phase_register <id> <label>
    PHASE_ORDER+=("$1")
    PHASE_LABEL+=("$2")
    PHASE_STATE+=("")
    PHASE_NOTE+=("")
}

phase_index() {
    local id="$1" i
    for i in "${!PHASE_ORDER[@]}"; do
        if [ "${PHASE_ORDER[$i]}" = "$id" ]; then
            printf '%s\n' "$i"
            return 0
        fi
    done
    return 1
}

# phase_set <id> <ok|skip|fail> <message>
phase_set() {
    local id="$1" state="$2" note="$3" idx
    idx="$(phase_index "$id")" || return 1
    PHASE_STATE[idx]="$state"
    PHASE_NOTE[idx]="$note"
    if [ "$state" = "fail" ]; then
        OS_TOTAL_FAILED=$((OS_TOTAL_FAILED + 1))
    fi
}

phase_count_in_state() {
    local state="$1" i count=0
    for i in "${!PHASE_STATE[@]}"; do
        if [ "${PHASE_STATE[$i]}" = "$state" ]; then
            count=$((count + 1))
        fi
    done
    printf '%s\n' "$count"
}

phase_print_detail() {
    local id="$1" idx state
    idx="$(phase_index "$id")" || return 0
    state="${PHASE_STATE[idx]}"
    case "$state" in
        ok)   printf '  %b[ok]%b   %-28s %s\n' "$GREEN" "$NC" "${PHASE_LABEL[idx]}" "${PHASE_NOTE[idx]}" ;;
        skip) printf '  %b[skip]%b %-28s %s\n' "$YELLOW" "$NC" "${PHASE_LABEL[idx]}" "${PHASE_NOTE[idx]}" ;;
        fail) printf '  %b[fail]%b %-25s %s\n' "$RED" "$NC" "${PHASE_LABEL[idx]}" "${PHASE_NOTE[idx]}" ;;
    esac
}

# ----------------------------------------------------------------------------
# TTY/stdin discipline
#
# Under `curl | bash` stdin IS the script. Nothing here reads stdin: answers
# come from /dev/tty, and only when it is readable.
# ----------------------------------------------------------------------------

ask_continue() {
    # ask_continue <question> -> 0=yes, 1=no/no-tty. Never reads stdin.
    [ "$ASSUME_YES" = "1" ] && return 0
    [ "$TTY_OK" = "1" ] || return 1
    local reply=""
    printf '%s [y/N]: ' "$1"
    if ! read -r reply < /dev/tty; then
        return 1
    fi
    case "$reply" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

# ----------------------------------------------------------------------------
# Downloads (fail closed; every direct download is verified)
# ----------------------------------------------------------------------------

http_fetch() {
    # http_fetch <url> <dest>
    curl -fsSL --proto '=https' --tlsv1.2 "$1" -o "$2"
}

http_get() {
    # body to stdout
    curl -fsSL --proto '=https' --tlsv1.2 "$1"
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        printf '\n'
    fi
}

# verify_against_checksums <file> <checksums.txt> <asset-name>
# Grep is anchored to the full asset name; a substring match could take the
# hash of a sibling like <name>.sig and fail a good download.
verify_against_checksums() {
    local file="$1" sums="$2" name="$3" actual expected
    actual="$(sha256_of "$file")"
    if [ -z "$actual" ]; then
        error "No sha256sum/shasum available to verify $(basename "$file")."
        return 1
    fi
    expected="$(grep -E "^[[:space:]]*[0-9a-fA-F]{64}[[:space:]]+\*?${name}[[:space:]]*$" "$sums" | awk '{print $1}' | head -n 1)"
    if [ -z "$expected" ]; then
        error "checksums.txt has no line for ${name}."
        return 1
    fi
    if [ "$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')" != "$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]')" ]; then
        error "SHA256 mismatch for ${name}"
        error "  expected: ${expected}"
        error "  actual:   ${actual}"
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------
# Version helpers
# ----------------------------------------------------------------------------

version_ge() {
    # version_ge <got> <want> -> 0 when got >= want (dot-separated numbers)
    printf '%s\n%s\n' "$2" "$1" | sort -V | tail -n 1 | grep -qxF "$1"
}

version_gt() {
    ! version_ge "$1" "$2"
}

tool_version() {
    # prints the version of a command, tolerating a v-prefix; empty on failure
    local cmd="$1" out=""
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf '\n'
        return 0
    fi
    out="$("$cmd" "${@:2}" 2>/dev/null | head -n 1 || true)"
    out="$(printf '%s' "$out" | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
    printf '%s\n' "$out"
}

arch_of() {
    case "$(uname -m)" in
        x86_64|amd64) printf 'amd64\n' ;;
        aarch64|arm64) printf 'arm64\n' ;;
        *) printf '\n' ;;
    esac
}

detect_wsl() {
    IS_WSL=0
    if grep -qi microsoft /proc/version 2>/dev/null; then
        IS_WSL=1
    fi
}

# ----------------------------------------------------------------------------
# sudo guard
#
# sudo must never read stdin. sudo -n is tried first; when a password would
# be required and no TTY is readable, the protected operation is skipped
# with the exact command the user must run. Not silently: it is recorded as
# a phase failure and shown in the summary.
# ----------------------------------------------------------------------------

SUDO=""

sudo_probe() {
    # Sets SUDO to the command prefix for privileged steps, or empty when a
    # password would be needed and no TTY is readable (callers then record a
    # failure with the exact manual command instead of going half-installed).
    SUDO=""
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi
    if ! command -v sudo >/dev/null 2>&1; then
        return 0
    fi
    if sudo -n true 2>/dev/null; then
        SUDO="sudo -n"
        return 0
    fi
    if [ "$TTY_OK" = "1" ]; then
        info "sudo needs your password; it will be read from the terminal (once)."
        if ask_continue "Run sudo apt steps now?"; then
            SUDO="sudo"
        fi
    fi
}

# run_priv <cmd...> — runs a command with sudo -n (never reading stdin).
# Returns non-zero when sudo is unavailable; the caller decides what to do.
run_priv() {
    if [ -z "$SUDO" ]; then
        return 1
    fi
    # shellcheck disable=SC2086
    $SUDO "$@"
}

# sudo_hint — exact, copy-pastable escalation when sudo is unavailable.
# Used by privileged steps so the user can complete them by hand and re-run.
sudo_hint() {
    echo "sudo could not run non-interactively (sudo -n) and no TTY is readable."
    echo "Run this step yourself, then re-run this installer inside WSL:"
    echo "  ${SWITCH_TO_ROOT_HINT} -- bash -c '<command>'"
    echo "Alternative: inside an interactive WSL shell, plain 'sudo <command>'"
    echo "asks for your password there (only when a TTY is readable)."
}

# no_stdin_cmd — prefix for commands that must never read stdin. Used for
# the third-party installers' own sudo elevations: under `curl | bash` the
# script text is stdin, and a helper reading it would eat the script. The
# phase records the exact manual command when this rule trips.
no_stdin_cmd() {
    if command -v setsid >/dev/null 2>&1; then
        printf 'setsid\n'
    else
        printf '\n'
    fi
}

# ----------------------------------------------------------------------------
# rc-file editing (idempotent, marker-based)
# ----------------------------------------------------------------------------

ensure_rc_block() {
    # ensure_rc_block <rc-file> <marker> <block>
    local rc="$1" marker="$2" block="$3"
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would add an rc block to ${rc}: ${marker}"
        return 0
    fi
    [ -f "$rc" ] || : >"$rc"
    if grep -qF "$marker" "$rc"; then
        return 0
    fi
    {
        echo ""
        printf '%s\n' "$block"
    } >>"$rc"
}

# ensure_rc_path_dir <dir> — adds 'export PATH="<dir>:$PATH"' under a marker
# to ~/.bashrc and ~/.profile when neither file already puts <dir> on PATH.
# D2: when <dir> sits inside the user's home, the emitted line uses the
# $HOME-relative form ("$HOME/...") so the rc files never carry a
# machine-absolute path; the absolute form is used only for directories
# genuinely outside home. The guard matches the directory in BOTH forms so
# a second run never appends a duplicate block.
ensure_rc_path_dir() {
    local d="$1" marker rel="" rc line
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would ensure a PATH entry for ${d} in ~/.bashrc and ~/.profile"
        return 0
    fi
    marker="# --- install-wsl.sh PATH additions ---"
    rel="${d#"$HOME"/}"
    if [ -n "$rel" ] && [ "$rel" != "$d" ]; then
        # $d is under $HOME: emit the portable, $HOME-relative form.
        line="export PATH=\"\$HOME/${rel}:\$PATH\""
    else
        # Outside home (or a bare "$HOME" itself): absolute is correct there.
        line="export PATH=\"${d}:\$PATH\""
    fi
    for rc in "$HOME/.bashrc" "$HOME/.profile"; do
        if grep -qF -- "$marker" "$rc" 2>/dev/null; then
            # Marker block exists: only add this entry when the rc does not
            # already name the directory in either form.
            if grep -qF -- "$d" "$rc" 2>/dev/null \
                || grep -qF -- "\$HOME/${rel}" "$rc" 2>/dev/null; then
                continue
            fi
            printf '%s\n' "$line" >>"$rc"
            continue
        fi
        ensure_rc_block "$rc" "$marker" "${marker}
${line}"
    done
}

# ensure_engram_rc — exports ENGRAM_BIN and prepends ~/.pi/agent/bin to PATH
# (marker-guarded, so re-runs never duplicate lines).
ensure_engram_rc() {
    local marker block rc
    marker="# --- install-wsl.sh: engram (pi agent binary) ---"
    block="${marker}
export ENGRAM_BIN=\"\$HOME/.pi/agent/bin/engram\""
    for rc in "$HOME/.bashrc" "$HOME/.profile"; do
        if grep -qF "$marker" "$rc" 2>/dev/null; then
            continue
        fi
        ensure_rc_block "$rc" "$marker" "$block"
        ensure_rc_path_dir "$PI_BIN_DIR"
    done
    # Current session too (so phase 9 verification can use it).
    export ENGRAM_BIN="$PI_BIN_ENGRAM"
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat <<EOF
${BOLD}kkapsca-skills — WSL/Linux ecosystem installer${NC}

Brings a fresh WSL2 Ubuntu (or any modern Linux) up to the full pi agent
ecosystem: prerequisites, Node.js, pi + CodeGraph, Engram (SHA256-verified),
the Gentle AI stack, herdr with its pi integration, pi packages, skills
(three sources) and the pi config files upstream tooling does not write.

Usage: install-wsl.sh [OPTIONS]

Modes (mutually exclusive):
  (no flag)        Install what is missing; report what is already present
  --update         Refresh everything to the latest published version
  --dry-run        Print the full plan, write nothing, exit 0
  --status         Print installed versions, change nothing, exit 0

Options:
  --ref REF                kkapsca-skills ref for the skills phase (default: main)
  --engram-project NAME    Pin this Engram project name into the container
                           directories given with --engram-pin-dir (written
                           locally only; never into ~/.engram, Engram's own
                           data directory)
  --engram-pin-dir DIR     Container directory to pin (repeatable). Requires
                           --engram-project and vice versa; each DIR gets a
                           .engram/config.json with the project name
  --skip-skills            Skip the kkapsca-skills skills phase
  --skip-herdr             Skip the herdr phase
  --skip-external-skills   Skip firebase + supabase skill sources
  --skip-tailscale         Skip the tailscale phase (network reachability)
  --skip-moshi             Skip the moshi phase (phone access)
  --tailscale-ssh          EXPERIMENTAL: run 'sudo tailscale up --ssh' and
                           skip openssh-server in the moshi phase. moshi's
                           Easy Pair pairs against a normal sshd, and
                           Tailscale SSH breaks mosh (issue #4919, fixed for
                           mosh only by PR #5057) and claims port 22 on the
                           tailnet address; the default (normal
                           openssh-server + Tailscale as the network) is the
                           supported path
  --yes                    Assume yes: no confirmation prompts (still never
                           reads stdin; sudo prompts on /dev/tty only)
  -h, --help               Show this help and exit 0

Examples:
  bash scripts/install-wsl.sh --dry-run
  bash scripts/install-wsl.sh --status
  curl -fsSL https://raw.githubusercontent.com/${GITHUB_OWNER}/${GITHUB_REPO}/main/scripts/install-wsl.sh | bash
  ./install-wsl.sh --engram-project my-work --engram-pin-dir ~/dev --engram-pin-dir ~/dev/proyects --ref main
EOF
}

# ----------------------------------------------------------------------------
# Argument parsing — unknown flag is a usage error (non-zero exit)
# ----------------------------------------------------------------------------

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                setup_colors
                show_help
                exit 0
                ;;
            --dry-run)
                MODE_DRYRUN=1
                shift
                ;;
            --status)
                MODE_STATUS=1
                shift
                ;;
            --update)
                MODE_UPDATE=1
                shift
                ;;
            --ref)
                [ $# -lt 2 ] && { error "--ref requires an argument"; show_help; exit 2; }
                ARG_REF="$2"
                shift 2
                ;;
            --engram-project)
                [ $# -lt 2 ] && { error "--engram-project requires an argument"; show_help; exit 2; }
                ARG_ENGRAM_PROJECT="$2"
                shift 2
                ;;
            --engram-pin-dir)
                [ $# -lt 2 ] && { error "--engram-pin-dir requires an argument"; show_help; exit 2; }
                ENGRAM_PIN_DIRS+=("$2")
                shift 2
                ;;
            --skip-skills)
                OPT_SKIP_SKILLS=1
                shift
                ;;
            --skip-herdr)
                OPT_SKIP_HERDR=1
                shift
                ;;
            --skip-external-skills)
                OPT_SKIP_EXTERNAL_SKILLS=1
                shift
                ;;
            --skip-tailscale)
                OPT_SKIP_TAILSCALE=1
                shift
                ;;
            --skip-moshi)
                OPT_SKIP_MOSHI=1
                shift
                ;;
            --tailscale-ssh)
                OPT_TAILSCALE_SSH=1
                shift
                ;;
            --yes|-y)
                ASSUME_YES=1
                shift
                ;;
            *)
                error "Unknown option: $1. Use --help for usage."
                exit 2
                ;;
        esac
    done

    # D1 fail-closed flag pairing (install/update/dry-run modes). A project
    # pin is only ever written into user-supplied container directories:
    # Engram's home/data dir (~/.engram) cannot be pinned, and no directory
    # is ever guessed. --status is exempt: there the dirs are read-only
    # inspection paths for the pin report.
    if [ "$MODE_STATUS" != "1" ]; then
        if [ -n "$ARG_ENGRAM_PROJECT" ] && [ "${#ENGRAM_PIN_DIRS[@]}" -eq 0 ]; then
            error "--engram-project without --engram-pin-dir: Engram's home/data directory (~/.engram) cannot be pinned."
            error "Project pins live in container directories only. Pass at least one: --engram-pin-dir <dir> (repeatable)."
            error "Each pin is written as <dir>/.engram/config.json."
            exit 2
        fi
        if [ "${#ENGRAM_PIN_DIRS[@]}" -gt 0 ] && [ -z "$ARG_ENGRAM_PROJECT" ]; then
            error "--engram-pin-dir without --engram-project: a pin needs a project name."
            error "Usage: --engram-project NAME --engram-pin-dir <dir> [--engram-pin-dir <dir2> ...]"
            exit 2
        fi
    fi
}

# ----------------------------------------------------------------------------
# Preflight: platform + basic tools
# ----------------------------------------------------------------------------

preflight() {
    step "Preflight"

    case "$(uname -s)" in
        Linux) : ;;
        *)
            fatal "Unsupported OS: $(uname -s). This installer targets WSL2 Ubuntu or a modern Linux."
            ;;
    esac

    detect_wsl
    if [ "$IS_WSL" = "1" ]; then
        success "WSL detected (this is a WSL/Linux environment; all phases run inside WSL)"
    else
        warn "Not a WSL kernel — running on plain Linux; phases run unchanged"
    fi

    ARCH="$(arch_of)"
    if [ -z "$ARCH" ]; then
        fatal "Unsupported architecture: $(uname -m). Supported: amd64 (x86_64) and arm64."
    fi
    success "Architecture: ${ARCH}"

    if [ ! -d "$HOME" ] || [ ! -w "$HOME" ]; then
        fatal "\$HOME is not set or not writable. Cannot install."
    fi

    if ! command -v curl >/dev/null 2>&1; then
        fatal "curl is required but not installed. Install curl and run this script again."
    fi
    if ! command -v tar >/dev/null 2>&1; then
        fatal "tar is required but not installed. Install tar and run this script again."
    fi
    if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
        fatal "Neither sha256sum nor shasum is available; checksum verification is mandatory here."
    fi
    success "curl, tar and a SHA256 tool are available"
}

# ============================================================================
# Phase 1: apt prerequisites
#
# Installs git, curl, ca-certificates, jq, tar, unzip, xz-utils, gnupg via
# apt. sudo needs a password on a fresh Ubuntu and a non-TTY run can not
# answer it, so it is asked-first (with --yes to skip the ask) and, if it
# cannot run, the phase records the exact apt command for the user instead
# of going half-installed.
# ============================================================================

APT_MISSING=()

apt_missing_pkgs() {
    APT_MISSING=()
    local p
    for p in "${APT_PACKAGES[@]}"; do
        case "$p" in
            curl)          command -v curl  >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            ca-certificates) [ -d /etc/ssl/certs ] || APT_MISSING+=("$p") ;;
            git)           command -v git   >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            jq)            command -v jq    >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            tar)           command -v tar   >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            unzip)         command -v unzip >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            xz-utils)      command -v xz    >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
            gnupg)         command -v gpg   >/dev/null 2>&1 || APT_MISSING+=("$p") ;;
        esac
    done
}

apt_missing_human() {
    local p out=""
    for p in "${APT_MISSING[@]:-}"; do
        [ -n "$p" ] || continue
        out+="${p} "
    done
    printf '%s' "${out% }"
}

phase_apt_prerequisites() {
    step "Phase 1/13: apt prerequisites"
    apt_missing_pkgs
    if [ "${#APT_MISSING[@]}" -eq 0 ]; then
        phase_set apt-prerequisites ok "all packages present"
        success "All apt prerequisite packages already present"
        return 0
    fi

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would run: sudo apt-get update; sudo apt-get install -y ${APT_PACKAGES[*]}"
        phase_set apt-prerequisites ok "(dry-run) would install: $(apt_missing_human)"
        return 0
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
        phase_set apt-prerequisites fail "no apt; missing: $(apt_missing_human)"
        error "apt is not available on this system."
        error "Install these packages with your package manager: ${APT_PACKAGES[*]}"
        return 0
    fi

    if [ "$TTY_OK" = "1" ]; then
        if ! ask_continue "Install apt packages: $(apt_missing_human)?"; then
            phase_set apt-prerequisites skip "user declined the apt install"
            warn "apt install skipped by user; missing packages may break later phases"
            return 0
        fi
    fi

    sudo_probe
    if [ -z "$(apt_missing_human)" ]; then
        phase_set apt-prerequisites ok "all present (nothing to do)"
        return 0
    fi
    if ! run_priv apt-get update; then
        phase_set apt-prerequisites fail "sudo unavailable for apt-get update"
        error "sudo could not run non-interactively (sudo -n) and no TTY is readable."
        error "Run this yourself, then re-run this installer:"
        error "  sudo apt-get update && sudo apt-get install -y ${APT_PACKAGES[*]}"
        return 0
    fi
    if ! run_priv apt-get install -y "${APT_MISSING[@]}"; then
        phase_set apt-prerequisites fail "apt-get install failed"
        error "apt-get install failed. Run this yourself and re-run the installer:"
        error "  sudo apt-get install -y ${APT_PACKAGES[*]}"
        return 0
    fi
    phase_set apt-prerequisites ok "installed: $(apt_missing_human)"
    success "apt packages installed: $(apt_missing_human)"
    return 0
}

# ============================================================================
# Phase 2: Node.js runtime
#
# pi declares its requirement in the package's own metadata (engines.node);
# a fresh Ubuntu's apt node is far older. When the system node is too old
# (or missing) and sudo is not available, a USER-LOCAL nvm is installed
# (never root) and a current LTS is fetched without sudo. Fail closed with
# an actionable message when the requirement cannot be met.
# ============================================================================

node_engine_requirement() {
    # prints pi's declared node requirement (engines.node), preferring to
    # query the npm registry; falls back to the locally known constant.
    local req=""
    if command -v npm >/dev/null 2>&1; then
        req="$(npm view @earendil-works/pi-coding-agent engines.node 2>/dev/null | tr -d '"' | head -n 1 || true)"
    fi
    if [ -z "$req" ]; then
        req="$NODE_MIN_VERSION"
    fi
    printf '%s\n' "$req"
}

node_ok_for() {
    # node_ok_for <min> -> 0 when `node` exists and satisfies <min>
    local min="$1" cur
    command -v node >/dev/null 2>&1 || return 1
    cur="$(node --version 2>/dev/null | sed 's/^v//')"
    [ -n "$cur" ] || return 1
    version_ge "$cur" "$min"
}

node_version_side() {
    # prints the current node version (no 'v' prefix) when node is on PATH
    local v=""
    if command -v node >/dev/null 2>&1; then
        v="$(node --version 2>/dev/null || true)"
        v="${v#v}"
    fi
    printf '%s\n' "$v"
}

ensure_rc_node_block() {
    local marker block
    marker="# --- pi node (added by install-wsl.sh) ---"
    block="${marker}
export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\""
    ensure_rc_block "$HOME/.bashrc" "$marker" "$block"
    ensure_rc_block "$HOME/.profile" "$marker" "$block"
}

print_sudo_node_hint() {
    # Explicit escalation ladder when the requirement cannot be met.
    echo "Node.js (>= ${1}) is required (pi's engines requirement) and no suitable node is on PATH."
    echo "Options (least invasive first):"
    echo "  a) user-local nvm (recommended, no sudo):"
    echo "     curl -o- ${NVM_INSTALL_SH_URL} | bash && . \"\$HOME/.nvm/nvm.sh\" && nvm install --lts"
    echo "  b) system-wide with sudo:"
    echo "     curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
    echo "Then re-run this installer."
}

phase_node_runtime() {
    step "Phase 2/13: Node.js runtime"

    local req cur
    req="$(node_engine_requirement)"
    req_n="${req#>=}"
    req_n="${req_n#v}"
    cur="$(node_version_side)"
    if [ -n "$cur" ]; then
        if version_ge "$cur" "$req_n"; then
            success "node ${cur} satisfies pi's requirement (${req})"
            phase_set node-runtime ok "node ${cur} (pi requires ${req})"
            return 0
        fi
        warn "node ${cur} is present but pi requires ${req}."
    else
        info "node is not on PATH (pi requires ${req})."
    fi

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would install nvm ${NVM_VERSION} user-locally and node LTS via nvm"
        phase_set node-runtime ok "(dry-run) would install node via nvm"
        return 0
    fi

    # --- user-local nvm path (no sudo) ---
    if [ ! -s "${NVM_DIR}/nvm.sh" ]; then
        info "Installing nvm ${NVM_VERSION} into ${NVM_DIR} (user-local, no sudo)"
        if ! http_get "${NVM_INSTALL_SH_URL}" | bash >/dev/null 2>&1; then
            phase_set node-runtime fail "nvm install failed"
            print_sudo_node_hint "$req_n"
            return 0
        fi
    fi

    if [ -s "${NVM_DIR}/nvm.sh" ]; then
        # shellcheck disable=SC1091  # loaded dynamically; path set above
        . "${NVM_DIR}/nvm.sh"
        if ! nvm install --lts >/dev/null 2>&1; then
            phase_set node-runtime fail "nvm install --lts failed"
            print_sudo_node_hint "$req_n"
            return 0
        fi
        nvm use --lts >/dev/null 2>&1 || true
        nvm alias default lts >/dev/null 2>&1 || true
        ensure_rc_node_block
        local new
        new="$(node_version_side)"
        if [ -z "$new" ]; then
            phase_set node-runtime fail "node still missing after nvm"
            print_sudo_node_hint "$req_n"
            return 0
        fi
        if ! version_ge "$new" "$req_n"; then
            phase_set node-runtime fail "node ${new} does not satisfy pi's requirement ${req}"
            print_sudo_node_hint "$req_n"
            return 0
        fi
        success "node ${new} installed via nvm (user-local)"
        phase_set node-runtime ok "node ${new} via nvm"
        return 0
    fi

    phase_set node-runtime fail "node not available after nvm attempt"
    print_sudo_node_hint "$req_n"
    return 0
}

# ============================================================================
# Phase 3: agent runtime (pi + CodeGraph)
# ============================================================================

phase_agent_runtime() {
    step "Phase 3/13: agent runtime (pi + CodeGraph)"

    if ! command -v npm >/dev/null 2>&1; then
        phase_set agent-runtime fail "npm is not available (node-runtime phase failed?)"
        error "npm is required to install pi and codegraph. Fix the Node.js phase first."
        return 0
    fi

    local v
    v="$(tool_version pi --version)"
    if [ -n "$v" ] && [ "$MODE_UPDATE" = "1" ]; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would re-run: npm install -g ${PI_PACKAGE}"
        else
            info "pi ${v} already installed; --update refreshes it"
            if ! npm install -g "$PI_PACKAGE"; then
                phase_set agent-runtime fail "pi update (npm install -g) failed"
                return 0
            fi
        fi
        v="$(tool_version pi --version)"
        if [ -n "$v" ]; then
            phase_set agent-runtime ok "pi ${v}"
            success "pi ${v}"
        else
            phase_set agent-runtime fail "pi not found after update"
        fi
        return 0
    elif [ -n "$v" ]; then
        phase_set agent-runtime ok "pi ${v} (already installed)"
        success "pi already installed: ${v}"
    else
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: npm install -g ${PI_PACKAGE}"
            phase_set agent-runtime ok "(dry-run) would install pi"
        else
            info "Installing pi (${PI_PACKAGE}) via npm global"
            if ! npm install -g "$PI_PACKAGE"; then
                phase_set agent-runtime fail "npm install -g pi failed"
                return 0
            fi
            v="$(tool_version pi --version)"
            if [ -z "$v" ]; then
                phase_set agent-runtime fail "pi not found after npm install"
                return 0
            fi
            phase_set agent-runtime ok "pi ${v}"
            success "pi ${v}"
        fi
    fi

    # CodeGraph — sibling of pi in the npm global store.
    v="$(tool_version codegraph --version)"
    if [ -n "$v" ]; then
        if [ "$MODE_UPDATE" = "1" ] && [ "$MODE_DRYRUN" = "0" ]; then
            info "codegraph ${v} present; --update refreshes it"
            if ! npm install -g "$CODEGRAPH_PACKAGE"; then
                warn "codegraph update failed; the MCP 'codegraph' server may not start"
                return 0
            fi
            v="$(tool_version codegraph --version)"
            success "codegraph ${v}"
        else
            success "codegraph already installed: ${v}"
        fi
    else
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: npm install -g ${CODEGRAPH_PACKAGE}"
        else
            info "Installing CodeGraph (${CODEGRAPH_PACKAGE})"
            if npm install -g "$CODEGRAPH_PACKAGE"; then
                v="$(tool_version codegraph --version)"
                success "codegraph ${v}"
            else
                warn "codegraph install failed; the MCP 'codegraph' server will not start"
            fi
        fi
    fi
    return 0
}

# ============================================================================
# Phase 4: engram binary (linux) — fail-closed, checksum-verified
# ============================================================================

# release_latest_tag <owner/repo> — latest release tag via the GitHub API.
# Prefers jq; falls back to a sed parse of the JSON (no jq dependency).
release_latest_tag() {
    local repo="$1" body tag=""
    body="$(http_get "https://api.github.com/repos/${repo}/releases/latest")" || return 1
    if [ -z "$body" ]; then
        return 1
    fi
    if command -v jq >/dev/null 2>&1; then
        tag="$(printf '%s' "$body" | jq -r '.tag_name // empty' 2>/dev/null)"
    fi
    if [ -z "$tag" ]; then
        tag="$(printf '%s\n' "$body" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    fi
    [ -n "$tag" ] || return 1
    printf '%s\n' "$tag"
}

phase_engram() {
    step "Phase 4/13: engram binary"
    if [ "$MODE_DRYRUN" != "1" ]; then
        mkdir -p "$PI_BIN_DIR"
    fi

    if [ -x "$PI_BIN_ENGRAM" ] && [ "$MODE_UPDATE" != "1" ]; then
        local v
        v="$("$PI_BIN_ENGRAM" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
        if [ -n "$v" ]; then
            phase_set engram ok "engram ${v} (already installed)"
            success "engram already installed: ${v} (${PI_BIN_ENGRAM})"
            ensure_engram_rc
            return 0
        fi
        warn "Existing engram binary does not respond to 'version'; reinstalling."
    elif [ -x "$PI_BIN_ENGRAM" ] && [ "$MODE_UPDATE" = "1" ]; then
        local v
        v="$("$PI_BIN_ENGRAM" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
        info "engram ${v:-present} installed; --update re-downloads the latest release"
    fi

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would download the latest engram linux_${ARCH} tarball and verify its SHA256"
        phase_set engram ok "(dry-run) would download+verify engram linux_${ARCH}"
        return 0
    fi

    local tag asset url cks_url tmpdir
    tag="$(release_latest_tag "$ENGRAM_REPO")" || {
        phase_set engram fail "could not read the latest release tag"
        return 0
    }
    tag="${tag#v}"
    asset="engram_${tag}_linux_${ARCH}.tar.gz"
    url="https://github.com/${ENGRAM_REPO}/releases/download/v${tag}/${asset}"
    cks_url="https://github.com/${ENGRAM_REPO}/releases/download/v${tag}/checksums.txt"

    tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/install-wsl-engram.XXXXXX")"

    info "Downloading ${asset}"
    if ! http_fetch "${url}" "${tmpdir}/${asset}"; then
        phase_set engram fail "download failed: ${ENGRAM_RELEASES_URL}"
        error "Could not download ${url}"
        return 0
    fi

    # Fail closed: NO checksums.txt -> NO engram. No fallback.
    info "Downloading checksums.txt"
    if ! http_fetch "${cks_url}" "${tmpdir}/checksums.txt"; then
        phase_set engram fail "checksums.txt unavailable"
        error "Could not download ${cks_url}"
        error "Refusing to install engram without checksum verification."
        return 0
    fi

    if ! verify_against_checksums "${tmpdir}/${asset}" "${tmpdir}/checksums.txt" "$asset"; then
        phase_set engram fail "SHA256 verification failed"
        return 0
    fi
    success "SHA256 verified"

    if ! tar -xzf "${tmpdir}/${asset}" -C "$tmpdir"; then
        phase_set engram fail "tar extract failed"
        return 0
    fi
    if [ ! -f "${tmpdir}/engram" ]; then
        phase_set engram fail "archive has no engram binary"
        return 0
    fi

    if ! mv "${tmpdir}/engram" "${PI_BIN_ENGRAM}"; then
        phase_set engram fail "could not place the binary in ${PI_BIN_DIR}"
        return 0
    fi
    chmod 755 "$PI_BIN_ENGRAM"

    local v2
    v2="$("$PI_BIN_ENGRAM" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
    if [ -z "$v2" ]; then
        phase_set engram fail "binary does not respond to version"
        return 0
    fi
    success "engram ${v2} installed at ${PI_BIN_ENGRAM}"

    ensure_engram_rc
    phase_set engram ok "engram ${v2} (checksum verified)"
    return 0
}

# ============================================================================
# Phase 5: Gentle AI stack — upstream installer + `gentle-ai install --agent pi`
#
# gentle-ai is installed by ITS OWN upstream installer (it verifies its own
# downloads and checksums fail-closed). This phase never reimplements that.
# After the CLI exists, the pi side of the stack comes from
# `gentle-ai install --agent pi --scope global`, which brings gentle-pi,
# gentle-shell and the gentle-ai agent overlays.
# ============================================================================


fetch_gentle_ai_installer() {
    # Prints the path of a downloaded installer script (owned by this phase's
    # temp space; cleaned by the trap). Fails closed: no file, no run.
    local f
    f="${TMPDIR:-/tmp}/install-wsl-gentle-ai.$$-${RANDOM}.sh"
    if ! http_fetch "$GENTLE_AI_INSTALL_URL" "$f"; then
        error "Could not download ${GENTLE_AI_INSTALL_URL}"
        rm -f "$f"
        return 1
    fi
    if [ ! -s "$f" ]; then
        error "Downloaded installer is empty: ${GENTLE_AI_INSTALL_URL}"
        rm -f "$f"
        return 1
    fi
    printf '%s\n' "$f"
}

run_gentle_ai_installer() {
    local script
    script="$(fetch_gentle_ai_installer)" || return 1
    info "Running the official gentle-ai installer (it verifies its own downloads)"
    # --method binary: no Go toolchain needed on a fresh machine; the binary
    # path is the upstream default when Homebrew is absent.
    if ! bash "$script" --method binary --channel stable; then
        error "The gentle-ai installer failed (exit non-zero)."
        return 1
    fi
    return 0
}

ensure_local_bin_path() {
    # Tool installers often target ~/.local/bin; make sure the current session
    # and the rc files can find it.
    local d="$HOME/.local/bin"
    if [ "$MODE_DRYRUN" != "1" ]; then
        [ -d "$d" ] || mkdir -p "$d"
    fi
    ensure_rc_path_dir "$d"
}

phase_gentle_stack() {
    step "Phase 5/13: Gentle AI stack"

    ensure_local_bin_path

    if command -v gentle-ai >/dev/null 2>&1; then
        local v
        v="$(gentle-ai version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
        if [ "$MODE_UPDATE" = "1" ]; then
            info "gentle-ai ${v:-unknown} present; --update re-runs its installer"
            if [ "$MODE_DRYRUN" = "0" ]; then
                if ! run_gentle_ai_installer; then
                    phase_set gentle-stack fail "gentle-ai installer failed on update"
                    return 0
                fi
            else
                info "(dry-run) would re-run the gentle-ai installer"
            fi
        else
            success "gentle-ai already installed: ${v:-unknown}"
        fi
    else
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: bash <(curl ${GENTLE_AI_INSTALL_URL}) --method binary --channel stable"
        else
            if ! run_gentle_ai_installer; then
                phase_set gentle-stack fail "gentle-ai installer failed"
                error "You can run it yourself and then re-run this script:"
                error "  curl -fsSL ${GENTLE_AI_INSTALL_URL} | bash -s -- --method binary --channel stable"
                return 0
            fi
        fi
    fi

    # The installer may have placed the binary in ~/.local/bin just now.
    hash -r 2>/dev/null || true
    if ! command -v gentle-ai >/dev/null 2>&1; then
        phase_set gentle-stack fail "gentle-ai not on PATH after installer"
        error "gentle-ai is not on PATH. Open a new shell (or add ~/.local/bin to PATH) and re-run."
        return 0
    fi

    local v2
    v2="$(gentle-ai version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
    success "gentle-ai ${v2:-unknown}"

    # --- pi stack from gentle-ai (delegated; upstream owns it) ---
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would run: gentle-ai install --agent pi --scope global --channel stable"
        phase_set gentle-stack ok "(dry-run) gentle-ai install --agent pi"
        return 0
    fi

    info "Installing the pi stack: gentle-ai install --agent pi --scope global --channel stable"
    if ! gentle-ai install --agent pi --scope global --channel stable; then
        phase_set gentle-stack fail "gentle-ai install --agent pi failed"
        error "Run it manually in an interactive terminal (it may prompt), then re-run this installer:"
        error "  gentle-ai install --agent pi --scope global --channel stable"
        return 0
    fi
    success "gentle-ai pi stack installed"
    phase_set gentle-stack ok "gentle-ai ${v2:-unknown} + pi stack"
    return 0
}

# ============================================================================
# Phase 6: pi packages — settings.json idempotent by specifier (D3)
#
# `pi install <pkg>` is the only supported writer here: it owns
# settings.json, and this script never edits that file directly. But a bare
# `pi install npm:<pkg>` happily appends a second entry when the same
# package is already declared in another form (version pin, or the
# node_modules path `gentle-ai install` leaves behind), which is exactly how
# machine A grew from 7 to 9 package entries. The phase therefore reads the
# existing packages array first and skips any request that is equivalent to
# an entry already there: same npm name with or without @version, and the
# same package expressed as a filesystem path. Path equivalence is
# name-based (…/node_modules/<name> <=> npm:<name>): a path outside a
# node_modules directory is left to pi, never matched by a builtin.
# ============================================================================

# settings_reads_ok — classifies the settings file for the packages phase.
# Sets SETTINGS_STATE to: missing (fresh machine), unreadable-or-invalid
# (exists but jq cannot parse it), notarray (packages exists but is not an
# array), or ok. Only "ok" enables the equivalence gate; anything else must
# fall back to plain `pi install`, never look like "empty".
settings_reads_ok() {
    [ -f "$PI_SETTINGS_FILE" ] || { SETTINGS_STATE="missing"; return 0; }
    if ! jq -r '.' "$PI_SETTINGS_FILE" >/dev/null 2>&1; then
        SETTINGS_STATE="unreadable-or-invalid"
        return 0
    fi
    local pkgs
    pkgs="$(jq -r 'if has("packages") and (.packages | type != "array") then "notarray" else "array" end' "$PI_SETTINGS_FILE" 2>/dev/null || true)"
    if [ "$pkgs" = "notarray" ]; then
        SETTINGS_STATE="notarray"
        return 0
    fi
    SETTINGS_STATE="ok"
    return 0
}

# settings_packages_list — prints settings.json's packages entries one per
# line (raw strings; non-string entries are shown as JSON fragments).
settings_packages_list() {
    jq -r '.packages // [] | .[] | if type == "string" then . else tojson end' "$PI_SETTINGS_FILE" 2>/dev/null
}

# pkg_identifier <entry> — the equivalence key for a packages entry.
#   npm:<name> / npm:<name>@version -> "npm:<name>"  (scoped names safe:
#   version is stripped only after org/name)
#   <anything>/node_modules/<name>  -> "npm:<name>"  (a node_modules path
#   names the same package as npm:<name>)
#   anything else (bare-word, git:, https:, builtin:, non-node_modules path)
#   has no key -> return 1; only the pi-builtins are recognized separately by
#   pkg_is_builtin_local_name.
pkg_identifier() {
    local entry="$1" name="" org="" rest=""
    case "$entry" in
        npm:*)
            name="${entry#npm:}"
            case "$name" in
                @*)
                    # scoped: @org/name(@version)? — the version strip must
                    # not eat the org's leading @.
                    org="@${name#@}"
                    org="${org%%/*}"
                    rest="${name#"$org"/}"
                    rest="${rest%%@*}"
                    [ -n "$rest" ] || return 1
                    name="${org}/${rest}"
                    ;;
                *)
                    name="${name%%@*}"
                    ;;
            esac
            [ -n "$name" ] || return 1
            printf 'npm:%s\n' "$name"
            ;;
        */node_modules/*)
            name="${entry##*/node_modules/}"
            case "$name" in
                @*)
                    # scoped remainder: @org/pkg(/subpath)?
                    org="@${name#@}"
                    org="${org%%/*}"
                    rest="${name#"$org"/}"
                    rest="${rest%%/*}"
                    [ -n "$rest" ] || return 1
                    name="${org}/${rest}"
                    ;;
                *)
                    name="${name%%/*}"
                    ;;
            esac
            [ -n "$name" ] || return 1
            printf 'npm:%s\n' "$name"
            ;;
        *)
            return 1
            ;;
    esac
}

# pkg_is_builtin_local <entry> — true when <entry> names a pi builtin with
# the "builtin:" scheme and the installed pi actually ships it. (Builtin
# requests stay valid: they are just never matched against settings.json.)
pkg_is_builtin_local() {
    local entry="$1" name
    case "$entry" in
        builtin:*) ;;
        *) return 1 ;;
    esac
    command -v pi >/dev/null 2>&1 || return 1
    name="${entry#builtin:}"
    name="${name%%@*}"
    [ -n "$name" ] || return 1
    pi __complete_packages 2>/dev/null | grep -qx "$name"
}

# pkg_equivalent_exists <request> <already-installed pi packages: one per line>
# Prints the first equivalent already-present entry (npm name with/without
# version, or the same package as a node_modules path); nothing if none.
pkg_equivalent_exists() {
    local want="$1" entry key want_key
    want_key="$(pkg_identifier "$want")" || return 1
    while IFS= read -r entry; do
        [ -n "$entry" ] || continue
        key="$(pkg_identifier "$entry")" || continue
        if [ "$key" = "$want_key" ]; then
            printf '%s\n' "$entry"
            return 0
        fi
    done
    return 1
}

# phase_pi_packages — installs the ecosystem's pi packages via `pi install`,
# skipping any package whose equivalent entry settings.json already carries.
# settings.json is only ever READ here: if it cannot be read or parsed, the
# phase says so and falls back to the previous (ungated) behaviour instead
# of corrupting the file.
phase_pi_packages() {
    step "Phase 6/13: pi packages (idempotent by specifier)"

    if ! command -v pi >/dev/null 2>&1; then
        phase_set pi-packages fail "pi is not available (agent-runtime phase failed?)"
        error "pi is required to install the pi packages; fix the agent-runtime phase and re-run."
        return 0
    fi

    SETTINGS_STATE=""
    settings_reads_ok
    local entries="" skips=0 installs=0 failures=0 pkg match
    if [ "$SETTINGS_STATE" = "ok" ]; then
        entries="$(settings_packages_list)"
    elif [ "$SETTINGS_STATE" = "missing" ]; then
        info "${PI_SETTINGS_FILE} does not exist yet; every package will be installed fresh"
    else
        warn "Cannot read or parse ${PI_SETTINGS_FILE}; falling back to plain 'pi install' without the duplicate guard (the file is never modified by this script)."
    fi

    if [ "$SETTINGS_STATE" = "ok" ] && [ -n "$entries" ]; then
        info "Existing pi packages: $(printf '%s' "$entries" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
    fi

    for pkg in "${PI_PACKAGES[@]}"; do
        match=""
        if [ "$SETTINGS_STATE" = "ok" ] && [ -n "$entries" ]; then
            match="$(printf '%s\n' "$entries" | pkg_equivalent_exists "$pkg")" || match=""
        fi
        if [ -n "$match" ]; then
            skips=$((skips + 1))
            success "pi package ${pkg}: already present as ${match} (skip)"
            continue
        fi
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: pi install ${pkg}"
            installs=$((installs + 1))
            continue
        fi
        info "Installing pi package: pi install ${pkg}"
        if pi install "$pkg"; then
            installs=$((installs + 1))
            success "pi package installed: ${pkg}"
        else
            failures=$((failures + 1))
            warn "pi install ${pkg} failed; continuing with the rest"
        fi
    done

    if [ "$failures" -gt 0 ]; then
        phase_set pi-packages fail "installed=${installs} skipped=${skips} failed=${failures}"
        return 0
    fi
    phase_set pi-packages ok "installed=${installs} skipped=${skips}"
    return 0
}

# ============================================================================
# Phase 10: Tailscale — network reachability (shared by Engram Cloud and
# the Moshi phone path)
#
# On a WSL2 host the IP is NAT'd and changes on every reboot, so a stable
# tailnet identity is the only workable way in for phone access. SSH
# transport stays the normal `openssh-server` (supported); `--tailscale-ssh`
# switches to `tailscale up --ssh`, which is experimental here because
# Moshi's Easy Pair pairs against a normal sshd and Tailscale SSH breaks
# mosh (tailscale/tailscale #4919, mosh fixed by PR #5057) and claims port
# 22 on the tailnet address.
#
# The Engram Cloud piece — enabling HTTPS certs in the admin console and
# `tailscale serve` for a server that does not exist on this machine yet —
# is NEVER executed here; it is printed as manual next steps.
# ============================================================================

tailscale_installed() {
    command -v tailscale >/dev/null 2>&1
}

run_tailscale_installer() {
    # Mirror how the gentle-ai and herdr phases do it: download to a file,
    # none of that curl-to-shell piping ever happening.
    local script
    script="${TMPDIR:-/tmp}/install-wsl-tailscale.$$-${RANDOM}.sh"
    info "Downloading the official tailscale installer (${TAILSCALE_INSTALL_URL})"
    if ! http_fetch "$TAILSCALE_INSTALL_URL" "$script"; then
        error "Could not download ${TAILSCALE_INSTALL_URL}"
        return 1
    fi
    if [ ! -s "$script" ]; then
        error "Downloaded tailscale installer is empty"
        return 1
    fi
    info "Running the official tailscale installer (it verifies its own downloads; needs sudo)"
    # shellcheck disable=SC2094 # intentionally not: curl | sh
    if ! sh "$script"; then
        error "The tailscale installer failed (exit non-zero)."
        return 1
    fi
    return 0
}

runs_tailscale_up() {
    # Interactive on purpose: `sudo tailscale up` opens a browser auth flow
    # that blocks until the user completes it in the browser. Only called
    # when /dev/tty is readable, so a curl|bash run never hangs silently.
    if [ ! -r /dev/tty ]; then
        return 1
    fi
    info "Starting interactive authentication: ${SUDO} tailscale up $*"
    info "Complete the flow in the browser that opens; this waits until it finishes."
    if ! $SUDO tailscale up "$@"; then
        return 1
    fi
    return 0
}

manual_tailscale_up_next() {
    echo "tailscale authentication is interactive ('sudo tailscale up' opens a browser flow)."
    echo "No TTY is readable in this session, so it was NOT started for you."
    echo "Run it by hand inside WSL, then re-run this installer to verify:"
    echo "  sudo tailscale up"
    echo "It is never started here automatically: that would hang on the browser flow."
    echo "Alternative from Windows PowerShell (outside WSL):"
    echo "  ${SWITCH_TO_ROOT_HINT} -- tailscale up"
    echo "Then verify: tailscale status && tailscale ip -4"
}

phase_tailscale() {
    if [ "$OPT_SKIP_TAILSCALE" = "1" ]; then
        phase_set tailscale skip "--skip-tailscale given"
        return 0
    fi
    step "Phase 10/13: tailscale (network reachability)"

    if [ "$OPT_TAILSCALE_SSH" = "1" ]; then
        warn "--tailscale-ssh is EXPERIMENTAL: tailscale up --ssh"
        echo "  Easy Pair pairs against a normal sshd; tailscale SSH claims port 22 on"
        echo "  the tailnet address and breaks mosh (tailscale/tailscale #4919, fixed for"
        echo "  mosh only by PR #5057). The default (normal openssh-server + tailscale as"
        echo "  the network) is the supported path."
    fi

    if ! tailscale_installed; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would download ${TAILSCALE_INSTALL_URL} to a temp file and run it with sh (needs sudo)"
        else
            if ! run_tailscale_installer; then
                phase_set tailscale fail "tailscale installer failed (download or installer itself)"
                error "Fix the download problem above, then re-run this installer (idempotent)."
                echo "Manual alternative (needs sudo, interactive):"
                echo "  curl -fsSL ${TAILSCALE_INSTALL_URL} -o /tmp/tailscale-install.sh && sh /tmp/tailscale-install.sh"
                echo "After that, re-run this installer; it verifies the node and prints the addresses."
                return 0
            fi
            hash -r 2>/dev/null || true
            if ! tailscale_installed; then
                phase_set tailscale fail "tailscale not on PATH after its installer"
                error "The installer exited zero but 'tailscale' is still not on PATH."
                error "Open a new shell (or add /usr/bin and /usr/local/bin to PATH) and re-run this installer."
                return 0
            fi
        fi
    else
        local tv
        tv="$(tailscale --version 2>/dev/null | head -n 1)"
        success "tailscale already installed: ${tv:-unknown}"
    fi

    # --- authenticated? ---
    # tailscale status already covers it (it fails without a tailnet
    # identity); sudo netcheck would additionally probe UDP for DERP
    # latency, which is not an authentication question.
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would now check 'tailscale status' and, when unauthenticated, start: sudo tailscale up"
        info "(dry-run) authentication is interactive (browser flow); under --dry-run it stays a preview"
        phase_set tailscale ok "(dry-run) tailscale installer/up previewed"
        return 0
    fi

    if tailscale status >/dev/null 2>&1; then
        success "tailscale node is authenticated"
    elif [ "$OPT_TAILSCALE_SSH" = "1" ]; then
        # Interactive on purpose; the --ssh flag only matters when a node is
        # first authenticated (or when enabling the feature later).
        if ! runs_tailscale_up --ssh; then
            if [ -r /dev/tty ]; then
                phase_set tailscale fail "tailscale up --ssh failed (see the error above)"
                error "Re-run this installer after fixing it (idempotent)."
            else
                manual_tailscale_up_next
                phase_set tailscale fail "tailscale needs interactive authentication (no TTY readable)"
            fi
            return 0
        fi
        info "tailscale up --ssh completed"
    else
        if ! runs_tailscale_up; then
            if [ -r /dev/tty ]; then
                phase_set tailscale fail "tailscale up failed (see the error above)"
                error "Re-run this installer after fixing it (idempotent)."
            else
                manual_tailscale_up_next
                phase_set tailscale fail "tailscale needs interactive authentication (no TTY readable)"
            fi
            return 0
        fi
        info "tailscale up completed"
    fi

    # --- verified addresses for phone + runbook ---
    if ! tailscale status >/dev/null 2>&1; then
        phase_set tailscale fail "tailscale is installed but not authenticated"
        error "tailscale status failed. Authenticate by hand, then re-run this installer:"
        echo "  sudo tailscale up"
        return 0
    fi
    success "tailscale: node is authenticated"

    local ts_ip ts_dns
    ts_ip="$(tailscale ip -4 2>/dev/null | head -n 1)"
    # status column 2 is the MagicDNS name when MagicDNS is enabled for the
    # tailnet; when it is disabled only the bare IP appears there. Accept
    # only a name that actually looks like one; never print a half-verified
    # guess.
    ts_dns="$(tailscale status 2>/dev/null | head -n 1 | awk '{print $2}')"
    case "$ts_dns" in
        *.ts.net) : ;;
        *) ts_dns="" ;;
    esac
    if [ -n "$ts_ip" ]; then
        success "tailscale IPv4: ${ts_ip}"
    else
        warn "tailscale ip -4 returned nothing; the node may not be able to reach the tailnet"
    fi
    if [ -n "$ts_dns" ]; then
        success "MagicDNS name: ${ts_dns}"
        echo "  ssh target for the phone: <user>@${ts_dns}"
    else
        info "MagicDNS name not shown; run 'tailscale status' — column 2 is the MagicDNS name (when MagicDNS is enabled)"
    fi

    # --- never automated here: printed as documented manual steps ---
    echo ""
    echo "Manual next steps (never run automatically here):"
    echo "  1) HTTPS certificates: in the tailscale admin console enable MagicDNS +"
    echo "     'Enable HTTPS'. Engram Cloud clients require HTTPS; this is a console"
    echo "     step, not an automated one."
    echo "  2) when an Engram Cloud server runs on THIS machine on 127.0.0.1:18080,"
    echo "     expose it on the tailnet (do NOT run it now — no cloud server here yet):"
    echo "       sudo tailscale serve --bg --https=443 http://127.0.0.1:18080"
    echo "  3) from the phone, verify reachability:"
    echo "       tailscale ping <this-host>"
    echo ""
    phase_set tailscale ok "tailscale ${tv:-installed}, authenticated"
    return 0
}

HERDR_TMP_SH=""

phase_herdr() {
    if [ "$OPT_SKIP_HERDR" = "1" ]; then
        phase_set herdr skip "--skip-herdr given"
        return 0
    fi
    step "Phase 7/13: herdr"

    if command -v herdr >/dev/null 2>&1; then
        local v
        v="$(herdr --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
        if [ "$MODE_UPDATE" = "1" ] && [ "$MODE_DRYRUN" = "0" ]; then
            info "herdr ${v:-unknown} present; --update re-runs its installer"
            if ! phase_run_herdr_installer; then
                phase_set herdr fail "herdr update installer failed"
                return 0
            fi
        elif [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would re-run the herdr installer (update)"
            phase_set herdr ok "(dry-run) herdr update previewed"
        else
            success "herdr already installed: ${v:-unknown}"
            phase_set herdr ok "herdr ${v} (already installed)"
        fi
    else
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run the herdr installer: ${HERDR_INSTALL_URL}"
        else
            if ! phase_run_herdr_installer; then
                phase_set herdr fail "herdr installer failed"
                return 0
            fi
        fi
    fi

    hash -r 2>/dev/null || true
    if ! command -v herdr >/dev/null 2>&1; then
        phase_set herdr fail "herdr not on PATH after installer"
        error "herdr did not land on PATH (expected ~/.local/bin/herdr)."
        error "Open a new shell and re-run this installer, or install manually: ${HERDR_INSTALL_URL}"
        return 0
    fi

    # herdr's pi integration: one extension file under ~/.pi/agent/extensions.
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would run: herdr integration install pi"
        phase_set herdr ok "(dry-run) cli + pi integration"
        return 0
    fi
    if ! herdr integration install pi; then
        phase_set herdr fail "herdr integration install pi failed"
        error "Run it manually later: herdr integration install pi"
        return 0
    fi
    success "herdr pi integration installed"
    phase_set herdr ok "herdr $(herdr --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
    return 0
}

phase_run_herdr_installer() {
    HERDR_TMP_SH="${TMPDIR:-/tmp}/install-wsl-herdr.$$-${RANDOM}.sh"
    if ! http_fetch "$HERDR_INSTALL_URL" "$HERDR_TMP_SH"; then
        error "Could not download ${HERDR_INSTALL_URL}"
        return 1
    fi
    if [ ! -s "$HERDR_TMP_SH" ]; then
        error "Downloaded herdr installer is empty"
        return 1
    fi
    info "Running the official herdr installer (POSIX sh; verifies its own SHA256)"
    if ! sh "$HERDR_TMP_SH"; then
        error "The herdr installer failed (exit non-zero)."
        return 1
    fi
    return 0
}

# ============================================================================
# Phase 8: skills — three independent sources, reported separately
#
#   A) kkapsca-skills (this repository) via scripts/install.sh
#   B) firebase/agent-skills          via `npx skills add`
#   C) supabase/agent-skills          via `npx skills add`
#
# gentle-ai's `install --agent pi` phase may bring additional skills; the
# per-source counts below make a partial install visible either way.
# ============================================================================

SKILLS_COUNT_REPO=0
SKILLS_COUNT_FIREBASE=0
SKILLS_COUNT_SUPABASE=0

skills_dir() {
    printf '%s\n' "$HOME/.agents/skills"
}

count_skills_dirs() {
    # Counts skill containers that carry a SKILL.md (what pi actually reads).
    local dir="$1" n=0 d
    [ -d "$dir" ] || { printf '0\n'; return 0; }
    for d in "$dir"/*; do
        [ -d "$d" ] || continue
        [ -f "$d/SKILL.md" ] || continue
        n=$((n + 1))
    done
    printf '%s\n' "$n"
}

phase_skills_source_repo() {
    # Source A: this repository's own installer (already handles conflicts,
    # caching and per-target reporting). Delegation keeps a single code path.
    if [ "$OPT_SKIP_SKILLS" = "1" ]; then
        phase_set repo-skills skip "--skip-skills given"
        return 0
    fi
    step "Phase 8/13: skills — source A: ${GITHUB_OWNER}/${GITHUB_REPO}"

    local cache="${XDG_DATA_HOME:-$HOME/.local/share}/${GITHUB_REPO}"
    local script="${cache}/scripts/install.sh"
    local need_fetch=1

    if [ -f "$script" ]; then
        if [ "$MODE_UPDATE" = "1" ] || [ "$ARG_REF" != "$(cat "${cache}/.repo-ref" 2>/dev/null || true)" ]; then
            need_fetch=1
        else
            need_fetch=0
        fi
    fi

    if [ "$need_fetch" = "1" ]; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would fetch ${REPO_URL} tarball (ref: ${ARG_REF}) into ${cache}"
        else
            local tgz try_ref ok=1
            tgz="${TMPDIR:-/tmp}/kkapsca-$$.tar.gz"
            for try_ref in "refs/heads/${ARG_REF}" "refs/tags/${ARG_REF}"; do
                if http_fetch "${REPO_URL}/archive/${try_ref}.tar.gz" "$tgz"; then ok=0; break; fi
            done
            if [ "$ok" != "0" ]; then
                phase_set repo-skills fail "could not fetch ref ${ARG_REF} (branch or tag)"
                error "Check the ref name and your network; try --ref main."
                return 0
            fi
            if ! tar -tzf "$tgz" >/dev/null 2>&1; then
                phase_set repo-skills fail "downloaded tarball is corrupt"
                return 0
            fi
            rm -rf "$cache"
            mkdir -p "$(dirname "$cache")" "${TMPDIR:-/tmp}/extract.$$"
            if ! tar -xzf "$tgz" -C "${TMPDIR:-/tmp}/extract.$$"; then
                phase_set repo-skills fail "tar extraction failed"
                return 0
            fi
            local top
            top="$(find "${TMPDIR:-/tmp}/extract.$$" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
            if [ -z "$top" ]; then
                phase_set repo-skills fail "archive layout unexpected"
                return 0
            fi
            mv "$top" "$cache"
            printf '%s\n' "$ARG_REF" > "${cache}/.repo-ref"
            rm -f "$tgz"
            rm -rf "${TMPDIR:-/tmp}/extract.$$"
        fi
    fi

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would run: bash ${script} --agent agents --ref ${ARG_REF}"
        phase_set repo-skills ok "(dry-run) would install kkapsca-skills"
        return 0
    fi

    if [ ! -f "$script" ]; then
        phase_set repo-skills fail "cached installer missing: ${script}"
        return 0
    fi
    info "Running this repository's installer for the pi/agents skills dir"
    if bash "$script" --agent agents; then
        SKILLS_COUNT_REPO="$(count_skills_dirs "$(skills_dir)")"
        phase_set repo-skills ok "${SKILLS_COUNT_REPO} skills"
        success "kkapsca-skills installed (${SKILLS_COUNT_REPO} skills in ~/.agents/skills)"
    else
        phase_set repo-skills fail "scripts/install.sh failed"
    fi
    return 0
}

phase_skills_source_npx() {
    # Sources B and C: the `skills` CLI (installed through npx on demand).
    if [ "$OPT_SKIP_EXTERNAL_SKILLS" = "1" ]; then
        phase_set framework-skills skip "--skip-external-skills given"
        return 0
    fi
    step "Phase 9/13: skills — sources B/C: firebase/agent-skills, supabase/agent-skills"

    if ! command -v npx >/dev/null 2>&1; then
        phase_set framework-skills fail "npx not available (node missing?)"
        return 0
    fi

    local repo
    for repo in "${SKILL_REPOS[@]}"; do
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: npx -y skills add ${repo} --yes"
            continue
        fi
        info "Adding ${repo} via the skills CLI"
        if npx -y skills add "${repo}" --yes; then
            success "skills from ${repo} installed"
        else
            warn "skills add ${repo} failed (continuing with the next source)"
        fi
    done

    # Report per-source counts by probing the lock file the skills CLI keeps.
    local lock="$HOME/.agents/.skill-lock.json"
    if [ -f "$lock" ]; then
        local fb sb
        fb="$(grep -c 'firebase/agent-skills' "$lock" 2>/dev/null || true)"
        sb="$(grep -c 'supabase/agent-skills' "$lock" 2>/dev/null || true)"
        if [ "${fb:-0}" -gt 0 ] 2>/dev/null; then SKILLS_COUNT_FIREBASE="$fb"; fi
        if [ "${sb:-0}" -gt 0 ] 2>/dev/null; then SKILLS_COUNT_SUPABASE="$sb"; fi
        info "skills lock: firebase=${SKILLS_COUNT_FIREBASE} supabase=${SKILLS_COUNT_SUPABASE}"
    fi

    local total
    total="$(count_skills_dirs "$(skills_dir)")"
    if [ "${total:-0}" -eq 0 ]; then
        phase_set framework-skills fail "no SKILL.md found under ~/.agents/skills"
        return 0
    fi
    phase_set framework-skills ok "firebase=${SKILLS_COUNT_FIREBASE} supabase=${SKILLS_COUNT_SUPABASE} total=${total}"
    success "external skills present (total ${total})"
    return 0
}

# ============================================================================
# Phase 11: Moshi — phone access (mosh/tmux/sshd + moshi-hook)
#
# The phone reaches this host over mosh/ssh (transport) and reads agent
# hooks through the moshi-hook daemon (127.0.0.1:24543, itself reached
# through the SSH session). Network reachability comes from the tailscale
# phase (a WSL2 host has no stable IP otherwise).
#
# Three Moshi steps need the phone and are NEVER executed by this script:
# Easy Pair, token pairing, and the agent hook install. They are detected
# and, when not done, printed as the exact commands to run. An unpaired
# host is a valid intermediate state, so it is reported as a skip, not a
# failure.
# ============================================================================

MOSHI_HOOK_BIN="${HOME}/.local/bin/moshi-hook"
MOSHI_UNIT_FILE="${HOME}/.config/systemd/user/moshi-hook.service"

# have_systemd — true only when a systemd USER session is actually usable:
# the systemd runtime dir present AND systemctl on PATH. Under plain WSL2
# this is false, and the moshi phase documents the shell-startup alternative
# instead of inventing autostart that cannot exist.
have_systemd() {
    [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1
}

moshi_ssh_skip_note() {
    echo "  openssh-server skipped: --tailscale-ssh was given (EXPERIMENTAL)."
    echo "  The tailnet address must carry an sshd: login goes over 'tailscale up --ssh'"
    echo "  there, not over a normal sshd. mosh does NOT work over Tailscale SSH"
    echo "  (tailscale/tailscale #4919; mosh fixed by PR #5057)."
}

phase_moshi() {
    if [ "$OPT_SKIP_MOSHI" = "1" ]; then
        phase_set moshi skip "--skip-moshi given"
        return 0
    fi
    step "Phase 11/13: moshi (phone access)"

    # --- packages: mosh, tmux, openssh-server (skipped under --tailscale-ssh) ---
    local missing=() p
    for p in mosh tmux; do
        command -v "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    if [ "$OPT_TAILSCALE_SSH" != "1" ]; then
        if ! dpkg -s openssh-server >/dev/null 2>&1; then
            missing+=("openssh-server")
        fi
    fi

    if [ "${#missing[@]}" -gt 0 ]; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: ${SUDO:-"sudo"} apt-get update && ${SUDO:-"sudo"} apt-get install -y ${missing[*]}"
            if [ "$OPT_TAILSCALE_SSH" = "1" ]; then
                info "(dry-run) openssh-server would be skipped (--tailscale-ssh: tailscale --ssh is the sshd)"
            fi
            phase_set moshi ok "(dry-run) would apt install: ${missing[*]}"
            return 0
        fi
        if ! command -v apt-get >/dev/null 2>&1; then
            phase_set moshi fail "no apt; missing: ${missing[*]}"
            error "Install these packages with your package manager: ${missing[*]}"
            return 0
        fi
        sudo_probe
        if ! run_priv apt-get update; then
            phase_set moshi fail "sudo unavailable for apt-get update"
            error "Missing moshi packages: ${missing[*]}"
            sudo_hint
            echo "  sudo apt-get update && sudo apt-get install -y ${missing[*]}"
            return 0
        fi
        if ! run_priv apt-get install -y "${missing[@]}"; then
            phase_set moshi fail "apt-get install failed"
            error "Run it by hand and re-run the installer:"
            echo "  sudo apt-get install -y ${missing[*]}"
            return 0
        fi
        success "moshi packages installed: ${missing[*]}"
    else
        if [ "$OPT_TAILSCALE_SSH" = "1" ]; then
            success "mosh and tmux installed; openssh-server intentionally skipped (--tailscale-ssh)"
        else
            success "mosh, tmux and openssh-server are already installed"
        fi
    fi

    # --- sshd running on :22 (never assumed; actually probed) ---
    if [ "$OPT_TAILSCALE_SSH" != "1" ]; then
        if have_systemd; then
            if ! systemctl is-enabled --quiet ssh >/dev/null 2>&1 \
                || ! systemctl is-active --quiet ssh >/dev/null 2>&1; then
                if [ "$MODE_DRYRUN" = "1" ]; then
                    info "(dry-run) would run: sudo systemctl enable --now ssh"
                else
                    sudo_probe
                    if ! run_priv systemctl enable --now ssh; then
                        phase_set moshi fail "systemctl enable --now ssh failed"
                        error "Run it by hand, then re-run this installer:"
                        echo "  sudo systemctl enable --now ssh"
                        return 0
                    fi
                fi
            fi
            if [ "$MODE_DRYRUN" != "1" ]; then
                if systemctl is-active --quiet ssh && ss -ltn 2>/dev/null | grep -q ':22[[:space:]]'; then
                    success "sshd: active and listening on port 22"
                else
                    phase_set moshi fail "sshd not listening on :22 after enable --now"
                    error "Check it by hand:"
                    echo "  systemctl status ssh"
                    echo "  ss -ltn | grep :22"
                    return 0
                fi
            fi
        else
            info "sshd: systemd is unavailable in this WSL environment; the service was not touched."
            info "Start it manually inside WSL (then verify with 'ss -ltn | grep :22'):"
            echo "  ${SWITCH_TO_ROOT_HINT} -- service ssh start"
            echo "To make it survive reboots without systemd, add /etc/wsl.conf [boot] systemd=true"
            echo "(wsl --shutdown from Windows, then start WSL again) or add 'service ssh start' to"
            echo "your WSL session startup."
        fi
    else
        moshi_ssh_skip_note
        if [ "$MODE_DRYRUN" = "1" ]; then
            : # only prints, no state to guard
        fi
    fi

    # --- moshi-hook CLI (user-local; no sudo; downloaded, then run) ---
    local mh="" mv=""
    if [ -x "$MOSHI_HOOK_BIN" ]; then
        mv="$(tool_version "$MOSHI_HOOK_BIN" --version)"
        success "moshi-hook already installed: ${mv:-present} (${MOSHI_HOOK_BIN})"
    elif command -v moshi-hook >/dev/null 2>&1; then
        mv="$(tool_version moshi-hook --version)"
        success "moshi-hook already installed (on PATH): ${mv:-present}"
    else
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would download ${MOSHI_INSTALL_URL} to a temp file and run: sh <installer> (installs into ~/.local/bin; needs no sudo)"
        else
            local script
            script="${TMPDIR:-/tmp}/install-wsl-moshi.$$.sh"
            info "Downloading ${MOSHI_INSTALL_URL}"
            if ! http_fetch "$MOSHI_INSTALL_URL" "$script" || [ ! -s "$script" ]; then
                phase_set moshi fail "could not download ${MOSHI_INSTALL_URL}"
                return 0
            fi
            info "Running the official moshi installer with sh (never piped blind; installs into ~/.local/bin, no sudo)"
            if ! sh "$script"; then
                phase_set moshi fail "moshi installer failed"
                error "Run it by hand inside WSL, then re-run this installer:"
                echo "  curl -fsSL ${MOSHI_INSTALL_URL} -o /tmp/moshi-install.sh && sh /tmp/moshi-install.sh"
                return 0
            fi
            hash -r 2>/dev/null || true
            [ -x "$MOSHI_HOOK_BIN" ] || command -v moshi-hook >/dev/null 2>&1 || {
                phase_set moshi fail "moshi-hook not found after its installer"
                error "Expected ${MOSHI_HOOK_BIN} (or moshi-hook on PATH). Install manually, then re-run."
                return 0
            }
            mv="$(tool_version "$MOSHI_HOOK_BIN" --version)"
            success "moshi-hook installed: ${mv:-present}"
        fi
    fi
    mh="$(command -v moshi-hook || echo "$MOSHI_HOOK_BIN")"

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) pair-state detection, doctor, daemon unit and runbook lines are shown, never executed"
        info "(dry-run) would write ${MOSHI_UNIT_FILE} only when the daemon is not armed yet (ExecStart=${mh} serve)"
        info "(dry-run) would run: systemctl --user daemon-reload && systemctl --user enable --now moshi-hook"
        phase_set moshi ok "(dry-run) moshi previewed"
        return 0
    fi

    # --- version gate: 'moshi-hook doctor' needs >= 0.4.3 ---
    if [ -n "$mv" ] && ! version_ge "$mv" "$MOSHI_HOOK_MIN_DOCTOR"; then
        warn "moshi-hook ${mv} is older than ${MOSHI_HOOK_MIN_DOCTOR}; 'moshi-hook doctor' should work, but the daemon/pairing phases were not verified against it. Update the vendor CLI and re-run."
    fi

    # --- pair-state detection (idempotency: a paired host reports, never repeats) ---
    local paired=0 token=0 hook=0
    "$mh" status >/dev/null 2>&1 && paired=1
    "$mh" pair --help >/dev/null 2>&1 || token=1   # presence of the subcommand only; real pairing state comes from 'status'
    [ -f "$HOME/.pi/agent/extensions/moshi-hooks.ts" ] && hook=1

    # --- phone-dependent steps: detected and printed, NEVER executed ---
    echo ""
    echo "Phone-dependent steps (need the Moshi app; never run by this script):"
    echo ""
    if [ "$paired" = "1" ]; then
        echo "  1) Easy Pair ... already done (moshi-hook status is non-empty)"
    else
        echo "  1) Easy Pair — NOT done yet. Run, then scan the QR with the Moshi app:"
        echo "       moshi-hook host setup"
        echo "     NOTE: the QR is a temporary credential. Anyone who scans it first gets"
        echo "     SSH access to this machine. Scan it yourself immediately."
    fi
    if [ "$token" = "1" ]; then
        echo "  2) hook pairing — NOT done yet. Get a token from the Moshi app"
        echo "     (Settings -> Hooks), then run, replacing <token>:"
        echo "       moshi-hook pair --token <token>"
        echo "     The token is a user secret; never share it or commit it anywhere."
    else
        echo "  2) hook pairing ... already done (paired and reachable from the phone)"
    fi
    if [ "$hook" = "1" ]; then
        echo "  3) agent hook install ... already present (~/.pi/agent/extensions/moshi-hooks.ts)"
    else
        echo "  3) agent hook install — NOT present yet. Run:"
        echo "       moshi-hook install --target pi"
        echo "     (writes ~/.pi/agent/extensions/moshi-hooks.ts; keep this fresh: after a"
        echo "      pi update the hook can go stale and Pi shows 'missing: extension'.)"
    fi

    # --- daemon under a process manager (user unit; systemd) ---
    if have_systemd; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would create ~/.config/systemd/user and write ${MOSHI_UNIT_FILE} (ExecStart=${mh} serve)"
        else
            mkdir -p "$HOME/.config/systemd/user"
        fi
        if [ ! -f "$MOSHI_UNIT_FILE" ]; then
            cat >"$MOSHI_UNIT_FILE" <<EOF
[Unit]
Description=moshi-hook daemon (phone-side notification of agent events)
After=graphical-session.target

[Service]
ExecStart=${mh} serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
            info "wrote ${MOSHI_UNIT_FILE}"
        else
            success "moshi-hook user unit already present (${MOSHI_UNIT_FILE})"
        fi
    else
        echo ""
        echo "Daemon without systemd: instead of a user unit, start it at login."
        echo "Add to ~/.bashrc (or ~/.profile):"
        echo "  # --- install-wsl.sh: moshi-hook daemon ---"
        echo "  pgrep -u \"\$USER\" -f \"moshi-hook serve\" >/dev/null 2>&1 || \"${mh}\" serve >/dev/null 2>&1 &"
        echo "(systemd user units don't exist here; this is the documented shell alternative,"
        echo "not an invented one.)"
    fi

    # --- daemon arming (never when a skip was requested) ---
    if have_systemd && [ "$OPT_SKIP_MOSHI" != "1" ]; then
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would run: systemctl --user daemon-reload && systemctl --user enable --now moshi-hook"
        else
            if ! systemctl --user daemon-reload; then
                phase_set moshi fail "systemctl --user daemon-reload failed"
                return 0
            fi
            if ! systemctl --user enable --now moshi-hook; then
                phase_set moshi fail "systemctl --user enable --now moshi-hook failed"
                error "Run it by hand, then re-run:"
                echo "  systemctl --user enable --now moshi-hook"
                return 0
            fi
            success "moshi-hook daemon: systemd user service armed"
        fi

        # A user unit only survives reboots when linger is on; enable it only
        # when it is actually off and the call can work — never assumed, and
        # the manual command is left on screen when it cannot run here.
        if [ "$MODE_DRYRUN" = "1" ]; then
            info "(dry-run) would enable linger when needed (loginctl enable-linger)"
        elif command -v loginctl >/dev/null 2>&1; then
            linger_state="$(loginctl show-user "${USER:-}" --property=Linger 2>/dev/null || true)"
            if [ "$linger_state" = "Linger=yes" ]; then
                success "linger already enabled (the daemon survives without an active login session)"
            elif loginctl enable-linger "${USER:-}" 2>/dev/null; then
                success "linger enabled: the moshi-hook daemon survives without an active login session"
            else
                warn "couldn't enable linger; the user unit stops when all login sessions end."
                echo "  sudo loginctl enable-linger \$USER"
            fi
        else
            warn "loginctl is unavailable; if the daemon stops after reboots, run: loginctl enable-linger"
        fi
    fi

    # --- verification: doctor for feature readiness, status for liveness ---
    if [ -x "$MOSHI_HOOK_BIN" ] || command -v moshi-hook >/dev/null 2>&1; then
        if "$mh" doctor >/dev/null 2>&1; then
            echo ""
            echo "moshi-hook doctor (feature readiness):"
            "$mh" doctor 2>/dev/null || true
        fi
        if "$mh" status >/dev/null 2>&1; then
            echo ""
            echo "moshi-hook status (current daemon/pairing state):"
            "$mh" status 2>/dev/null || true
        fi
        if [ "$paired" = "0" ] && [ "$token" = "1" ] && [ "$hook" = "0" ]; then
            phase_set moshi ok "moshi installed; phone-dependent steps printed above"
            echo "(an unpaired host is a valid intermediate state — the phone is the next step)."
            return 0
        fi
        phase_set moshi ok "moshi-hook ${mv:-present}; doctor and status ran"
    else
        phase_set moshi fail "moshi-hook is not installed"
    fi
    return 0
}
# ============================================================================
# Phase 12: pi config — mcp-adapter.json + subagents.json (the hybrid decision)
#
# These two files are the reason this installer exists: upstream tools write
# mcp.json (which pi-mcp-adapter 3.x no longer reads) and no tool writes
# subagents.json. Everything else (settings.json, the pi packages) belongs
# to `pi install` and `gentle-ai install` and is delegated above.
#
# Privacy: nothing personal is stored here. The mcp-adapter's stitch server
# reads its API key at RUNTIME through a `!cat` command; no token is ever
# written. The engram MCP entry resolves the binary through ENGRAM_BIN.
#
# pi-engram init is NEVER called: it writes mcp.json, which pi-mcp-adapter
# 3.x does not read.
# ============================================================================

# build_mcp_adapter_json — prints the file content (4 servers).
build_mcp_adapter_json() {
    cat <<'JSON'
{
  "mcpServers": {
    "codegraph": {
      "command": "codegraph",
      "args": ["serve", "--mcp"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "engram": {
      "command": "node",
      "args": [
        "-e",
        "const { spawn } = require('node:child_process'); const bin = process.env.ENGRAM_BIN || 'engram'; const child = spawn(bin, ['mcp', '--tools=agent'], { stdio: 'inherit' }); child.on('error', () => process.exit(127)); child.on('exit', (code, signal) => { if (typeof code === 'number') process.exit(code); process.kill(process.pid, signal || 'SIGTERM'); });"
      ],
      "env": {
        "ENGRAM_BIN": "!echo ${ENGRAM_BIN:-$HOME/.pi/agent/bin/engram}"
      },
      "directTools": false,
      "lifecycle": "lazy"
    },
    "stitch": {
      "url": "https://stitch.googleapis.com/mcp",
      "headers": {
        "X-Goog-Api-Key": "!cat $HOME/.config/opencode/.secrets/stitch-key.txt"
      }
    }
  }
}
JSON
}

# build_subagents_json — prints the file content (gentle-ai's phase agents).
# The model identifiers here are provider-agnostic gentle-ai roles; upstream
# `gentle-ai install` may refine them later, but this shape boots cleanly.
build_subagents_json() {
    cat <<'JSON'
{
  "model_profiles": {
    "review-resilience": { "model": "opencode-go/deepseek-v4.1-flash", "effort": "high" },
    "review-risk":       { "model": "opencode-go/glm-5.3",            "effort": "high" },
    "sdd-init":          { "model": "opencode-go/qwen3.8-flash",      "effort": "high" },
    "sdd-onboard":       { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "sdd-explore":       { "model": "opencode-go/glm-5.3-flash",      "effort": "high" },
    "sdd-research":      { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "sdd-proposal":      { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "sdd-spec":          { "model": "opencode-go/glm-5.3-flash",      "effort": "high" },
    "sdd-design":        { "model": "opencode-go/glm-5.3",            "effort": "high" },
    "sdd-tasks":         { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "sdd-status":        { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "sdd-apply":         { "model": "opencode-go/glm-5.3-flash",      "effort": "high" },
    "sdd-verify":        { "model": "opencode-go/glm-5.3",            "effort": "high" },
    "sdd-sync":          { "model": "opencode-go/glm-5.3-flash",      "effort": "high" },
    "sdd-archive":       { "model": "opencode-go/gpt-5.6-luna",       "effort": "high" },
    "jd-judge-a":        { "model": "opencode-go/glm-5.3",            "effort": "high" },
    "jd-judge-b":        { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "jd-fix-agent":      { "model": "opencode-go/glm-5.3-flash",      "effort": "high" },
    "gentle-ai-explore": { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "gentle-ai-verify":  { "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "gentle-ai-worker":  { "model": "opencode-go/glm-5.3-flash",      "effort": "xhigh" },
    "review-readability":{ "model": "opencode-go/deepseek-v4.1-flash","effort": "high" },
    "review-reliability":{ "model": "opencode-go/deepseek-v4.1-flash","effort": "high" }
  }
}
JSON
}

# install_config_file <target> <content-builder> <label>
# Writes via a temp file + mv (atomic). On an existing, differing file the
# old one is preserved as <target>.bak-<timestamp> and the change is named.
install_config_file() {
    local target="$1" builder="$2" label="$3" tmp
    tmp="${target}.tmp.$$"
    "$builder" >"$tmp"
    if [ -f "$target" ]; then
        if cmp -s "$target" "$tmp"; then
            rm -f "$tmp"
            success "${label}: already up to date (${target})"
            return 0
        fi
        local bak
        bak="${target}.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$target" "$bak"
        warn "${label}: existing file differed; backup saved as ${bak}"
    fi
    mv "$tmp" "$target"
    success "${label}: wrote ${target}"
    return 0
}

# write_engram_project_pin <project-name>
# D1: writes {"project_name": "<name>"} into <dir>/.engram/config.json for
# each user-supplied container directory. A home-level pin is impossible:
# ~/.engram is Engram's own data directory and the tool reads project pins
# only from container dirs. Never guesses a directory and never falls back
# to ~/.engram/config.json: a non-empty project name with no pin dir (and
# vice versa) is a usage error (fail closed). Privacy: directories are
# user-supplied at runtime; none is hard-coded here.
write_engram_project_pin() {
    local name="$1" dir cfg tmp i

    if [ -z "$name" ] && [ "${#ENGRAM_PIN_DIRS[@]}" -eq 0 ]; then
        info "No --engram-project and no --engram-pin-dir given: skipping the engram project pins (no name or directory guessed)."
        return 0
    fi
    if [ -z "$name" ]; then
        error "--engram-pin-dir without --engram-project: a project pin needs a project name (--engram-project NAME)."
        return 1
    fi
    if [ "${#ENGRAM_PIN_DIRS[@]}" -eq 0 ]; then
        error "--engram-project given without --engram-pin-dir: Engram's home/data directory (~/.engram) cannot be pinned; project pins live in container directories only."
        error "Pass at least one container directory: --engram-pin-dir <dir> (repeatable; each gets <dir>/.engram/config.json)."
        return 1
    fi

    for i in "${!ENGRAM_PIN_DIRS[@]}"; do
        dir="${ENGRAM_PIN_DIRS[$i]}"
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            warn "engram pin: container directory did not exist; created ${dir}"
        elif [ ! -w "$dir" ]; then
            error "engram pin: container directory is not writable: ${dir}"
            return 1
        fi
        cfg="${dir}/.engram/config.json"
        mkdir -p "${dir}/.engram"
        tmp="${cfg}.tmp.$$"
        printf '{\n  "project_name": "%s"\n}\n' "$name" >"$tmp"
        if [ -f "$cfg" ]; then
            if cmp -s "$cfg" "$tmp"; then
                rm -f "$tmp"
                success "engram project pin already present (${cfg})"
            else
                local bak
                bak="${cfg}.bak-$(date +%Y%m%d-%H%M%S)"
                mv "$cfg" "$bak"
                warn "engram pin: existing ${cfg} differed; backup saved as ${bak}"
                mv "$tmp" "$cfg"
                success "engram project pin written: ${cfg} (project_name=${name})"
            fi
        else
            mv "$tmp" "$cfg"
            success "engram project pin written: ${cfg} (project_name=${name})"
        fi
    done
    return 0
}

phase_pi_config() {
    step "Phase 12/13: pi config (mcp-adapter.json + subagents.json)"
    if [ "$MODE_DRYRUN" != "1" ]; then
        mkdir -p "$PI_AGENT_DIR"
    fi
    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) would write ${MCP_ADAPTER_FILE} (4 MCP servers)"
        info "(dry-run) would write ${SUBAGENTS_FILE} (gentle-ai model profiles)"
        if [ -n "$ARG_ENGRAM_PROJECT" ] && [ "${#ENGRAM_PIN_DIRS[@]}" -gt 0 ]; then
            local pdir
            for pdir in "${ENGRAM_PIN_DIRS[@]}"; do
                info "(dry-run) would pin engram project '${ARG_ENGRAM_PROJECT}' in ${pdir}/.engram/config.json"
            done
        elif [ -n "$ARG_ENGRAM_PROJECT" ]; then
            info "(dry-run) engram pin requested but NOT planned: --engram-project without --engram-pin-dir is a usage error (Engram's home/data dir cannot be pinned)"
        elif [ "${#ENGRAM_PIN_DIRS[@]}" -gt 0 ]; then
            info "(dry-run) engram pin dirs given but NOT planned: --engram-pin-dir without --engram-project is a usage error"
        else
            info "(dry-run) would skip the engram project pins (--engram-project and --engram-pin-dir absent)"
        fi
        phase_set pi-config ok "(dry-run) would write 2 config files"
        return 0
    fi
    install_config_file "$MCP_ADAPTER_FILE" build_mcp_adapter_json "mcp-adapter.json"
    install_config_file "$SUBAGENTS_FILE" build_subagents_json "subagents.json"
    local pin_rc=0
    write_engram_project_pin "$ARG_ENGRAM_PROJECT" || pin_rc=1
    if [ "$pin_rc" = "1" ]; then
        phase_set pi-config fail "engram project pin flags invalid (see the error above)"
        error "Fix the --engram-project / --engram-pin-dir usage and re-run."
        return 0
    fi

    # gentle-ai's engram step may have run `pi-engram init`, which writes
    # mcp.json — a file pi-mcp-adapter 3.x does NOT read (it reads this
    # script's mcp-adapter.json). Remove it so nobody edits the dead file
    # by mistake; it carries no personal value (no tokens, no paths).
    if [ -f "$PI_AGENT_DIR/mcp.json" ]; then
        local bak
        bak="${PI_AGENT_DIR}/mcp.json.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$PI_AGENT_DIR/mcp.json" "$bak"
        warn "pi-engram init artifact removed: mcp.json (pi-mcp-adapter 3.x reads mcp-adapter.json); backup: ${bak}"
    fi

    phase_set pi-config ok "2 config files in place"
    return 0
}


# ============================================================================
# Phase 13: final verification — versions table, skills count, failures named
# ============================================================================

phase_verification() {
    step "Phase 13/13: final verification"
    local missing=0 line name
    local -a rows
    rows=("git|$(command -v git >/dev/null 2>&1 && git --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("node|$(command -v node >/dev/null 2>&1 && node --version 2>/dev/null || echo MISSING)")
    rows+=("npm|$(command -v npm >/dev/null 2>&1 && npm --version 2>/dev/null || echo MISSING)")
    rows+=("pi|$(command -v pi >/dev/null 2>&1 && pi --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("codegraph|$(command -v codegraph >/dev/null 2>&1 && codegraph --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("engram|$([ -x "$PI_BIN_ENGRAM" ] && "$PI_BIN_ENGRAM" version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("gentle-ai|$(command -v gentle-ai >/dev/null 2>&1 && gentle-ai version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("herdr|$(command -v herdr >/dev/null 2>&1 && herdr --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("tailscale|$(command -v tailscale >/dev/null 2>&1 && tailscale --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("mosh|$(command -v mosh >/dev/null 2>&1 && mosh --version 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("tmux|$(command -v tmux >/dev/null 2>&1 && tmux -V 2>/dev/null | head -n 1 || echo MISSING)")
    rows+=("moshi-hook|$([ -x "$MOSHI_HOOK_BIN" ] && "$MOSHI_HOOK_BIN" --version 2>/dev/null | head -n 1 || echo MISSING)")

    echo ""
    echo -e "${BOLD}Installed components${NC}"
    for line in "${rows[@]}"; do
        name="${line%%|*}"
        if [ "${line#*|}" = "MISSING" ]; then
            printf '  %b- %b%-12s %s\n' "$RED" "$NC" "$name" "not found"
            missing=$((missing + 1))
        else
            printf '  %b+%b %-12s %s\n' "$GREEN" "$NC" "$name" "${line#*|}"
        fi
    done

    if [ "$MODE_DRYRUN" = "1" ]; then
        info "(dry-run) engram doctor, pi list and skill counts are skipped"
        phase_set verification ok "(dry-run) preview"
        return 0
    fi

    local skills_total
    skills_total="$(count_skills_dirs "$(skills_dir)")"
    info "skills installed in ~/.agents/skills: ${skills_total}"

    if command -v engram >/dev/null 2>&1; then
        if engram doctor >/dev/null 2>&1; then
            success "engram doctor: ok"
        else
            warn "engram doctor reports findings (run 'engram doctor' for details)"
        fi
    fi

    if command -v pi >/dev/null 2>&1; then
        info "pi packages: pi list (see above summary)"
    fi

    if [ "$missing" -gt 0 ]; then
        phase_set verification fail "${missing} component(s) not found"
        warn "${missing} component(s) reported MISSING above — see the failed phases for the fix."
        return 0
    fi
    phase_set verification ok "all components respond"
    success "all components respond to their version queries"
    return 0
}

# ============================================================================
# --status: read-only report; never modifies anything; always exits 0
# ============================================================================

run_status() {
    step "Status"
    local v
    v="$(tool_version git --version)"
    if [ -n "$v" ]; then echo "  git        ${v}"; else echo "  git        not found"; fi
    v="$(tool_version node --version)"
    if [ -n "$v" ]; then echo "  node       ${v}"; else echo "  node       not found"; fi
    v="$(tool_version npm --version)"
    if [ -n "$v" ]; then echo "  npm        ${v}"; else echo "  npm        not found"; fi
    v="$(tool_version pi --version)"
    if [ -n "$v" ]; then echo "  pi         ${v}"; else echo "  pi         not found"; fi
    v="$(tool_version codegraph --version)"
    if [ -n "$v" ]; then echo "  codegraph  ${v}"; else echo "  codegraph  not found"; fi
    if [ -x "$PI_BIN_ENGRAM" ]; then
        v="$("$PI_BIN_ENGRAM" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n 1)"
        echo "  engram     ${v:-present, no version}  (${PI_BIN_ENGRAM})"
    elif command -v engram >/dev/null 2>&1; then
        echo "  engram     $(engram version 2>/dev/null | head -n 1)  (on PATH, not under ~/.pi/agent/bin)"
    else
        echo "  engram     not found"
    fi
    v="$(tool_version gentle-ai version)"
    if [ -n "$v" ]; then echo "  gentle-ai  ${v}"; else echo "  gentle-ai  not found"; fi
    v="$(tool_version herdr --version)"
    if [ -n "$v" ]; then echo "  herdr      ${v}"; else echo "  herdr      not found"; fi
    v="$(tool_version tailscale --version)"
    if [ -n "$v" ]; then echo "  tailscale  ${v}"; else echo "  tailscale  not found"; fi
    if command -v mosh >/dev/null 2>&1; then
        echo "  mosh       $(mosh --version 2>/dev/null | head -n 1)"
    else
        echo "  mosh       not found"
    fi
    if [ -x "$MOSHI_HOOK_BIN" ] || command -v moshi-hook >/dev/null 2>&1; then
        local mvv
        mvv="$(tool_version "${MOSHI_HOOK_BIN}" --version)"
        echo "  moshi-hook ${mvv:-present}  (${MOSHI_HOOK_BIN})"
    else
        echo "  moshi-hook not found"
    fi
    if command -v tailscale >/dev/null 2>&1; then
        if tailscale status >/dev/null 2>&1; then
            echo "  tailnet    authenticated ($(tailscale ip -4 2>/dev/null | head -n 1))"
        else
            echo "  tailnet    installed but not authenticated (run: sudo tailscale up)"
        fi
    else
        echo "  tailnet    no tailscale client"
    fi
    if dpkg -s openssh-server >/dev/null 2>&1; then
        if command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | grep -q ':22[[:space:]]'; then
            echo "  sshd       listening on :22"
        else
            echo "  sshd       installed, not confirmed listening on :22"
        fi
    else
        echo "  sshd       openssh-server not installed"
    fi
    if [ -f "$MOSHI_UNIT_FILE" ]; then
        echo "  moshi svc  unit present (${MOSHI_UNIT_FILE})"
    else
        echo "  moshi svc  no user unit (written by the moshi phase)"
    fi
    if [ -f "$HOME/.pi/agent/extensions/moshi-hooks.ts" ]; then
        echo "  moshi hook pi extension present (~/.pi/agent/extensions/moshi-hooks.ts)"
    else
        echo "  moshi hook pi extension absent (moshi-hook install --target pi)"
    fi

    if [ -f "$MCP_ADAPTER_FILE" ]; then
        echo "  mcp-adapter.json  present (${MCP_ADAPTER_FILE})"
    else
        echo "  mcp-adapter.json  absent (this installer writes it in the pi-config phase)"
    fi
    if [ -f "$SUBAGENTS_FILE" ]; then
        echo "  subagents.json    present (${SUBAGENTS_FILE})"
    else
        echo "  subagents.json    absent (this installer writes it in the pi-config phase)"
    fi
    # D1: report the pin files actually found, one line per --engram-pin-dir.
    # ~/.engram (Engram's data dir) is never probed: it cannot hold a project
    # pin.
    if [ "${#ENGRAM_PIN_DIRS[@]}" -gt 0 ]; then
        local pdir pcfg
        for pdir in "${ENGRAM_PIN_DIRS[@]}"; do
            pcfg="${pdir%/}/.engram/config.json"
            if [ -f "$pcfg" ]; then
                local pn
                pn="$(sed -n 's/.*"project_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$pcfg" 2>/dev/null | head -n 1)"
                echo "  engram pin        ${pn:-present, unnamed}  (${pcfg})"
            else
                echo "  engram pin        absent (${pcfg}; written by --engram-project + --engram-pin-dir)"
            fi
        done
    elif [ -n "$ARG_ENGRAM_PROJECT" ]; then
        echo "  engram pin        no container dirs given (--engram-pin-dir); ~/.engram cannot be pinned"
    else
        echo "  engram pin        none (--engram-project + --engram-pin-dir write container pins)"
    fi
    echo "  skills            $(count_skills_dirs "$(skills_dir)") in ~/.agents/skills"
    echo ""
    echo "Nothing was modified. Compare against the latest published releases"
    echo "with --update (it re-runs each upstream installer)."
    return 0
}

# ============================================================================
# Runner + summary
# ============================================================================

run_all_phases() {
    phase_register "apt-prerequisites" "apt prerequisites"
    phase_register "node-runtime"      "Node.js runtime"
    phase_register "agent-runtime"     "pi + CodeGraph"
    phase_register "engram"            "engram binary + env"
    phase_register "gentle-stack"      "gentle-ai + pi stack"
    phase_register "pi-packages"       "pi packages (settings.json)"
    phase_register "herdr"             "herdr + pi integration"
    phase_register "repo-skills"       "skills: kkapsca-skills"
    phase_register "framework-skills"  "skills: firebase + supabase"
    phase_register "tailscale"         "tailscale (network)"
    phase_register "moshi"             "moshi (phone access)"
    phase_register "pi-config"         "pi config (mcp-adapter, subagents)"
    phase_register "verification"      "final verification"

    local -a order=(apt-prerequisites node-runtime agent-runtime engram gentle-stack pi-packages herdr repo-skills framework-skills tailscale moshi pi-config verification)
    local id
    for id in "${order[@]}"; do
        case "$id" in
            apt-prerequisites) phase_apt_prerequisites ;;
            node-runtime)      phase_node_runtime ;;
            agent-runtime)     phase_agent_runtime ;;
            engram)            phase_engram ;;
            gentle-stack)      phase_gentle_stack ;;
            pi-packages)       phase_pi_packages ;;
            herdr)             phase_herdr ;;
            repo-skills)       phase_skills_source_repo ;;
            framework-skills)  phase_skills_source_npx ;;
            tailscale)         phase_tailscale ;;
            moshi)             phase_moshi ;;
            pi-config)         phase_pi_config ;;
            verification)      phase_verification ;;
        esac
    done
}

print_summary() {
    echo ""
    step "Summary"
    local i state note sym color
    for i in "${!PHASE_ORDER[@]}"; do
        state="${PHASE_STATE[$i]}"
        note="${PHASE_NOTE[$i]}"
        case "$state" in
            ok)   sym="ok";   color="$GREEN" ;;
            skip) sym="skip"; color="$YELLOW" ;;
            fail) sym="FAIL"; color="$RED" ;;
            *)    sym="??";   color="$RED" ;;
        esac
        printf '  %b%-5s%b %-30s %s\n' "$color" "[${sym}]" "$NC" "${PHASE_LABEL[$i]}" "$note"
    done
    echo ""
    if [ "$OS_TOTAL_FAILED" -gt 0 ]; then
        echo -e "${RED}${BOLD}${OS_TOTAL_FAILED} phase(s) failed.${NC} Fix the reported phases and re-run."
        echo "Note: any phase failed due to sudo runs its exact command by hand; re-running is safe (idempotent)."
        return 1
    fi
    echo -e "${GREEN}${BOLD}Done.${NC} Restart your shell so PATH/ENGRAM_BIN take effect, then run: pi"
    return 0
}

# ============================================================================
# Temp space — everything downloaded lands under one dir, removed on exit.
# Registered INSIDE main: a top-level `trap` here runs at parse time under
# `bash script` too, but registering in main keeps exit-code paths explicit.
# ============================================================================

WORK_DIR=""
cleanup() {
    if [ -n "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
    fi
}

main() {
    setup_colors
    TTY_OK=0
    if [ -r /dev/tty ]; then TTY_OK=1; fi
    trap cleanup EXIT

    parse_args "$@"

    WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/install-wsl.XXXXXX")"

    if [ "$MODE_STATUS" = "1" ]; then
        run_status
        exit 0
    fi

    if [ "$MODE_DRYRUN" = "1" ] && [ "$MODE_UPDATE" = "1" ]; then
        fatal "--dry-run and --update are mutually exclusive."
    fi

    preflight
    if [ "$MODE_UPDATE" = "1" ]; then
        info "Update mode: already-installed tools are refreshed to the latest version."
    fi

    run_all_phases
    if ! print_summary; then
        exit 1
    fi
    exit 0
}

# Execution guard: works as a file and under `curl | bash` (BASH_SOURCE empty).
if [ -z "${BASH_SOURCE[0]:-}" ] || [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
