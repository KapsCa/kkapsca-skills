# Proceso, operaciones y comandos — Zoom Out

Detalle local de `SKILL.md` (## Execution Steps, ## Hard Rules y ## References).

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

## Reglas Operativas

- **Super breve**: no escribas un tratado, el resumen debe caber en una pantalla.
- **No hagas cambios aquí**: solo mapa y diagnóstico de riesgos.
- **Enfócate en efectos colaterales**: el objetivo es no romper nada al editar.
- **Usa herramientas del stack**: `grep -r "import" lib/`, `go list -m all`, etc.
