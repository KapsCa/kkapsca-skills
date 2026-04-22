---
name: flutter
description: >
  Flutter & Dart development with GetX state management, Feature-First Screaming Architecture,
  and code generation (freezed, json_serializable, build_runner).

  ALWAYS use this skill when the user is working on ANY Flutter or Dart task: creating features,
  widgets, models, routing, services, controllers, bindings, or any .dart file. Trigger immediately
  when the user mentions Flutter, Dart, GetX, mobile app, widget, screen, route, freezed, or
  any mobile development context — even if they don't say "Flutter" explicitly. Never write
  Flutter code without consulting this skill first.

license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "2.0"
---

# Flutter — GetX + Screaming Architecture

## When NOT to Use

- Backend/server-side Dart (use a Dart-specific skill instead)
- Pure Dart CLI tools with no Flutter dependency
- Web-only projects using a non-Flutter stack

## ⚠️ La Neta Técnica: El Elefante en la Habitación (GetX)

GetX es un "God Object" gigantesco. Te resuelve estado, inyección de dependencias (Bindings) y ruteo en un solo paquete. Es un atajo enorme que tiende a acoplar tu capa de presentación de una manera brutal. Si no tienes disciplina militar, tus `GetxController` se van a volver monolitos que rompen toda la arquitectura limpia que con tanto esfuerzo construiste en tus capas de Domain y Data.

**La Regla Técnica INQUEBRANTABLE:** 
Tus `GetxController` SOLAMENTE pueden comunicarse con tus Casos de Uso. Por ningún motivo pueden conocer la existencia de un Repositorio o un Modelo de Data, o tu Screaming Architecture se va a la basura. 

Si por requerimientos del proyecto mantenemos GetX, úsalo como un simple puente, no como la base de tu lógica de negocio.

---

## Architecture: Feature-First (Screaming Architecture)

The folder structure SCREAMS what the app does, not how it's built.
Each feature is a self-contained vertical slice.

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp + routing bootstrap
│   ├── routes/
│   │   ├── app_pages.dart        # GetPages list
│   │   └── app_routes.dart       # Route name constants
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── di/
│   │   └── injection.dart        # Global GetX bindings / Get.put
│   ├── network/
│   │   └── dio_client.dart
│   ├── error/
│   │   ├── failures.dart         # Freezed sealed classes
│   │   └── exceptions.dart
│   └── utils/
│       └── extensions.dart
└── features/
    └── [feature_name]/           ← screams what the feature does
        ├── data/
        │   ├── datasources/
        │   │   └── [feature]_remote_datasource.dart
        │   ├── models/
        │   │   └── [feature]_model.dart      # freezed + json_serializable
        │   └── repositories/
        │       └── [feature]_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── [feature]_entity.dart     # freezed, pure Dart
        │   ├── repositories/
        │   │   └── [feature]_repository.dart # abstract interface
        │   └── usecases/
        │       └── get_[feature].dart
        └── presentation/
            ├── bindings/
            │   └── [feature]_binding.dart    # GetX dependency injection
            ├── controllers/
            │   └── [feature]_controller.dart # GetxController
            ├── pages/
            │   └── [feature]_page.dart
            └── widgets/
                └── [feature]_card.dart
```

**Regla crítica**: nunca importes de `presentation/` dentro de `domain/` ni `data/`.
Las dependencias solo fluyen hacia adentro: `presentation → domain ← data`.

---

## State Management: GetX

### Controller
```dart
class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  AuthController(this._loginUseCase);

  // Observables — usa .obs, nunca ValueNotifier ni setState
  final _user = Rxn<UserEntity>();
  final _status = Rx<AuthStatus>(AuthStatus.initial);

  // Expón solo getters, nunca el Rx directamente
  UserEntity? get user => _user.value;
  AuthStatus get status => _status.value;
  bool get isLoading => _status.value == AuthStatus.loading;

  Future<void> login(String email, String password) async {
    _status.value = AuthStatus.loading;

    final result = await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        _status.value = AuthStatus.error;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        _user.value = user;
        _status.value = AuthStatus.success;
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }

  @override
  void onClose() {
    // Limpia recursos si los hay
    super.onClose();
  }
}
```

### Binding (inyección de dependencias por feature)
```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Registra siempre la interfaz, no la implementación
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Get.find()),
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find()),
    );
    // Casos de uso
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    // Controlador
    Get.lazyPut(() => AuthController(Get.find<LoginUseCase>()));
  }
}
```

### Page (Obx en el árbol, no GetBuilder salvo casos específicos)
```dart
class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) return const Center(child: CircularProgressIndicator());
        return LoginForm(onSubmit: controller.login);
      }),
    );
  }
}
```

**Cuándo usar cada primitiva:**
- `Obx` → reactivo, rebuild automático. Úsalo por defecto.
- `GetBuilder` → performance crítica, rebuild manual con `update()`.
- `GetX<Controller>` → cuando necesitas acceso al controller Y reactividad en el mismo widget.
- `ever`, `once`, `interval` → side effects reactivos en el controller, no en widgets.

---

## Routing con GetX
```dart
// app_routes.dart
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile/:id'; // parámetros con :nombre
}

