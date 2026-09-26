---
name: repo-guardrails
description: "Trigger: estar por hacer push, crear PR o mergear, revisión de cumplimiento antes de ejecutar, recordatorios de convenciones. Capa advisory: revisa ramas, PRs, labels y commits; solo advierte, no bloquea."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/dev-bootstrap"
---

# Repo Guardrails — Advisory-First Wrapper

> **Input:** estado de rama, PR, labels, commits y reglas de `repo-bootstrap` / `docs/governance.md`
> **Output:** warnings/checklist inline; NO bloquea ni reemplaza `repo-bootstrap`

---

## Activation Contract

Carga cuando el usuario esté por **hacer push, crear un PR o mergear**; cuando quieras una **revisión rápida de cumplimiento** antes de ejecutar; o cuando necesites recordar las convenciones del repo **sin imponer reglas nuevas**.

NO la actives cuando: ya estés ejecutando `repo-bootstrap` (esa skill manda en normas) · el usuario esté en la rama SDD (`/sdd-*`) · o busques **bloquear** una acción, porque esta skill solo advierte.

## Hard Rules

- **Warning-first, never blocking.** Es una capa lateral que operacionaliza las reglas de `repo-bootstrap` y `docs/governance.md`: no añade reglas ni reemplaza el flujo normativo.
- NO bloquea pushes ni PRs: eso lo hacen el hook `pre-push` y la protección de rama de `repo-bootstrap`.
- NO escribe reglas nuevas: usa las de `docs/governance.md`.
- NO crea artifacts canónicos ni issues.

## Decision Gates

| Situación | Ruta |
|---|---|
| Se está ejecutando `repo-bootstrap` | Ceder: esa skill manda en normas |
| El usuario está en `/sdd-*` | Usar la fase SDD correspondiente; en ODD (el flujo por defecto) esta capa **sí** aplica |
| Se busca bloquear una acción | No es esta skill: `repo-bootstrap` (hook y protección de rama) |
| Hay que crear un issue o un PR | `issue-creation` / `branch-pr` |

## Execution Steps

Antes de push, PR o merge, revisá la tabla advisory —rama, PR, Conventional Commits, labels, checks y plantilla de PR— y devolvé los hallazgos inline.

Tabla completa y ejemplo de output: `references/checklist.md`.

## Output Contract

Una lista inline de warnings, con `[WARN]` por cada hallazgo y `[OK]` por lo que está correcto:

```text
⚠️ Guardrails Check:
- [WARN] ...
- [OK]   ...
```

Ejemplo exacto: `references/checklist.md`.

## References

- `references/context-validation.md` — cuándo activarse y cuándo no.
- `references/no-hace-limites.md` — principio rector y lo que esta skill no hace.
- `references/checklist.md` — la tabla advisory y el ejemplo de output.
- `references/relacion-skills.md` — relación con `repo-bootstrap`, `branch-pr` e `issue-creation`.
- `references/referencia.md` — dónde viven las reglas que esta skill revisa.
