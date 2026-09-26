---
name: product-discovery
description: "Trigger: responder si hay una necesidad real, quién la usaría, qué alternativas existen y cómo validarla sin construir de más. Valida necesidad, usuario, competencia y mercado de una idea o Brief."
license: MIT
metadata:
  author: KkapsCa
  version: "3.0"
  pipeline: "project-kickstart/02"
  prev: "brainstorm"
  next: "project-init"
---

# Product Discovery — Step 2

> **Pipeline:** `brainstorm` → `product-discovery` → `project-init` → `tech-feasibility` · **Input ideal:** Product Brief o idea ya suficientemente definida · **Output:** Discovery Report

## Activation Contract

Carga ante una idea ya aterrizada cuyo problema, usuario y valor hay que validar **antes** de construir.

NO activar si: idea demasiado vaga, sin claridad mínima del problema · mercado ya validado, solo falta stack/arquitectura · el objetivo es solo comparar tecnologías.

Pre-flight: Brief o idea aterrizada · problema nombrable sin hablar de solución · pista de usuario o nicho. Si falla una casilla, vuelve a `brainstorm`.

## Hard Rules

- Una pregunta a la vez; desafía suposiciones; mercado desconocido → investigarlo, no inventarlo.
- Regla de oro: necesidad, usuario concreto y razón real de uso o pago, antes de invertir semanas.
- Rigor: pequeño → ruta ligera sin formalismo; negocio serio → más rigor.
- Máximo 1-2 perfiles; "esto es para todos" → empuja a un usuario primario; no avances si sigue genérico/difuso.
- Propuesta de valor no clara por escrito → no avances de fase.
- Primero la validación más barata: sin MVP técnico si algo más barato enseña lo mismo; tampoco avanzar a `tech-feasibility` entonces.

## Decision Gates

Paso 0 — tipo de proyecto (nivel de discovery; ninguna fila aplica → pregunta antes de continuar):

| Tipo | Prioridad |
|---|---|
| Aprendizaje | entender problema, usuario y utilidad |
| Side project / microproducto | validar interés rápido (→ `project-init`) |
| Producto serio / negocio | mercado, monetización y viabilidad |
| Herramienta interna | utilidad y ahorro de tiempo/costo |

Modo de trabajo:

| Modo | Aplica cuando |
|---|---|
| **A — Discovery completo** | producto serio · monetizar · inversión grande de tiempo/dinero · justificar ante otras personas |
| **B — Discovery ligero** | side project · herramienta personal/interna · aprendizaje · interés rápido a validar |

Pipeline: A → el de arriba; B → `project-init` opcional (ver `references/work-modes.md`).

## Execution Steps

1. Clasifica el tipo y elige el modo (gates).
2. **Modo B — ligero**: las 5 (Problema · Usuario · Alternativa · Señal de valor · Validación mínima) → con las 5 claras: `project-init` (opcional) → `tech-feasibility`.
3. **Modo A — fases 1-6 en orden** (detalle: `references/discovery-phases.md`):
   1. Mercado y contexto: frecuencia/afectados del nicho; TAM/SAM/SOM solo si es producto serio/negocio; si no: nicho+usuarios+intensidad.
   2. Competencia y alternativas: directa, indirecta, sustitutos; tarjeta por competidor.
   3. Usuario y JTBD: 1-2 perfiles con perfil/problema/motivación/fricciones + job (plantilla en la referencia).
   4. Propuesta de valor: la frase de valor (plantilla en la referencia).
   5. Modelo de valor y monetización: nivel según el tipo; si monetiza: freemium/suscripción/pago único/comisión/B2B/consultoría; pregunta qué valor genera y cómo capturarlo.
   6. Validación: la más barata primero (métodos: `references/validation-methods.md`).

## Output Contract

Discovery Report: `references/discovery-report-template.md`. Se genera cuando ya existe: usuario principal claro · necesidad entendible · alternativa identificada · propuesta de valor concreta · método realista de validación · contexto suficiente para decisiones técnicas con sentido.

Incluye insumos de `project-init`: usuario, problema validado, riesgos, enfoque sugerido (Paso 0).

## References

- `references/work-modes.md` — modos A/B y pipelines completos.
- `references/discovery-ligero.md` — ruta ligera: las 5 preguntas con ejemplos.
- `references/discovery-phases.md` — filosofía, regla de oro y fases 1-6 completas.
- `references/validation-methods.md` — tabla de métodos de validación.
- `references/discovery-report-template.md` — plantilla del reporte y transición a project-init.
