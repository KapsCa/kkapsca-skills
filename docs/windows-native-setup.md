# Instalación del ecosistema en Windows nativo

> **Este documento es un runbook ejecutable.** Está escrito para que un agente (pi) lo lea y ejecute de arriba hacia abajo en una máquina Windows, sin adivinar pasos ni inventar valores.

## Para quién es esto

Para quien quiere el ecosistema completo —pi, Gentle AI, Engram, skills, MCP, subagentes— funcionando en **Windows nativo**, sin WSL.

Si preferís WSL2, esa ruta sigue documentada y es más simple: ver [Configuración WSL](wsl-setup.md). Este documento existe porque WSL no siempre es una opción, y porque varias piezas del ecosistema se comportan distinto en Windows nativo sin que eso esté documentado en ningún lado.

## Cómo leer y ejecutar este documento

| Concepto | Regla |
|---|---|
| Bloques `powershell` | Se ejecutan en **PowerShell** (Windows PowerShell 5.1 o PowerShell 7) |
| Bloques `bash` | Se ejecutan en **Git Bash**, no en CMD ni en PowerShell |
| `%USERPROFILE%` | Placeholder de tu carpeta de usuario. En PowerShell también podés usar `$env:USERPROFILE` |
| Contenido de archivos | Los bloques JSON son **el contenido literal** del archivo indicado |
| Rutas en JSON | La barra invertida se escapa: `C:\\Users\\<user>` |

> **Regla de oro:** no mezcles rutas de WSL (`/mnt/c/...`) con rutas nativas de Windows (`C:\...`) en el mismo flujo. Si estás en Windows nativo, todo es `C:\...` o `/c/...` dentro de Git Bash.

## Qué se instala

| Componente | Rol | Cómo se obtiene en Windows |
|---|---|---|
| **pi** (`@earendil-works/pi-coding-agent`) | El agente | npm global |
| **Git for Windows** | Provee el shell `bash` que pi usa | Instalador o winget |
| **Go** | Toolchain para compilar Gentle AI | Instalador o winget |
| **gentle-ai** (CLI) | Instalador y gestor del ecosistema | **Solo desde fuente** con `go install` |
| **gentle-pi** (repo `gentle-shell`) | Harness de pi: ODD, SDD, subagentes, tema, skills | Paquete de pi |
| **gentle-engram** + **engram** | Memoria persistente | Paquete de pi + binario |
| **pi-mcp-adapter** | Puente MCP | Paquete de pi |
| **pi-lens** | Diagnósticos LSP y análisis | Paquete de pi |
| **pi-web-access** | Búsqueda y lectura web | Paquete de pi |
| **pi-btw** | Conversación lateral | Paquete de pi |
| **@juicesharp/rpiv-ask-user-question** | Preguntas interactivas al humano | Paquete de pi |
| **pi-intercom** (opcional) | Mensajería entre sesiones | Paquete de pi |
| **codegraph** | Grafo de código para consultas | npm global |
| **Skills** | Capacidades del agente | Tres fuentes, ver Paso 7 |

---

## Paso 0 — Prerequisitos

### Versión de Windows

Windows 10 versión 2004 (build 19041) o superior, o Windows 11. Arquitectura x64 o arm64.

### Instalar los prerequisitos

```powershell
winget install --id Git.Git --exact
winget install --id OpenJS.NodeJS.LTS --exact
winget install --id GoLang.Go --exact
```

