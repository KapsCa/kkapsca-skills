# Governance y fuente de verdad — Repo Bootstrap

Detalle local de `SKILL.md` (## Activation Contract).

## Governance Source of Truth

> **⚠️ Normativo**: Este archivo es la **fuente normativa** de todas las reglas de gobernanza de repositorios en este ecosistema.
> `docs/governance.md` es una **vista derivada operativa** que resume estas reglas sin contradecirlas. Si existe conflicto entre ambos documentos, este archivo prevalece.

### Governance Modes

| Modo | PR obligatorio | Approvals requeridos | Auto-merge | Branch protection |
|------|---------------|---------------------|------------|-------------------|
| **Solo-dev** | ✅ Siempre | 0 (GitHub no permite auto-aprobarse) | ✅ Solo tras checks verdes | Hook `pre-push` + branch protection si público; solo hook si privado Free |
| **Team** | ✅ Siempre | ≥ 1 (configurable por equipo) | ✅ Solo tras checks + approvals | Classic branch protection completa obligatoria |

Para implementación detallada, ver [Principios No Negociables](#principios-no-negociables-quick-reference) y [Decision Tree](#decision-tree).

### Auto-merge del release PR

El bootstrap deja el auto-merge del release PR funcionando de punta a punta:

- `allow_auto_merge=true` en el repo: lo habilita
  `configure-public-branch-protection.sh` (PATCH `repos/<owner>/<repo>`),
  idempotente y fail-soft.
- La plantilla de `release-please.yml` pide el merge:
  `gh pr merge --auto --squash --repo <owner>/<repo> <number>`, con el
  output `pr` de la acción y `--repo` explícito (el job no hace checkout).
  `--squash` y no `--merge` porque la protección fija
  `required_linear_history=true`, que prohíbe merge commits.
- El release PR se crea con el secret `RELEASE_PLEASE_TOKEN` (PAT
  dedicado), nunca con `GITHUB_TOKEN`: los eventos de `GITHUB_TOKEN` no
  disparan otros workflows, así que el PR no correría los checks requeridos
  y el auto-merge esperaría para siempre.
- Con checks requeridos: un `if:` por job reporta `skipped` y cuenta como
  éxito (no bloquea el merge); un filtro de workflow (`paths:` /
  `branches:`) deja el check pending y sí lo bloquea.

---

