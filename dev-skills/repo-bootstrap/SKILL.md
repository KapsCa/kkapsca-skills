---
name: repo-bootstrap
description: >
  Skill ejecutiva para preparar un repositorio desde el arranque con estándares sanos de trabajo:
  ramas por feature, PR obligatorio, bloqueo local de push directo a main, checks funcionales
  obligatorios antes de merge, auto-merge cuando todo pase, documentación operativa y
  release-please como mecanismo base de releases.

  --- DELEGATION GUIDANCE ---
  Delegation of GitHub Actions is handled through the orchestrator.
  This skill file is DEAD data for the orchestrator; no direct execution here.
  The orchestrator loads this file and extracts configuration for delegation.
  For existing repos, the orchestrator preserves existing workflows and appends only what's missing.
  For new repos, the orchestrator creates all required assets from templates.
  --- END DELEGATION GUIDANCE ---

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/dev-bootstrap"
---

# Repo Bootstrap — Execution Skill (Hardened)

> **Input:** proyecto nuevo o repo sin estándares claros
> **Output:** repositorio listo para trabajar con PRs, release-please y reglas operativas coherentes

---

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

## When to Use

Usa esta skill cuando:

- el usuario diga "crea un proyecto nuevo",
- toque bootstrapear un repo antes de meter features,
- se quiera evitar push directo a `main`,
- se quiera usar `release-please` desde el día 1,
- se quiera estandarizar GitHub + flujo local para proyectos personales o pequeños.

## When NOT to Use

- el usuario todavía no tiene claridad funcional o técnica suficiente del proyecto,
- aún falta pasar por `brainstorm`, `product-discovery` o `tech-feasibility`,
- el repo ya tiene estándares maduros y solo toca implementar una feature puntual.

---

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

## Resultado Esperado

Cuando esta skill se aplica bien, el repo debe quedar con:

**Gobernanza:**

- `PULL_REQUEST_TEMPLATE.md`
- workflow de `release-please`
- `release-please-config.json`
- `.release-please-manifest.json`
- `CHANGELOG.md`
- `docs/repository-standards.md`
- hook local `pre-push`
- al menos un workflow funcional de validación del stack
- branch protection clásica en públicos, si aplica

**Seguridad:**

- `.github/workflows/gitleaks.yml` y `.gitleaks.toml`
- `.github/workflows/audit.yml`
- `.github/workflows/codeql.yml` (solo si el repo es público)
- `.github/dependabot.yml`
- `SECURITY.md`
- bloque de secretos fusionado dentro del `.gitignore`

---

## Seguridad: qué cubre cada herramienta

Cada herramienta cubre una parte distinta. Ninguna cubre todo, y los huecos están declarados abajo a propósito: es mejor saber qué NO está cubierto que asumir cobertura que no existe.

| Herramienta | Qué responde | Cómo se llama |
|---|---|---|
| `gitleaks` | ¿Alguien escribió una contraseña o una clave en el código? | `gitleaks.yml` |
| `dependabot` | ¿Salió una versión nueva de algo que uso? | `dependabot.yml` |
| `codeql` | ¿Hay formas conocidas de escribir código inseguro? | `codeql.yml` |
| `audit` | ¿Algo que YA tengo tiene una falla conocida hoy? | `audit.yml` |

### Matriz de cobertura por stack

| Stack | Secretos | Versiones | Análisis estático | Auditoría de librerías |
|---|---|---|---|---|
| Go | ✅ | ✅ | ✅ CodeQL | ✅ `govulncheck` |
| Python | ✅ | ✅ | ✅ CodeQL | ✅ `pip-audit` |
| Node / TS | ✅ | ✅ | ✅ CodeQL | ✅ `npm audit` |
| Rust | ✅ | ✅ | ✅ CodeQL | ❌ |
| Dart / Flutter | ✅ | ✅ | ❌ **sin cobertura** | ❌ **sin cobertura** |
| Shell (bash) | ✅ | n/a | ❌ **sin cobertura** | n/a |
| PowerShell | ✅ | n/a | ❌ **sin cobertura** | n/a |
| Workflows de Actions | ✅ | ✅ | ✅ CodeQL (`actions`) | n/a |

### Huecos conocidos, declarados

**CodeQL no entiende Dart/Flutter, shell ni PowerShell.** Sus lenguajes soportados son C/C++, C#, Go, Java/Kotlin, JavaScript/TypeScript, Python, Ruby, Rust, Swift y los propios workflows de Actions. En un repo de Flutter, `codeql.yml` corre y no encuentra nada: no es un error, es un hueco.

**Dart/Flutter no tiene herramienta oficial de auditoría de librerías para CI.** Por eso `audit.yml` no lo cubre. Es el único stack del ecosistema sin ninguna capa de análisis ni auditoría automática.