// app_pages.dart
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()], // guards de ruta
    ),
  ];
}
```

---

## Code Generation: freezed + json_serializable

### Modelo (Data Layer)
```dart
// features/product/data/models/product_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    @Default(0) int stock,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  // Mapper a entidad de dominio — NUNCA al revés
  const ProductModel._();
  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    price: price,
    stock: stock,
  );
}
```

### Entidad (Domain Layer — sin json, sin framework)
```dart
// features/product/domain/entities/product_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';

@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String name,
    required double price,
    required int stock,
  }) = _ProductEntity;
}
```

### Failures sellados (Either pattern)
```dart
// core/error/failures.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.server({required String message, required int code}) = ServerFailure;
  const factory Failure.cache({required String message}) = CacheFailure;
  const factory Failure.unauthorized() = UnauthorizedFailure;
}
```

### Comandos de generación
```bash
# Generar una sola vez
dart run build_runner build --delete-conflicting-outputs

# Modo watch durante desarrollo
dart run build_runner watch --delete-conflicting-outputs
```

**Regla**: Nunca edites archivos `.freezed.dart` o `.g.dart` manualmente.
Siempre re-genera después de cambiar un modelo.

---

## Use Cases (Domain Layer)
```dart
// Patrón callable — cada use case hace UNA sola cosa
class GetProductsUseCase {
  final ProductRepository _repository;
  GetProductsUseCase(this._repository);

  // Either<Failure, T> — nunca lances exceptions desde domain
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) =>
      _repository.getProducts();
}
```

---

## Repository (contrato en domain, implementación en data)
```dart
// domain/repositories/product_repository.dart
abstract interface class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(String id);
}

// data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  const ProductRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final models = await _remote.fetchProducts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on NetworkException {
      return Left(const Failure.network(message: 'Sin conexión'));
    }
  }
}
```

---

## Performance: Reglas No Negociables

```dart
// ✅ const donde sea posible
const MyWidget({super.key});

// ✅ RepaintBoundary para animaciones costosas
RepaintBoundary(child: ComplexAnimation())

// ✅ Divide widgets grandes — un widget = una responsabilidad
// ✅ Usa ListView.builder, nunca Column con map() para listas largas
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, i) => ProductCard(product: items[i]),
)

// ❌ NUNCA — context.watch / setState en features con GetX
// ❌ NUNCA — BuildContext across async gaps sin montar verificación
if (!context.mounted) return;
await someAsyncOperation();
```

---

## pubspec.yaml — Dependencias Base

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dartz: ^0.10.1               # Either<L, R>
  dio: ^5.4.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  get_it: ^8.0.0               # opcional si usas Get.find() como DI global

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

---

## Checklist de Feature Nueva

Antes de hacer el PR, verifica:
- [ ] Binding registra dependencias usando interfaces, no implementaciones.
- [ ] Controller no importa nada de `data/` directamente (solo `domain/usecases`).
- [ ] Modelos tienen `toEntity()`, entidades NO tienen `fromJson()`.
- [ ] Todos los archivos generados están actualizados (`build_runner build`).
- [ ] No hay `setState` ni `StatefulWidget` donde GetX puede resolver.
- [ ] Use cases retornan `Either<Failure, T>`, nunca lanzan exceptions.
- [ ] GetPage tiene su Binding asociado.
- [ ] Widgets > 60 líneas fueron extraídos a componentes independientes.
- [ ] Uso extensivo de `const` en constructores y árboles de widgets.

---

## Referencias

Para profundizar, lee los archivos en `references/`:
- `references/getx-patterns.md` — Patrones avanzados: workers, services, middleware
- `references/testing.md` — Testing de controllers, use cases y widgets con GetX
- `references/code-generation.md` — Configuración avanzada de build_runner y freezed
