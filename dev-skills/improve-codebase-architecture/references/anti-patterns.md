# Anti-patrones y enfoque proporcional — Improve Codebase Architecture

Detalle local de `SKILL.md` (## Execution Steps e ## Integración con el trabajo formal en `references/report-template.md`).

## Core Patterns

### 1. Enfoque proporcional
- No impongas Clean Architecture completa a un proyecto de 2 pantallas.
- Detecta si el tamaño del proyecto justifica capas separadas (`flutter-architecting-apps`) o si basta con separar responsabilidades básicas.

### 2. Detecta anti-patrones
- Lógica de negocio dentro de UI,
- IO (HTTP, DB) en widgets o controladores de estado,
- Estado global compartido innecesariamente,
- Dependencias circulares o acoplamiento fuerte entre módulos.
