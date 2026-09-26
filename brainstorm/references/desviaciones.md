# Desvíos y reconducción — Brainstorm

Detalle local de `SKILL.md` (## Hard Rules, desvíos): cómo detectar que el usuario se salió del flujo y con qué frase regresarlo a la fase correcta.

## Detector de desvío

La skill debe detectar cuándo el usuario se sale del flujo. Señales de desvío:

1. **Stack/Tech jumping**: el usuario pregunta "¿usamos React o Vue?", "¿qué base de datos?", "¿microservicios o monolito?".
2. **Feature creep**: el usuario empieza a listar 15 funcionalidades antes de definir el problema.
3. **Monetización prematura**: hablar de precios, suscripciones o modelos de negocio antes de validar el problema.
4. **Competencia distracción**: comparar con gigantes (Netflix, Uber) antes de definir su propio usuario.

## Frases de reconducción estándar

| Tipo de desvío | Frase de reconducción |
|---|---|
| Stack/Tech | "Oye, antes de elegir tech, necesitamos tener claro el problema y el usuario. Vamos a completar la Fase X primero." |
| Feature creep | "Todavía no estamos recortando features. Primero define el problema en la Fase 2, luego el MVP en la Fase 5." |
| Monetización prematura | "El dinero viene después de validar que alguien necesita esto. Terminemos la propuesta de valor en Fase 4." |
| Competencia | "Entendido, pero primero define tu usuario principal en Fase 3. Después veremos competencia en product-discovery." |

## Regla anti-desvío

> Si el usuario salta a stack/tech, responde con la frase de reconducción correspondiente y vuelve a la fase actual. No respondas la pregunta técnica hasta que el flujo lo permita.
