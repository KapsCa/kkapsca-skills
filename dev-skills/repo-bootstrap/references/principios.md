# Principios no negociables — Repo Bootstrap

Detalle local de `SKILL.md` (## Hard Rules).

## Principios No Negociables (Quick Reference)

| # | Principle | MUST/SHALL Language | Manual-Reviewable Acceptance Criteria |
|---|-----------|---------------------|----------------------------------------|
| 1 | **No push directo a `main`** | Branch protection SHALL require a pull request before merging. Push to main MUST be blocked. | Verify branch protection rules show "Restrict who can push to main" as an empty restriction (no users or teams allowed to bypass), per what `configure-public-branch-protection.sh` sets. |
| 2 | **`release-please` es obligatorio** | release-please SHALL be configured in repo workflows for all projects. Conventional Commits MUST be used. | Verify `.github/workflows/release-please.yml` exists and `release-please-config.json` is valid. Check that `CHANGELOG.md` exists and has at least one entry. |
| 3 | **Ningún merge sin validación real** | Every repo SHALL have at least one functional workflow as a status check. | Verify at least one workflow file exists under `.github/workflows/` and contains a valid job (e.g., `flutter test`). Confirm the check runs successfully before manual verification. |
| 4 | **Auto-merge solo después de checks verdes** | Auto-merge MAY be enabled ONLY after PR validation + checks funcionales. | Verify branch protection requires status checks and "Include administrators" is enabled. Confirm no "Allow auto-merge" checkbox is enabled without checks passing. |
| 5 | **Review automático opcional** | GitHub Copilot code review is MAY if available; otherwise PR validation + tests are SHALL. | Verify Copilot code review status if claimed. Ensure PR template includes review guidance. |
| 6 | **Protección dual** | Protection depends on two layers: repo versioned assets AND local `pre-push` hook. | Verify `pre-push` hook exists in `.git/hooks/pre-push` and is executable. Verify templates exist in `assets/templates/`. |
| 7 | **Repos públicos: protección clásica** | Branch protection clásica SHALL be configured for `main`. | Verify branch protection rules are enforced (not "Not enforced") for public repos. |
| 8 | **Repos privados personales Free** | GitHub enforcement MAY not apply; hook local es obligatorio como red de seguridad. | Verify hook exists and blocks pushes. Acknowledge GitHub UI may show "Not enforced". |
| 9 | **Solo-dev: approvals en 0** | Solo-dev SHALL have `required approvals = 0`. GitHub no permite aprobar tu propio PR. | Verify branch protection shows "Required approving reviews: 0". |
| 10 | **Ningún secreto se versiona** | Todo repo SHALL tener `.gitleaks.toml` y un workflow que FALLE el build al detectar un secreto. | Verify `.github/workflows/gitleaks.yml` exists and runs on PR and push to main. Introduce a fake secret in a branch and confirm the check fails. |
| 11 | **Un secreto detectado se rota** | Un secreto que llegó a un commit MUST considerarse comprometido. Borrar la línea NO alcanza: hay que rotar la credencial. | Verify the secret was rotated in the provider, not just removed from the file. |
| 12 | **Acciones pinneadas por SHA completo** | Toda acción de GitHub Actions SHALL referenciarse por SHA completo de 40 caracteres, con la versión como comentario. | Verify `grep -rn 'uses:.*@' .github/workflows \| grep -vE '@[0-9a-f]{40}'` returns nothing. |
| 13 | **Permisos mínimos del token** | Todo workflow SHALL declarar `permissions:` explícito, y el default del repo SHALL ser `read`. La escalada a `write` SHALL ser por job y justificada. | Verify `gh api repos/OWNER/REPO/actions/permissions/workflow` reports `read`, and that every workflow declares `permissions:`. |
| 14 | **Actualizador de dependencias activo** | Todo repo SHALL tener `.github/dependabot.yml` con los ecosistemas que el repo realmente tiene. Un ecosistema declarado sin sus archivos HACE FALLAR su job. | Verify each declared ecosystem has its manifest committed, and that no Dependabot job is failing. |
| 15 | **Análisis estático y auditoría** | Todo repo SHALL tener `audit.yml` (auditoría de dependencias) y, si es público, `codeql.yml`. | Verify both workflows exist and pass. In a repo with no code yet, `codeql.yml` SHALL skip instead of failing. |
| 16 | **Fail-closed en seguridad** | Si un chequeo de seguridad no corrió, o corrió degradado, el PR MUST NOT mergearse. Un chequeo ausente NUNCA cuenta como aprobado. | Verify that removing a security workflow blocks the PR instead of letting it through. |

---

