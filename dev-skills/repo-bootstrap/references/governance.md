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

---

