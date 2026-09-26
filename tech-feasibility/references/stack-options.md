# Opciones de stack — Tech Feasibility
Detalle local de SKILL.md (Fase 3).
## Fase 3 — Opciones, no recetas

Presenta alternativas con contexto y tradeoffs.

### Frontend

| Opción | Cuándo considerar | Ventaja principal | Tradeoff principal |
|---|---|---|---|
| **Flutter** | Quieres una codebase fuerte para varias plataformas y buena consistencia UI | Productividad alta, tipado fuerte, UI controlada | Requiere aprender Dart/ecosistema Flutter |
| **React Native** | El equipo domina React/JS y prioriza reaprovechar ese conocimiento | Menor fricción para equipos web | Integración nativa y performance dependen más del caso |
| **Nativo** | El producto depende fuerte de plataforma, rendimiento extremo o integraciones profundas | Máximo control | Más costo de desarrollo y mantenimiento |
| **Web (SPA/SSR)** | El producto vive en el navegador o se accede desde escritorio sin instalar nada | Distribución inmediata, sin builds por plataforma | Menos acceso a funciones nativas y offline |
| **Desktop** | Se necesita app de escritorio (acceso a archivos, hardware o ejecución local) | Integración profunda con el sistema | Mantenimiento de builds por OS (Electron/Tauri/Flutter desktop) |

### Backend

| Opción | Cuándo considerar | Ventaja principal | Tradeoff principal |
|---|---|---|---|
| **Firebase** | MVP rápido, poco equipo, auth/real-time listos | Velocidad de salida | Vendor lock-in y costos variables |
| **Supabase** | Quieres velocidad con SQL real y más control | PostgreSQL, simple para MVP y productos chicos-medianos | Menos ecosistema cerrado que Firebase |
| **Node/Nest** | Requieres backend custom o lógica más seria | Flexibilidad y control | Más código y operación |
| **Otro backend propio** | Hay requisitos específicos fuertes o experiencia previa sólida | Diseño a medida | Más complejidad inicial |

### Base de datos

| Opción | Cuándo considerar |
|---|---|
| **PostgreSQL** | Default fuerte para la mayoría de productos con datos estructurados |
| **SQLite** | Estado/datos locales o modo offline en cliente |
| **MongoDB** | Documentos y estructura cambiante, si el caso realmente lo pide |
| **Redis** | Caché, colas o sesiones; no reemplaza tu base principal en la mayoría de casos |

---

