---
name: zoom-out
description: >
  Da una perspectiva de sistema antes de tocar código poco familiar.
  Mapea dependencias, flujos y riesgos para evitar romper cosas al editar.
  Integra con el trabajo formal: úsalo antes de implementar en código desconocido (ODD paso 6, o `sdd-design` / `sdd-apply` si SDD fue seleccionado).
  Trigger: Cuando el usuario diga "entender el sistema", "zoom out",
  "perspectiva global", "antes de editar esto", "entender flujo completo",
  "system map", "dependency check".
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
---

# Zoom Out — Perspectiva de Sistema

**Companion Skill** — Contexto previo a edición (usa `improve-codebase-architecture` para review amplio).

## When to Use

Usa esta skill cuando:

- vayas a editar código que no conoces bien,
- necesites entender cómo encaja una pieza en el sistema antes de proponer cambios,
- el usuario pida "entender el sistema", "zoom out", "perspectiva global",
- estés a punto de implementar en un módulo desconocido.

## Trigger

Cárgala al escuchar: "entender el sistema", "zoom out", "perspectiva global", "antes de editar esto", "entender flujo completo", "system map", "dependency check" o cualquier variante que pida ver el panorama completo antes de tocar código.

## When NOT to Use

- para debugging puntual (usa `diagnose`),
- para revisión de arquitectura amplia (usa `improve-codebase-architecture`),
- cuando ya conoces bien el módulo y no hay riesgo de efectos colaterales.

## Precedencia

- Omitir si el módulo ya es conocido o el cambio es mecánico.
- Esta skill es **companion** para contexto previo a edición; no compite con skills de stack específico.

## Fallback

- Si no hay código suficiente o el usuario apenas inicia, no activar; usar fases upstream (`brainstorm`, `product-discovery`).
- Si la skill no está instalada en `~/.config/opencode/skills`, documentar la brecha y seguir con el flujo disponible (ODD o SDD).
- Si el módulo es conocido, omitir esta skill y proceder directo a la implementación.

---

## Paso de Perspectiva de Sistema

Antes de editar código desconocido, ejecuta este proceso:

```
1. MAPA DE DEPENDENCIAS
   - ¿Qué importa este archivo?
   - ¿Qué otros archivos dependen de él?
   - ¿Qué servicios, repositorios o APIs externas toca?

2. FLUJO DE DATOS
   - ¿De dónde entra la información?
   - ¿Cómo se transforma antes de llegar aquí?
   - ¿Qué efectos secundarios tiene (logs, DB, red)?

3. RIESGOS IDENTIFICADOS
   - ¿Qué podría romperse si cambio la firma de esta función?
   - ¿Hay tests que cubran este flujo?
   - ¿Hay otros módulos que asuman el comportamiento actual?
```

---

## Output Esperado

Entrega un resumen súper breve:

```markdown
# System Zoom — [Módulo/Archivo]

## Dependencias clave
- [Archivo/Api 1]
- [Archivo/Api 2]

## Flujo de datos
Entrada: [de dónde]
Salida: [a dónde]
Efectos: [logs, DB, red]

## Riesgos al editar
- [Riesgo 1: qué podría romperse]
- [Riesgo 2: ...]

## Recomendación
[Editar con cuidado / Hacer refactor previo / Está seguro modificar]
```

---

## Integración con el trabajo formal (ODD / SDD)

- Esta skill es **companion** de la implementación: ODD paso 6 por defecto, o `sdd-design` / `sdd-apply` si SDD fue seleccionado.
- Úsala **antes** de escribir código en módulos que no dominas.
- No reemplaza el análisis de diseño (`sdd-design` si SDD fue seleccionado), solo da contexto previo.
- Si el mapa revela que el módulo necesita refactor, considera `improve-codebase-architecture` primero.

---

## PRE-FLIGHT CHECKLIST

- [ ] Ya identifiqué las dependencias directas del archivo/módulo
- [ ] Ya trazé el flujo de datos de entrada a salida
- [ ] Ya listé los riesgos potenciales al editar
- [ ] Ya entregué el resumen breve
- [ ] Ya indiqué si es seguro editar o requiere pasos previos

---

## Reglas Operativas

- **Super breve**: no escribas un tratado, el resumen debe caber en una pantalla.
- **No hagas cambios aquí**: solo mapa y diagnóstico de riesgos.
- **Enfócate en efectos colaterales**: el objetivo es no romper nada al editar.
- **Usa herramientas del stack**: `grep -r "import" lib/`, `go list -m all`, etc.

---

## Commands (reference)

```bash
# Ver imports de un archivo (Dart)
grep -R "^import" lib/features/my_feature/

# Ver dependencias de un paquete (Node)
npm list --depth=1

# Ver módulos que usan un paquete (Go)
grep -r "mi_paquete" .
```
