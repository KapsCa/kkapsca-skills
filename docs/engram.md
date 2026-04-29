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

## Resumen práctico

1. **Engram** → memoria y contexto que sobrevive entre sesiones
2. **Bootstrap (`bash scripts/bootstrap.sh`)** → hace que opencode vea tus skills localmente
3. **`.atl/skill-registry.md`** → solo lo usa la orquestación SDD, no afecta la detección local de skills

Si tu repo ya usa Engram, úsalo para recordar contexto y decisiones; **igual debes correr el bootstrap** para que opencode detecte las skills.
