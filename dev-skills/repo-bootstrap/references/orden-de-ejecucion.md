# Orden de ejecución — Repo Bootstrap

Detalle local de `SKILL.md` (## Execution Steps).

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

La parte mecánica ya viene resuelta por el bootstrap; el criterio es lo que
se evalúa a mano:

- **Habilitación en el repo**: `configure-public-branch-protection.sh`
  habilita `allow_auto_merge=true` (PATCH `repos/<owner>/<repo>`,
  idempotente y fail-soft). Sin esa opción del repo, el `gh pr merge --auto`
  del workflow falla.
- **Pedido del merge**: la plantilla de `release-please.yml` agrega un paso
  posterior a la acción que corre `gh pr merge --auto --squash --repo
  <owner>/<repo> <number>`, con el número sacado del output `pr` de la
  acción y `--repo` explícito porque el job no hace checkout. Si no hubo
  release PR, el paso se saltea y no hace nada.
- **`--squash`, nunca `--merge`**: la protección que instala esta skill fija
  `required_linear_history=true`, que prohíbe merge commits; un auto-merge
  con `--merge` quedaría esperando para siempre.
- **PAT dedicado**: el release PR se crea con el secret
  `RELEASE_PLEASE_TOKEN`, no con `GITHUB_TOKEN`. Los eventos creados con
  `GITHUB_TOKEN` no disparan otros workflows, así que el PR nunca correría
  los checks del repo, quedarían pendientes y el auto-merge esperaría por
  siempre. El instalador avisa que hay que cargar el secret.

#### Checks requeridos: salto por job vs salto por workflow

Con status checks requeridos, la forma de saltear un trabajo decide si
bloquea el merge. GitHub cuenta `success`, `skipped` y `neutral` como
estados que aprueban el merge:

| Cómo se saltea | Resultado |
|---|---|
| `if:` a nivel de **job** | reporta `skipped` → **no bloquea** |
| Filtro a nivel de **workflow** | el check queda **pending** → **bloquea** |

Por eso saltear validaciones en los release PRs con un `if:` por job es
seguro, y lograr lo mismo con un filtro de `paths:`/`branches:` en el
workflow rompería el auto-merge.

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

