---
name: flutter
description: >
  Flutter y Dart para proyectos personales con prácticas alineadas a la documentación oficial:
  arquitectura mantenible, state management según el alcance del estado, performance en widgets,
  manejo asíncrono claro, testing y código simple antes de sobre-arquitectura.

  Usa esta skill cuando el usuario trabaje en Flutter, Dart, widgets, pantallas, navegación,
  consumo de APIs, modelos, testing, performance o arquitectura móvil. Para proyectos nuevos,
  prioriza simplicidad, separación de responsabilidades y decisiones justificadas; no impongas
  GetX ni ningún framework si no aporta valor real.

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "3.0"
---

# Flutter — Personal Development Skill

## Propósito

Esta skill sirve para proyectos personales y de aprendizaje.
La meta no es casarse con una librería, sino aprender Flutter BIEN:

- entender el ciclo de vida de widgets,
- elegir state management por necesidad real,
- mantener código fácil de leer y probar,
- evitar complejidad prematura.

---

## When to Use

Usa esta skill cuando:

- el proyecto use Flutter o Dart,
- se vaya a crear una feature móvil,
- haya que decidir estructura, state management o navegación,
- se necesite mejorar performance de UI,
- se trabajen widgets, formularios, listas, APIs, testing o arquitectura.

## When NOT to Use

- Backend/server-side Dart
- Scripts CLI sin Flutter
- Proyectos web que no usan Flutter

---

## Principios No Negociables

1. **Primero simple, luego escalable**
   - No metas Clean Architecture completa si el proyecto es pequeño.
   - Empieza con la estructura mínima que resuelva el problema.

2. **Separa responsabilidades**
   - UI renderiza.
   - Estado coordina.
   - Servicios/repositorios obtienen datos.
   - Modelos representan información.

3. **Elige state management por alcance del estado**
   - Estado local → `StatefulWidget` + `setState()`.
   - Estado compartido sencillo → `ChangeNotifier` + `Provider`.
   - Estado compartido escalable o más predecible → `Riverpod` o `Bloc`.
   - `GetX` solo si el proyecto YA lo usa o hay una razón técnica clara. No es default.

4. **Performance desde el diseño**
   - Usa `const` donde puedas.
   - Evita trabajo costoso dentro de `build()`.
   - Divide widgets grandes en widgets pequeños.

5. **No elijas librerías por moda**
   - Cada dependencia debe resolver un problema real.

---

## Estructura Recomendada

### Proyectos pequeños o MVP

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── features/
│   └── counter/
│       ├── presentation/
│       │   ├── counter_page.dart
│       │   └── widgets/
│       ├── state/
│       │   └── counter_notifier.dart
│       └── data/
│           └── counter_repository.dart
└── shared/
    ├── widgets/
    ├── utils/
    └── services/
```

### Proyectos medianos o grandes

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── errors/
│   ├── network/
│   ├── constants/
│   └── utils/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── widgets/
│           └── state/
└── shared/
    ├── widgets/
    └── services/
```

### Regla de arquitectura

- Si el proyecto es pequeño: **feature-first simple**.
- Si el proyecto crece: evoluciona a capas (`data/domain/presentation`) sin rehacer todo.
- No mezcles llamadas HTTP directas dentro de widgets.
- No pongas lógica de negocio pesada dentro de `build()`.

---

## State Management: Qué usar y cuándo

### 1. Estado local

Usa `StatefulWidget` y `setState()` cuando el estado:

