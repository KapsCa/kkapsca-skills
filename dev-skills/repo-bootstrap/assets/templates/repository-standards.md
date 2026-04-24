# Repository Standards

Este repositorio sigue el flujo estándar de trabajo personal:

## Branching

- Nunca hacer push directo a `main`
- Usar ramas como `feat/*`, `fix/*`, `chore/*`, `docs/*`, `refactor/*`
- Integrar cambios mediante Pull Request

## Pull Requests

- Todo cambio debe pasar por PR
- Resolver conversaciones antes de merge
- En repos públicos, aplicar Classic Branch Protection si GitHub lo permite
- En repos privados Free personales, la protección local via hook sigue siendo obligatoria porque GitHub puede no enforcear reglas del servidor

## Checks, tests y auto-merge

- Ningún PR debe mergearse sin checks funcionales reales
- Todo repo debe tener al menos un workflow de validación útil para su stack
- Auto-merge solo se habilita cuando PR validation y checks funcionales ya existen y pasan
- Si GitHub Copilot code review está disponible por plan/licencia, se activa como capa extra de review

### Ejemplos de check funcional por stack

- Flutter → `flutter test`
- Go → `go test ./...`
- Python → `pytest`
- Node → `npm test`
- Repos de scripts/herramientas → lint/checks relevantes del propio repo

La regla universal no es un mismo comando.
La regla universal es que exista validación real antes de merge automático.

## Release Please

El uso de `release-please` es obligatorio en proyectos nuevos y forma parte de la definición base del repositorio.

### Reglas

- `feat:` genera incremento minor
- `fix:` genera incremento patch
- `!` o `BREAKING CHANGE:` genera major
- `docs:`, `chore:`, `refactor:` normalmente no disparan release funcional

### Flujo

1. Trabaja en una rama
2. Abre PR
3. Espera checks y review automático si aplica
4. Auto-merge cierra el PR cuando todo pasa
5. `release-please` crea o actualiza Release PR
6. Al mergear ese PR se publica tag/release

## Protección de main

### Siempre

- Hook local `pre-push` bloqueando `main`
- PR template con checklist de release y validación

### En repos públicos

Aplicar además Classic Branch Protection con:

- Require a pull request before merging
- Require conversation resolution before merging
- Require status checks before merging
- Require branches to be up to date before merging
- Apply to administrators
- No force pushes
- No deletions
- Required approvals: 0 para solo-dev

## Nota de solo-dev

No configurar `1 approval required` si eres la única persona programando, porque GitHub no permite aprobar tu propio PR y terminarás bloqueando el flujo.
