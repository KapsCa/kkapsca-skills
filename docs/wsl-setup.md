# Instalación del ecosistema en WSL2

> **Este documento es un runbook ejecutable.** Está escrito para que un agente (pi) lo lea y ejecute de arriba hacia abajo en una máquina con WSL2, sin adivinar pasos ni inventar valores. La ruta hermana en Windows nativo está en [Instalación del ecosistema en Windows nativo](windows-native-setup.md).

## Para quién es esto

Para quien quiere el ecosistema completo —pi, Gentle AI, Engram, skills, MCP, subagentes, acceso desde el teléfono— funcionando en **WSL2**, instalándolo **con un solo script** a partir de los prerequisitos.

Si WSL2 no es una opción, la ruta en [Windows nativo](windows-native-setup.md) cubre el mismo ecosistema con un instalador PowerShell propio y bastante más pasos manuales. Elegí una ruta: mezclar ambas rompe rutas, shells y configuraciones.

## Por qué WSL2 (y qué cambia frente a Windows nativo)

- Las herramientas del ecosistema (git, bash, scripts, shell por defecto de pi) asumen entorno Unix.
- Evita mezclar rutas de Windows (`C:\Users\...`) con rutas de Linux (`/home/...`) en el mismo flujo.
- El instalador de este ecosistema es **bash**: corre nativo en WSL2 sin compilar nada ni depender de PowerShell.
- Las piezas de red del final —el teléfono (Moshi) y el reenvío HTTPS de Engram Cloud— dependen de un entorno Linux; en Windows nativo no hay camino equivalente documentado.

Lo que cambia frente a Windows nativo: menos pasos manuales (el instalador de un solo paso cubre de los prerequisitos en adelante), sin Go ni firmas Authenticode, y una ruta de teléfono que solo existe acá.

## Requisitos previos

| Requisito | Detalle |
|---|---|
| Versión de Windows | Windows 10 versión 2004 (build 19041) o superior, o Windows 11 |
| Virtualización | habilitada en BIOS/UEFI |
| Distribución | Ubuntu (la que `wsl --install` trae por defecto) |

```powershell
wsl --install
```

Reiniciá después de la instalación y verificá:

```powershell
wsl --list --verbose
```

Todo lo que sigue corre **dentro de WSL** (PowerShell solo para los comandos `wsl`). Cloná los repositorios en el filesystem de Linux —nunca bajo `/mnt/c/...`— y, si no lo hiciste nunca, configurá tu identidad de git dentro de WSL:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

## El instalador de un solo paso

```bash
curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install-wsl.sh | bash
```

Es seguro pasarlo por un pipe: el instalador **nunca lee stdin** (con `curl | bash`, la entrada *es* el script). Las confirmaciones se leen de `/dev/tty` solo cuando hay una terminal legible; `sudo` también pregunta por `/dev/tty`, y si no puede correr sin contraseña (`sudo -n`) y no hay TTY, la fase **falla con el comando exacto** para ejecutarlo a mano y reintentar. El instalador trae la **última versión publicada** de cada herramienta: no fija versiones.

### Modos

| Modo | Qué hace |
|---|---|
| *(sin flags)* | Instala lo que falta; reporta lo que ya está presente |
| `--update` | Refresca todo a la última versión publicada (re-corré cada instalador upstream) |
| `--dry-run` | Imprime el plan completo, **no escribe nada**, exit 0 |
| `--status` | Imprime las versiones instaladas, no cambia nada, exit 0 |
| `-h`, `--help` | Ayuda y exit 0 |

### Flags

