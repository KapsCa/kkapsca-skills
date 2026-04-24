---
name: repo-bootstrap
description: >
  Skill ejecutiva para preparar un repositorio desde el arranque con estándares sanos de trabajo:
  ramas por feature, PR obligatorio, bloqueo local de push directo a main, checks funcionales
  obligatorios antes de merge, auto-merge cuando todo pase, documentación operativa y
  release-please como mecanismo base de releases.

  Usa esta skill cuando el usuario esté creando un proyecto nuevo, quiera dejar listo el repositorio,
  necesite configurar GitHub para trabajar con pull requests o quiera estandarizar su pipeline inicial
  antes de empezar a implementar features.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/dev-bootstrap"
---

# Repo Bootstrap — Execution Skill

> **Input:** proyecto nuevo o repo sin estándares claros
> **Output:** repositorio listo para trabajar con PRs, release-please y reglas operativas coherentes

---

## When to Use

Usa esta skill cuando:

- el usuario diga “crea un proyecto nuevo”,
- toque bootstrapear un repo antes de meter features,
- se quiera evitar push directo a `main`,
- se quiera usar `release-please` desde el día 1,
- se quiera estandarizar GitHub + flujo local para proyectos personales o pequeños.

## When NOT to Use

- el usuario todavía no tiene claridad funcional o técnica suficiente del proyecto,
- aún falta pasar por `brainstorm`, `product-discovery` o `tech-feasibility`,
- el repo ya tiene estándares maduros y solo toca implementar una feature puntual.

---

## Principios No Negociables

1. **No push directo a `main`**
   - Siempre trabajar en ramas.
   - Siempre integrar por PR.

2. **`release-please` es obligatorio en proyectos nuevos**
   - Los releases no se improvisan.
   - Los commits deben seguir Conventional Commits.

3. **Ningún repo se mergea sin validación real**
   - Todo repo debe tener al menos un workflow funcional de validación según su stack.
   - El comando exacto cambia por stack (`flutter test`, `go test`, `pytest`, `npm test`, etc.).
   - La regla universal es que exista un check útil antes de permitir merge automático.

4. **Auto-merge solo después de checks verdes**
   - Auto-merge está bien si ya existen PR validation + checks funcionales.
   - Nunca habilites auto-merge sobre un repo sin validación real.

5. **Review automático es deseable, pero depende de plan**
   - Si GitHub Copilot code review está disponible, actívalo.
   - Si no está disponible, mantén PR validation + tests/checks + auto-merge.

6. **La protección depende de dos capas**
   - Capa repo versionada: templates, workflow, docs, changelog.
   - Capa local: hook `pre-push`.

7. **En repos públicos sí aplica protección clásica real**
   - Configurar branch protection para `main`.

8. **En repos privados personales Free no confíes en GitHub para enforcement real**
   - La UI puede mostrar reglas, pero no necesariamente enforcearlas.
   - El hook local es obligatorio como red de seguridad.

9. **Solo-dev no debe auto-bloquearse con approvals requeridos**
   - Si eres la única persona programando, `required approvals = 0`.
   - GitHub no permite aprobar tu propio PR.

---

## Resultado Esperado

Cuando esta skill se aplica bien, el repo debe quedar con:

- `PULL_REQUEST_TEMPLATE.md`
- workflow de `release-please`
- `release-please-config.json`
- `.release-please-manifest.json`
- `CHANGELOG.md`
- `docs/repository-standards.md`
- hook local `pre-push`
- al menos un workflow funcional de validación del stack
- branch protection clásica en públicos, si aplica

---

## Flujo Recomendado

```text
Idea → Brainstorm → Product Discovery → Tech Feasibility → Repo Bootstrap → Desarrollo
```

La parte importante es esta:

- `tech-feasibility` responde **cómo construir**,
- `repo-bootstrap` deja listo **dónde y bajo qué reglas construir**.

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
- Apply to administrators
- No force pushes
- No deletions
- Required approvals = 0 si es solo-dev

### 5. Definir el check funcional del stack

Todo repo debe tener al menos un workflow útil para validar que no se rompió lo importante.

| Stack detectado | Check funcional mínimo |
|---|---|
| Flutter | `flutter test` |
| Go | `go test ./...` |
| Python | `pytest` |
| Node | `npm test` |
| Repos de scripts/herramientas | lint/checks relevantes del repo |

No existe un solo comando universal para todos los stacks.
La regla universal es que haya al menos un check funcional real antes de mergear.

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
- SÍ configurar la regla en UI si el usuario lo desea, pero aclarando que puede salir como `Not enforced`.

---

## Assets

- **Instalador**: [assets/install-repo-standards.sh](assets/install-repo-standards.sh)
- **Protección pública**: [assets/configure-public-branch-protection.sh](assets/configure-public-branch-protection.sh)
- **Templates**: [assets/templates/](assets/templates/)

---

## Commands

### Instalar estándares en el repo actual

```bash
bash dev-skills/repo-bootstrap/assets/install-repo-standards.sh
```

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

Si el usuario pide “crear un proyecto nuevo”, esta skill debe cargarse después de tener claridad suficiente del proyecto.

Primero se piensa.
Luego se decide.
Luego se bootstrapea.
Luego se construye.
