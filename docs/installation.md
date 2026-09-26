# Instalación Detallada — KkapsCa Skills

Este documento cubre el detalle operativo de instalación de las habilidades (**skills**) en tu entorno local.

## Inicio Rápido

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El proceso de inicialización (**bootstrap**) se corre desde **este repositorio de habilidades**, no desde la carpeta de tu proyecto futuro.

### Después del bootstrap

1. Reinicia opencode para refrescar la lista de habilidades disponibles.
2. Prueba una habilidad explícita, por ejemplo: `Usa la habilidad brainstorm`.
3. Si todavía no tienes carpeta de proyecto, no pasa nada: puedes empezar con `brainstorm` o `product-discovery` antes de crearla.

---

## ¿Qué hace el bootstrap?

- Hace que las habilidades estén disponibles en opencode
- Crea **enlaces simbólicos** por defecto (ideal para mantener las habilidades actualizadas al hacer `git pull`)

### Opciones de instalación

**Enlaces simbólicos (por defecto)**:
```bash
bash scripts/bootstrap.sh
```
Ventaja: al hacer `git pull` en el repositorio de habilidades, los cambios se reflejan automáticamente.

**Copia física independiente**:
```bash
bash scripts/bootstrap.sh --copy
```
Ventaja: las habilidades son independientes del repositorio original.

> **Nota**: `bash scripts/bootstrap.sh` funciona **siempre**, sin importar si los archivos tienen el bit de ejecución activado.

---

## Routing vs Availability

Este repositorio distingue tres conceptos que a menudo se confunden:

| Concepto | Qué hace | Afecta detección en opencode |
|----------|----------|-------------------------------|
| **Routing lógico** (`docs/skill-registry.md`) | Define **cuándo activar** cada skill según contexto y fase del proyecto | ❌ No |
| **Bootstrap** (`scripts/bootstrap.sh`) | Instala skills en `~/.config/opencode/skills` vía enlaces simbólicos o copia | ✅ Sí |
| **Instalación real** (`~/.config/opencode/skills/`) | Hace que opencode detecte y cargue la skill | ✅ Sí |

### Skill State Model

El registry clasifica cada skill con un estado que indica su disponibilidad real:

- **repo-local**: La skill vive en este repositorio y el bootstrap la instala por defecto.
- **external-bootstrappable**: La skill existe en `${AGENTS_DIR}` (por defecto `$HOME/.agents/skills`). El bootstrap puede enlazarla si el directorio externo está configurado.
- **logical-only**: Regla de routing o candidato sin instalación garantizada. opencode no la cargará sin pasos manuales adicionales.

### ¿Por qué importa?

Si el registry dice «activa `supabase` tras stack confirmado», eso es solo **routing lógico** para el orquestador. Para que opencode realmente use esa skill:

1. La skill debe estar en `~/.config/opencode/skills/` (vía bootstrap o instalación manual)
2. opencode debe estar reiniciado para refrescar la lista de skills

Sin instalación física, el routing falla silenciosamente: el orquestador pedirá la skill pero opencode no la tendrá disponible. Consulta el [skill-registry](skill-registry.md) para ver el estado actual de cada skill.

---

## Segundo destino: Pi (`--pi-only`)

El bootstrap instala en **dos destinos**: el de opencode (todas las skills del repo) y el de **Pi**, que recibe solo un subconjunto. De las skills de usuario, Pi lee `~/.agents/skills` y nada más: lo que no esté ahí, Pi no lo ve. (Las que vienen dentro de un paquete o plugin se instalan aparte, con `pi install`.)

### Qué se instala en Pi

Seis skills, en dos grupos:

| Grupo | Skills | Por qué |
|---|---|---|
| Estándares del repo | `repo-bootstrap`, `repo-guardrails` | Pi tiene que conocer y verificar los estándares antes de un push |
| Pipeline de producto | `brainstorm`, `product-discovery`, `project-init`, `tech-feasibility` | Cubren la fase **anterior** a todo lo que Pi ya sabe hacer: de idea vaga a producto definido. Pi no tiene ninguna de las cuatro, y su `sdd-explore` explora una idea de *cambio*, no de producto |

