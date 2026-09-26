# Principios no negociables — Flutter Personal Standards

Detalle local de `SKILL.md` (## Hard Rules).

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
