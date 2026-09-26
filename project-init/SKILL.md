---
name: project-init
description: "Trigger: decidir enfoque de desarrollo (predictivo, adaptativo o híbrido), secuencia de trabajo, alcance en épics y stories, acuerdos mínimos. Convierte el Discovery Report en un Project Framing Doc."
license: MIT
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/03"
  prev: "product-discovery"
  next: "tech-feasibility"
---

# Project Init — Step 3

> **Input:** Discovery Report de `product-discovery` (o Product Brief por bypass)
> **Output:** Project Framing Doc (alias: Project Charter)

## Activation Contract

Carga cuando el problema y el usuario ya están validados y hay que encuadrar cómo se construirá el proyecto antes de la factibilidad técnica.

NO activar si: el bypass ya cubre el caso — proyecto chico, un único interesado y decisor, sin restricciones (condiciones exactas en `references/gates.md`).

Pre-flight: Discovery Report con enfoque sugerido · problema y usuario validados · señal clara del tipo de proyecto. Si falta claridad, volver a `product-discovery`.

## Hard Rules

- Plan ligero, no burocracia: el mejor plan cabe en un sprint y permite avanzar sin bloquearse (`references/filosofia.md`).
- Sin el enfoque de desarrollo decidido y justificado no se continúa (`references/gates.md`).
- Backlog: suficiente para el primer sprint, no completo al 100% (`references/alcance.md`).
- DoD (Definition of Done) solo si aporta claridad real: breve y proporcional, nunca rígida en framing (`references/gobernanza.md`).
- Las skills de stack requieren instalación previa en `~/.config/opencode/skills` (opencode) o `~/.agents/skills` (Pi); el registry define orquestación, no instala (`docs/skill-registry.md`).

## Decision Gates

| Gate | Ruta |
| --- | --- |
| Enfoque de desarrollo sin decidir | Fase 1 primero: matriz de señales predictivo/adaptativo/híbrido (`references/gates.md`) |
| Bypass aplicable (1-2 features, único decisor, sin regulación) | `tech-feasibility` con el Discovery Report directo (`references/gates.md`) |
| Stack confirmado (Supabase o Firebase) | Propagar la señal antes de cerrar (`references/stack-skill-activation.md`) |

## Execution Steps

1. **Fase 1 — Enfoque**: decidí con la matriz de señales; fijá enfoque + justificación (`references/gates.md`).
2. **Fase 2 — Fases y cadencia**: ≤4 fases con nombres propios del contexto · cadencia 1/2/4 semanas con revisor (opcional) · backlog priorizado por valor, talla S/M/L (`references/fases.md`).
3. **Fase 3 — Alcance**: MUST-HAVEs → user stories · aceptación mínima solo en stories críticas · primer sprint + épics para el resto del roadmap (`references/alcance.md`).
4. **Fase 4 — Gobernanza mínima**: cómo se toman decisiones · cómo se gestionan cambios de alcance · qué debe estar claro para avanzar (`references/gobernanza.md`).
5. **Generá el Project Framing Doc** (Output Contract).

## Output Contract

Project Framing Doc v1.0 en 7 secciones: enfoque con justificación · fases · cadencia (opcional) · alcance inicial (backlog del primer sprint + épics) · gobernanza mínima · stakeholders · siguiente paso. Plantilla exacta: `references/framing-doc-template.md`.

Criterio de salida: enfoque seleccionado con justificación · fases ligeras · user stories de al menos 1 sprint · gobernanza acordada · criterios de avance claros hacia `tech-feasibility` · stakeholders identificados.

## References

- `references/gates.md` — pre-flight, matriz de enfoque (Fase 1) y bypass.
- `references/fases.md` — Fase 2: fases, cadencia y priorización.
- `references/alcance.md` — Fase 3: stories, aceptación, tallas y épics.
- `references/gobernanza.md` — Fase 4: tres preguntas, DoD y mapeo PMBOK 8.
- `references/stack-skill-activation.md` — matriz Supabase/Firebase.
- `references/framing-doc-template.md` — plantilla del Project Framing Doc.
- `references/filosofia.md` — regla de oro y filosofía.
