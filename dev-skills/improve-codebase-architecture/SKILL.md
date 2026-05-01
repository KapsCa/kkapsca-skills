---
name: improve-codebase-architecture
description: >
  Revisión de arquitectura enfocada en detectar deuda, acoplamiento y violaciones
  de responsabilidades. Integra con SDD como paso previo a propuestas o diseño.
  Trigger: Cuando el usuario diga "revisar arquitectura", "architecture review",
  "mejorar estructura", "codebase health", "tech debt check", "refactor review".
license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
---

# Improve Codebase Architecture

**Main Skill** — Revisión arquitectónica primaria (las otras dos son *companions*).

## When to Use

Usa esta skill cuando:

- el usuario pida revisar la arquitectura de un proyecto o módulo,
- haya sospecha de deuda técnica, acoplamiento excesivo o responsabilidades mezcladas,
- se vaya a iniciar una propuesta (`sdd-propose`) o diseño (`sdd-design`) y necesites un diagnóstico previo,
- quieras justificar un refactor antes de proponer cambios formales en SDD.

## Trigger

Cárgala cuando escuches: "revisar arquitectura", "architecture review", "mejorar estructura", "codebase health", "tech debt check", "refactor review", o cualquier variante que sugiera evaluar la salud estructural del código.

## When NOT to Use

- para correcciones pequeñas o fixes puntuales (usa `diagnose`),
- cuando el problema sea específico de Flutter, Firebase o Supabase (usa la skill oficial correspondiente),
- si el usuario apenas está en fase de `brainstorm` o `product-discovery` y no hay código que revisar,
- **si hay un comando `/sdd-*` explícito (SDD manda, esta skill es solo complemento previo)**.

## Precedencia

- Si el problema es específico de un stack (Flutter, Firebase, Supabase, Genkit), usa la skill oficial de ese stack en lugar de esta.
- Esta skill es **main skill** para revisión arquitectónica transversal; las skills de stack tienen prioridad si el problema es puramente de ese framework.

## Fallback

- Si no hay código suficiente para revisar (proyecto en fase `brainstorm`/`discovery`), no activar; usar la fase upstream correspondiente.
- Si la skill requerida no está instalada en `~/.config/opencode/skills`, documentar la brecha y seguir con SDD/skill disponible.
- Si el módulo ya es conocido y el cambio es mecánico, omitir esta skill.

---

## Core Patterns

### 1. Enfoque proporcional
- No impongas Clean Architecture completa a un proyecto de 2 pantallas.
- Detecta si el tamaño del proyecto justifica capas separadas (`flutter-architecting-apps`) o si basta con separar responsabilidades básicas.

### 2. Detecta anti-patrones
- Lógica de negocio dentro de UI,
- IO (HTTP, DB) en widgets o controladores de estado,
- Estado global compartido innecesariamente,
- Dependencias circulares o acoplamiento fuerte entre módulos.

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

## Input para SDD
- [Si aplica: qué propuesta/diseño debería hacerse tras este review]
```

### 4. Integración con SDD
- Esta skill NO reemplaza `sdd-propose` ni `sdd-design`.
- Es un paso previo que alimenta esas fases con contexto estructural.
- Si el usuario quiere cambios formales después del review, enruta a `sdd-propose` con este output como base.

---

## Workflow (Architecture Review)

```
1. Leer estructura de directorios relevante (lib/, src/, internal/, etc.)
2. Identificar responsabilidades por archivo/carpeta
3. Detectar anti-patrones y deuda técnica
4. Evaluar si la arquitectura es proporcional al alcance
5. Producir el resumen ejecutivo (ver formato arriba)
6. Sugerir próximos pasos (SDD propose/design o fixes puntuales)
```

---

## Output Contract

La skill termina cuando se entregó el resumen ejecutivo y se indicó claramente si el siguiente paso es:

- `sdd-propose` (cambio formal),
- fix puntual (usa `diagnose`),
- o mantener y monitorear (si el estado es bueno).

---

## Diagnostics Integration

Si durante la revisión encuentras un bug o comportamiento incorrecto, NO intentes arreglarlo aquí.
- Documéntalo en la sección de hallazgos,
- Luego usa `diagnose` para el fix puntual.

---

## PRE-FLIGHT CHECKLIST

- [ ] Ya identifiqué la estructura general del proyecto
- [ ] Ya detecté si hay capas separadas o todo está mezclado
- [ ] Ya confirmé si la arquitectura es proporcional al alcance
- [ ] Ya produje el resumen ejecutivo
- [ ] Ya indiqué próximos pasos (SDD o fixes)

---

## Reglas Operativas

- Mantén el tono directo y constructivo, no seas un manual de teoría.
- Enfócate en lo que está mal y cómo arreglarlo, no en lo que está bien.
- Si el proyecto no tiene arquitectura discernible, di "acoplado / sin estructura" y recomienda pasos mínimos.
- No inventes reglas de Clean Architecture si el proyecto es pequeño.
- Si aparece un concepto específico (Flutter, Firebase, Supabase), enruta a la skill oficial correspondiente.

---

## Commands (reference)

```bash
# Quick structure overview
find lib -type f -name "*.dart" | head -20
tree -L 3 src/ 2>/dev/null || find src -type d | head -20
```
