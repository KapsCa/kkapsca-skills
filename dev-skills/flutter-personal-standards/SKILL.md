---
name: flutter-personal-standards
description: "Trigger: dudas de estructura, estado, complejidad o arquitectura en Flutter/Dart, o decidir cuán simple o escalable debe ser. Criterio de simplicidad y arquitectura proporcional; enruta a skills oficiales."
license: MIT
metadata:
  author: KkapsCa
  version: "4.0"
---

# Flutter Personal Standards

> **Input:** trabajo en Flutter o Dart con dudas de estructura, estado o complejidad
> **Output:** decisión argumentada + routing a la skill oficial cuando corresponde

---

## Activation Contract

Carga cuando el usuario esté trabajando en **Flutter o Dart** y necesite criterio general: dudas sobre estructura, estado, complejidad o arquitectura; decidir qué tan simple o escalable debe ser una solución; o enrutar el problema hacia una skill oficial más específica.

NO la actives cuando: el problema ya es claramente específico y una skill oficial de Flutter lo cubre mejor · el proyecto ya tenga GetX como convención explícita · sea para backend, CLI o Dart sin Flutter.

## Hard Rules

1. **Primero simple, luego escalable**: no metas arquitectura pesada antes de necesitarla.
2. **Umbrales simples para la complejidad**: hasta 5 pantallas → estructura simple por feature; más de 5 o estado compartido entre varios flows → Riverpod; equipo con eventos/estados explícitos → Bloc/Cubit.
3. **Separá responsabilidades**: UI renderiza, estado coordina, servicios/repositorios hacen IO, modelos representan datos.
4. **State management por alcance real del estado**: local → `setState()`; compartido sencillo → Provider/ChangeNotifier; escalable → Riverpod o Bloc; **GetX solo si el proyecto lo exige de verdad**.
5. **Sin librerías por moda**: cada dependencia justifica su costo.
6. **Performance desde el diseño**: `const` donde se pueda, nada pesado dentro de `build()`, widgets grandes partidos en piezas pequeñas.

Los umbrales completos: `references/principios.md`.

## Decision Gates

| Situación | Recomendación |
|---|---|
| Pantalla simple con estado efímero | `StatefulWidget` + `setState()` |
| Estado compartido simple | Provider / ChangeNotifier |
| Más testabilidad y escalabilidad | Riverpod |
| Equipo con eventos/estados explícitos | Bloc/Cubit |
| El proyecto ya usa GetX | Aceptarlo como restricción, no como default |
| El caso es específico de un área | Cargar la skill oficial (`references/routing-skills-oficiales.md`) |

**Regla operativa**: si no podés ubicar el caso en una fila, no improvises framework — **preguntá antes de imponer uno**.

## Execution Steps

1. Confirmá que el problema es **general** de Flutter/Dart y no específico de un área.
2. Verificá si el proyecto ya trae una librería de estado impuesta.
3. Revisá si el caso cabe en `setState`, Provider, Riverpod o Bloc.
4. Evaluá si conviene cargar una **skill oficial** especializada.
5. Producí el output y, si corresponde, enrutá a la skill oficial.

Checklist previo: `references/pre-flight.md`. Anti-patrones a evitar: `references/anti-patrones.md`.

## Output Contract

Una decisión breve: tipo de proyecto, estructura propuesta, state management **con su justificación**, skills oficiales a cargar y anti-patrones relevantes. Plantilla exacta: `references/output-esperado.md`.

Criterio de salida: estructura proporcional · state management justificado · UI/estado/datos separados · sin sobrecomplejidad · delegado a la skill oficial cuando correspondía (`references/criterio-de-salida.md`).

## References

- `references/context-validation.md` — cuándo activarse y cuándo no.
- `references/principios.md` — los principios no negociables y sus umbrales.
- `references/reglas-decision.md` — la tabla de decisión rápida.
- `references/routing-skills-oficiales.md` — qué skill oficial cargar según la necesidad.
- `references/anti-patrones.md` — lo que hay que evitar.
- `references/pre-flight.md` — el checklist previo.
- `references/output-esperado.md` — la plantilla del output.
- `references/criterio-de-salida.md` — cuándo la skill está completa.
- `references/commands.md` — el comando de ejemplo.
