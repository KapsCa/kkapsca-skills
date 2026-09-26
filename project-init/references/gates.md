# Puertas de decisión — project-init

Detalle local de SKILL.md (## Decision Gates). Incluye la matriz de Fase 1, las condiciones de bypass y el pre-flight completo.

## Pre-flight Checklist

- [ ] Existe un Discovery Report con enfoque sugerido
- [ ] El problema y usuario ya están validados
- [ ] Ya hay una señal clara del tipo de proyecto

Si no hay suficiente claridad, volver a `product-discovery`.

---

## Fase 1 — Selección de Enfoque de Desarrollo

**Objetivo**: Decidir cómo se construirá el proyecto.

**Pregunta clave**:
> ¿Los requisitos son claros y estables, o van a evolucionar con feedback?

**Marco de decisión**:

| Señal | Enfoque recomendado | Justificación |
|-------|---------------------|---------------|
| Requisitos claros, entregable definido, cambio costoso | **Predictivo** | El alcance es fijo y los riesgos de cambio son altos |
| Requisitos evolucionan, feedback continuo es clave | **Adaptativo (Ágil)** | El valor se entrega iterativamente, los cambios son baratos |
| Mix de estable y evolutivo | **Híbrido** | Componentes regulatorios (predictivo) + desarrollo iterativo |

**Output**:
- `enfoque`: Predictivo / Adaptativo / Híbrido
- `justificación`: Razón técnica y de negocio

**Restricción**: No se puede continuar sin esta decisión.

---

## Bypass — Cuándo Saltar project-init

**Condiciones para usar bypass** (`brainstorm → product-discovery → tech-feasibility`):

- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con el Discovery Report directo

- En este caso, se puede usar el bypass: `brainstorm → product-discovery → tech-feasibility`

**En bypass**: `tech-feasibility` recibe el Discovery Report como input principal.
