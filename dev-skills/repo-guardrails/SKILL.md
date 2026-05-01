---
name: repo-guardrails
description: >
  Capa advisory/warning-first que revisa estado de ramas, PRs, labels y commits
  antes de acciones git/gh. NO reemplaza repo-bootstrap ni bloquea nada.
  Solo advierte basándose en reglas ya definidas en repo-bootstrap y docs/governance.md.
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/dev-bootstrap"
---

# Repo Guardrails — Advisory-First Wrapper

> **Input:** estado de rama, PR, labels, commits y reglas de `repo-bootstrap` / `docs/governance.md`
> **Output:** warnings/checklist inline; NO bloquea ni reemplaza `repo-bootstrap`

---

## When to Use

Usa esta skill cuando:
- el usuario esté por hacer push, crear PR o mergear,
- quieras una revisión rápida de cumplimiento antes de ejecutar,
- necesites recordatorios sobre convenciones del repo sin imponer nuevas reglas.

## When NOT to Use

- ya estés ejecutando `repo-bootstrap` (esa skill manda en normas),
- el usuario esté en flujo SDD (`/sdd-*`) — usa la fase correspondiente,
- busques bloquear acciones: esta skill SOLO advierte, no bloquea.

---

## Principio Rector

**Warning-first, never blocking.** Esta skill es una capa lateral que operacionaliza las reglas de `repo-bootstrap` y `docs/governance.md`, pero no añade nuevas reglas ni reemplaza el flujo normativo.

---

## Checklist de Guardrails (Advisory)

Antes de push / PR / merge, revisa:

| Ítem | Qué verificar | Warning si... |
|-------|---------------|---------------|
| Rama | ¿Es `main`, `master` o `release`? | Push directo a rama protegida |
| PR | ¿Existe PR abierto para la rama? | Push sin PR abierto |
| Conventional Commits | ¿Los commits siguen formato `type(scope): message`? | Commits sin formato convencional |
| Labels | ¿Tiene labels apropiados para el tipo de cambio? | PR sin labels después de 2h abierto |
| Checks | ¿Passing? | Checks fallando o pendientes |
| PR template | ¿Llenó la descripción? | PR vacío o con template sin tocar |

---

## Qué NO hace esta skill

- NO bloquea pushes ni PRs (eso lo hace `repo-bootstrap` vía hook `pre-push` y branch protection)
- NO escribe nuevas reglas (usa las de `docs/governance.md`)
- NO reemplaza `issue-creation` ni `branch-pr`
- NO crea artifacts canónicos nuevos

---

## Output Esperado

Una lista inline de warnings, ejemplo:

```
⚠️ Guardrails Check:
- [WARN] Push directo a main detectado → usa rama feature
- [WARN] No se encontró PR abierto para feat/mi-cambio
- [OK] Conventional commit detectado: feat(core): add flow
```

---

## Relación con Otras Skills

| Skill | Relación |
|--------|----------|
| `repo-bootstrap` | Manda en normas; `repo-guardrails` solo lee sus reglas |
| `branch-pr` | `repo-guardrails` advierte antes de que abras PR |
| `issue-creation` | No se solapan; `repo-guardrails` no crea issues |

---

## Referencia

Las reglas que esta skill revisa viven en:
- `docs/governance.md` — estándares del repo
- `dev-skills/repo-bootstrap/SKILL.md` — definición normativa
- `.github/PULL_REQUEST_TEMPLATE.md` — checklist de PR
