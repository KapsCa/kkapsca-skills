---
name: flutter-personal-standards
description: >
  Criterio personal para proyectos Flutter: simplicidad primero, arquitectura proporcional,
  state management según el alcance real del estado y uso de las skills oficiales de Flutter
  cuando el problema es específico. Trigger: Usa esta skill cuando el usuario trabaje con
  Flutter/Dart y necesite guía general de arquitectura, estructura, decisiones técnicas o
  dirección sobre qué skill oficial conviene cargar. No la uses para imponer GetX como default.

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

## When NOT to Use

- cuando el problema ya es claramente específico y una skill oficial de Flutter cubre mejor el caso,
- cuando el proyecto sea Ananta o cualquier otro proyecto donde GetX ya sea convención explícita,
- para backend, CLI o Dart sin Flutter.

---

## Propósito

Esta skill NO reemplaza las skills oficiales de Flutter.
Sirve como una capa de criterio personal para decidir bien:

- cuánto diseño necesita el proyecto,
- qué state management tiene sentido,
- cuándo mantener simple,
- cuándo usar una skill oficial especializada.

La idea es evitar dos errores clásicos:

1. sobre-arquitectura por ansiedad,
2. soluciones improvisadas sin separación de responsabilidades.

---

## Principios No Negociables

1. **Primero simple, luego escalable**
   - No metas arquitectura pesada antes de necesitarla.
   - Empieza con la estructura mínima correcta.

2. **La arquitectura debe ser proporcional al proyecto**
   - MVP o proyecto pequeño → feature-first simple.
   - Proyecto que ya creció → capas más claras y módulos mejor separados.

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
