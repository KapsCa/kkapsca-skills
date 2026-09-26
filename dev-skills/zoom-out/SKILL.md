---
name: zoom-out
description: "Trigger: entender el sistema, zoom out, perspectiva global, antes de editar esto, entender flujo completo, system map, dependency check, editar código desconocido. Mapea dependencias, flujos y riesgos del sistema."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
---

# Zoom Out — Perspectiva de Sistema

**Companion Skill** — Contexto previo a edición (usa `improve-codebase-architecture` para review amplio).

## Activation Contract

Carga esta skill antes de editar código desconocido: cuando necesites entender cómo encaja una pieza en el sistema antes de proponer cambios, o vayas a implementar en un módulo que no dominas.

NO la actives para debugging puntual (usa `diagnose`) ni para revisión de arquitectura amplia (usa `improve-codebase-architecture`). Si el módulo ya es conocido o el cambio es mecánico, omítela.

Precedencia: companion para contexto previo a edición; no compite con skills de stack específico.

## Hard Rules

- Super breve: el resumen debe caber en una pantalla; no escribas un tratado.
- No hagas cambios aquí: solo mapa y diagnóstico de riesgos.
- Enfócate en efectos colaterales: el objetivo es no romper nada al editar.
- Usa herramientas del stack: `grep -r "import" lib/`, `go list -m all`, etc.

## Decision Gates

| Gate | Ruta |
| --- | --- |
| No hay código suficiente o el usuario apenas inicia | No activar; usar fases upstream (`brainstorm`, `product-discovery`) |
| La skill no está instalada en `~/.config/opencode/skills` | Documentar la brecha y seguir con el flujo disponible (ODD o SDD) |
| Módulo ya conocido, cambio mecánico | Omitir esta skill y proceder directo a la implementación |
| El mapa revela que el módulo necesita refactor | Considerar `improve-codebase-architecture` primero |

## Execution Steps

1. Ejecuta el proceso de tres direcciones antes de editar código desconocido: mapa de dependencias, flujo de datos y riesgos identificados (`references/process.md`).
2. Usa herramientas del stack en cada dirección (`references/commands.md`).
3. Entrega el resumen breve (Output Contract) **antes** de escribir código en módulos que no dominas.

## Output Contract

Entrega `# System Zoom — [Módulo/Archivo]`: dependencias clave, flujo de datos (entrada, salida, efectos), riesgos al editar y recomendación final. Plantilla exacta, checklist e integración con el trabajo formal: `references/report-template.md`.

## References

- `references/context-validation.md` — criterios de activación, precedencia y fallback.
- `references/process.md` — proceso completo, reglas operativas y detalle de cada dirección.
- `references/report-template.md` — plantilla del reporte, checklist e integración ODD/SDD.
- `references/commands.md` — comandos por stack (Dart, Node, Go).
