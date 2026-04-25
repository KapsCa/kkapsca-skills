---
name: flutter-personal-standards
description: >
  Criterio personal para proyectos Flutter: simplicidad primero, arquitectura proporcional,
  state management según el alcance real del estado y uso de las skills oficiales de Flutter
  cuando el problema es específico. No la uses para imponer GetX como default.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "4.0"
---

# Flutter Personal Standards

## When to Use

Usa esta skill cuando:

- el usuario esté trabajando en Flutter o Dart y necesite criterio general,
- haya dudas sobre estructura, estado, complejidad o arquitectura,
- toque decidir qué tan simple o qué tan escalable debe ser una solución,
- haga falta enrutar el problema hacia una skill oficial más específica.

## Trigger

Usa esta skill cuando el usuario trabaje con Flutter/Dart y necesite guía general de arquitectura,
estructura, decisiones técnicas o dirección sobre qué skill oficial conviene cargar.

## When NOT to Use

- cuando el problema ya es claramente específico y una skill oficial de Flutter cubre mejor el caso,
- cuando el proyecto sea Ananta o cualquier otro proyecto donde GetX ya sea convención explícita,
- para backend, CLI o Dart sin Flutter.

---

## Principios No Negociables

1. **Primero simple, luego escalable**
   - No metas arquitectura pesada antes de necesitarla.
   - Empieza con la estructura mínima correcta.

2. **Usa umbrales simples para decidir complejidad**
   - hasta 5 pantallas → estructura simple por feature
   - más de 5 pantallas o estado compartido entre múltiples flows → Riverpod recomendado
   - si el equipo ya usa eventos/estados explícitos como estándar → Bloc/Cubit

3. **Separa responsabilidades**
   - UI renderiza.
   - Estado coordina.
   - Servicios/repositorios hacen IO.
   - Modelos/entidades representan datos.

4. **State management por alcance real del estado**
   - local → `setState()`
   - compartido sencillo → Provider / ChangeNotifier
   - escalable y más robusto → Riverpod o Bloc
   - GetX solo si el proyecto lo exige de verdad

5. **No elijas librerías por moda**
   - cada dependencia debe justificar su costo.

6. **Performance desde el diseño**
   - `const` donde se pueda,
   - nada pesado dentro de `build()`,
   - widgets grandes se parten en piezas pequeñas.

---

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

---

## Routing hacia Skills Oficiales

Cuando el problema ya es específico, carga la skill oficial adecuada:

| Necesidad | Skill oficial |
|---|---|
| arquitectura general por capas | `flutter-architecting-apps` |
| estado y flujo de datos | `flutter-managing-state` |
| navegación y routing | `flutter-implementing-navigation-and-routing` |
| formularios | `flutter-building-forms` |
| layout y composición UI | `flutter-building-layouts` |
| HTTP + JSON | `flutter-handling-http-and-json` |
| testing | `flutter-testing-apps` |
| theming | `flutter-theming-apps` |
| bases de datos locales | `flutter-working-with-databases` |
| accesibilidad | `flutter-improving-accessibility` |

No reexplique aquí lo que ya resuelven mejor las skills oficiales.

---

## Anti-Patrones

- meter Clean Architecture completa en una app que apenas tiene dos pantallas,
- mezclar llamadas HTTP dentro de widgets,
- usar una librería de estado solo porque está de moda,
- hacer un widget monstruo con lógica, IO y navegación mezclados,
- meter GetX como respuesta automática a todo.

## PRE-FLIGHT CHECKLIST

- [ ] Ya identifiqué si el problema es general o específico
- [ ] Ya confirmé si el proyecto ya trae una librería de estado impuesta
- [ ] Ya confirmé si el caso cabe en `setState`, Provider, Riverpod o Bloc
- [ ] Ya confirmé si en realidad conviene cargar una skill oficial especializada

Si la respuesta a la última casilla es sí, enruta a la skill oficial y no reinventes la guía aquí.

---

## Criterio de salida

Esta skill está completa cuando el agente ya:

- propuso una estructura proporcional al proyecto,
- justificó la elección de state management,
- separó UI/estado/datos,
- evitó sobrecomplejidad,
- y, cuando aplicaba, delegó a la skill oficial correcta.

---

## Output esperado

```markdown
# Decisión Flutter — [Proyecto]

## Tipo de proyecto
[simple / intermedio / escalable]

## Estructura propuesta
[feature-first simple / capas separadas / otra]

## State management
[setState / Provider / Riverpod / Bloc] — Justificación: [razón]

## Skills oficiales a cargar
- [skill-name] para [problema específico]

## Anti-patrones a evitar
- [anti-patrón relevante]
```

---

## Resultado Esperado

Si esta skill se usa bien, el agente debe:

- proponer una estructura proporcional al proyecto,
- justificar la elección de estado,
- separar UI/estado/datos,
- evitar sobrecomplejidad,
- y, cuando aplique, delegar a la skill oficial correcta.

---

## Commands

```bash
# Ejemplo simple para recordar el enfoque feature-first
mkdir -p lib/features/my_feature/{presentation,state,data}
```

## Resources

- **Referencia**: usa las skills oficiales de Flutter para problemas especializados
- **Bootstrap**: usa `repo-bootstrap` cuando el repo aún no tiene estándares operativos
