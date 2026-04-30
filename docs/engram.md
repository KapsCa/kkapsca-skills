# Engram vs Bootstrap vs Skill-Registry

Es común confundir el papel de **Engram** con el registro de skills en opencode. Son cosas distintas y ambas cumplen roles diferentes.

## Comparación rápida

| Concepto | ¿Qué hace? | ¿Registra skills en opencode? |
|----------|------------|-------------------------------|
| **Engram** | Guarda memoria persistente del proyecto, contexto, decisiones y flujos de trabajo entre sesiones. | ❌ No |
| **Bootstrap / Instalador** | Crea symlinks o copias de las skills en `~/.config/opencode/skills` para que opencode las detecte. | ✅ Sí |
| **`.atl/skill-registry.md`** | Catálogo de skills del proyecto para que el `sdd-orchestrator` resuelva estándares y reglas de proyecto. | ❌ No |

## Engram — Memoria persistente

Engram es un sistema de memoria que sobrevive entre sesiones y compactions. Permite:

- Guardar decisiones de arquitectura y diseño
- Recordar bugs fixeados y lecciones aprendidas
- Mantener contexto de proyecto para el orquestador SDD
- Buscar trabajo previo mediante búsqueda de texto completo (FTS5)

### Cuándo usarlo
- Después de hacer una decisión de arquitectura
- Al completar un bug fix importante
- Cuando estableces un patrón o convención
- Al iniciar una sesión nueva (para recuperar contexto)

### Ciclo de vida
1. `mem_save` → guarda una observación
2. `mem_search` → busca contexto previo
3. `mem_get_observation` → recupera contenido completo
4. `mem_session_summary` → cierra sesión con resumen

## Bootstrap — Registro local de skills

El script `scripts/bootstrap.sh` hace que opencode vea tus skills localmente:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

Después de ejecutar el bootstrap, **reinicia opencode** para que refresque la lista de skills disponibles.

### Opciones
- Por defecto: crea **symlinks** (se actualizan con `git pull`)
- Con `--copy`: crea copia física independiente

### Desde qué carpeta se ejecuta
El bootstrap se ejecuta desde la **carpeta de este repo de skills**, no desde la carpeta de tu proyecto futuro.

## `.atl/skill-registry.md` — Catálogo para orquestación

Este archivo es usado únicamente por el `sdd-orchestrator` para:

- Resolver estándares de proyecto (compact rules)
- Inyectar reglas en sub-agentes
- Mapear triggers de skills a contextos de código

No afecta la detección local de skills en opencode.

### Importante: Registry resuelve orquestación SDD, NO instala ni garantiza disponibilidad

El `.atl/skill-registry.md` define **cuándo activar** una skill (ej. "activar `supabase` tras decidir el stack en tech-feasibility"). Pero esto es solo **lógica de orquestación**. Para que opencode realmente detecte y use una skill, esta debe estar físicamente presente en `~/.config/opencode/skills/`.

**Ejemplo con Supabase**:
- Registry dice: "activa `supabase` tras stack confirmado" → esto es orquestación lógica
- Skill `supabase` debe estar en `~/.config/opencode/skills/supabase/` → esto es disponibilidad real
- Si no está instalada, el pipeline documenta la brecha pero NO promete autoactivación

**Ejemplo con Firebase**:
- Registry dice: "activa `firebase-basics` tras stack confirmado en `tech-feasibility`" → esto es orquestación lógica
- Skill `firebase-basics` debe estar en `~/.config/opencode/skills/firebase-basics/` → esto es disponibilidad real
- Si no está instalada, el pipeline documenta la brecha pero NO promete autoactivación
- Regla crítica: no activar skills Firebase solo por mencionar Firebase; requieren contexto técnico específico o confirmación de stack

## Separación: Pipeline/Registry (lógico) vs Bootstrap/Scripts (disponibilidad real)

Es fundamental entender que:

| Concepto | Rol | Afecta detección en opencode |
|----------|-----|------------------------------|
| **Pipeline/Registry** (`.atl/skill-registry.md`) | Define **cuándo activar** skills según contexto y fase | ❌ No |
| **Bootstrap/Scripts** (`scripts/install-opencode-skills.sh`) | Hace que opencode **detecte** las skills físicamente | ✅ Sí |

### Por qué importa esta distinción

Si el registry dice "activa `supabase` tras stack confirmado", eso es solo una **regla de orquestación lógica** para el `sdd-orchestrator`. Para que opencode realmente use esa skill, debes:

