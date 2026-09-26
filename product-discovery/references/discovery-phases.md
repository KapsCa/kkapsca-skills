# Fases 1-6 del discovery completo — Product Discovery

Detalle local de `SKILL.md` (## Execution Steps, Modo A): instrucción, reglas de avance y plantillas de cada fase.

## Filosofía

Discovery no es burocracia.
Es el filtro que evita construir algo que nadie necesita.

### Regla de oro

> Antes de invertir semanas en desarrollo, confirma que existe una necesidad,
> un usuario concreto y una razón real para que alguien use —o incluso pague— por lo que estás imaginando.

## Fase 1 — Mercado y contexto

No necesitas sonar a consultor. Necesitas orden.

### Tamaño de oportunidad (si aplica)

Usa TAM / SAM / SOM solo cuando el proyecto realmente lo amerite.

- **TAM** → tamaño total del mercado
- **SAM** → segmento al que realmente puedes llegar
- **SOM** → porción realista que podrías capturar

Si el proyecto es pequeño o interno, puedes sustituir esto por:

- tamaño del nicho,
- número estimado de usuarios potenciales,
- intensidad del problema.

### Regla de avance

Solo usa TAM / SAM / SOM si el proyecto es un producto serio o un negocio.
Si es side project, aprendizaje o herramienta interna, usa nicho + usuarios potenciales + intensidad del problema.

### Preguntas clave

- ¿Este problema ocurre con suficiente frecuencia?
- ¿A cuántas personas afecta en el nicho relevante?
- ¿Es un dolor real o solo una idea curiosa?

## Fase 2 — Competencia y alternativas

No busques solo competidores directos.
Busca también sustitutos.

```text
Competidor o alternativa: [nombre]
Qué resuelve: [descripción]
Fortaleza: [qué hace bien]
Debilidad: [qué deja mal resuelto]
Oportunidad: [qué podrías hacer mejor o distinto]
```

### Tipos de competencia

- **Directa** → hace algo muy parecido
- **Indirecta** → resuelve el mismo problema de otra forma
- **Sustituto actual** → Excel, WhatsApp, Notion, papel, procesos manuales

## Fase 3 — Usuario y Jobs To Be Done

La skill debe aterrizar máximo 1 o 2 perfiles centrales.

```text
Persona: [nombre ficticio]
Perfil: [ocupación, contexto, comportamiento]
Problema principal: [dolor real]
Motivación: [qué espera ganar]
Fricciones: [qué lo haría no usar tu producto]

Job to be done:
"Cuando [situación], quiero [motivación], para [resultado esperado]"
```

### Regla

Si el usuario responde "esto es para todos", hay que empujarlo a elegir un usuario primario.

### Regla para avanzar

No avances si el usuario principal sigue siendo genérico o difuso.

## Fase 4 — Propuesta de valor

Obliga a resumir la propuesta así:

```text
Ayudamos a [usuario] a [resolver problema] mediante [solución],
para que pueda [resultado valioso].
```

Si esto no se puede escribir con claridad, el producto sigue borroso.

## Fase 5 — Modelo de valor y monetización

No todos los proyectos necesitan modelo de negocio fuerte desde el día 1.

Primero define cuál de estos aplica:

- **Negocio** → sí necesita monetización clara.
- **Side project** → puede empezar sin monetizar, pero debe tener una hipótesis.
- **Aprendizaje** → monetización opcional.
- **Herramienta interna** → el valor puede ser ahorro de tiempo o costo, no ventas.

### Si sí aplica monetización

Explora opciones como:

- freemium,
- suscripción,
- pago único,
- comisión,
- B2B,
- consultoría/servicio asociado.

### Pregunta correcta

No preguntes solo "¿cómo ganará dinero?"
Pregunta también:

> "¿Qué tipo de valor genera este producto y cómo se podría capturar?"

### Regla para avanzar

No avances a la siguiente fase si la propuesta de valor todavía no se puede escribir con claridad.

## Fase 6 — Estrategia de validación

Siempre busca primero la validación más barata posible. Tabla de métodos y reglas: `validation-methods.md`.

### Regla

No construyas un MVP técnico si todavía puedes aprender lo mismo con algo más barato.

### Regla para avanzar

No avances a `tech-feasibility` si la validación mínima todavía puede hacerse con algo más barato.
