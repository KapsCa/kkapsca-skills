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

## Seguridad

Estas reglas no son opcionales, y cada una tiene una herramienta que la hace cumplir sola. No dependen de que alguien se acuerde.

### Secretos

- Nunca se escribe una contraseña, una clave ni un token en el código. Solo variables de entorno o secretos de GitHub.
- El `.gitignore` ignora los archivos de credenciales, incluidos los de nombre en español (`credenciales*`, `secretos*`, `contrasenas*`). El archivo de ejemplo (`.env.example`) **sí** se versiona, porque no tiene valores reales.
- El workflow `gitleaks` revisa cada cambio y **falla** si encuentra un secreto. También corre una vez por semana, porque un secreto pudo haber entrado antes de que existiera este chequeo.
- **Si un secreto llegó a un commit, se considera comprometido: hay que rotarlo.** Borrar la línea no alcanza. En el historial sigue estando, y en un repo público ya lo vio cualquiera.

### Dependencias

- El archivo de versiones exactas (`package-lock.json`, `go.sum`, `pubspec.lock`) se versiona, y la instalación es reproducible.
- `dependabot` avisa cada semana si alguna herramienta o librería tiene una versión nueva, y abre un PR.
- `audit` compara lo que **ya tenés** contra la lista pública de librerías con fallas conocidas, y falla en severidad alta. Son dos preguntas distintas: una es "¿salió algo nuevo?", la otra es "¿lo que tengo está fallado hoy?".

### Análisis estático

- `codeql` revisa el código buscando formas conocidas de escribir cosas inseguras.
- **Solo entiende algunos lenguajes.** Dart/Flutter, shell y PowerShell quedan afuera. Si tu proyecto es de esos, el chequeo corre y no encuentra nada: no es un error, es un hueco conocido.
- Solo funciona en repos **públicos**. En privados necesita una licencia paga, así que no se instala.
- Si el repo todavía no tiene código, el chequeo se saltea solo en vez de fallar. Un proyecto nuevo no nace con el CI en rojo.

### Permisos y versiones exactas

- Cada workflow declara sus permisos, y los mínimos. La llave abre lo que ese trabajo necesita, no toda la casa. El permiso por defecto del repo es de solo lectura.
- Cada acción de GitHub se referencia por **versión exacta**, nunca por "la última". Así, si alguien toma el control de esa herramienta, no puede cambiar qué significa "la última" y meter código sin que nadie lo revise.

### Si un chequeo de seguridad no corre

**No se mergea.** Un chequeo ausente no es un chequeo aprobado. Si un workflow de seguridad falló, se rompió o se salteó sin motivo, el cambio no pasa.