Alternativa: descargar los instaladores manualmente desde [git-scm.com](https://git-scm.com/download/win), [nodejs.org](https://nodejs.org/) y [go.dev/dl](https://go.dev/dl/).

> **Go es obligatorio, no opcional.** La distribución oficial de Gentle AI para Windows está en pausa hasta que se restablezca la firma Authenticode, así que no existen binarios ni paquete Scoop. La única vía es compilar desde fuente, y eso requiere **Go 1.25.10 o superior**.

### Verificar prerequisitos

```powershell
git --version
node --version
npm --version
go version
```

**Esperado:** Go debe reportar `go1.25.10` o superior. Si reporta menos, actualizá antes de continuar — el Paso 2 va a fallar.

### Cerrar y reabrir la terminal

Después de instalar, cerrá **todas** las terminales y abrí una nueva. Si no, los binarios recién instalados no están en `PATH` y los pasos siguientes fallan con "no se reconoce el comando".

---

## Paso 1 — Instalar pi

```powershell
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
pi --version
```

**Esperado:** un número de versión, por ejemplo `0.85.1`.

### Si `pi` no se reconoce

El directorio global de npm no está en `PATH`. Averiguá dónde quedó:

```powershell
npm config get prefix
```

Agregá ese directorio (normalmente `%APPDATA%\npm`) a `PATH` y reabrí la terminal.

> Pi usa **Git Bash** como shell por defecto en Windows. Busca, en orden: una ruta custom en `settings.json` (`shellPath`), `C:\Program Files\Git\bin\bash.exe`, y `bash.exe` en `PATH`. Con Git for Windows instalado en su ruta por defecto no hay nada que configurar.

---

## Paso 2 — Instalar Gentle AI

### Compilar el CLI desde fuente

```powershell
go install github.com/gentleman-programming/gentle-ai/v3/cmd/gentle-ai@latest
```

> **Atención al módulo `v3`.** Versiones anteriores del ecosistema usaban `/v2/`. Con `@latest` sobre la ruta `v3` obtenés la línea actual. Si copiás un comando viejo con `/v2/`, vas a instalar una versión desactualizada.

### Verificar que quedó en `PATH`

```powershell
gentle-ai version
```

**Esperado:** algo como `gentle-ai 3.3.0`.

Si falla, `go install` escribe en `GOBIN` o, si no está definido, en `%USERPROFILE%\go\bin`. Agregá ese directorio a `PATH` y reabrí la terminal:

```powershell
$env:Path += ";$env:USERPROFILE\go\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
```

### Instalar el stack de Pi

```powershell
gentle-ai install --agent pi --scope global
```

Esto instala el paquete de pi, Engram, el adaptador MCP y los companions, y prepara los assets de soporte. Es idempotente: si lo volvés a correr, no rompe lo que ya está.

**Subagentes en background.** Por defecto `auto` hereda la política gestionada y nunca se habilita solo. Si querés decidirlo explícitamente:

```powershell
gentle-ai install --agent pi --scope global --pi-background-subagents=on
```

La política resuelta queda en `%USERPROFILE%\.pi\gentle-ai\background-subagents.json`.

### Canal beta (opcional)

Solo si querés adelantarte a la próxima release:

```powershell
$env:GENTLE_AI_CHANNEL="beta"; irm https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.ps1 | iex
```

Preservá el canal al actualizar después: `$env:GENTLE_AI_CHANNEL="beta"; gentle-ai upgrade`.

---

## Paso 3 — Instalar el binario de Engram

Engram es un binario de Go que escribe la memoria en SQLite local. El paquete de pi **no lo incluye**: hay que bajarlo aparte.

### Descargar

Andá a [github.com/Gentleman-Programming/engram/releases](https://github.com/Gentleman-Programming/engram/releases) y bajá el asset que corresponda a tu arquitectura:

| Arquitectura | Asset |
|---|---|
| x64 | `engram_<version>_windows_amd64.zip` |
| arm64 | `engram_<version>_windows_arm64.zip` |

Descargá también `checksums.txt` del **mismo release**.

### Verificar y extraer

```powershell
$version = "2.0.0"
$arch = "amd64"   # o "arm64"
$url = "https://github.com/Gentleman-Programming/engram/releases/download/v$version/engram_${version}_windows_${arch}.zip"
$dest = "$env:USERPROFILE\.pi\agent\bin"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\engram.zip"

# Verificá el hash contra checksums.txt del release antes de seguir.
Get-FileHash "$env:TEMP\engram.zip" -Algorithm SHA256

Expand-Archive -Path "$env:TEMP\engram.zip" -DestinationPath $dest -Force
```

**Antes de continuar**, compará el hash que devolvió `Get-FileHash` con la línea correspondiente de `checksums.txt`. Si no coincide, **detené el proceso**: el archivo está corrupto o fue manipulado.

### Registrarlo

```powershell
& "$env:USERPROFILE\.pi\agent\bin\engram.exe" version
```

**Esperado:** algo como `engram 2.0.0`.

Definí `ENGRAM_BIN` para que pi lo encuentre aunque el directorio no esté en `PATH`:

```powershell
[Environment]::SetEnvironmentVariable("ENGRAM_BIN", "$env:USERPROFILE\.pi\agent\bin\engram.exe", "User")
```

### Inicializar la configuración de pi para Engram

```powershell
npm exec --yes --package gentle-engram@latest -- pi-engram init
```

Esto escribe la entrada MCP de Engram en `%USERPROFILE%\.pi\agent\mcp.json` y garantiza que `pi-mcp-adapter` esté declarado en `settings.json`. **No edites esa entrada MCP a mano**: `pi-engram init` es su dueño y la va a reescribir.

---

## Paso 4 — Instalar los paquetes de pi del ecosistema

```powershell
pi install npm:gentle-pi
pi install npm:pi-lens
pi install npm:pi-web-access
pi install npm:pi-btw
```

> **`gentle-pi` es el nombre npm del repo `gentle-shell`.** Son el mismo paquete. Si preferís seguir el repositorio en lugar de las releases de npm, existe la fuente alternativa `pi install git:github.com/Gentleman-Programming/gentle-shell`. Elegí una de las dos y no mezcles: tener ambas declaradas genera cargas duplicadas.

Después de instalar paquetes, **reiniciá pi** para que se carguen las extensiones.

### Verificar

```powershell
pi list
```

**Esperado:** la lista incluye `npm:gentle-pi`, `npm:gentle-engram`, `npm:pi-mcp-adapter`, `npm:pi-lens`, `npm:pi-web-access`, `npm:pi-btw`, `npm:@juicesharp/rpiv-ask-user-question`.

**Cosas que NO se instalan a mano:**

- `pi-pretty` — viene como dependencia transitiva de `gentle-pi`.
- Los subagentes (`subagent_*`) y el seguimiento de tareas — vienen dentro de `gentle-pi`.
- `pi-subagents-j0k3r` — **legacy**. Si aparece en tu `settings.json` de una instalación anterior, `gentle-ai install` lo saca en la próxima corrida.

---

## Paso 5 — Instalar codegraph

```powershell
npm install -g @colbymchenry/codegraph
codegraph --version
```

Codegraph se registra como servidor MCP en el Paso 6.

---

## Paso 6 — Escribir la configuración

### `%USERPROFILE%\.pi\agent\settings.json`

```json
{
  "defaultModel": "<tu-modelo-por-defecto>",
  "defaultProvider": "<tu-provider>",
  "hideThinkingBlock": false,
  "packages": [
    "npm:gentle-pi",
    "npm:gentle-engram",
    "npm:pi-mcp-adapter",
    "npm:pi-lens",
    "npm:pi-web-access",
    "npm:pi-btw",
    "npm:@juicesharp/rpiv-ask-user-question"
  ],
  "quietStartup": true,
  "terminal": {
    "showTerminalProgress": false
  },
  "theme": "Gentleman-Sexy",
  "tuiMode": "fullscreen"
}
```

> **No copies `packages` a mano si ya usaste `pi install`.** `pi install` escribe esa lista por vos. Este bloque sirve para verificar que quedó completa, no para reemplazarla.

El tema `Gentleman-Sexy` viene incluido en `gentle-pi` (`themes/Gentleman-Sexy.json`), junto con `Gentle` y `Gentleman-Cute`. No hay que instalarlo aparte.

### `%USERPROFILE%\.pi\agent\mcp.json`

```json
{
  "mcpServers": {
    "codegraph": {
      "command": "codegraph",
      "args": ["serve", "--mcp"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "--package=@upstash/context7-mcp@2.2.5", "--", "context7-mcp"]
    }
  }
}
```

> **La entrada de Engram la escribe `pi-engram init`.** No la agregues a mano. Después del Paso 3, ese archivo va a contener también el servidor `engram`.

**Trampa de Windows:** cuando un servidor MCP se lanza con `npx`, en Windows a veces hace falta `npx.cmd` en lugar de `npx`. Si el servidor falla al arrancar con un error de "no se encuentra el archivo", cambiá `"command": "npx"` por `"command": "npx.cmd"`.

Si usás el servidor `stitch` (Google), necesita una API key. En Windows la forma limpia es que `mcp.json` la lea de un archivo fuera del repositorio y **fuera del control de versiones**:

```json
{
  "mcpServers": {
    "stitch": {
      "url": "https://stitch.googleapis.com/mcp",
      "headers": {
        "X-Goog-Api-Key": "!cat C:\\Users\\<user>\\secrets\\stitch-key.txt"
      }
    }
  }
}
```

La ruta `C:\Users\<user>\secrets\stitch-key.txt` es solo un ejemplo: poné la tuya y verificá que el archivo exista antes de confiar en el servidor. Guardá la key fuera de cualquier carpeta versionada.

### `%USERPROFILE%\.pi\agent\subagents.json`

Mapea cada rol de subagente a un modelo y un nivel de esfuerzo. Este es el mapa que usa el ecosistema de referencia; **ajustá los IDs de modelo a los que tu provider realmente exponga**:

```json
{
  "model_profiles": {
    "gentle-ai-explore": { "model": "<provider>/<modelo>", "effort": "high" },
    "gentle-ai-verify": { "model": "<provider>/<modelo>", "effort": "high" },
    "gentle-ai-worker": { "model": "<provider>/<modelo>", "effort": "xhigh" },
    "review-risk": { "model": "<provider>/<modelo>", "effort": "high" },
    "review-resilience": { "model": "<provider>/<modelo>", "effort": "high" },
    "review-readability": { "model": "<provider>/<modelo>", "effort": "high" },
    "review-reliability": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-explore": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-research": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-proposal": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-spec": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-design": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-tasks": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-apply": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-verify": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-sync": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-archive": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-init": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-onboard": { "model": "<provider>/<modelo>", "effort": "high" },
    "sdd-status": { "model": "<provider>/<modelo>", "effort": "high" },
    "jd-judge-a": { "model": "<provider>/<modelo>", "effort": "high" },
    "jd-judge-b": { "model": "<provider>/<modelo>", "effort": "high" },
    "jd-fix-agent": { "model": "<provider>/<modelo>", "effort": "high" }
  }
}
```

Si omitís un rol, el subagente usa el modelo por defecto de la sesión. Un `subagents.json` incompleto **no** rompe nada: solo deja esos roles sin modelo asignado.

### Autenticación

Los archivos de credenciales (`auth.json`) **no se copian entre máquinas**. Hay que autenticarse en la máquina nueva:

```powershell
pi
```

Y dentro de pi, usar el comando de login del provider que elijas (`/login` o el diálogo de `/settings`).

---

## Paso 7 — Instalar las skills

Pi carga skills desde tres lugares. En Windows nativo:

| Alcance | Ruta |
|---|---|
| Global | `%USERPROFILE%\.pi\agent\skills\` |
| Global (compartido entre agentes) | `%USERPROFILE%\.agents\skills\` |
| Proyecto | `.pi\skills\` y `.agents\skills\` en el proyecto y en sus directorios padre, hasta la raíz del repo (solo tras confiar en el proyecto) |

Además, cada paquete de pi puede traer sus propias skills.

### 7.a — Skills que ya vienen con los paquetes

`gentle-pi` incluye sus skills (branch-pr, chained-pr, cognitive-doc-design, comment-writer, gentle-ai, issue-creation, judgment-day, rdd-defect-workflow, release, skill-creator, skill-improver, skill-registry, work-unit-commits). **No requieren paso manual**: si instalaste el paquete, están disponibles.

### 7.b — Skills de este repositorio

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git ~/dev/kkapsca-skills
cd ~/dev/kkapsca-skills
OPENCODE_SKILLS_DIR="$HOME/.agents/skills" bash scripts/bootstrap.sh --copy
```

> **Dos cosas importantes, y las dos son específicas de Windows.**
>
> **1. Hay que redirigir la ruta de destino.** El instalador apunta por defecto a `~/.config/opencode/skills`, que es la ruta de **opencode**. Pi lee `%USERPROFILE%\.agents\skills` y `%USERPROFILE%\.pi\agent\skills`. Si lo dejás por defecto, el instalador va a reportar éxito y pi **no va a ver ninguna skill**. `OPENCODE_SKILLS_DIR` es la variable que corrige esto.
>
> **2. Hay que usar `--copy`.** Por defecto el instalador crea enlaces simbólicos, y en Windows nativo crear symlinks requiere Developer Mode activado o privilegios de administrador. Sin eso, el comando falla. `--copy` hace una copia física y no necesita permisos especiales.

Ejecutá esto desde **Git Bash** (el bloque es `bash`), no desde PowerShell.

Si preferís que las skills se actualicen solas al hacer `git pull`, activá Developer Mode (Configuración → Sistema → Para programadores) y omití `--copy`. Con `--copy` hay que volver a correr el bootstrap después de cada `git pull`.

### 7.c — Skills externas (Supabase, Firebase, Genkit)

Viven en `%USERPROFILE%\.agents\skills\` y se instalan desde sus propios repositorios. El instalador de este repo las procesa automáticamente si ya están ahí (lee `${EXTERNAL_SKILLS_DIR}`, que por defecto es ese directorio).

Corré el bootstrap de 7.b **después** de instalarlas, así quedan enlazadas junto con las del repo.

> Sin este paso, el enrutamiento del [skill registry](../.atl/skill-registry.md) falla en silencio: el orquestador pide una skill que pi no tiene cargada.

### Verificar

Dentro de pi, ejecutá `/skill:` y mirá el autocompletado, o preguntale al agente qué skills tiene disponibles. Si no aparece ninguna, el problema casi siempre es la ruta de destino del bootstrap (7.b, punto 1).

---

## Paso 8 — Companion opcional: pi-intercom

```powershell
pi install npm:pi-intercom
```

`gentle-pi` ya provee comunicación entre sesiones con `orchestrator_session_id`, `orchestrator_list` y `orchestrator_send_message`. `pi-intercom` **se solapa parcialmente** con eso. Si vas a instalar solo uno, mirá qué se pierde:

| Capacidad | `orchestrator_*` | `pi-intercom` |
|---|---|---|
| Notificar a otra sesión | ✅ | ✅ |
| Listar sesiones | ✅ (solo IDs) | ✅ (nombre, alias, prefijo, y filtro por directorio) |
| **Preguntar y esperar respuesta** | ❌ | ✅ `ask` + `reply` |
| Ver preguntas sin responder | ❌ | ✅ `pending` |
| Cancelar un mensaje enviado | ❌ | ✅ `cancel` |
| Adjuntar archivos o fragmentos | ❌ (solo texto, tope 8192 bytes) | ✅ |
| Enviar por nombre en vez de ID opaco | ❌ | ✅ |
| UI interactiva para el humano | ❌ | ✅ `/intercom` y `Alt+M` |
| Abrir una sesión en un panel nuevo | ❌ | ✅ |

El punto que define la decisión es **`ask` + `reply`**. `orchestrator_send_message` es fire-and-forget: su propia respuesta dice que la aceptación *"no es un acuse de entrega ni de lectura"*, y su esquema no tiene campo de respuesta. Si nunca necesitás respuesta de otra sesión, `orchestrator_*` alcanza y podés ahorrarte la superficie extra de tools. Si necesitás ida y vuelta, `pi-intercom` es la única opción.

Como referencia: el README de `gentle-pi` lista `pi-intercom` entre los paquetes companion recomendados, y el CLI oficial (`gentle-ai`) no lo instala por defecto.

---

## Paso 9 — Verificación final

Ejecutá todo esto y comparalo con lo esperado. **Un paso que falla acá no es cosmético**: cada línea cubre una pieza que falla en silencio más adelante.

```powershell
pi --version
gentle-ai version
& "$env:USERPROFILE\.pi\agent\bin\engram.exe" version
codegraph --version
pi list
```

| Verificación | Esperado |
|---|---|
| `pi --version` | Una versión (la actual es 0.85.1) |
| `gentle-ai version` | Una versión (la actual es 3.3.0) |
| `engram.exe version` | Una versión (la actual es 2.0.0) |
| `codegraph --version` | Una versión (la actual es 1.6.0) |
| `pi list` | Los paquetes del Paso 4 |

### Verificación funcional dentro de pi

Abrí pi en cualquier carpeta y comprobá:

1. **Memoria** — preguntale *"¿qué recordás de este proyecto?"*. Debe responder usando `mem_context`, no un error. Si da error, Engram no está conectado: revisá `ENGRAM_BIN` y reiniciá pi.
2. **Skills** — preguntale qué skills tiene disponibles.
3. **Subagentes** — pedile que liste los subagentes. Debe mostrar los de `gentle-pi` (gentle-ai-explore, gentle-ai-verify, gentle-ai-worker, sdd-*, review-*, jd-*).
4. **Tema** — `/settings` debe mostrar `Gentleman-Sexy` disponible.
5. **MCP** — el arranque no debe reportar servidores MCP caídos. Un `error MCP: 0/N servers` con `mem_*` funcionando es el gateway MCP global, no Engram: revisá `mcp.json` por entradas obsoletas.

---

## Trampas específicas de Windows

| Situación | Qué pasa | Qué hacer |
|---|---|---|
| El instalador de skills "funciona" pero pi no ve nada | Instala en la ruta de opencode, no en la de pi | Definí `OPENCODE_SKILLS_DIR` apuntando a `%USERPROFILE%\.agents\skills` |
| El bootstrap falla al crear enlaces | Windows necesita Developer Mode o admin para symlinks | Usá `--copy` |
| Un servidor MCP lanzado con `npx` no arranca | En Windows el ejecutable es `npx.cmd` | Cambiá el `command` en `mcp.json` |
| `%USERPROFILE%` no se expande en un JSON | Las variables de entorno no se expanden dentro de valores JSON | Escribí la ruta absoluta, con `\\` escapado |
| Mezclás `/mnt/c/...` con `C:\...` | Rutas rotas y archivos que no se encuentran | En Windows nativo todo es `C:\...` o `/c/...` en Git Bash |
| `gentle-ai install` falla con "Go no encontrado" | Windows no tiene binarios de Gentle AI | Instalá Go 1.25.10+ (Paso 0) |
| Mensajería entre sesiones no responde | El transporte usa named pipes en Windows y depende de un helper de PowerShell del paquete | Verificá que `gentle-pi` esté cargado; si persiste, usá `pi-intercom` |
| RTK no está | Es intencional: "Windows remains intentionally unavailable" | No lo busques, no aplica en Windows |

---

## Lo que este runbook NO hace

Sé explícito con las brechas para no dar por sentado lo que no está:

- **No migra la memoria de Engram.** La máquina nueva arranca con base vacía. Si querés llevarte el historial, hay que copiar el archivo SQLite aparte, y eso no está cubierto acá porque depende de dónde lo tenga cada instalación.
- **No migra credenciales.** `auth.json` no se copia: hay que autenticarse en la máquina nueva.
- **No migra sesiones de pi.** El historial de conversaciones vive en `%USERPROFILE%\.pi\agent\sessions\` y no se replica.
- **No valida que tu provider exponga los modelos** que pongas en `subagents.json`. Los IDs son tuyos; si no existen, los subagentes fallan al lanzarse.
- **No configura el servidor MCP `stitch`** más allá del ejemplo: requiere que crees el archivo de la key con tus propias credenciales de Google.
- **No cubre RTK** (no disponible en Windows) ni ningún otro componente que el CLI marque como no soportado.

---

## Desinstalación

```powershell
# Assets gestionados por Gentle AI
gentle-ai uninstall

# Paquetes de pi
pi remove npm:gentle-pi
pi remove npm:gentle-engram
pi remove npm:pi-mcp-adapter
pi remove npm:pi-lens
pi remove npm:pi-web-access
pi remove npm:pi-btw
pi remove npm:@juicesharp/rpiv-ask-user-question

# Binarios globales
npm uninstall -g @colbymchenry/codegraph
npm uninstall -g @earendil-works/pi-coding-agent
```

Las skills que instaló este repositorio se desinstalan aparte, desde **Git Bash** y con la misma ruta de destino que usaste al instalarlas:

```bash
cd ~/dev/kkapsca-skills
OPENCODE_SKILLS_DIR="$HOME/.agents/skills" bash scripts/uninstall-opencode-skills.sh
```

> **Sin la variable no borra nada.** El desinstalador resuelve su destino igual que el instalador —`${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}`— y solo actúa si encuentra skills instaladas por él mismo. Si omitís `OPENCODE_SKILLS_DIR`, apunta a la ruta de opencode, no encuentra nada y termina sin error: un no-op silencioso que parece haber funcionado.

`gentle-ai uninstall` borra solo los archivos que gestiona. Los archivos personales que hayas editado a mano no se tocan.

---

## Referencias

- [README principal](../README.md) — Qué es el repositorio y flujo recomendado
- [Guía de instalación](installation.md) — Instalación de skills y bootstrap
- [Configuración WSL](wsl-setup.md) — La ruta alternativa, más simple si WSL es una opción
- [Contexto Gentle AI](gentle-ai.md) — El stack y su relación con este repo
- [Memoria Persistente (Engram)](engram.md) — Engram, bootstrap y skill-registry
- [Documentación de pi sobre Windows](https://github.com/earendil-works/pi/blob/main/docs/windows.md) — Shell, Git Bash y rutas custom
- [Plataformas soportadas por Gentle AI](https://github.com/Gentleman-Programming/gentle-ai/blob/main/docs/platforms.md) — Estado oficial por sistema operativo
