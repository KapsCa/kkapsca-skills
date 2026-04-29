# KkapsCa Skills Repository

> Skills públicas para pasar de una idea a un producto y de un producto a una implementación técnica con criterio en un servicio de edición **AI-first**.

Este repositorio reúne skills pensadas desde la experiencia personal de **KkapsCa**, optimizadas para flujos de trabajo asistidos por IA (como Cursor, Windsurf o **opencode**) y redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

Al mismo tiempo, estas skills están **optimizadas para trabajar especialmente bien dentro del stack de [Gentle AI](https://github.com/Gentleman-Programming/gentle-ai)** y flujos coordinados por **`sdd-orchestrator`**.

En otras palabras:

- **sí son reutilizables** fuera de ese ecosistema,
- pero su mejor rendimiento aparece cuando se usan como **potenciador del stack de Gentle AI**.

La filosofía es simple:

- no correr al código sin entender el problema,
- no elegir tecnologías por moda,
- no meter complejidad antes de tiempo,
- construir con fundamentos, no con ocurrencias.

## Nota de entorno

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** para mantener un entorno más consistente con Linux y evitar fricción innecesaria con rutas, shells y dependencias.

Referencias útiles:

- https://learn.microsoft.com/windows/wsl/
- https://learn.microsoft.com/windows/wsl/install
- https://learn.microsoft.com/windows/wsl/filesystems

---

## Mejor experiencia de uso

Estas skills están pensadas para ser útiles por sí solas, pero fueron afinadas para que den mejores resultados cuando:

- el agente opera con contexto consistente,
- existe un `sdd-orchestrator` coordinando fases o subagentes,
- y el entorno ya sigue las convenciones del stack de Gentle AI.

Si quieres la mejor experiencia de instalación, ejecución y contexto compartido, ve al repo de **Gentle AI** y sigue su guía:

- https://github.com/Gentleman-Programming/gentle-ai

La idea correcta no es vender estas skills como piezas aisladas mágicas, sino como un **potenciador del stack** para lograr mejor ejecución, menos ambigüedad y mejores resultados con agentes IA.

### Windows + opencode

- En Windows, usa **WSL2** como entorno base para opencode.
- Evita mezclar rutas de Windows y Linux dentro del mismo flujo.
- Si una guía o skill asume shell Unix, WSL te deja mucho más cerca de ese comportamiento real.

---

## Qué contiene este repositorio

```text
KkapsCa-project-kickstart/
├── README.md
├── brainstorm/
│   └── SKILL.md
├── product-discovery/
│   └── SKILL.md
├── project-init/
│   ├── SKILL.md
│   └── README.md
├── tech-feasibility/
│   └── SKILL.md
└── dev-skills/
    ├── flutter-personal-standards/
    │   └── SKILL.md
    └── repo-bootstrap/
        ├── SKILL.md
        └── assets/
```

Se divide en dos grupos:

### 1. Skills de inicio de proyecto
Sirven para aterrizar una idea antes de construir.

- **brainstorm** → convierte una idea vaga en un Product Brief.
- **product-discovery** → valida mercado, usuario, competencia y negocio.
- **project-init** → cierra la brecha entre discovery y factibilidad (opcional por bypass).
- **tech-feasibility** → evalúa stack, riesgos, arquitectura y esfuerzo.

### 2. Skills de desarrollo
Sirven cuando el proyecto ya tiene claridad suficiente y toca implementar.

- **dev-skills/flutter-personal-standards** → criterio personal para Flutter y puente hacia las skills oficiales.
- **dev-skills/repo-bootstrap** → prepara el repositorio para ejecutar bien: PR workflow, hook local, release-please y estándares base.

### 3. Skills internas / exclusivas de empresa
Estas skills no se distribuyen en este repo público. Si existe una convención interna, vive en su repositorio o instalación privada correspondiente.

---

## Pipeline recomendado

El flujo ideal para un proyecto nuevo es este:

```text
Idea → brainstorm → product-discovery → project-init → tech-feasibility → repo-bootstrap → Desarrollo
```

**Ruta ligera (bypass de project-init)**:
```text
Idea → brainstorm → product-discovery → tech-feasibility → repo-bootstrap → Desarrollo
```

**Condiciones para bypass de project-init**:
- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con Discovery Report directo

Pero este repositorio **no es dogmático**.

Si ya tienes trabajo previo real, puedes entrar más adelante en el pipeline.

### Ejemplos

- Si solo tienes una idea vaga → empieza en **brainstorm**.
- Si ya tienes claro problema, usuario y MVP → puedes entrar en **product-discovery**.
- Si ya tienes Discovery Report completo y quieres cerrar brecha → usa **project-init** (recomendado).
- Si ya tienes claridad funcional y solo falta tech → entra en **tech-feasibility**.
- Si ya tienes claridad funcional y técnica → usa una **dev-skill**.

La regla no es "seguir pasos porque sí".
La regla es **no saltarte el pensamiento que todavía no has hecho**.

---

## Para quién sirve

Este repo puede servirle a:

- developers que arrancan proyectos desde cero,
- founders técnicos,
- builders indie,
- estudiantes que quieren aprender a pensar antes de programar,
- equipos pequeños que necesitan estructura sin caer en burocracia absurda.

---

## Instalación para opencode

Hoy este repo **no se autodetecta solo por existir en tu filesystem**. opencode lista las skills desde `~/.config/opencode/skills`, así que después de clonar el repo hay que registrarlas una vez.

### Primer paso: Bootstrap local

El método recomendado y más sencillo es usar el comando único de bootstrap. Esto garantiza que siempre uses el flujo correcto sin preocuparte por permisos de ejecución:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: `bash scripts/bootstrap.sh` funciona **siempre**, sin importar si los archivos tienen el bit de ejecución activado. Si prefieres usar `./scripts/bootstrap.sh`, asegúrate de que el archivo sea ejecutable (`chmod +x scripts/bootstrap.sh`).

#### Opciones del bootstrap

Por defecto, `bootstrap.sh` crea **symlinks** (ideal para mantener las skills actualizadas al hacer `git pull`). Si prefieres una copia física independiente:

```bash
bash scripts/bootstrap.sh --copy
```

Después de ejecutar el bootstrap, **reinicia opencode** para que refresque la lista de skills disponibles.

### Desinstalar

```bash
bash scripts/uninstall-opencode-skills.sh
```

### Qué hace el instalador

- registra cada carpeta que contiene `SKILL.md`
- instala tanto las skills raíz como las de `dev-skills/`
- usa `~/.config/opencode/skills` por defecto (configurable vía `OPENCODE_SKILLS_DIR`)
- respeta conflictos si ya existe una skill con el mismo nombre y no fue instalada por este repo

> Si quieres instalar en otra ubicación, exporta `OPENCODE_SKILLS_DIR=/ruta/destino` antes de correr el script.

---

### Aclaración importante: Engram vs Descubrimiento local

Es común confundir el papel de **Engram** con el registro de skills en opencode. Son cosas distintas y ambas cumplen roles diferentes:

| Concepto | ¿Qué hace? | ¿Registra skills en opencode? |
|----------|------------|-------------------------------|
| **Engram** | Guarda memoria persistente del proyecto, contexto, decisiones y flujos de trabajo entre sesiones. | ❌ No |
| **Bootstrap / Instalador** | Crea symlinks o copias de las skills en `~/.config/opencode/skills` para que opencode las detecte. | ✅ Sí |
| **`.atl/skill-registry.md`** | Catálogo de skills del proyecto para que el `sdd-orchestrator` resuelva estándares y reglas de proyecto. | ❌ No |

#### Resumen práctico

1. **Engram** → memoria y contexto que sobrevive entre sesiones.
2. **Bootstrap (`bash scripts/bootstrap.sh`)** → hace que opencode vea tus skills localmente.
3. **`.atl/skill-registry.md`** → solo lo usa la orquestación SDD, no afecta la detección local de skills.

Si tu repo ya usa Engram, úsalo para recordar contexto y decisiones; **igual debes correr el bootstrap** para que opencode detecte las skills.

---

## Cómo usarlo

### Si comienzas con una idea

1. Usa `brainstorm`
2. Continúa con `product-discovery`
3. Sigue con `project-init` (o sáltala solo si aplica el bypass)
4. Continúa con `tech-feasibility`
5. Aplica `dev-skills/repo-bootstrap`
6. Pasa a la skill de desarrollo adecuada

### Si ya estás en etapa de implementación

Ve directo a `dev-skills/` y usa la skill que corresponda al stack.
Si el repo aún no tiene estándares operativos claros, aplica primero `repo-bootstrap`.

---

## Filosofía del repositorio

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**

---

## Estado actual

Skills disponibles hoy:

- `brainstorm` (Paso 1)
- `product-discovery` (Paso 2)
- `project-init` (Paso 3 — transición, opcional para proyectos pequeños)
- `tech-feasibility` (Paso 4)
- `flutter-personal-standards`
- `repo-bootstrap`

Skills internas hoy:

- (no distribuidas en este repo público)

Skills futuras posibles:

- backend
- arquitectura
- testing
- bases de datos
- automatización

---

## Versionado y releases

Este repositorio usa **release-please** para manejar versionado semántico, changelog y GitHub Releases.

### Flujo

1. Los cambios se integran por Pull Request usando Conventional Commits.
2. Al llegar cambios a `main`, `release-please` analiza los commits.
3. GitHub crea o actualiza un **Release PR** con versión y changelog.
4. Al mergear ese Release PR, se publica el tag y el GitHub Release.

### Tipos de commits y su impacto en versiones

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
| `[skip release]` | ❌ No | fuerza skip |

> **Nota**: Commits de `perf:` pueden disparar release depending configuración, pero típicamente no lo hacen.

### Release-please跳过

Para evitar que un commit dispare release, añade `[skip release]` o `[no-release]` en el mensaje:

```bash
git commit -m "chore: update deps [skip release]"
```

### Reglas de commits

- `feat:` → minor
- `fix:` → patch
- `!` o `BREAKING CHANGE:` → major
- `docs:`, `chore:`, `refactor:`, `test:`, `ci:` → normalmente no disparan release funcional

La meta es NO versionar manualmente a mano ni mantener changelogs a puro copy-paste.

---

## Protección de ramas

### main branch protection

Este repositorio **requiere** que la rama `main` tenga protección habilitada en GitHub:

1. Ve a **Settings → Branches → Branch protection rules**
2. Crea una regla para `main`
3. Configura:
   - ✅ **Require approvals** (al menos 1)
   - ✅ **Require status checks to pass** antes de merge
   - ✅ **Require conversation resolution** antes de merge
   - ❌ **Allow force pushes** → NO permitido
   - ❌ **Allow deletions** → NO permitido

### Flujo de contribución

1. **No seas ese wey que hace push directo a main** 😤
2. Todo cambio entra por **Pull Request**
3. El PR debe tener:
   - Labels `type:*` y `status:approved`
   - Referencia a issue (Closes #N)
   - Commits en formato Conventional Commits
   - Todos los status checks pasando
4. **Auto-merge** solo después de validación exitosa

La meta es mantener historial limpio, cambios trazables y releases automatizados sin intervención manual.

---

## Agradecimientos

Gracias a [Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai).

Usando esa herramienta fue posible revisar, corregir y refinar este repositorio mientras también se fortalecía el proceso de aprendizaje técnico y programación con mejores fundamentos.

---

## Autor

**KkapsCa**

GitHub: https://github.com/KapsCa/kkapsca-skills