1. Tener la skill en `~/.config/opencode/skills/supabase/` (vía symlink o copia)
2. Reiniciar opencode para refrescar la lista de skills

Si la skill no está físicamente instalada, el routing fallará silenciosamente (el orquestador pedirá la skill, pero opencode no la tendrá disponible).

## Resumen práctico

1. **Engram** → memoria y contexto que sobrevive entre sesiones
2. **Bootstrap (`bash scripts/bootstrap.sh`)** → hace que opencode vea las skills del repo localmente
3. **`.atl/skill-registry.md`** → solo lo usa la orquestación SDD, no afecta la detección local de skills
4. **Skills externas** (como `supabase` y Firebase en `/home/kkaps/.agents/skills/`) → el bootstrap las procesa por default desde `~/.agents/skills`; `EXTERNAL_SKILLS_DIR` solo sirve como override si quieres otra fuente
5. **Firebase skills** → no activar solo por mencionar Firebase; requieren contexto técnico específico o confirmación de stack

Si tu repo ya usa Engram, úsalo para recordar contexto y decisiones; **igual debes correr el bootstrap** para que opencode detecte las skills del repo. Para skills externas, documenta la dependencia y proporciona guidance de instalación. No activar skills Firebase prematuramente.

## Evaluación de `scripts/install-opencode-skills.sh` para Skills Externas

El script actual **sí puede exponer skills externas** y por defecto usa `EXTERNAL_SKILLS_DIR="${HOME}/.agents/skills"`. Su lógica ahora:

1. Procesa directorios dentro del repo: `"${REPO_ROOT}"/*` y `"${REPO_ROOT}"/dev-skills/*`
2. Procesa directorios externos desde `"${EXTERNAL_SKILLS_DIR}"/*` cuando la variable apunta a una carpeta válida (o a la ruta por defecto)
3. Puede enlazar skills de `/home/kkaps/.agents/skills/` hacia `~/.config/opencode/skills/`

### Implicaciones para Supabase

- Las skills `supabase` y `supabase-postgres-best-practices` pueden enlazarse con `scripts/install-opencode-skills.sh`; por defecto ya toma `/home/kkaps/.agents/skills` como fuente externa
- El `.atl/skill-registry.md` define orquestación lógica (cuándo activar), pero sin instalación física, opencode no las detectará
- **No se promete autoactivación real**: cualquier documentación debe indicar que requiere paso previo de instalación o bootstrap con skills externas

### Implicaciones para Firebase

- Las 10 skills de Firebase (`firebase-basics`, `firebase-auth-basics`, `firebase-firestore-standard`, `firebase-firestore-enterprise-native-mode`, `firebase-hosting-basics`, `firebase-app-hosting-basics`, `firebase-security-rules-auditor`, `firebase-data-connect`, `firebase-ai-logic-basics`, `developing-genkit-js`) pueden enlazarse con `scripts/install-opencode-skills.sh`; por defecto ya toma `/home/kkaps/.agents/skills` como fuente externa
- El `.atl/skill-registry.md` define orquestación lógica (cuándo activar cada una), pero sin instalación física, opencode no las detectará
- **No activar skills Firebase solo por mencionar Firebase**: requieren contexto técnico específico o confirmación de stack
- **No se promete autoactivación real**: cualquier documentación debe indicar que requiere paso previo de instalación o bootstrap con skills externas

### Fallback Guidance

Si el bootstrap no se ejecutó todavía, tienes dos opciones equivalentes:

```bash
# Opción A: bootstrap por defecto (usa ~/.agents/skills)
bash scripts/bootstrap.sh

# Opción B: symlinks manuales
ln -s /home/kkaps/.agents/skills/supabase ~/.config/opencode/skills/supabase
ln -s /home/kkaps/.agents/skills/supabase-postgres-best-practices ~/.config/opencode/skills/supabase-postgres-best-practices
```

Para Firebase, aplica el mismo patrón (o sobrescribe `EXTERNAL_SKILLS_DIR` si tu fuente externa es otra):

```bash
bash scripts/bootstrap.sh
```

Sin ese paso, el routing del registry fallará silenciosamente (el orquestador pedirá la skill, pero opencode no la tendrá disponible).

> **Regla crítica**: No activar skills Firebase solo por mencionar Firebase. Cada skill requiere contexto técnico específico o confirmación de stack en `tech-feasibility`. Sin instalación física, el routing fallará silenciosamente.
