# Micro-contratos de salida por fase — Brainstorm

Detalle local de `SKILL.md` (## Execution Steps): la filosofía, el orden de fases y el contrato de cada fase — qué capturar, qué NO responder aún y cuál es la señal de avance.

## Filosofía

Brainstorm no es lanzar ideas al aire.
Es convertir intuición en una hipótesis de producto que se pueda analizar después.

### Orden correcto (PMBOK 8)

1. **Problema** — Identificar el dolor real
2. **Usuario** — Identificar el usuario principal
3. **Propuesta de valor** — Proponer solución
4. **MVP** — Definir lo mínimo necesario
5. **Diferenciadores** — Elegir 1-2 ventajas clave
6. **Preguntas abiertas** — Qué dudas quedan

La tecnología va al final, no al principio.

## Fase 1 — Idea cruda

### Regla para avanzar

Avanza a Fase 2 solo cuando exista una explicación de 30 segundos y haya al menos una pista concreta de problema y usuario.

### Micro-contrato de salida (Fase 1)

```text
Captura:
  - Explicación de 30 segundos (idea cruda)
  - Al menos una pista de problema
  - Al menos una pista de usuario potencial
  - Contexto org preliminar (personal / negocio / organización)

NO responde aún:
  - ¿Quién es exactamente el usuario? (Fase 3)
  - ¿Cuál es la propuesta de valor exacta? (Fase 4)
  - ¿Qué incluye el MVP? (Fase 5)
  - Valor esperado completo (Fase 4)
  - Dudas abiertas finales (Fase 6)

Señal de avance:
  - Explicación de 30s documentada + rastro de problema/usuario identifiers
```

## Fase 2 — Problema real

### Salida de esta fase

```text
Problema: [dolor concreto]
Solución actual: [cómo lo resuelven hoy]
Gap: [qué queda mal resuelto]
```

### Regla para avanzar

No avances a Fase 3 si faltan problema, solución actual o gap.

### Micro-contrato de salida (Fase 2)

```text
Captura:
  - Problema concreto identificado
  - Solución actual documentada
  - Gap detectado (qué queda mal resuelto)

NO responde aún:
  - Perfil detallado del usuario (Fase 3)
  - Propuesta de valor final (Fase 4)
  - Alcance del MVP (Fase 5)

Señal de avance:
  - Bloque "Problema / Solución actual / Gap" completado y validado
```

## Fase 3 — Usuario principal + Interesados (PMBOK 8)

### Regla para avanzar

Avanza a Fase 4 solo si el usuario principal ya no es genérico y puede describirse con claridad.

### Micro-contrato de salida (Fase 3)

```text
Captura:
  - Usuario principal definido (perfil, frecuencia, motivación, fricción)
  - Interesados ampliados (PMBOK 8): patrocinador, equipo, regulatorios si aplica

NO responde aún:
  - Propuesta de valor final (Fase 4)
  - Definición de MVP (Fase 5)
  - Diferenciadores (Fase 6)

Señal de avance:
  - Usuario principal con perfil no genérico + interesados mapeados
```

## Fase 4 — Propuesta de valor

### Regla para avanzar

Avanza a Fase 5 solo cuando la frase de valor sea clara y específica.

### Micro-contrato de salida (Fase 4)

```text
Captura:
  - Frase de propuesta de valor: "Ayudamos a [usuario] a [resolver problema] mediante [solución], para que pueda [resultado valioso]"
  - Valor esperado preliminar: beneficio para el usuario, valor para el negocio y señal de éxito

NO responde aún:
  - Definición de MVP (Fase 5)
  - Diferenciadores (Fase 6)

Señal de avance:
  - Frase de valor clara, específica y documentada
```

## Fase 5 — MVP (y alcance inicial)

### Regla para avanzar

Avanza a Fase 6 solo cuando el MVP esté recortado y no incluya más de lo necesario para resolver el problema principal.

### Micro-contrato de salida (Fase 5)

```text
Captura:
  - MVP recortado (Must Have / Should Have / Could Have / Not in MVP)
  - Definición clara de qué resuelve el problema principal

NO responde aún:
  - Diferenciadores (Fase 6)

Señal de avance:
  - MVP con Must Have listados y Fuera de MVP explícito
```

## Fase 6 — Diferenciadores

### Regla para avanzar

Si no puedes elegir máximo 2 diferenciadores claros, no cierres el brief todavía.

### Micro-contrato de salida (Fase 6)

```text
Captura:
  - Máximo 2 diferenciadores claros
  - Dudas abiertas y supuestos por validar
  - Product Brief completo listo para product-discovery

NO responde aún:
  - Definición de mercado/competencia (eso es product-discovery)
  - Validación pesada (product-discovery)
  - Decisiones de stack (tech-feasibility)

Señal de avance:
  - Diferenciadores definidos + Product Brief completo generado
```