**Un repo sin código todavía no tiene ninguna señal de lenguaje.** Ese es el estado inicial normal de un proyecto nuevo. En ese caso: `codeql.yml` se saltea solo (tiene un guard), `audit.yml` saltea todos sus pasos sin fallar, y `dependabot.yml` queda solo con `github-actions`. Nada falla, y cada pieza se activa cuando aparece el código.

### Límites de plan

| Herramienta | Límite |
|---|---|
| CodeQL | Gratis en repos **públicos**. En privados necesita licencia de GitHub Code Security, así que el instalador solo lo copia en públicos |
| gitleaks | Gratis con **cuenta personal**. Si el repo pasa a una **organización**, necesita una licencia gratuita de gitleaks.io |

### Dónde vive cada regla

| Nivel | Archivo | Rol |
|---|---|---|
| Normativo | este `SKILL.md` | Fuente de verdad. Si hay conflicto, este archivo gana |
| Por repo | `docs/repository-standards.md` | Lo que aterriza en cada proyecto |
| Operativo | [`docs/security-baseline.md`](../../docs/security-baseline.md) | Vista derivada, para leer sin abrir una skill |

---

## Delegación de Acciones (GitHub Actions)

### Orchestrator Behavior
- The orchestrator loads this SKILL.md as dead data to extract configuration.
- For **new repos**: orchestrator creates all assets from embedded templates.
- For **existing repos**: orchestrator preserves existing workflows/templates and appends only missing configurations.
- Delegation is handled by the orchestrator; this file defines what to create/overwrite.

### Preservation/Overwrite Guidance
- **Preserve**: Any existing workflow files that are NOT `release-please.yml` are preserved as-is.
- **Overwrite**: If `release-please.yml`, `release-please-config.json`, or `.release-please-manifest.json` exist but are malformed, they are overwritten with canonical versions.
- **Preserve with append**: `PULL_REQUEST_TEMPLATE.md` and `docs/repository-standards.md` are created if missing; if present, they are left untouched.
- **Hook preservation**: Local `pre-push` hook is overwritten only if the user explicitly requests reinstallation.

---

## Decision Tree

| Escenario | Qué hacer |
|---|---|
| Proyecto nuevo | Aplicar bootstrap completo |
| Repo existente sin estándares | Aplicar bootstrap cuidando no pisar archivos críticos |
| Repo público | Aplicar bootstrap + branch protection clásica |
| Repo privado personal Free | Aplicar bootstrap + hook local; explicar que GitHub puede no enforcear reglas |
| Solo-dev | PR obligatorio, approvals en 0 |
| Equipo pequeño | Evaluar subir approvals, code owners y checks más estrictos |
| Auto-merge deseado | Habilitar solo después de PR validation + checks funcionales |

---

## Orden de Ejecución

### 1. Verificar contexto

Antes de escribir nada, confirma explícitamente:

- tipo de repo: nuevo o existente,
- público o privado,
- rama principal (`main` por estándar; `master` solo si es un repo legacy),
- si ya existen workflows, templates o changelog,
- si el usuario es solo-dev o equipo.

### PRE-FLIGHT CHECKLIST (obligatorio)

- [ ] Ya confirmé si el repo es nuevo o existente
- [ ] Ya confirmé si es público o privado
- [ ] Ya confirmé la rama principal
- [ ] Ya confirmé si ya existen workflows/templates/changelog
- [ ] Ya confirmé si el usuario es solo-dev o equipo
- [ ] Ya confirmé el stack o al menos el comando de validación funcional

Si alguna casilla no puede resolverse, NO inventes. Pregunta al usuario antes de seguir.

### 2. Aplicar assets versionados

Instalar o adaptar:

- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/release-please.yml`
- `release-please-config.json`
- `.release-please-manifest.json`
- `CHANGELOG.md`
- `docs/repository-standards.md`

### 3. Instalar protección local

Instalar hook `pre-push` para bloquear pushes a:

- `main`
- `master`
- `release`

### 4. Si el repo es público

Configurar Classic Branch Protection con:

- Require a pull request before merging
- Require conversation resolution before merging
- Require status checks before merging
- Require branches to be up to date before merging
- Require linear history
- Apply to administrators
- No force pushes
- No deletions

### 5. Definir el check funcional del stack

Todo repo debe tener al menos un workflow útil para validar que no se rompió lo importante.

| Stack detectado | Check funcional mínimo |
|---|---|
| Flutter | `flutter test` |
| Go | `go test ./...` |
| Python | `pytest` |
| Node | `npm test` |
| Repos de scripts/herramientas | lint/checks relevantes del repo |

No existe un solo comando universal para todos los stacks. La regla universal es que haya al menos un check funcional real antes de mergear.

### Regla de bloqueo

Si el stack detectado NO aparece en la tabla anterior y no existe un comando de validación ya conocido en el repo, DEBES preguntar al usuario antes de proponer auto-merge.

### 6. Configurar auto-merge con criterio

Activa auto-merge solo cuando ya existan:

- PR validation,
- checks funcionales del stack,
- reglas razonables de rama.

Si hay Copilot code review disponible por plan/licencia, actívalo como capa extra.

### 7. Explicar el flujo operativo

El agente debe dejar claro que el flujo esperado es:

1. crear rama,
2. hacer commits convencionales,
3. push a rama,
4. abrir PR,
5. esperar checks,
6. dejar que auto-merge cierre el PR cuando todo pase,
7. dejar que `release-please` cree/actualice Release PR.

---

## Critical Patterns

### `release-please` siempre explícito

No basta con meter el workflow.
El agente debe dejar su uso explícito también en:

- la documentación del repo,
- la plantilla de PR,
- la explicación del flujo.

### Tests/checks antes de auto-merge

No basta con lint superficial.
Antes de activar auto-merge, el repo debe tener al menos un check que valide comportamiento o integridad real del stack.

### Auto-review opcional, checks obligatorios

El review automático de Copilot es deseable, pero puede depender de plan.
Los checks funcionales y PR validation sí son obligatorios como estándar.

### GO / NO-GO para auto-merge

Auto-merge solo puede recomendarse si TODO esto es verdadero:

- [ ] Existe PR validation
- [ ] Existe al menos un check funcional del stack
- [ ] La rama protegida requiere status checks
- [ ] El flujo del repo ya usa PR obligatorios

Si alguna casilla falla, NO recomiendes auto-merge todavía.

### No tocar git global

No modificar configuración global de Git para imponer esta convención.
La convención debe vivir en:

- el repo,
- scripts del repo,
- hooks locales por clon.

### No asumir enforcement en privados Free

Si el repo es privado personal Free:

- NO prometer que GitHub bloqueará pushes realmente,
- SÍ dejar hook local,
- SÍ explicar la limitación,
- SÍ configurar la regla en UI si el usuario lo desea, pero aclarando que puede salir como "Not enforced".

---

## Assets

- **Instalador**: [assets/install-repo-standards.sh](assets/install-repo-standards.sh)
- **Protección pública**: [assets/configure-public-branch-protection.sh](assets/configure-public-branch-protection.sh)
- **Templates**: [assets/templates/](assets/templates/)

### Plantillas de seguridad

| Plantilla | Destino en el repo |
|---|---|
| `gitleaks.yml` | `.github/workflows/gitleaks.yml` |
| `gitleaks.toml` | `.gitleaks.toml` |
| `audit.yml` | `.github/workflows/audit.yml` |
| `codeql.yml` | `.github/workflows/codeql.yml` (solo público) |
| `dependabot.yml` | `.github/dependabot.yml` (base: solo `github-actions`) |
| `dependabot-ecosystems/*.yml` | se concatenan a `.github/dependabot.yml` según el stack detectado |
| `SECURITY.md` | `SECURITY.md` |
| `gitignore-security.txt` | se fusiona dentro del `.gitignore`, detrás de un marcador |

### Política de instalación

Los archivos de **contenido del proyecto** (`CHANGELOG.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/repository-standards.md`) y todos los de **seguridad** se crean **solo si faltan**. Nunca se pisan: un `CHANGELOG.md` tiene el historial real y un `.gitleaks.toml` puede estar ajustado a mano.

Los archivos de **configuración de release-please** sí se sobrescriben: los genera la herramienta y no deberían editarse a mano.

El hook `pre-push` solo se reinstala si se pide explícitamente con `--reinstall-hook`.

---

## Commands

### Instalar estándares en el repo actual

```bash
bash dev-skills/repo-bootstrap/assets/install-repo-standards.sh
```

Es idempotente: correrlo dos veces no cambia nada de lo que ya estaba. Para reinstalar el hook `pre-push` a propósito:

```bash
bash dev-skills/repo-bootstrap/assets/install-repo-standards.sh --reinstall-hook
```

### Probar las plantillas antes de publicarlas

Las plantillas se prueban ejecutándose en [KapsCa/baseline-sandbox](https://github.com/KapsCa/baseline-sandbox), un repo público que existe solo para eso. Una plantilla que nunca se ejecutó no está verificada: el banco de pruebas ya encontró un defecto que la lectura no vio.

### Aplicar protección clásica en repo público

```bash
bash dev-skills/repo-bootstrap/assets/configure-public-branch-protection.sh
```

### Flujo mínimo recomendado

```bash
git switch -c feat/mi-cambio
git add .
git commit -m "feat(core): add initial flow"
git push -u origin feat/mi-cambio
gh pr create --fill
```

---

## Nota final para agentes

Si el usuario pide "crear un proyecto nuevo", esta skill debe cargarse después de tener claridad suficiente del proyecto.

Primero se piensa.
Luego se decide.
Luego se bootstrapea.
Luego se construye.
