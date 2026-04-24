---
name: ananta-standards
description: >
  Estándares específicos de Ananta para Flutter con GetX: arquitectura por features,
  bindings obligatorios, uso disciplinado de controllers, routing con `GetPage` y separación
  clara entre UI, estado y lógica. Trigger: Usa esta skill cuando el trabajo sea sobre Ananta,
  una feature de Ananta, refactors en GetX, bindings, routing, controllers o estructura del proyecto.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
---

# Ananta Standards

## When to Use

Usa esta skill cuando:

- el usuario mencione **Ananta**,
- se vaya a crear o refactorizar una feature dentro de Ananta,
- toque trabajar con GetX, `Bindings`, `GetPage`, `Controller` o módulos,
- se necesite alinear implementación con las convenciones del proyecto.

## When NOT to Use

- proyectos Flutter genéricos sin relación con Ananta,
- discusiones generales sobre Flutter sin necesidad de asumir GetX,
- bootstrap transversal de repos (para eso existe `repo-bootstrap`).

---

## Propósito

En Ananta, GetX NO es una opción entre varias.
Es parte del contexto del proyecto.

Esta skill existe para que el agente no improvise arquitectura y no convierta GetX en espagueti.

---

## Reglas No Negociables

1. **No abuses de `Get.find()`**
   - úsalo desde lugares controlados,
   - no lo disperses por widgets ni lógica arbitraria.

2. **Toda dependencia importante entra por `Bindings`**
   - controllers,
   - use cases,
   - repositories,
   - servicios necesarios para la feature.

3. **La UI NO resuelve negocio**
   - la vista observa estado y dispara eventos,
   - el controller coordina,
   - el caso de uso decide,
   - el repositorio accede a datos.

4. **Usa `Rx` solo cuando sí aporta**
   - no conviertas todo en reactivo por costumbre,
   - si una variable no necesita reactividad, mantenla simple.

5. **Navegación solo con rutas nombradas y `GetPage`**
   - nada de navegación improvisada,
   - cada ruta importante debe tener su binding claro.

6. **La feature manda la organización**
   - el código debe vivir por módulo/feature,
   - no por carpetas globales caóticas sin contexto.

---

## Estructura Recomendada por Feature

```text
lib/
└── features/
    └── profile/
        ├── bindings/
        │   └── profile_binding.dart
        ├── controllers/
        │   └── profile_controller.dart
        ├── domain/
        │   ├── entities/
        │   └── usecases/
        ├── data/
        │   ├── models/
        │   ├── datasources/
        │   └── repositories/
        └── presentation/
            ├── pages/
            └── widgets/
```

Adáptala si el proyecto ya tiene una variante equivalente, pero no regreses a estructura caótica.

---

## Contrato por Capa

| Capa | Responsabilidad |
|---|---|
| `presentation/view` | renderizar UI y delegar eventos |
| `controller` | exponer estado y coordinar flujo |
| `usecase` | reglas de negocio |
| `repository` | abstracción de acceso a datos |
| `datasource/service` | IO real, red, storage, etc. |

---

## Anti-Patrones Prohibidos

- `Get.find()` por todo el código,
- lógica de negocio metida en widgets,
- controllers gigantes con responsabilidades mezcladas,
- navegación sin `Bindings`,
- usar `Rx` para todo sin criterio,
- hacer llamadas remotas directo desde la UI.

---

## Binding Mínimo Esperado

```dart
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(Get.find()));
    Get.lazyPut<LoadProfileUseCase>(() => LoadProfileUseCase(Get.find()));
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()));
  }
}
```

---

## Cómo Decidir con esta Skill

Cuando el agente trabaje en Ananta, debe preguntarse:

1. ¿La feature ya tiene módulo/feature claro?
2. ¿Las dependencias están entrando por binding?
3. ¿El controller solo coordina o está haciendo de todo?
4. ¿La vista está limpia?
5. ¿El uso de GetX está justificado en cada parte?

---

## Relación con otras Skills

- Usa `repo-bootstrap` solo para el arranque del repo, no para lógica de app.
- Si el problema es Flutter muy específico (forms, testing, theming, HTTP), puedes apoyarte en las skills oficiales correspondientes.
- Si hace falta criterio más genérico de Flutter fuera del contexto de Ananta, usa `flutter-personal-standards`.

---

## Commands

```bash
# Estructura base de una feature en Ananta
mkdir -p lib/features/{feature}/{bindings,controllers,domain,data,presentation}
```

## Resources

- **GetX genérico**: `mobile-getx-architect` como base general
- **Flutter general**: `flutter-personal-standards`
