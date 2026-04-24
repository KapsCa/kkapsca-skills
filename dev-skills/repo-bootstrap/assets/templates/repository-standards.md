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
3. Merge a `main`
4. `release-please` crea o actualiza Release PR
5. Al mergear ese PR se publica tag/release

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
