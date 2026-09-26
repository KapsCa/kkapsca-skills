# Plantilla del reporte y checklist — Improve Codebase Architecture

Detalle local de `SKILL.md` (## Output Contract).

Al terminar el review, entrega el resumen ejecutivo usando esta plantilla exacta:

### 3. Archivo de salida (output)
La revisión debe producir un resumen ejecutivo conciso:

```markdown
# Architecture Review — [Proyecto/Módulo]

## Estado general
[Bueno / Aceptable / Problemático] — [breve justificación]

## Hallazgos clave
- [Violación 1: dónde, qué, impacto]
- [Violación 2: ...]

## Recomendaciones
- [Acción concreta, archivos sugeridos, prioridad]

## Input para el trabajo formal
- [Si aplica: qué propuesta/diseño debería hacerse tras este review]
```

## Integración con el trabajo formal (ODD / SDD)

### 4. Integración con el trabajo formal (ODD / SDD)
- Esta skill NO reemplaza el trabajo formal: ni ODD ni `sdd-propose` / `sdd-design`.
- Es un paso previo que alimenta esas fases con contexto estructural.
- Si el usuario quiere cambios formales después del review, enruta al trabajo formal (ODD, o `sdd-propose` si SDD fue seleccionado) con este output como base.

## PRE-FLIGHT CHECKLIST

- [ ] Ya identifiqué la estructura general del proyecto
- [ ] Ya detecté si hay capas separadas o todo está mezclado
- [ ] Ya confirmé si la arquitectura es proporcional al alcance
- [ ] Ya produje el resumen ejecutivo
- [ ] Ya indiqué próximos pasos (trabajo formal o fixes)

## Diagnostics Integration

Si durante la revisión encuentras un bug o comportamiento incorrecto, NO intentes arreglarlo aquí.
- Documéntalo en la sección de hallazgos,
- Luego usa `diagnose` para el fix puntual.
