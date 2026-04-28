# Branch Protection Settings — Requerido en GitHub

> Este archivo documenta la configuración necesaria de branch protection en GitHub. Los cambios deben aplicarse **manualmente en la interfaz de GitHub**; no pueden configurarse mediante archivos en el repositorio.

## Configuración requerida para `main`

### En GitHub: Settings → Branches → Branch protection rules

| Configuración | Valor |
|-------------|-------|
| Branch name pattern | `main` |
| ✅ Require pull request reviews before merging | 1 approve required |
| ✅ Require status checks to pass before merging | (selecciona los checks de PR validation) |
| ✅ Require conversation resolution | enabled |
| ✅ Require branches to be up to date before merging | enabled |
| ❌ Allow force pushes | **DESACTIVADO** |
| ❌ Allow deletions | **DESACTIVADO** |
| ✅ Include administrators | enabled |

## Por qué esto importa

- **Sin protección en main**: anyone puede hacer push directo → se pierde trazabilidad
- **Sin require approvals**: se pueden mergear cambios sin review
- **Sin status checks**: cambios que no pasan validaciones pueden llegar a main

## Workflow esperado

```
1. Crear branch feature/fix-descriptive-name
2. Trabajar con commits Conventional Commits
3. Abrir PR con labels type:*, status:approved
4. esperar a que pase PR validation (incluye conventional commits check)
5. una vez approvals + checks verdes → merge
6. release-please detecta y crea Release PR
7. al mergear Release PR → tag + release
```

##記住

- Este documento es **solo lectura/reference**
- La configuración real se hace en GitHub
- Repo admins deben aplicar estos settings manualmente

---

Para dudas sobre el flujo de contribución, ver README.md sección "Protección de ramas".
