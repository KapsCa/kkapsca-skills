---
name: brainstorm
description: "Trigger: tengo una idea, quiero hacer una app, no sé por dónde empezar, ayúdame a aterrizar esto, definir mejor mi producto. Convierte una idea vaga en un Product Brief."
license: MIT
metadata:
  author: KkapsCa
  version: "4.0"
  pipeline: "project-kickstart/01"
  next: "product-discovery"
  prev: ""
---

# Brainstorm — Step 1

> **Pipeline:** `brainstorm` → `product-discovery` → `project-init` → `tech-feasibility` · **Input:** idea vaga, intuición o problema mal definido · **Output:** Product Brief

## Activation Contract

NO activar si: hay claridad suficiente de problema/usuario/MVP · el usuario trae un Brief razonable · se busca comparar tecnologías o planear implementación.

Pre-flight: idea real, no Brief completo · sin claridad de problema/usuario/MVP · objetivo: aterrizar, no decidir stack. Si alguna casilla falla, pasa a la skill correcta.

## Hard Rules

- Una pregunta a la vez; desafía ideas difusas con respeto; pregunta mínima del paso si falta info y vuelve al flujo.
- No saltes fases ni respondas adelantado lo de fases posteriores; sin features prematuras; micro-contrato por fase (`references/phase-contracts.md`).
- Sin stack antes de problema y usuario: la tecnología va al final.
- Desvío (stack jumping, feature creep, monetización prematura, competencia distractora) → frase de reconducción y volver a la fase; no la técnica hasta que el flujo lo permita (`references/desviaciones.md`).
- Output útil siempre: Brief válido según gates; si no, fase pendiente explícita. Nada de conversación suelta.
- Brief Parcial → `product-discovery` solo con fases 1-4 completas; falta crítica → terminar brainstorm.

## Decision Gates

| Condición | Salida |
|---|---|
| Fases 1-6 + micro-contratos completos | **Brief Completo** (Output Contract) |
| Faltan fases; micro-contrato actual cumplido | **Brief Parcial** (`references/brief-templates.md`) |
| Detiene a mitad de fase sin micro-contrato | **No generar Brief** — reconducir a completar la fase actual |
| Falta dato crítico, pero hay suficiente para ser útil | **Brief Parcial** con campos "Pendientes de validación" |

## Execution Steps

Fases 1-6 en orden. Preguntas por fase y micro-contratos: `references/question-bank.md` + `references/phase-contracts.md`.

1. **Idea cruda**: pregunta de arranque → explicación de 30s + pista de problema/usuario + contexto org. Gate: explicación + pista concreta de problema y de usuario.
2. **Problema real**: pregunta a la vez → Problema / Solución actual / Gap. Gate: bloque completo y validado.
3. **Usuario + Interesados (PMBOK 8)**: primario no genérico ("para todos" no sirve) + interesados ampliados (sufre/aprueba/construye/regulatorios). Gate: usuario ya no genérico.
4. **Propuesta de valor**: frase "Ayudamos a [usuario] a [resolver problema] mediante [solución], para que pueda [resultado valioso]" + valor preliminar. Gate: frase clara y específica.
5. **MVP**: versión mínima que resuelve el problema principal y permite aprender; recorta con Must/Should/Could Have y Not in MVP (`references/mvp-guide.md`). Gate: recortado, sin más de lo necesario.
6. **Diferenciadores**: máximo 2 claros (catálogo: `references/question-bank.md`) + dudas abiertas. Gate: sin diferenciador claro, no cierres el brief.
7. Genera el Brief.

## Output Contract

Plantilla v4.0 en `references/brief-templates.md`, solo tras pasar todas las reglas de avance. Parcial: fases completadas, fase pendiente, ausentes como "pendiente de validación en discovery".

Criterio de salida: problema claro · usuario identificable · propuesta de valor entendible · MVP recortado · valor esperado claro · interesados PMBOK 8 · insumos para pasar a discovery sin improvisar.

## References

- `references/phase-contracts.md` — contratos por fase: captura / NO responde aún / señal de avance.
- `references/question-bank.md` — arranque, qué observar, preguntas por fase, diferenciadores.
- `references/mvp-guide.md` — el MVP, explicación no técnica, ejemplos y clasificación.
- `references/desviaciones.md` — desvíos y frases de reconducción.
- `references/brief-templates.md` — plantillas Brief Completo/Parcial; transición a `product-discovery`.
