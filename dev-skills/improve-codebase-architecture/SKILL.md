---
name: improve-codebase-architecture
description: "Trigger: revisar arquitectura, architecture review, mejorar estructura, codebase health, tech debt check, refactor review. Detecta deuda, acoplamiento y responsabilidades mezcladas; input al trabajo formal."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
---
# Improve Codebase Architecture

**Main Skill** — Revisión arquitectónica primaria (las otras dos son *companions*).

## Activation Contract

Carga esta skill cuando haya sospecha de deuda técnica, acoplamiento excesivo o responsabilidades mezcladas, se vaya a iniciar trabajo formal — ODD, o `sdd-propose` / `sdd-design` si SDD fue seleccionado — y necesites un diagnóstico previo, o quieras justificar un refactor antes de proponer cambios formales.

NO la actives para: correcciones pequeñas o fixes puntuales (usa `diagnose`) · problemas específicos de Flutter, Firebase o Supabase (skill oficial correspondiente) · fase de `brainstorm`/`product-discovery` sin código que revisar · un comando `/sdd-*` explícito (SDD manda; esta skill es solo complemento previo).

Precedencia: main skill para revisión arquitectónica transversal. Si el problema es puramente de un stack (Flutter, Firebase, Supabase, Genkit), la skill oficial de ese stack tiene prioridad.

## Hard Rules

- Mantén el tono directo y constructivo; no seas un manual de teoría.
- Enfócate en lo que está mal y cómo arreglarlo, no en lo que está bien.
- Si el proyecto no tiene arquitectura discernible, di "acoplado / sin estructura" y recomienda pasos mínimos.
- No inventes reglas de Clean Architecture si el proyecto es pequeño.
- Si aparece un concepto específico (Flutter, Firebase, Supabase), enruta a la skill oficial correspondiente.
- No impongas Clean Architecture completa a un proyecto de 2 pantallas; evalúa si el tamaño justifica capas separadas (`references/anti-patterns.md`).
- Si durante la revisión encuentras un bug, NO lo arregles aquí: documéntalo en hallazgos y usa `diagnose`.

## Decision Gates

| Gate | Ruta |
| --- | --- |
| No hay código suficiente para revisar (fase `brainstorm`/`discovery`) | No activar; usar la fase upstream correspondiente |
| La skill requerida no está instalada en `~/.config/opencode/skills` | Documentar la brecha y seguir con el flujo disponible (ODD o SDD) |
| Módulo ya conocido y cambio mecánico | Omitir esta skill |
| Tras el review, el usuario quiere cambios formales | Enrutar al trabajo formal con este output como base (ODD, o `sdd-propose` si SDD) |

## Execution Steps

1. workflow (Architecture Review): leer estructura, identificar responsabilidades, detectar anti-patrones y deuda, evaluar proporción, producir el resumen y sugerir próximos pasos (`references/workflow.md`).
2. Aplica el enfoque proporcional y detecta anti-patrones: `references/anti-patterns.md`.
3. Termina cuando se entregó el resumen ejecutivo con el siguiente paso claro (Output Contract).

## Output Contract

La skill termina cuando se entregó el resumen ejecutivo y se indicó claramente si el siguiente paso es: iniciar el trabajo formal ODD con un documento de feature (`odd/tasks/<feature>.md`; esto es lo que corresponde por defecto), `sdd-propose` (cambio formal, solo si SDD fue seleccionado), fix puntual (usa `diagnose`), o mantener y monitorear (si el estado es bueno). Plantilla exacta y checklist: `references/report-template.md`.

## References

- `references/workflow.md` — Workflow (Architecture Review).
- `references/anti-patterns.md` — enfoque proporcional y anti-patrones.
- `references/report-template.md` — plantilla, integración formal y checklist.
- `references/rules.md` — reglas operativas (detalle de las Hard Rules).
- `references/commands.md` — comandos de overview rápido.
