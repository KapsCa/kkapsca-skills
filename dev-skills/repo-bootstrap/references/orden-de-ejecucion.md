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