**Quedan afuera** `clarify-with-artifacts`, `diagnose`, `zoom-out`, `improve-codebase-architecture`, `flutter-personal-standards` y `sdd-to-issues`: no son parte del hueco detectado. Cada skill instalada agrega una línea de metadata al prompt de Pi en **todos** los proyectos, así que la lista se mantiene justificada, no acumulada.

### Cómo se usa

```bash
# Instalar solo el destino Pi, sin tocar opencode
bash scripts/bootstrap.sh --pi-only

# Cambiar la lista sin editar el script
PI_SKILLS="brainstorm product-discovery" bash scripts/bootstrap.sh --pi-only

# Cambiar el directorio destino (por defecto ~/.agents/skills)
PI_SKILLS_DIR="$HOME/otro/dir" bash scripts/bootstrap.sh --pi-only
```

> **Si más adelante corres `bash scripts/bootstrap.sh` sin `--pi-only`**, esa corrida vuelve a procesar como externas las skills que viven en `~/.agents/skills`, estas seis incluidas. No rompe nada y **no genera conflictos** (medido en una copia descartable: exit 0 y 0 conflictos): los enlaces del destino Pi resuelven al mismo directorio real que los del repositorio, así que el guard de "origen y destino son el mismo" las omite.

Después de instalarlas, **reinicia Pi** para que refresque la lista de skills disponibles.

### Cómo verificar que Pi las ve

La prueba tiene que usar `--tools read`. **Con `--no-tools` la sección de skills no se inyecta en el prompt**, así que el modelo responde "no" a todas —incluso a las que existen— y la prueba miente:

```bash
pi --tools read -p "Sin usar herramientas: en tu lista de skills disponibles, para cada nombre decime SOLO SI o NO:
issue-creation
brainstorm
una-skill-que-no-existe-xyz
Formato exacto: <nombre>=<SI|NO>"
```

Siempre con **control positivo** (`issue-creation`, que siempre existe) y **control negativo** (`una-skill-que-no-existe-xyz`, que nunca existe). Sin los dos, el resultado no significa nada.

---

## Desinstalación

```bash
bash scripts/uninstall-opencode-skills.sh
```

---

## ¿Necesito tener ya creada la carpeta del proyecto?

**No para instalar las habilidades.**

Puedes instalar las habilidades una sola vez en tu máquina local y luego usarlas para pensar o descubrir ideas aunque todavía no exista la carpeta final del proyecto.

### Flujo recomendado

1. Clona este repositorio de habilidades.
2. Ejecuta `bash scripts/bootstrap.sh` una sola vez.
3. Usa `brainstorm` o `product-discovery` para aterrizar la idea.
4. Cuando la idea ya tenga forma, crea la carpeta real del proyecto.
5. Desde esa carpeta sigue con `project-init`, `tech-feasibility` o la habilidad de desarrollo que aplique.

### Ejemplo práctico

```text
~/dev/kkapsca-skills        -> instalar habilidades
~/dev/                       -> explorar idea
~/dev/mi-nuevo-proyecto      -> aterrizar e implementar
```

---

## Requisito de entorno (Windows)

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** para mantener un entorno más consistente con Linux. Ver detalles en [docs/wsl-setup.md](wsl-setup.md).

Si en cambio necesitás el ecosistema en **Windows nativo**, WSL2 no es una opción válida. Esa ruta tiene restricciones propias —el CLI de Gentle AI solo se instala desde fuente, el instalador de skills usa enlaces simbólicos y apunta a la ruta de opencode— y está cubierta paso a paso en [Instalación en Windows nativo](windows-native-setup.md).

---

## Referencias

- [README principal](../README.md) — Qué es el repositorio, instalación rápida, flujo recomendado
- [Contexto Gentle AI](gentle-ai.md) — Stack Gentle AI y relación con este repo
- [Memoria Persistente (Engram)](engram.md) — Diferencia entre Engram, bootstrap y skill-registry
- [Desarrollo Estructurado (ODD y SDD)](sdd.md) — ODD por defecto; SDD como rama opcional
- [Instalación en Windows nativo](windows-native-setup.md) — Runbook del ecosistema completo sin WSL
