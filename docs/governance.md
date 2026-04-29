# Governance — Flujo de Contribución y Branch Protection

Este documento describe las reglas operativas de este repositorio: protección de ramas, flujo de Pull Requests, validaciones y convenciones de commits.

## Branch Protection en `main`

Este repositorio **requiere** que la rama `main` tenga protección habilitada en GitHub. La configuración se aplica **manualmente en la interfaz de GitHub** (no se puede configurar mediante archivos en el repositorio).

### Configuración requerida

En GitHub: **Settings → Branches → Branch protection rules**

| Configuración | Valor |
|-------------|-------|
| Branch name pattern | `main` |
| ✅ Require pull request reviews before merging | 1 aprobación requerida |
| ✅ Require status checks to pass before merging | selecciona los checks de PR validation |
| ✅ Require conversation resolution | habilitado |
| ✅ Require branches to be up to date before merging | habilitado |
| ❌ Allow force pushes | **DESACTIVADO** |
| ❌ Allow deletions | **DESACTIVADO** |
| ✅ Include administrators | habilitado |

### Por qué esto importa

- **Sin protección en main**: cualquiera puede hacer push directo → se pierde trazabilidad
- **Sin require approvals**: se pueden mergear cambios sin review
- **Sin status checks**: cambios que no pasan validaciones pueden llegar a main

## Flujo de Contribución

Regla de oro: **No seas ese wey que hace push directo a main** 😤

### Pasos

1. Crear branch descriptivo: `feature/nombre-descriptivo` o `fix/nombre-descriptivo`
2. Trabajar con commits en formato **Conventional Commits**
3. Abrir Pull Request con:
   - Labels `type:*` y `status:approved`
   - Referencia a issue (ej. `Closes #N`)
   - Todos los status checks pasando
4. Esperar aprobación y validación
5. **Auto-merge** solo después de validación exitosa + checks verdes

### Workflow esperado

```text
1. Crear branch feature/fix-descriptive-name
2. Trabajar con commits Conventional Commits
3. Abrir PR con labels type:*, status:approved
4. Esperar a que pase PR validation (incluye conventional commits check)
5. Una vez approvals + checks verdes → merge
6. release-please detecta y crea Release PR
7. Al mergear Release PR → tag + release
```

## Conventional Commits

Todos los commits deben seguir el estándar [Conventional Commits](https://www.conventionalcommits.org/):

### Formato

```text
<tipo>(<área opcional>): <descripción corta>

[body opcional]

[footer opcional: Closes #N, [skip release], etc.]
```

### Tipos comunes

| Tipo | ¿Cuándo usarlo? | ¿Dispara release? |
|------|-----------------|-------------------|
| `feat:` | Nueva funcionalidad | ✅ Sí (minor) |
| `fix:` | Corrección de bug | ✅ Sí (patch) |
| `docs:` | Cambios en documentación | ❌ No |
| `chore:` | Mantenimiento, deps, config | ❌ No |
| `refactor:` | Refactorización sin cambio funcional | ❌ No |
| `test:` | Agregar o modificar tests | ❌ No |
| `ci:` | Cambios en CI/CD | ❌ No |
| `build:` | Cambios en build system | ❌ No |
| `style:` | Formato, no cambios lógicos | ❌ No |
| `perf:` | Mejoras de rendimiento | ❌ Tal vez* |

### Breaking Changes

Para cambios incompatibles (major version):

```bash
git commit -m "feat!: cambio que rompe compatibilidad"
# o
git commit -m "feat: nueva feature

BREAKING CHANGE: se removió el endpoint /old-api"
```

## Reglas de releases

- `feat:` → minor (0.1.0 → 0.2.0)
- `fix:` → patch (0.0.1 → 0.0.2)
- `!` o `BREAKING CHANGE:` → major (0.1.0 → 1.0.0)
- `docs:`, `chore:`, `refactor:`, `test:`, `ci:` → normalmente no disparan release funcional

La meta es NO versionar manualmente a mano ni mantener changelogs a puro copy-paste.
