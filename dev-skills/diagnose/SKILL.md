---
name: diagnose
description: "Trigger: debug, diagnosticar, arreglar error, fix bug, por qué falla, reproducir bug, regression check; crash o fallo inesperado. Debugging sistemático: repro → minimiza → instrumenta → arregla → regresión."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
---

# Diagnose — Debugging Canónico

**Companion Skill** — Debugging puntual (usa `improve-codebase-architecture` para review amplio).

## When to Use

Usa esta skill cuando:

- haya un error concreto, crash o comportamiento inesperado,
- el usuario pida "debug", "diagnosticar", "arreglar este error",
- necesites aislar un bug antes de proponer un cambio formal (ODD, o SDD si fue seleccionado),
- quieras validar que un fix no rompió nada (regresión).

## Trigger

Cárgala al escuchar: "debug", "diagnosticar", "arreglar error", "fix bug", "por qué falla", "reproducir bug", "regression check" o cualquier variante que pida investigar un fallo específico.

## When NOT to Use

- para revisiones de arquitectura amplias (usa `improve-codebase-architecture`),
- para planear features nuevas (usa el flujo por defecto, ODD; o `sdd-propose` si SDD fue seleccionado),
- para editing de flujo normal sin un bug claro,
- **no usar para review arquitectónico amplio; para eso usa `improve-codebase-architecture`**.

## Precedencia

- Si el bug es puramente de framework (Flutter, Firebase, Supabase, Genkit), usar la skill oficial de stack en su lugar.
- Esta skill es **companion** para debugging puntual; no compite con skills de stack específico.

## Fallback

- Si no hay error reproducible o el usuario está en fase de diseño/propuesta, no activar; usar el flujo SDD (`sdd-design` o `sdd-propose`) si fue seleccionado.
- Si la skill requerida no está instalada en `~/.config/opencode/skills`, documentar la brecha y seguir con el flujo disponible (ODD o SDD).
- Si el problema resulta ser arquitectónico y no un bug puntual, enrutar a `improve-codebase-architecture`.

---

## Ciclo de Debugging (Canónico)

```
1. REPRO: reproducir el error de forma consistente.
   - Anotar pasos exactos.
   - Identificar entorno (OS, versión, stack).

2. MINIMIZE: reducir el escenario al mínimo viable.
   - Eliminar variables: ¿ocurre sin estado previo? ¿con datos mínimos?
   - Aislar el componente/archivo sospechoso.

3. INSTRUMENT: agregar observabilidad.
   - Logs, prints, debugger, tests que fallen.
   - Capturar el estado exacto en el punto de falla.

4. FIX: aplicar la corrección mínima.
   - No refactors grandes, solo lo necesario para que pase el caso.
   - Mantener el fix proporcional al problema.

5. REGRESSION: verificar que no rompió nada.
   - Correr tests existentes.
   - Si no hay tests, crear un caso mínimo que valide el fix.
```

---

## Output Esperado

Al terminar, entrega un reporte breve:

```markdown
# Diagnóstico — [Breve descripción del error]

## Reproducción
Pasos: [1, 2, 3]
Entorno: [stack/versión]

## Causa raíz
[Qué lo provocó]

## Fix aplicado
[Archivo + qué cambió]

## Regresión
- [x] Tests existentes pasan
- [x] Nuevo caso de validación agregado (o justificación de por qué no)
```

---

## Integración con el trabajo formal (ODD / SDD)

- Esta skill es un **companion** del trabajo formal, no un proceso paralelo. ODD es el flujo por defecto; las fases SDD aplican si SDD fue seleccionado.
- Si el bug revela una necesidad de cambio estructural, luego enruta al trabajo formal con este diagnóstico como base: ODD (documento de feature + tareas), o `sdd-propose` si SDD fue seleccionado.
- Si el fix requiere una feature o refactor amplio, no lo hagas aquí: documéntalo y propón el cambio por el flujo formal (ODD, o SDD si fue seleccionado).

---

## PRE-FLIGHT CHECKLIST

- [ ] Ya reproduje el error de forma consistente
- [ ] Ya minimicé el escenario
- [ ] Ya instrumenté para ver el estado interno
- [ ] Ya apliqué el fix mínimo
- [ ] Ya verifiqué regresión

---

## Reglas Operativas

- **No refactors mientras debuggeas**: enfócate en arreglar el bug.
- **No mixes con arquitectura**: si descubres deuda técnica, anótala para después.
- **Output conciso**: no escribas un tratado, entrega el reporte y ya.
- **Usa las herramientas de observabilidad del stack**: `print` en Dart, `log` en Go, `console.log` en JS, etc.

---

## Commands (reference)

```bash
# Correr tests rápidos (según stack)
flutter test
go test ./...
npm test
pytest
```
