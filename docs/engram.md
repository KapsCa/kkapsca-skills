# Engram — Memoria Persistente para Desarrollo

**Engram** es un sistema de memoria persistente diseñado para entornos de desarrollo asistidos por Inteligencia Artificial. Su propósito es mantener contexto, decisiones y flujos de trabajo entre sesiones de desarrollo, incluso después de reinicios o compresiones de contexto (compactions) del agente.

## ¿Por qué usamos Engram en este repositorio?

Este repositorio de habilidades (**skills**) utiliza Engram para:

- **Recordar decisiones de arquitectura** tomadas durante el desarrollo de las habilidades
- **Mantener contexto de proyecto** para que el orquestador SDD (**sdd-orchestrator**) tenga información histórica
- **Guardar patrones y convenciones** establecidos mientras se escriben las habilidades
- **Recuperar trabajo previo** mediante búsqueda de texto completo (FTS5)

Al usar Engram, las sesiones de desarrollo no empiezan desde cero: el agente puede recuperar qué se hizo, qué decisiones se tomaron y qué problemas se resolvieron anteriormente.

## Comparación rápida: Engram vs Bootstrap vs Skill-Registry

Es común confundir el papel de **Engram** con el registro de habilidades en opencode. Son cosas distintas y ambas cumplen roles diferentes.

| Concepto | ¿Qué hace? | ¿Registra skills en opencode? |
|----------|------------|-------------------------------|
| **Engram** | Guarda memoria persistente del proyecto, contexto, decisiones y flujos de trabajo entre sesiones. | ❌ No |
| **Bootstrap / Instalador** | Crea enlaces simbólicos o copias de las skills en `~/.config/opencode/skills` para que opencode las detecte. | ✅ Sí |
| **`.atl/skill-registry.md`** | Catálogo de skills del proyecto para que el `sdd-orchestrator` resuelva estándares y reglas de proyecto. | ❌ No |

## Engram — Memoria persistente

Engram es un sistema de memoria que sobrevive entre sesiones y compresiones de contexto (compactions). Permite:

- Guardar decisiones de arquitectura y diseño
- Recordar errores corregidos y lecciones aprendidas
- Mantener contexto de proyecto para el orquestador SDD
- Buscar trabajo previo mediante búsqueda de texto completo (FTS5)

### Cuándo usarlo

- Después de hacer una decisión de arquitectura
- Al completar una corrección de error importante
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

- Por defecto: crea **enlaces simbólicos** (se actualizan con `git pull`)
- Con `--copy`: crea copia física independiente

### Desde qué carpeta se ejecuta

El bootstrap se ejecuta desde la **carpeta de este repo de skills**, no desde la carpeta de tu proyecto futuro.

## `.atl/skill-registry.md` — Catálogo para orquestación

Este archivo es usado únicamente por el `sdd-orchestrator` para:

- Resolver estándares de proyecto (reglas compactas)
- Inyectar reglas en sub-agentes
- Mapear disparadores (**triggers**) de skills a contextos de código

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

1. Tener la skill en `~/.config/opencode/skills/supabase/` (vía enlace simbólico o copia)
2. Reiniciar opencode para refrescar la lista de skills

Si la skill no está físicamente instalada, el enrutamiento (routing) fallará silenciosamente (el orquestador pedirá la skill, pero opencode no la tendrá disponible).

## Resumen práctico

1. **Engram** → memoria y contexto que sobrevive entre sesiones
2. **Bootstrap (`bash scripts/bootstrap.sh`)** → hace que opencode vea las skills del repo localmente
3. **`.atl/skill-registry.md`** → solo lo usa la orquestación SDD; incluye columna `State` (repo-local, external-bootstrappable, logical-only) para distinguir disponibilidad real de routing lógico. No afecta la detección local de skills.
4. **Skills externas** (Supabase, Firebase, Genkit) → el bootstrap las procesa por defecto desde `${AGENTS_DIR}` (equivale a `$HOME/.agents/skills`). Usa `EXTERNAL_SKILLS_DIR` solo si quieres otra fuente.
5. **Firebase skills** → no activar solo por mencionar Firebase; requieren contexto técnico específico o confirmación de stack.

Si tu repo ya usa Engram, úsalo para recordar contexto y decisiones; **igual debes correr el bootstrap** para que opencode detecte las skills del repo. Para skills externas, documenta la dependencia y proporciona una guía de instalación. No actives skills de Firebase prematuramente.

## Evaluación de `scripts/install-opencode-skills.sh` para Skills Externas

El script actual **sí puede exponer skills externas** y por defecto usa `EXTERNAL_SKILLS_DIR="${HOME}/.agents/skills"`. Su lógica ahora:

1. Procesa directorios dentro del repo: `"${REPO_ROOT}"/*` y `"${REPO_ROOT}"/dev-skills/*`
2. Procesa directorios externos desde `"${EXTERNAL_SKILLS_DIR}"/*` cuando la variable apunta a una carpeta válida (o a la ruta por defecto)
3. Puede enlazar skills de la carpeta externa hacia `~/.config/opencode/skills/`

### Skills Externas

El registry ahora usa una convención portable (`${AGENTS_DIR}`) en lugar de rutas absolutas. El estado de cada skill se indica en la columna `State`:

- **external-bootstrappable**: La skill existe en `${AGENTS_DIR}` (por defecto `$HOME/.agents/skills`). El bootstrap la procesa si el directorio externo está configurado.
- **repo-local**: Vive en este repositorio.
- **logical-only**: Candidato o referencia sin instalación garantizada.

Para cualquier skill externa (Supabase, Firebase, Genkit), aplica el mismo principio:

- El `.atl/skill-registry.md` define orquestación lógica (cuándo activar), pero sin instalación física opencode no las detectará.
- **No se promete autoactivación real**: cualquier documentación debe indicar que requiere paso previo de instalación o bootstrap con skills externas.
- **No activar skills Firebase solo por mencionar Firebase**: requieren contexto técnico específico o confirmación de stack.
- **Genkit**: cada lenguaje tiene su propia skill (`developing-genkit-{js,dart,go,python}`) con trigger específico. Consultar la matriz en el registry para el routing correcto.

### Fallback Guidance

Si el bootstrap no se ejecutó todavía, tienes dos opciones equivalentes:

```bash
# Opción A: bootstrap por defecto (usa ${HOME}/.agents/skills)
bash scripts/bootstrap.sh

# Opción B: enlaces simbólicos manuales
ln -s ${HOME}/.agents/skills/supabase ~/.config/opencode/skills/supabase
ln -s ${HOME}/.agents/skills/supabase-postgres-best-practices ~/.config/opencode/skills/supabase-postgres-best-practices
```

Para Firebase, aplica el mismo patrón (o sobrescribe `EXTERNAL_SKILLS_DIR` si tu fuente externa es otra):

```bash
bash scripts/bootstrap.sh
```

Sin ese paso, el enrutamiento del registry fallará silenciosamente (el orquestador pedirá la skill, pero opencode no la tendrá disponible).

> **Regla crítica**: No activar skills Firebase solo por mencionar Firebase. Cada skill requiere contexto técnico específico o confirmación de stack en `tech-feasibility`. Sin instalación física, el enrutamiento (routing) fallará silenciosamente.
