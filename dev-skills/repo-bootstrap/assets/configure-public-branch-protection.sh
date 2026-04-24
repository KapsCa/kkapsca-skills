#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$REPO_ROOT" ]]; then
  printf 'Error: ejecuta este script dentro de un repositorio git.\n' >&2
  exit 1
fi

REPO_SLUG="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
IS_PRIVATE="$(gh repo view --json isPrivate --jq .isPrivate)"

if [[ "$IS_PRIVATE" == "true" ]]; then
  printf '⚠️  El repo es privado. En cuentas personales Free, branch protection puede no estar enforced.\n' >&2
  printf 'Mantén el hook local como protección principal.\n' >&2
  exit 1
fi

mapfile -t CHECK_NAMES < <(gh api "repos/$REPO_SLUG/commits/main/check-runs" --jq '.check_runs | map(.name) | unique | .[]' 2>/dev/null || true)

ARGS=(
  --method PUT "repos/$REPO_SLUG/branches/main/protection"
  -H "Accept: application/vnd.github+json"
  -F enforce_admins=true
  -F 'required_pull_request_reviews[dismiss_stale_reviews]=false'
  -F 'required_pull_request_reviews[require_code_owner_reviews]=false'
  -F 'required_pull_request_reviews[required_approving_review_count]=0'
  -F 'required_pull_request_reviews[require_last_push_approval]=false'
  -F restrictions=
  -F required_linear_history=true
  -F allow_force_pushes=false
  -F allow_deletions=false
  -F block_creations=false
  -F required_conversation_resolution=true
  -F lock_branch=false
)

if [[ ${#CHECK_NAMES[@]} -gt 0 ]]; then
  ARGS+=( -F 'required_status_checks[strict]=true' )
  for check_name in "${CHECK_NAMES[@]}"; do
    ARGS+=( -F "required_status_checks[contexts][]=$check_name" )
  done
else
  ARGS+=( -F required_status_checks= )
fi

gh api "${ARGS[@]}"

printf '✅ Classic branch protection aplicada a main en %s\n' "$REPO_SLUG"
printf 'Recuerda: approvals requeridos = 0 para flujo solo-dev.\n'

if [[ ${#CHECK_NAMES[@]} -eq 0 ]]; then
  printf '⚠️  No encontré status checks registrados todavía.\n'
  printf 'Cuando tu CI exista, agrega checks requeridos manualmente en GitHub o vuelve a correr este script.\n'
fi
