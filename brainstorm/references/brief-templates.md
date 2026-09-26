# Plantillas del Product Brief — Brainstorm

Detalle local de `SKILL.md` (## Output Contract): las plantillas exactas del Product Brief v4.0 completo y parcial, y el mapa de transición a `product-discovery`.

## Product Brief Completo

Solo genera este bloque cuando ya pasaste todas las reglas de avance de las fases (micro-contratos en `phase-contracts.md`, gates en `SKILL.md`).

```markdown
# [Nombre Tentativo] — Product Brief
**Generado por:** brainstorm skill v4.0
**Fecha:** [fecha]
**Contexto org:** [personal / negocio / organización]
**Interesados:** [lista principal]

## 1. Problema
[descripción concreta del dolor]

## 2. Solución actual
[cómo se resuelve hoy]

## 3. Gap detectado
[qué sigue mal resuelto]

## 4. Usuario principal
- Perfil: [descripción]
- Frecuencia del problema: [alta/media/baja]
- Motivación: [qué gana]
- Fricción principal: [qué podría frenarlo]

## 5. Propuesta de valor
[frase clara]

## 6. MVP
### Must Have
- [feature 1]
- [feature 2]

### Should Have
- [feature 3]

### Could Have
- [feature 4]

### Fuera del MVP
- [feature 5]

## 7. Valor esperado
- Para el usuario: [qué gana]
- Para el negocio: [qué valor genera]
- Señal de éxito: [métrica o señal]

## 8. Diferenciadores
- [diferenciador 1]
- [diferenciador 2]

## 9. Interesados ampliados (PMBOK 8)
- Principal: [descripción]
- Patrocinador: [descripción - si aplica]
- Equipo: [descripción]
- Regulatorios: [descripción - si aplica]

## 10. Dudas abiertas
- [pregunta 1]
- [supuesto por validar 1]

## 11. Siguiente paso
- Pasar a product-discovery
```

## Product Brief Parcial (salida controlada)

Cuando el usuario no completa todas las fases, la skill entrega un **Product Brief Parcial** en lugar de forzar el cierre o dejar conversación suelta. Los criterios de cuándo corresponde cada salida están en el gate de `SKILL.md`.

> **Regla**: El Brief Parcial solo puede pasar a `product-discovery` si al menos las fases 1-4 (Idea, Problema, Usuario, Propuesta de valor) están completas. Si falta algo crítico, el siguiente paso siempre es terminar brainstorm.

```markdown
# [Nombre Tentativo] — Product Brief PARCIAL
**Generado por:** brainstorm skill v4.0
**Fecha:** [fecha]
**Contexto org:** [personal / negocio / organización]
**Interesados:** [lista principal si aplica]
**Fases completadas:** [lista de fases terminadas con su micro-contrato]
**Fase pendiente:** [qué falta para el Brief Completo]

## 1. Problema
[descripción concreta del dolor — si se completó Fase 2]

## 2. Solución actual
[cómo se resuelve hoy — si se completó Fase 2]

## 3. Gap detectado
[qué sigue mal resuelto — si se completó Fase 2]

## 4. Usuario principal
- Perfil: [descripción — si se completó Fase 3]
- Frecuencia del problema: [alta/media/baja]
- Motivación: [qué gana]
- Fricción principal: [qué podría frenarlo]

## 5. Propuesta de valor
[frase clara — si se completó Fase 4]

## 6. MVP
### Must Have
- [feature 1 — si se completó Fase 5]

### Should Have
- [feature 2 — si se completó Fase 5]

### Could Have
- [feature 3 — si se completó Fase 5]

### Fuera del MVP
- [feature 4 — si se completó Fase 5]

## 7. Valor esperado
- Para el usuario: [qué gana — si se completó Fase 4]
- Para el negocio: [qué valor genera — si aplica]
- Señal de éxito: [métrica o señal — si se completó Fase 4]

## 8. Diferenciadores
- [diferenciador 1 — si se completó Fase 6]

## 9. Interesados ampliados (PMBOK 8)
- Principal: [descripción — si se completó Fase 3]
- Patrocinador: [descripción - si aplica]
- Equipo: [descripción]
- Regulatorios: [descripción - si aplica]

## 10. Dudas abiertas
- [pregunta 1]
- [supuesto por validar 1]

## 11. Siguiente paso
- Volver a brainstorm para completar fase(s) faltante(s) **O** pasar a product-discovery con este Brief Parcial (solo si las fases críticas 1-4 están completas)
```

## Nota de transición a `product-discovery`

Este Product Brief está diseñado para ser el **input directo y compatible** con la skill `product-discovery`. Los campos clave que alimentan el siguiente paso son:

| Campo del Product Brief | Uso en `product-discovery` |
|---|---|
| 1. Problema + 2. Solución actual + 3. Gap | Valida el problema (Fase 1 y Discovery ligero punto 1) |
| 4. Usuario principal | Define el usuario a validar (Fase 3 y Discovery ligero punto 2) |
| 5. Propuesta de valor | Base para la propuesta de valor en discovery (Fase 4) |
| 6. MVP | Referencia para no sobre-dimensionar el discovery |
| 10. Dudas abiertas | Se convierten en hipótesis de riesgos para `project-init` |
| 11. Siguiente paso | Confirma el pipeline `brainstorm → product-discovery` |

> **Nota**: Si el Brief es Parcial, `product-discovery` usará las secciones disponibles y marcará las faltantes como "pendientes de validación en discovery".
