# Plantilla del reporte y checklist — Zoom Out

Detalle local de `SKILL.md` (## Output Contract).

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

## Integración con el trabajo formal (ODD / SDD)

- Esta skill es **companion** de la implementación: ODD paso 6 por defecto, o `sdd-design` / `sdd-apply` si SDD fue seleccionado.
- Úsala **antes** de escribir código en módulos que no dominas.
- No reemplaza el análisis de diseño (`sdd-design` si SDD fue seleccionado), solo da contexto previo.
- Si el mapa revela que el módulo necesita refactor, considera `improve-codebase-architecture` primero.

## PRE-FLIGHT CHECKLIST

- [ ] Ya identifiqué las dependencias directas del archivo/módulo
- [ ] Ya trazé el flujo de datos de entrada a salida
- [ ] Ya listé los riesgos potenciales al editar
- [ ] Ya entregué el resumen breve
- [ ] Ya indiqué si es seguro editar o requiere pasos previos
