# Reglas de Decisión Rápida — Flutter Personal Standards

Detalle local de `SKILL.md` (## Decision Gates).

## Reglas de Decisión Rápida

| Situación | Recomendación |
|---|---|
| Pantalla simple con estado efímero | `StatefulWidget` + `setState()` |
| Estado compartido simple | Provider / ChangeNotifier |
| Más testabilidad y escalabilidad | Riverpod |
| Equipo ama eventos/estados explícitos | Bloc/Cubit |
| Proyecto ya usa GetX | aceptarlo como restricción, no como default |

### Regla operativa

Si no puedes ubicar el caso del usuario en una fila de la tabla anterior, no improvises framework: pregunta antes de imponer uno.
