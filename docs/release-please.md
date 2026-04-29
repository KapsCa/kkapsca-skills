# Release-please — Versionado Automatizado

Este repositorio usa **[release-please](https://github.com/googleapis/release-please)** para manejar versionado semántico, changelog y GitHub Releases de forma automática.

## Qué hace release-please

1. Analiza los commits en `main` que siguen **Conventional Commits**
2. Determina el siguiente número de versión (major, minor, patch)
3. Crea o actualiza un **Release PR** con changelog automático
4. Al mergear ese Release PR, publica el tag y el GitHub Release

## Flujo de versionado

```text
Cambios → Pull Request → Merge a main → release-please analiza commits → Crea/actualiza Release PR → Merge Release PR → Tag + GitHub Release
```

## Tipos de commits y su impacto

| Tipo de commit | ¿Dispara release? | Tipo de cambio |
|----------------|-------------------|---------------|
| `feat:` | ✅ Sí | minor (0.1.0 → 0.2.0) |
| `fix:` | ✅ Sí | patch (0.0.1 → 0.0.2) |
| `feat:` + `!` o `BREAKING CHANGE:` | ✅ Sí | major (0.1.0 → 1.0.0) |
| `fix:` + `!` o `BREAKING CHANGE:` | ✅ Sí | major (0.1.0 → 1.0.0) |
| `docs:` | ❌ No | — |
| `chore:` | ❌ No | — |
| `refactor:` | ❌ No | — |
| `test:` | ❌ No | — |
| `ci:` | ❌ No | — |
| `build:` | ❌ No | — |
| `style:` | ❌ No | — |
| `perf:` | ❌ Tal vez* | — |

> **Nota**: Commits de `perf:` pueden disparar release dependiendo de la configuración, pero típicamente no lo hacen.

## Reglas de versionado

- `feat:` → minor
- `fix:` → patch
- `!` o `BREAKING CHANGE:` → major
- `docs:`, `chore:`, `refactor:`, `test:`, `ci:` → normalmente no disparan release funcional

## Skip release

Para evitar que un commit dispare release, añade `[skip release]` o `[no-release]` en el mensaje:

```bash
git commit -m "chore: update deps [skip release]"
```

## Configuración de Conventional Commits

Los commits deben seguir el formato:

```text
<tipo>(<área opcional>): <descripción corta>

[body opcional]

[footer opcional: Closes #N, [skip release], BREAKING CHANGE: ...]
```

### Ejemplos

```bash
git commit -m "feat: add new skill for database setup"
git commit -m "fix: correct bootstrap symlink path"
git commit -m "feat!: change skill registry format

BREAKING CHANGE: skill-registry.md now requires version field"
git commit -m "docs: update README structure [skip release]"
```

## La meta

NO versionar manualmente a mano ni mantener changelogs a puro copy-paste. release-please automatiza todo el flujo de releases basado en los commits.
