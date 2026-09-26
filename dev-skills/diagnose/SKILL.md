---
name: diagnose
description: "Trigger: debug, diagnosticar, arreglar error, fix bug, por qué falla, reproducir bug, regression check; crash o fallo inesperado. Debugging sistemático: repro → minimiza → instrumenta → arregla → regresión."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
---

# Diagnose — Debugging Canónico

**Companion Skill** — debugging puntual; review amplio: `improve-codebase-architecture`.

## Activation Contract

Carga esta skill ante: un bug concreto (crash o comportamiento inesperado); un pedido de "debug", "diagnosticar" o "arreglar este error"; aislar un bug antes de proponer un cambio formal (ODD, o SDD si fue seleccionado); o validar que un fix no rompió nada (regresión).

NO la actives para: revisión de arquitectura amplia, features nuevas ni editing de flujo normal sin un bug claro (rutas en **Decision Gates**).

Precedencia: **companion** para debugging puntual, no compete con skills de stack. Bug puramente de framework (Flutter, Firebase, Supabase, Genkit): usa la skill oficial de stack.

## Hard Rules

- No refactors mientras debuggeas: solo lo necesario para que el caso pase.
- Fix proporcional al problema.
- No mezcles con arquitectura: anota la deuda técnica para después.
- Output conciso: entrega el reporte.
- Usa la observabilidad del stack (tabla en `references/commands.md`).

## Decision Gates

| Gate | Ruta |
| --- | --- |
| Sin error reproducible, o el usuario está en diseño/propuesta | No activar: seguir ODD (flujo por defecto); `sdd-design`/`sdd-propose` solo si SDD fue seleccionado. |
| Bug puramente de framework (Flutter, Firebase, Supabase, Genkit) | Usar la skill oficial de stack en su lugar. |
| Arquitectónico, no bug puntual | Enrutar a `improve-codebase-architecture`. |
| El fix requiere feature o refactor amplio | No aquí: documentarlo y proponerlo por el flujo formal (ODD, o SDD si fue seleccionado). |
| Skill requerida no instalada en `~/.config/opencode/skills` | Documentar la brecha y seguir con el flujo disponible (ODD o SDD). |

## Execution Steps

1. **REPRO** — reproducir el error de forma consistente: registra los pasos exactos y el entorno (OS, versión, stack).
2. **MINIMIZE** — reducir al escenario mínimo viable: elimina variables (¿sin estado previo? ¿con datos mínimos?) y aísla el componente/archivo sospechoso.
3. **INSTRUMENT** — agrega logs, prints, debugger o tests que fallen: captura el estado exacto en el punto de falla.
4. **FIX** — aplicar la corrección mínima.
5. **REGRESSION** — correr los tests existentes; si no hay, crear un caso mínimo que valide el fix. Comandos por stack: `references/commands.md`.

## Output Contract

Devuelve el reporte `# Diagnóstico — [breve descripción del error]` con: Reproducción (pasos + entorno), Causa raíz, Fix aplicado (archivo + qué cambió) y Regresión. Plantilla exacta, pre-flight checklist e integración con el trabajo formal (ODD por defecto; SDD solo si fue seleccionado): `references/report-template.md`.

## References

- `references/report-template.md` — reporte y checklist (ver Output Contract).
- `references/commands.md` — detalle de comandos y observabilidad por stack.
