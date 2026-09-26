# Puertas de decisión — Tech Feasibility
Detalle local de SKILL.md (Paso 0 y Fase 2).
## Paso 0 — Clasifica el proyecto

Antes de hablar de stack, define qué tipo de proyecto es:

| Tipo | Señal principal | Nivel de rigor |
|---|---|---|
| **Proyecto de aprendizaje** | aprender y terminar | bajo |
| **Side project / microproducto** | velocidad y costo bajo | medio |
| **Herramienta interna** | utilidad y bajo costo de mantenimiento | medio |
| **Producto serio / negocio** | mantenibilidad y operación | alto |

### Regla de clasificación

- 1 = research / exploración muy temprana
- 2 = internal-tool
- 3 = side-project
- 4-5 = production

Si no puedes clasificar el proyecto con claridad, no sigas a Fase 1.

- **Proyecto de aprendizaje** → prioridad: entender, iterar, terminar.
- **Side project / microproducto** → prioridad: velocidad y costo bajo.
- **Producto serio / negocio** → prioridad: mantenibilidad, validación y operación.
- **Herramienta interna** → prioridad: utilidad y bajo costo de mantenimiento.

Esta clasificación cambia el nivel de complejidad aceptable.

---

## Fase 2 — Framework de decisión de stack

No propongas tecnología todavía. Primero responde estas preguntas:

### Stack Selection Gate

Solo puedes recomendar stack si ya sabes:

- qué plataforma o plataformas soportará,
- qué sabe ya el equipo,
- qué dependencias nativas o de terceros son críticas,
- y si la prioridad es velocidad, control o costo operativo.

### Cliente / frontend

1. ¿La app será mobile, web, desktop o varias?
2. ¿Qué sabe ya el equipo?
3. ¿El producto depende mucho de hardware o integraciones nativas?
4. ¿La prioridad es velocidad de salida o control fino de plataforma?

### Backend

1. ¿Necesita tiempo real o solo CRUD estándar?
2. ¿La lógica de negocio es simple o compleja?
3. ¿El equipo puede operar infraestructura propia?
4. ¿El producto necesita salir rápido con bajo costo operativo?

> **⚠️ Disponibilidad de skills externas**: Para cualquier skill externa (Supabase, Firebase, Genkit), consulta el [skill-registry](../docs/skill-registry.md) para ver el estado real de disponibilidad (repo-local, external-bootstrappable, logical-only). El bootstrap las procesa desde `${AGENTS_DIR}` (por defecto `$HOME/.agents/skills`). El pipeline y el registry definen orquestación lógica (cuándo activar), no disponibilidad real. Sin instalación física en `~/.config/opencode/skills`, opencode no detectará estas skills. En Pi el destino físico es `~/.agents/skills` (ver docs/installation.md, sección "Segundo destino: Pi").

### Datos e infraestructura

1. ¿Los datos son relacionales o muy variables?
2. ¿Hace falta almacenamiento local/offline?
3. ¿Hace falta escalar desde el día 1 o solo validar?
4. ¿Qué dependencia externa sería riesgosa?

---

