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
| **Routing lógico** (`.atl/skill-registry.md`) | Define **cuándo activar** cada skill según contexto y fase del proyecto | ❌ No |
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

Sin instalación física, el routing falla silenciosamente: el orquestador pedirá la skill pero opencode no la tendrá disponible. Consulta el [skill-registry](../.atl/skill-registry.md) para ver el estado actual de cada skill.

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

---

## Referencias

- [README principal](../README.md) — Qué es el repositorio, instalación rápida, flujo recomendado
- [Contexto Gentle AI](gentle-ai.md) — Stack Gentle AI y relación con este repo
- [Memoria Persistente (Engram)](engram.md) — Diferencia entre Engram, bootstrap y skill-registry
- [Desarrollo Estructurado (SDD)](sdd.md) — SDD y sdd-orchestrator