| Flag | Qué hace |
|---|---|
| `--ref REF` | Ref de kkapsca-skills para la fase de skills (por defecto: `main`) |
| `--engram-project NAME` | Fija este nombre de proyecto Engram en los directorios dados con `--engram-pin-dir` (escrito localmente; **nunca** en `~/.engram`) |
| `--engram-pin-dir DIR` | Directorio contenedor a fijar (repetible). Requiere `--engram-project` y vice versa; cada `DIR` recibe un `.engram/config.json` con el nombre del proyecto |
| `--skip-skills` | Salta la fase de skills de kkapsca-skills |
| `--skip-herdr` | Salta la fase de herdr |
| `--skip-external-skills` | Salta las fuentes firebase + supabase |
| `--skip-tailscale` | Salta la fase de Tailscale (alcance de red) |
| `--skip-moshi` | Salta la fase de moshi (acceso desde el teléfono) |
| `--tailscale-ssh` | **Experimental**: corre `sudo tailscale up --ssh` y no instala `openssh-server`. Ver [la decisión del transporte SSH](#la-decisión-del-transporte-ssh) |
| `--yes` (también `-y`) | Asume que sí: sin prompts de confirmación (igual nunca lee stdin; sudo pregunta solo por `/dev/tty`) |

Sobre los pins de Engram: `~/.engram` es el **directorio de datos** de Engram (base, WAL, logs) y no puede fijar un proyecto por sí mismo; los pins viven solo en directorios contenedores —por ejemplo los proyectos donde trabajás— como `<dir>/.engram/config.json` con `{"project_name": "..."}`. Sin `--engram-project` el instalador **no adivina** ningún nombre ni escribe ningún pin. Los valores personales entran solo en runtime y nunca terminan en archivos versionados; las credenciales (`auth.json`) tampoco las escribe nunca este script: el login del provider se hace a mano en la máquina nueva.

### Lo que el script NO hace, por diseño

- No lee stdin, y no deja que `sudo` lo lea: corrélo de una terminal interactiva.
- No copia ni produce credenciales: `auth.json` no se migra.
- No escribe en `~/.engram/` ni adivina nombres de proyecto ni directorios.
- No edita `settings.json` directamente: esa lista pertenece a `pi install` y `gentle-ai install` (la fase de paquetes solo la **lee**, para no duplicar entradas).
- No ejecuta los pasos del teléfono: los detecta y **imprime** los comandos exactos.
- No inicia ni expone servicios de red por su cuenta: `tailscale serve`, los certificados HTTPS y el despliegue de Engram Cloud quedan como pasos manuales impresos.
- No tiene modo de desinstalación: quitá cada pieza con el mecanismo propio de cada una (`apt`, `npm`, `pi remove`; los archivos de config que escribe son archivos tuyos).

### Las 13 fases, en orden de ejecución

La tabla lista **qué deja atrás cada fase**, no solo qué corre.

| # | Fase (como la imprime el script) | Qué deja atrás |
|---|---|---|
| 1/13 | apt prerequisites | `sudo apt-get update` + instalación de `curl ca-certificates git jq tar unzip xz-utils gnupg` |
| 2/13 | Node.js runtime | node acorde al requisito `engines` de pi (lo consulta contra el registro npm; reserva interna `>= 22.19.0`): vía **nvm user-local** (`~/.nvm`), sin sudo, más el bloque rc para cargarlo en `~/.bashrc` y `~/.profile` |
| 3/13 | agent runtime (pi + CodeGraph) | `npm install -g @earendil-works/pi-coding-agent` y `npm install -g @colbymchenry/codegraph` |
| 4/13 | engram binary | binario linux del último release de GitHub, **SHA256 verificado contra `checksums.txt`** → `~/.pi/agent/bin/engram`, más `ENGRAM_BIN` y `PATH` en `~/.bashrc`/`~/.profile`. Fail-closed: sin `checksums.txt`, no instala nada |
| 5/13 | Gentle AI stack | instalador upstream de gentle-ai (`--method binary --channel stable`; lo baja a un archivo temporal y lo corre, nunca `curl \| sh`), luego `gentle-ai install --agent pi --scope global --channel stable`: el paquete de pi, gentle-shell y los overlays |
| 6/13 | pi packages | `pi install` de los 7 paquetes npm del ecosistema (`gentle-pi`, `gentle-engram`, `pi-btw`, `pi-intercom`, `pi-lens`, `pi-mcp-adapter`, `pi-web-access`), **idempotente por especificador**: una entrada equivalente ya presente (mismo nombre npm con o sin `@versión`, o el mismo paquete como ruta de `node_modules`) se salta, nunca duplica |
| 7/13 | herdr | instalador upstream (POSIX sh, verifica su propio SHA256) → `~/.local/bin/herdr`, más `herdr integration install pi` (extensión en `~/.pi/agent/extensions`) |
| 8/13 | skills — source A: kkapsca-skills | tarball del repositorio cacheado en `~/.local/share/kkapsca-skills` + su propio `scripts/install.sh --agent agents` → `~/.agents/skills` |
| 9/13 | skills — sources B/C: firebase/agent-skills, supabase/agent-skills | `npx -y skills add <owner>/<repo>` por fuente; registro en `~/.agents/.skill-lock.json` |
| 10/13 | tailscale (network reachability) | instalador oficial (descargado a archivo y corrido con `sh`; necesita sudo), autenticación interactiva por navegador (`tailscale up`, solo con TTY legible), y la impresión de la IPv4 + nombre MagicDNS del nodo + los pasos manuales que nunca automatiza |
| 11/13 | moshi (phone access) | apt de `mosh`, `tmux` y `openssh-server` (salvo `--tailscale-ssh`); sshd habilitado y verificado en `:22` (con systemd); `moshi-hook` en `~/.local/bin`; unidad user de systemd + `enable --now` + linger; corre `moshi-hook doctor` y `status`; **imprime** los tres pasos que necesitan el teléfono |
| 12/13 | pi config (mcp-adapter, subagents) | `~/.pi/agent/mcp-adapter.json` (4 servidores: codegraph, context7, engram vía `ENGRAM_BIN`, stitch con la key leída en runtime) y `~/.pi/agent/subagents.json` (perfiles de modelo de gentle-ai); si quedó un `mcp.json` muerto de `pi-engram init`, lo respalda y lo saca; pins de proyecto optativos |
| 13/13 | final verification | tabla de componentes con versiones, conteo de skills, `engram doctor`, aviso de `pi list`; tabla final por fase (`ok`/`skip`/`FAIL`) y exit code 1 si algo falló |

> **El orden no es casual:** Tailscale (10) corre **antes** que moshi (11) a propósito. La fase de teléfono necesita una dirección estable y alcanzable, y en WSL2 la única forma de conseguirla es el tailnet.

Este archivo es hermano de `scripts/install-windows.ps1` (ruta Windows nativo): la familia de mensajes y fases se mantiene igual entre los dos.

## El camino del teléfono (Moshi)

Moshi ([getmoshi.app](https://getmoshi.app)) es una terminal móvil (iOS 17+ / Android 10+) que se conecta a una máquina que **vos ya tenés** por SSH / mosh / ET y permite manejar agentes de código de larga duración desde el teléfono. No hay relé de sesiones: la app habla directo con tu máquina. La capa gratuita cubre SSH, monitoreo de agentes y notificaciones push, sin cuenta ni tarjeta; Pro es opcional.

### Lo que el host necesita

| Pieza | Para qué | Quién la deja |
|---|---|---|
| `openssh-server` | la única vía de entrada de la app | fase moshi: apt + habilitar el servicio ssh |
| `mosh` | mantiene la sesión viva ante cortes de red celular y sleep | fase moshi (apt) |
| `tmux` | espacios de trabajo que sobreviven reconexiones | fase moshi (apt) |
| `moshi-hook` + `moshi` | pareo, hooks, demonio y el lanzador `moshi <dir>` que abre tmux | fase moshi, desde el instalador upstream (queda en `~/.local/bin/moshi-hook`, sin sudo) |
| Tailscale | la dirección estable y alcanzable desde el teléfono | fase tailscale |

El demonio de hooks queda como **unidad user de systemd** (`~/.config/systemd/user/moshi-hook.service`, `ExecStart=moshi-hook serve`) armada con `enable --now`, y el instalador habilita **linger** para que sobreviva sin sesión activa. En un WSL2 sin systemd —el caso común— el script **no inventa autostart**: imprime la alternativa documentada (arrancar el demonio desde el shell al iniciar sesión, o `wsl.conf` con `[boot] systemd=true`). El gateway del demonio escucha en `127.0.0.1:24543` y se alcanza a través de la sesión SSH, no desde la red.

### Los tres pasos que necesitan el teléfono

Son los únicos que el instalador **imprime pero nunca ejecuta**, porque requieren la app en tu mano. Detecta el estado de cada uno y solo muestra los que faltan:

```bash
# 1) Easy Pair — genera un QR para escanear desde la app
moshi-hook host setup

# 2) Pareo de hooks — el token sale de la app (Settings → Hooks)
moshi-hook pair --token <token>

# 3) Hook del agente — escribe la extensión de pi
moshi-hook install --target pi
```

Tres advertencias que valen la pena grabar:

- **El QR de Easy Pair es una credencial temporal.** Quien lo escanee primero obtiene acceso SSH a tu máquina — escanealo vos inmediatamente, no dejes el QR abierto.
- **El token de pareo es un secreto tuyo:** no lo compartas ni lo comprometas nunca.
- **El hook de pi queda obsoleto después de actualizar pi.** Tras cada update de pi, corré de nuevo `moshi-hook install --target pi`: la extensión (`~/.pi/agent/extensions/moshi-hooks.ts`) puede quedar vieja y pi reporta `missing: extension`.

La verificación puntual de esta fase la da `moshi-hook doctor` (necesita `moshi-hook` ≥ 0.4.3; con versiones más viejas el instalador lo advierte en vez de asumir readiness) y `moshi-hook status`. Un host **sin parear es un estado intermedio válido**: el instalador lo reporta como `skip`, no como `fail`.

## Por qué WSL2 necesita Tailscale (y no una IP cruda)

La IP de WSL2 es **NATeada** y **cambia en cada reboot** — darle al teléfono una IP cruda es darle una dirección que se rompe en cada reinicio. Tailscale le da al nodo de WSL2 una **identidad del tailnet estable**: una IPv4 fija dentro del tailnet y un nombre MagicDNS (`<maquina>.<tailnet>.ts.net`), sin abrir puertos del router ni exponer nada a internet.

Y **el mismo tailnet sirve para los dos usos**:

| Uso | Lo que el tailnet da |
|---|---|
| Teléfono (SSH / mosh) | `ssh <usuario>@<maquina>.<tailnet>.ts.net` — una dirección que no cambia |
| Servidor Engram Cloud (futuro) | un HTTP interno expuesto como HTTPS real: `sudo tailscale serve --bg --https=443 http://127.0.0.1:18080` (los clientes de Engram Cloud exigen HTTPS) |

Instalar Tailscale es lo único que hace el script de esta parte, y la autenticación (`tailscale up` con flujo de navegador) es interactiva: solo corre si hay TTY legible; si no, imprime el comando exacto para hacerlo a mano. **La parte que el script nunca ejecuta:**

```bash
# 1) certificados HTTPS: paso en la consola de administración de Tailscale
#    (MagicDNS + "Enable HTTPS") — no es automatizable desde el nodo
# 2) cuando exista un servidor Engram Cloud en esta máquina:
sudo tailscale serve --bg --https=443 http://127.0.0.1:18080
# 3) desde el teléfono, verificar alcance:
tailscale ping <esta-maquina>
```

## La decisión del transporte SSH

**Por defecto: un `openssh-server` normal, y Tailscale solo como la red.**

Es el camino soportado y el que el instalador deja armado. La exposición del sshd queda, en la práctica, limitada al tailnet —detrás del NAT de WSL2 no hay un puerto publicado—, y Easy Pair instala una clave **por dispositivo**, así que la autenticación es key-only.

El flag `--tailscale-ssh` existe pero es **experimental**, y no es el default por dos razones concretas: mosh se rompe sobre Tailscale SSH (referencia: `tailscale/tailscale` issue #4919; la parte de mosh se arregló por separado en PR #5057), y Tailscale SSH **reclama el puerto 22** en la dirección del tailnet, lo que excluye un `sshd` normal en el mismo nodo. Además Easy Pair se aparea contra un `sshd` normal — es lo que la app espera encontrar.

> Referencias como texto plano a propósito: los números de issue envejecen mejor que los enlaces. Son `tailscale/tailscale` issue **#4919** y PR **#5057**.

## Advertencias conocidas que NO son fallas del instalador

Sobre pi **0.99.1**, al arrancar van a aparecer dos advertencias de extensiones:

| Aviso de arranque | Causa real |
|---|---|
| `gentle-pi` reporta que no resuelve **`@earendil-works/pi-tui`** | el paquete `gentle-pi` lo declara en `dependencies`: defecto de manifiesto de **terceros**, con seguimiento upstream |
| `gentle-engram` reporta que no resuelve **`typebox`** | el paquete `gentle-engram` lo declara en `dependencies`: defecto de manifiesto de **terceros**, con seguimiento upstream |

Lo importante para no confundirte:

- **Aparecen en cualquier máquina** que tenga esos dos paquetes en su última versión publicada, sin importar cómo se instalaron. No son específicos de este instalador ni de esta máquina.
- **Este repositorio no los puede corregir**: los dueños del defecto son los mantenedores de `gentle-pi` y `gentle-engram`.
- **A la fecha de este documento no están corregidos**: no los tomes como señal de que falló la instalación. Verificá lo de la sección siguiente: si los componentes responden a sus versiones, la instalación está bien.

## Verificación

Antes de correr nada:

```bash
# el plan completo, sin escribir un byte
bash scripts/install-wsl.sh --dry-run

# solo lectura: qué está instalado hoy en esta máquina
bash scripts/install-wsl.sh --status
```

Después de correrlo:

1. **La tabla final por fase.** Cada fase sale `ok`, `skip` o `FAIL`, con su nota. Exit code 1 = algo falló; el mensaje nombra la fase y el comando exacto para completarla a mano (re-corriendo es seguro: el instalador es idempotente).
2. **Abrí una terminal nueva** para que `PATH` y `ENGRAM_BIN` tomen efecto, y corré `pi`.
3. **Chequeo de componentes:**

```bash
pi --version
gentle-ai version
codegraph --version
"$HOME/.pi/agent/bin/engram" version
engram doctor
tailscale status
ss -ltn | grep :22        # sshd: un sshd activo debe estar escuchando
moshi-hook doctor
```

| Verificación | Esperado |
|---|---|
| `pi --version`, `gentle-ai version`, `codegraph --version` | una versión cada uno |
| `engram --version` (`~/.pi/agent/bin/engram`) | una versión, y `ENGRAM_BIN` definido en el shell |
| `tailscale status` | el nodo en el tailnet con nombre MagicDNS, no "no tailscale client" |
| `ss -ltn \| grep :22` | el sshd escuchando (a menos que uses `--tailscale-ssh`) |
| `moshi-hook doctor` | el reporte de readiness por feature, sin bloqueos |
| `pi list` | los paquetes del ecosistema (ver tabla de fases) |

### `engram doctor` y su hallazgo previo

`engram doctor` corre también dentro de la fase de verificación del instalador. En la máquina de referencia el doctor reporta **un** hallazgo, y es **preexistente**: estaba antes de que el instalador tocara nada y la instalación no lo causa.

El chequeo se llama **`sync_target_closed_space`**, y sus filas son `foreign_sync_target` inertes (targets `cloud:<proyecto>` que quedaron de una configuración vieja). Lo que importa no es el número sino **la forma de la fila**:

```json
{"lifecycle": "idle", "target_key": "cloud:<proyecto>", "unacked_mutations": 0}
```

Cuando esas filas están en `idle` y con `unacked_mutations: 0`, el propio mensaje nativo del doctor dice que **no hay acción requerida y ningún dato en riesgo**: la fila no puede avanzar y la limpia un slice posterior de cloud-inbox. Un hallazgo del doctor **no** es una caída del doctor: la utilidad responde y reporta, que es exactamente lo que se espera de una instalación correcta.

> **Ojo con el número:** el conteo depende de la historia de cada máquina, así que en una instalación nueva puede ser distinto o incluso cero. Lo que hay que mirar es el **nombre del chequeo** y la forma de las filas, no la cantidad. Si aparece un hallazgo con otro nombre, el reporte completo del comando te dice qué es.

### Idempotencia

**Correrlo una segunda vez no cambia nada**: las herramientas ya presentes se **reportan** ("already installed"), las fases que no tienen nada que hacer marcan `ok` con nota, y la corrida termina exit 0. Esa es la expectativa de diseño; si un re-run tocara algo que ya estaba bien, es un bug del instalador — reportalo en el repo.

## Lo que el instalador NO hace: queda manual

| Queda manual | Por qué |
|---|---|
| Desplegar el servidor Engram Cloud | El script instala la herramienta; el servidor **no existe** en esta máquina todavía y el script no levanta servicios. Para la memoria real entre máquinas hace falta el despliegue del cloud |
| La memoria no se migra | Con el ecosistema instalado, Engram arranca con base **vacía** hasta que exista Engram Cloud: la cookie no se lleva en el script, por decisión de diseño |
| Escanear el QR de Easy Pair | Necesita la app en el teléfono: el instalador imprime `moshi-hook host setup` y detiene; la credencial debe consumirla un humano |
| Pareo del hook (`moshi-hook pair --token`) y del agente (`moshi-hook install --target pi`) | Requieren el token del teléfono y la app; el instalador los detecta y los imprime, nunca los ejecuta |
| Certificados HTTPS de Tailscale | Es un paso de la **consola de administración** de Tailscale, desde el nodo no se puede |
| `tailscale serve` | Solo cuando exista un servidor en esta máquina: el script lo imprime con el comando exacto pero no lo corre |
| Login del provider en pi | Credenciales: `auth.json` no se copia ni se produce; autenticación en la máquina nueva |
| Arranque de sshd y del demonio moshi-hook sin systemd | En WSL2 sin systemd el script imprime la alternativa documentada y **no** inventa autostart: toca usar `service ssh start` manual o `wsl.conf` con `[boot] systemd=true`, según tu caso |
| Desinstalación | No hay modo de desinstalación; quitá cada pieza con su mecanismo propio (`apt remove`, `npm uninstall -g`, `pi remove`, `gentle-ai uninstall`) |

---

## Referencias

- [Instalación del ecosistema en Windows nativo](windows-native-setup.md) — la ruta hermana, sin WSL
- [Guía de instalación](installation.md) — instalación de las skills y bootstrap
- [Memoria Persistente (Engram)](engram.md) — Engram, bootstrap y skill-registry
- [README principal](../README.md) — Qué es el repositorio y flujo recomendado
- [Instalación de WSL](https://learn.microsoft.com/windows/wsl/install)
- [Documentación general de WSL](https://learn.microsoft.com/windows/wsl/)
