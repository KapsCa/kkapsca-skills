---
name: tech-feasibility
description: "Trigger: qué tan difícil es construir esto, qué stack tiene más sentido, riesgos del MVP, cuánto esfuerzo y arquitectura mínima. Evalúa factibilidad técnica y elige stack con framework de decisión."
license: MIT
metadata:
  author: KkapsCa
  version: "3.0"
  pipeline: "project-kickstart/04"
  prev: "project-init"
  next: ""
  input_principal: "Project Framing Doc"
  input_bypass: "Discovery Report"
---

# Tech Feasibility — Step 4

> **Input:** Project Framing Doc (o Discovery Report por bypass) · **Output:** Tech Spec

## Activation Contract

Carga cuando el problema, el usuario y el MVP ya están definidos y el objetivo es **decidir cómo construir**, no explorar la idea desde cero.

NO activar si: la idea todavía está borrosa y no hay problema ni usuario definidos · el usuario solo quiere saber qué stack está "de moda" · no hay claridad funcional para distinguir qué entra al MVP.

Pre-flight: existe un Product Brief o un Discovery Report suficientemente claro · problema, usuario y MVP definidos a nivel útil · el objetivo es decidir cómo construir. Si falla una casilla, vuelve a la skill anterior.

## Hard Rules

- Problema antes que tecnología; riesgo antes que hype; arquitectura proporcional al alcance; decisiones justificadas, no heredadas de un tutorial (`references/filosofia.md`).
- No confundas preferencia personal con criterio técnico.
- Presenta siempre al menos una alternativa y su tradeoff: son opciones, no recetas ni favoritos.
- Sin el inventario técnico del MVP no propongas stack: elegir stack sin él es disparar a ciegas (`references/mvp-inventory.md`).
- Si el modelo de negocio o el usuario no están claros, dilo: el problema ya no es técnico.
- Si una dependencia externa puede romper el producto, documentá esa fragilidad.

## Decision Gates

| Situación | Ruta |
|---|---|
| Falta el inventario técnico del MVP | Fase 1 primero (`references/mvp-inventory.md`) |
| No sabés si ya podés recomendar stack | Resolvé el Stack Selection Gate (`references/gates.md`) |
| Ya podés recomendar | Fases 3 a 6, cada una con su referencia |
| Stack confirmado: Supabase, Firebase o Genkit | Activar las skills de ese stack en la implementación (`references/stack-skill-activation.md`) |

## Execution Steps

0. **Clasifica el proyecto** — aprendizaje · side project · producto serio · herramienta interna — y ajustá el rigor (`references/gates.md`).
1. **Inventario técnico del MVP**: por cada Must Have, las capacidades que necesita y los requisitos no funcionales mínimos (`references/mvp-inventory.md`).
2. **Framework de decisión de stack**: respondé las preguntas del gate **antes** de proponer tecnología (`references/gates.md`).
3. **Opciones, no recetas**: frontend, backend y datos/infraestructura con contexto y tradeoffs (`references/stack-options.md`).
4. **Complejidad y riesgos por feature**: complejidad, riesgo principal, dependencia externa y plan B (`references/feature-risk-map.md`).
5. **Estimación por rangos**: T-shirt sizing y optimista/realista/pesimista (`references/estimation.md`).
6. **Arquitectura mínima adecuada**: proporcional al tipo de proyecto (`references/architecture.md`).
7. **Generá el Tech Spec** (Output Contract).

## Output Contract

Tech Spec de 8 secciones; plantilla exacta en `references/tech-spec-template.md`: contexto · requisitos técnicos clave · decisión de stack con la alternativa descartada · riesgos · estimación · arquitectura · decisiones abiertas · siguiente paso.

Criterio de salida: propuesta de stack justificada · mapa de riesgos claro · estimación por rangos · arquitectura proporcional · claridad suficiente para empezar sin improvisar todo.

## References

- `references/gates.md` — Paso 0 y framework de decisión de stack.
- `references/mvp-inventory.md` — checklist técnico por feature.
- `references/stack-options.md` — opciones de frontend, backend y datos.
- `references/feature-risk-map.md` — riesgo por feature.
- `references/estimation.md` — T-shirt sizing y rangos.
- `references/architecture.md` — arquitectura por tipo de proyecto.
- `references/stack-skill-activation.md` — skills a activar por stack confirmado.
- `references/tech-spec-template.md` — plantilla del Tech Spec.
- `references/filosofia.md` — regla de oro y principios.
