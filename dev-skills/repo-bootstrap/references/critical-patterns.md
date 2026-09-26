# Patrones críticos — Repo Bootstrap

Detalle local de `SKILL.md` (## Hard Rules).

## Critical Patterns

### `release-please` siempre explícito

No basta con meter el workflow.
El agente debe dejar su uso explícito también en:

- la documentación del repo,
- la plantilla de PR,
- la explicación del flujo.

### Tests/checks antes de auto-merge

No basta con lint superficial.
Antes de activar auto-merge, el repo debe tener al menos un check que valide comportamiento o integridad real del stack.

### Auto-review opcional, checks obligatorios

El review automático de Copilot es deseable, pero puede depender de plan.
Los checks funcionales y PR validation sí son obligatorios como estándar.

### GO / NO-GO para auto-merge

Auto-merge solo puede recomendarse si TODO esto es verdadero:

- [ ] Existe PR validation
- [ ] Existe al menos un check funcional del stack
- [ ] La rama protegida requiere status checks
- [ ] El flujo del repo ya usa PR obligatorios

Si alguna casilla falla, NO recomiendes auto-merge todavía.

### No tocar git global

No modificar configuración global de Git para imponer esta convención.
La convención debe vivir en:

- el repo,
- scripts del repo,
- hooks locales por clon.

### No asumir enforcement en privados Free

Si el repo es privado personal Free:

- NO prometer que GitHub bloqueará pushes realmente,
- SÍ dejar hook local,
- SÍ explicar la limitación,
- SÍ configurar la regla en UI si el usuario lo desea, pero aclarando que puede salir como "Not enforced".

---

