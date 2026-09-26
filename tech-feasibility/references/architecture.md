# Arquitectura mínima — Tech Feasibility
Detalle local de SKILL.md (Fase 6).
## Fase 6 — Arquitectura mínima adecuada

La arquitectura propuesta debe ser proporcional al tipo de proyecto.

### Para aprendizaje o MVP pequeño

- estructura simple por features,
- separación básica entre UI, estado y acceso a datos,
- pocas dependencias,
- despliegue sencillo.

### Para producto serio o crecimiento probable

- separación más clara de capas,
- estrategia de testing desde temprano,
- observabilidad básica,
- manejo explícito de errores,
- decisiones documentadas.

### Principios

- **YAGNI** → no diseñes para una escala imaginaria.
- **Separación de responsabilidades** → evita mezclar todo en un solo archivo/capa.
- **Evolución progresiva** → la arquitectura debe poder crecer sin rehacer todo.

---