- vive solo en un widget o pantalla,
- no se comparte,
- es efímero (toggle, loading local, índice actual, tabs, animación simple).

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_counter')),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
      ),
    );
  }
}
```

### 2. Estado levantado al padre

Úsalo cuando varios widgets hermanos comparten un valor.

- El padre posee el estado.
- Los hijos reciben datos y callbacks.

### 3. Estado global o compartido

#### Opción por defecto para aprender y proyectos personales: `Provider + ChangeNotifier`

Úsalo cuando:

- necesitas algo simple y entendible,
- quieres aprender flujo de datos sin demasiada magia,
- el estado se comparte entre pantallas o widgets.

```dart
class CartNotifier extends ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);

  void add(Item item) {
    _items.add(item);
    notifyListeners();
  }
}
```

#### `Riverpod`

Úsalo cuando:

- quieres más control, testabilidad y escalabilidad,
- no quieres depender de `BuildContext` para leer estado,
- el proyecto ya tiene varias features.

#### `Bloc/Cubit`

Úsalo cuando:

- el equipo prefiere flujos explícitos por eventos/estados,
- hay lógica compleja y quieres alta predictibilidad.

#### `GetX`

No es el default para esta skill.
Solo se permite si:

- el proyecto legacy ya lo usa,
- necesitas mantener compatibilidad,
- puedes justificar por qué aporta más de lo que complica.

---

## Manejo Asíncrono y Datos

### Reglas

- Usa repositorios o servicios para IO.
- No hagas llamadas HTTP dentro del widget.
- Siempre modela estados de `loading`, `success` y `error`.
- Si el dato viene una sola vez desde UI simple, `FutureBuilder` puede ser suficiente.
- Si el flujo crece, mueve la carga a un notifier/viewmodel/controller.

### Ejemplo simple con `FutureBuilder`

```dart
FutureBuilder<User>(
  future: repository.fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    if (!snapshot.hasData) {
      return const Text('Sin datos');
    }

    return Text(snapshot.data!.name);
  },
)
```

---

## Modelos y Serialización

### Usa `freezed` + `json_serializable` cuando:

- consumes APIs reales,
- necesitas modelos inmutables,
- quieres copyWith, equality y parsing robusto.

### Evítalo cuando:

- estás haciendo prototipos diminutos,
- un modelo manual de 3 campos resuelve el problema.

### Regla

- Las entidades de dominio NO deben conocer JSON.
- El parsing vive en data/model.

---

## Performance Best Practices

Estas sí están alineadas con la documentación oficial de Flutter:

1. **Usa `const` constructors** siempre que sea posible.
2. **Evita trabajo pesado en `build()`**.
3. **Prefiere widgets a funciones helper** para reutilizar UI.
4. **Usa `ListView.builder`** para listas largas.
5. **Usa `RepaintBoundary`** en widgets que repintan frecuentemente.
6. **Parte widgets grandes** según cómo cambian sus dependencias.

```dart
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    );
  }
}
```

```dart
const Text('Hola Flutter');
```

```dart
const RepaintBoundary(
  child: CircularProgressIndicator(),
)
```

---

## Navegación

Para proyectos personales:

- Proyecto simple → `Navigator` / `Navigator 2` abstraído mínimamente.
- Proyecto mediano/grande → `go_router` como opción preferida por claridad.

Evita mezclar navegación, estado y DI en una sola herramienta si no hace falta.

---

## Testing

Todo proyecto Flutter serio debería tener al menos:

1. **Unit tests** para lógica pura.
2. **Widget tests** para componentes importantes.
3. **Integration tests** para flujos críticos si el proyecto ya maduró.

### Qué sí testear primero

- validaciones,
- notifiers/viewmodels/controllers,
- mappers de modelos,
- widgets con comportamiento.

### Qué no hacer

- testear getters triviales solo por inflar cobertura,
- meter lógica no testeable en widgets gigantes.

---

## Dependencias Base Recomendadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  go_router: ^14.2.0
  http: ^1.2.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

### Dependencias opcionales

- `flutter_riverpod` → si necesitas más escalabilidad en estado.
- `bloc` / `flutter_bloc` → si quieres arquitectura basada en eventos.
- `dio` → si el proyecto requiere interceptores, cancelación o clientes más complejos.

---

## Checklist Antes de Crear una Feature

- [ ] ¿La estructura es proporcional al tamaño del proyecto?
- [ ] ¿El estado local se quedó local?
- [ ] ¿El estado compartido está en una solución apropiada?
- [ ] ¿La UI no hace llamadas HTTP directas?
- [ ] ¿Los widgets grandes se partieron en piezas pequeñas?
- [ ] ¿Se usó `const` donde aplica?
- [ ] ¿Las listas largas usan `ListView.builder`?
- [ ] ¿Existe manejo de loading/error/empty state?
- [ ] ¿La nueva dependencia está realmente justificada?
- [ ] ¿La lógica importante tiene tests?

---

## Decisiones por Defecto de Esta Skill

Si el usuario no especifica otra cosa:

- arquitectura inicial → **feature-first simple**,
- estado local → **StatefulWidget/setState**,
- estado compartido → **Provider + ChangeNotifier**,
- navegación → **go_router** para proyectos medianos,
- modelos complejos → **freezed + json_serializable**,
- performance → **const + widgets pequeños + lazy lists**.

La idea es aprender fundamentos primero. Luego ya te pones mamalón con arquitecturas más pesadas.

---

## Recursos Oficiales

- Flutter App Architecture: https://docs.flutter.dev/app-architecture
- State Management: https://docs.flutter.dev/data-and-backend/state-mgmt/intro
- UI Interactivity: https://docs.flutter.dev/ui/interactivity
- Performance Best Practices: https://docs.flutter.dev/perf/best-practices
