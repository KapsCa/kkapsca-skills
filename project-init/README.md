# Project Init — Skill de Transición

## Qué hace

Esta skill cierra la brecha entre `product-discovery` y `tech-feasibility`, transformando los hallazgos de discovery en un plan ejecutable para desarrollo técnico.

## Output Principal

- **Project Framing Doc** (nombre canónico)
- **Project Charter** (alias temporal, nota secundaria)

## Documentación Completa

Ver [SKILL.md](SKILL.md) para la especificación detallada de la fase, procesos, handoffs y casos de uso.

## Uso Rápido

### Pipeline completo (4 pasos)

```
brainstorm → product-discovery → project-init → tech-feasibility
```

### Ruta ligera (bypass de project-init, 3 pasos)

```
brainstorm → product-discovery → tech-feasibility
```

**Condiciones para bypass**:
- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con Discovery Report directo

## Archivos de Referencia

- [SKILL.md](SKILL.md) — Especificación completa de la skill
- [../docs/sdd-pmbok8-lite-alignment-spec.md](../docs/sdd-pmbok8-lite-alignment-spec.md) — Cambio completo (pmbok8-lite-alignment)

## Output Esperado

- **Project Framing Doc** (Project Charter como alias): Enfoque, fases, alcance inicial y gobernanza mínima
- **Próximos pasos**: Tech Spec listo para `tech-feasibility`

## Notas

- **Sin implementación técnica**: Esta skill solo produce documentación y acuerdos
- **Enfoque PMBOK 8 Lite**: Mínimo indispensable, nada de burocracia pesada
- **Compatible con side projects**: Diseñada para no añadir overhead innecesario
- **Project Charter**: Solo como alias temporal; el nombre canónico es Project Framing Doc
