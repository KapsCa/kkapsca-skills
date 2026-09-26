# Seguridad — Baseline de CI/CD

> **Vista derivada operativa.** Las reglas normativas viven en [`dev-skills/repo-bootstrap/SKILL.md`](../dev-skills/repo-bootstrap/SKILL.md).
> Este documento las explica para leerlas sin abrir una skill, sin contradecirlas. Si hay conflicto, prevalece `repo-bootstrap/SKILL.md`.

## Qué agrega el instalador

Un repo nuevo nace con seis piezas de seguridad. Ninguna depende de que alguien se acuerde de correrlas:

| Pieza | Qué responde | Cuándo corre |
|---|---|---|
| `gitleaks` | ¿Alguien escribió una contraseña o una clave en el código? | En cada PR, en cada push a `main`, y una vez por semana |
| `dependabot` | ¿Salió una versión nueva de algo que uso? | Una vez por semana |
| `codeql` | ¿Hay formas conocidas de escribir código inseguro? | En cada PR, en cada push a `main`, y una vez por semana |
| `audit` | ¿Algo que YA tengo tiene una falla conocida hoy? | En cada PR, en cada push a `main`, y una vez por semana |
| `SECURITY.md` | ¿A quién le aviso si encuentro un problema? | No corre: es una guía |
| Bloque en `.gitignore` | ¿Qué archivos no deben guardarse nunca? | No corre: es una lista |

## La diferencia entre las dos que parecen iguales

`dependabot` y `audit` se confunden todo el tiempo, y son preguntas distintas:

- **`dependabot`** mira hacia adelante: *"¿salió algo nuevo de lo que uso?"*
- **`audit`** mira el presente: *"¿lo que tengo ahora mismo tiene una falla conocida?"*

Hacen falta las dos. Una versión nueva puede traer un arreglo, pero también puede traer un problema nuevo: por eso el updater espera unos días antes de proponerla.

## Qué cubre cada stack

| Stack | Secretos | Versiones nuevas | Análisis estático | Falla en librerías |
|---|---|---|---|---|
| Go | ✅ | ✅ | ✅ | ✅ |
| Python | ✅ | ✅ | ✅ | ✅ |
| Node / TypeScript | ✅ | ✅ | ✅ | ✅ |
| Rust | ✅ | ✅ | ✅ | ❌ |
| **Dart / Flutter** | ✅ | ✅ | ❌ | ❌ |
| Shell (bash) | ✅ | n/a | ❌ | n/a |
| PowerShell | ✅ | n/a | ❌ | n/a |

## Huecos conocidos

Están acá a propósito. Es mejor saber qué **no** está cubierto que asumir cobertura que no existe.

### CodeQL no entiende Dart, shell ni PowerShell

Sus lenguajes soportados son C/C++, C#, Go, Java/Kotlin, JavaScript/TypeScript, Python, Ruby, Rust, Swift y los propios workflows de GitHub Actions.

En un proyecto de Flutter, `codeql.yml` **corre y no encuentra nada**. No es un error: es un hueco. Si alguien te dice "tenemos análisis estático", en Flutter eso es falso.

### Dart/Flutter no tiene auditoría de librerías en CI

No existe una herramienta oficial equivalente a `npm audit` o `govulncheck` para Flutter. Por eso `audit.yml` no lo cubre. **Es el único stack del ecosistema sin ninguna capa automática de análisis ni auditoría.**

### Un repo sin código todavía no tiene lenguaje

Ese es el estado inicial normal de un proyecto nuevo: pedís el proyecto y todavía no sabés en qué lenguaje va a ser. En ese caso:

- `codeql.yml` **se saltea solo** (tiene una guarda). Sin esa guarda, el CI nace en rojo: CodeQL no se saltea cuando no hay código, **falla**.
- `audit.yml` saltea todos sus pasos y pasa sin quejarse.
- `dependabot.yml` queda solo con `github-actions`, que aplica a cualquier repo.
- El instalador no inventa ecosistemas que no existen.

Cada pieza se activa sola cuando aparece el código.

## Límites de plan

| Herramienta | Límite |
|---|---|
| **CodeQL** | Gratis en repos **públicos**. En privados necesita licencia de GitHub Code Security, así que el instalador **solo lo copia en públicos**. Si el repo pasa a ser público, se vuelve a correr el instalador |
| **gitleaks** | Gratis con **cuenta personal**. Si el repo pasa a una **organización**, necesita una licencia gratuita de gitleaks.io |

## Cómo verificar que está funcionando

```bash
# ¿Todos los workflows declaran sus permisos?
grep -L "^permissions:" .github/workflows/*.yml

# ¿Queda alguna acción sin versión exacta?
grep -rn 'uses:.*@' .github/workflows/ | grep -vE '@[0-9a-f]{40}'

# ¿El permiso por defecto del repo es de solo lectura?
gh api "repos/OWNER/REPO/actions/permissions/workflow"

# ¿Ningún job de dependabot está fallando?
gh run list --limit 20 | grep "in /. - Update"
```

## Qué hacer cuando algo falla

| Qué ves | Qué significa | Qué hacer |
|---|---|---|
| `gitleaks` falla | Encontró un secreto | **Rotar la credencial.** No alcanza con borrar la línea. Si es un falso positivo, agregarlo a `gitleaks.toml` |
| `audit` falla | Una librería tuya tiene una falla conocida | Esperar el PR de dependabot, o actualizar la librería a mano |
| `codeql` falla | Encontró un patrón inseguro | Revisar el hallazgo en la pestaña Security. Puede ser un falso positivo, pero se revisa |
| Un job de dependabot falla | Declaraste un ecosistema que el repo no tiene | Borrar ese bloque de `.github/dependabot.yml`. Dependabot **no lo saltea: falla** |
| `codeql` falla en un repo sin código | Falta la guarda | Actualizar `codeql.yml` desde `repo-bootstrap` |

## Dónde vive cada regla

| Nivel | Archivo | Rol |
|---|---|---|
| **Normativo** | `dev-skills/repo-bootstrap/SKILL.md` | Fuente de verdad. Si hay conflicto, gana este |
| **Por repo** | `docs/repository-standards.md` | Lo que aterriza en cada proyecto |
| **Operativo** | este documento | Explicación para leer sin abrir una skill |
| **Plantillas** | `dev-skills/repo-bootstrap/assets/templates/` | Los archivos reales que se copian |
| **Instalador** | `dev-skills/repo-bootstrap/assets/install-repo-standards.sh` | Quien los coloca |
