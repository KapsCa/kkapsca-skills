# Governance — Flujo de Contribución y Branch Protection

> **Vista derivada operativa.** Los recursos normativos de gobernanza viven en [`dev-skills/repo-bootstrap/SKILL.md`](../dev-skills/repo-bootstrap/SKILL.md).
> Este documento resume las reglas para consulta rápida sin contradecir la fuente. Si existe conflicto, prevalece `repo-bootstrap/SKILL.md`.

## Branch Protection en `main`

Este repositorio **requiere** que la rama `main` tenga protección habilitada en GitHub. La configuración de protección varía según el modo de gobernanza:

| Modo | Approvals requeridos | Aplica a |
|------|---------------------|----------|
| **Solo-dev** | 0 (GitHub no permite auto-aprobarse) | Proyectos personales / un solo contribuidor |
| **Team** | ≥ 1 | Equipos con múltiples contribuidores |

La configuración se aplica **manualmente en la interfaz de GitHub** (Settings → Branches → Branch protection rules), complementada por el hook local `pre-push` que instala `repo-bootstrap`.

### Configuración requerida (modo Team)

En GitHub: **Settings → Branches → Branch protection rules**

| Configuración | Valor |
|-------------|-------|
| Branch name pattern | `main` |
| ✅ Require pull request reviews before merging | ≥ 1 aprobación requerida |
| ✅ Require status checks to pass before merging | selecciona los checks de PR validation |
| ✅ Require conversation resolution | habilitado |
| ✅ Require branches to be up to date before merging | habilitado |
| ❌ Allow force pushes | **DESACTIVADO** |
| ❌ Allow deletions | **DESACTIVADO** |
| ✅ Include administrators | habilitado |

### Configuración requerida (modo Solo-dev)

| Configuración | Valor |
|-------------|-------|
| Branch name pattern | `main` |
| ✅ Require pull request reviews before merging | **0 aprobaciones requeridas** |
| ✅ Require status checks to pass before merging | selecciona los checks de PR validation |
| ✅ Require conversation resolution | habilitado |
| ✅ Require branches to be up to date before merging | habilitado |
| ❌ Allow force pushes | **DESACTIVADO** |
| ❌ Allow deletions | **DESACTIVADO** |
| ✅ Include administrators | habilitado |

> **Nota para repos privados Free**: GitHub puede mostrar "Not enforced" en la UI de branch protection. En ese caso, el hook local `pre-push` es la red de seguridad real. Ver `repo-bootstrap` para la instalación del hook.

### Por qué esto importa

- **Sin protección en main**: cualquiera puede hacer push directo → se pierde trazabilidad
- **Sin require approvals** (modo team): se pueden mergear cambios sin review
- **Sin status checks**: cambios que no pasan validaciones pueden llegar a main

## Flujo de Contribución

Regla de oro: **No seas ese wey que hace push directo a main** 😤

### Pasos

#### Modo Solo-dev

1. Crear branch descriptivo: `feature/nombre-descriptivo` o `fix/nombre-descriptivo`
2. Trabajar con commits en formato **Conventional Commits**
3. Abrir Pull Request con:
   - Labels `type:*` y `status:approved`
   - Referencia a issue (ej. `Closes #N`)
   - Todos los status checks pasando
4. Esperar a que pasen los checks de validación (no requiere approvals)
5. **Auto-merge** después de validación exitosa + checks verdes

#### Modo Team

1. Crear branch descriptivo: `feature/nombre-descriptivo` o `fix/nombre-descriptivo`
2. Trabajar con commits en formato **Conventional Commits**
3. Abrir Pull Request con:
   - Labels `type:*` y `status:approved`
   - Referencia a issue (ej. `Closes #N`)
   - Todos los status checks pasando
4. Esperar ≥1 approval + validación exitosa
5. **Auto-merge** solo después de approvals + checks verdes

### Workflow esperado

#### Solo-dev

```text
1. Crear branch feature/fix-descriptive-name
2. Trabajar con commits Conventional Commits
3. Abrir PR con labels type:*, status:approved
4. Esperar a que pase PR validation (incluye conventional commits check)
5. Una vez checks verdes → merge (approvals NO requeridos)
6. release-please detecta y crea Release PR
7. Al mergear Release PR → tag + release
```

#### Team

```text
1. Crear branch feature/fix-descriptive-name
2. Trabajar con commits Conventional Commits
3. Abrir PR con labels type:*, status:approved
4. Esperar a que pase PR validation (incluye conventional commits check)
5. Una vez approvals + checks verdes → merge
6. release-please detecta y crea Release PR
7. Al mergear Release PR → tag + release
```

## Repo Guardrails (Capa Advisory)

Este repositorio cuenta con la skill `repo-guardrails` como capa **advisory/warning-first** que revisa el estado de ramas, PRs, labels y commits antes de acciones críticas.

**Nota importante**: `repo-guardrails` NO bloquea nada; es una ayuda visual que opera sobre las reglas definidas en este documento y en `dev-skills/repo-bootstrap/SKILL.md`. Las reglas normativas y el bloqueo real los impone `repo-bootstrap` vía hook `pre-push` y branch protection.

Antes de push / PR / merge, `repo-guardrails` revisa:
- Push directo a `main`, `master` o `release`
- Existencia de PR abierto para la rama
- Formato Conventional Commits
- Labels apropiados en el PR
- Checks pasando
- Plantilla de PR llenada

---

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
