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

# ---------------------------------------------------------------------------
# Auto-merge a nivel de repo: allow_auto_merge=true.
#
# El workflow de release-please pide el merge con `gh pr merge --auto`, y ese
# pedido falla si el repo no tiene auto-merge habilitado. Por eso el bootstrap
# lo activa aca, junto con la proteccion de rama, en vez de dejarlo como paso
# manual que se olvida.
#
# No es un ajuste de branch protection sino del repo (PATCH /repos/...), asi
# que va en su propia llamada. Reenviar true deja el mismo estado, asi que la
# corrida es idempotente. Es fail-soft a proposito: si falla (gh sin permisos
# de admin, por ejemplo), la proteccion de rama ya quedo aplicada, se avisa
# como habilitarlo a mano y el script no aborta.
#
# allow_squash_merge va en la misma llamada porque este script aplica
# required_linear_history=true, que prohibe los merge commits: el auto-merge
# del release PR usa --squash, asi que si el repo tuviera el squash
# deshabilitado el pedido nunca podria completarse. GitHub lo trae habilitado
# por defecto, pero no conviene depender del default.
# ---------------------------------------------------------------------------
if auto_merge_output="$(
  gh api --method PATCH "repos/$REPO_SLUG" \
    -F allow_auto_merge=true -F allow_squash_merge=true 2>&1
)"; then
  printf '✅ Auto-merge habilitado en %s (allow_auto_merge=true, allow_squash_merge=true)\n' "$REPO_SLUG"
else
  printf '↷ No se pudo habilitar allow_auto_merge en %s: %s\n' \
    "$REPO_SLUG" "$auto_merge_output" >&2
  printf '   Habilítalo a mano: Settings -> General -> Pull Requests\n' >&2
  printf '   -> Allow auto-merge, y Allow squash merging. O con:\n' >&2
  printf '   gh api --method PATCH repos/%s -F allow_auto_merge=true -F allow_squash_merge=true\n' \
    "$REPO_SLUG" >&2
  printf '   Sin esta opción, el pedido de auto-merge del workflow falla.\n' >&2
fi
