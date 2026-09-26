# Seguridad y cobertura por stack — Repo Bootstrap

Detalle local de `SKILL.md` (## Hard Rules).

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

