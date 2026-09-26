---
name: repo-bootstrap
description: "Trigger: crear un proyecto nuevo, bootstrapear un repo, evitar push directo a main, usar release-please desde el día 1. Prepara el repo con ramas por feature, PR obligatorio, checks y docs operativos."
license: MIT
metadata:
  author: KkapsCa
  version: "1.1"
  pipeline: "project-kickstart/dev-bootstrap"
---

# Repo Bootstrap — Execution Skill (Hardened)

> **Input:** proyecto nuevo o repo sin estándares claros
> **Output:** repositorio listo para trabajar con PRs, release-please y reglas operativas coherentes

---

## Activation Contract

**Esta skill es la fuente de verdad normativa del repositorio**: sus reglas son MUST/SHALL, y el detalle con criterios verificables está en `references/principios.md`.

Carga cuando el repositorio sea **nuevo**, cuando sea **existente y sin estándares**, o cuando haya que **aplicar o revisar las reglas operativas** —PR obligatorio, `release-please`, checks y seguridad—.

Antes de escribir nada, confirmá el contexto: nuevo o existente · público o privado · solo-dev o equipo. Modos de gobernanza: `references/governance.md`. Validación previa: `references/context-validation.md`.

## Hard Rules

Los **16 principios no negociables** están en `references/principios.md`, con su lenguaje MUST/SHALL y **cómo verificar cada uno**. Los seis que no admiten excepción:

1. **Sin push directo a `main`**: la protección exige PR.
2. **`release-please` es obligatorio**, con Conventional Commits.
3. **Ningún merge sin al menos un check funcional del stack.**
4. **Ningún secreto se versiona**: `.gitleaks.toml` y un workflow que **falla** al detectarlo. Un secreto detectado **se rota**; borrar la línea no alcanza.
5. **Acciones pinneadas por SHA completo** de 40 caracteres, con la versión como comentario.
6. **Fail-closed en seguridad**: un chequeo que no corrió **nunca** cuenta como aprobado.

El resto, por tema: **protección dual** (assets versionados + hook `pre-push`), **públicos contra privados Free**, **solo-dev con approvals en 0**, **permisos mínimos del token** y **actualizador de dependencias solo con los ecosistemas que el repo tiene**.

## Decision Gates

| Escenario | Qué hacer |
|---|---|
| Proyecto nuevo | Bootstrap completo |
| Repo existente sin estándares | Bootstrap **sin pisar** archivos críticos |
| Repo público | Bootstrap + branch protection clásica |
| Repo privado Free | Bootstrap + hook local; aclarar que GitHub puede no enforcear |
| Solo-dev | PR obligatorio, approvals en 0 |
| Equipo pequeño | Evaluar approvals, code owners y checks más estrictos |
| Auto-merge deseado | Solo tras PR validation + checks funcionales |

Detalle: `references/decision-tree.md`.

## Execution Steps

Siete pasos, en orden. Detalle y el **PRE-FLIGHT CHECKLIST obligatorio**: `references/orden-de-ejecucion.md`.

1. **Verificar contexto** antes de escribir nada.
2. **Aplicar los assets versionados** (`references/assets.md`).
3. **Instalar la protección local**: hook `pre-push`.
4. **Si el repo es público**: branch protection clásica.
5. **Definir el check funcional del stack** (al menos uno, y que sirva).
6. **Configurar auto-merge con criterio**.
7. **Explicar el flujo operativo** al usuario.


## Output Contract

Un repositorio listo para trabajar: reglas de rama y PR, `release-please`, checks funcionales y la capa de seguridad instalada. Qué se considera terminado: `references/resultado-esperado.md`. Comandos: `references/commands.md`. Nota final para agentes: `references/nota-final.md`.

## References

- `references/governance.md` — fuente de verdad y modos de gobernanza.
- `references/context-validation.md` — activación.
- `references/principios.md` — los 16 principios, verificables.
- `references/resultado-esperado.md` — qué es "terminado".
- `references/seguridad.md` — cobertura por stack y huecos.
- `references/delegacion-github-actions.md` — delegación de acciones.
- `references/decision-tree.md` — árbol de decisión.
- `references/orden-de-ejecucion.md` — los 7 pasos y el pre-flight.
- `references/critical-patterns.md` — patrones críticos.
- `references/assets.md` — assets e instalación.
- `references/commands.md` — comandos.
- `references/nota-final.md` — nota final.
