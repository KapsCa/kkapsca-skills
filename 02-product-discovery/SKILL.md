---
name: product-discovery
description: >
  PASO 2 DE 3 del Project Kickstart Pipeline. Valida un Product Brief con análisis de
  mercado, competidores, público objetivo detallado (proto-personas + Jobs To Be Done),
  modelo de negocio y factibilidad económica. Produce un Discovery Report listo para
  la evaluación técnica.

  SIEMPRE activa esta skill cuando el usuario tenga un Product Brief y quiera validar
  su idea de negocio, analizar el mercado, definir su modelo de monetización, conocer
  a su competencia, construir proto-personas, o evaluar si la idea es económicamente
  viable. También activa cuando el usuario diga "¿hay mercado para esto?", "¿cómo
  ganaría dinero?", "¿quién más hace esto?", o "quiero validar antes de construir".

license: Apache-2.0
metadata:
  author: KkapsCa
  version: "1.0"
  pipeline: "project-kickstart/02"
  prev: "brainstorm"
  next: "tech-feasibility"
---

# Product Discovery — Paso 2 de 3

> **Pipeline:** `brainstorm` → `product-discovery` → `tech-feasibility`  
> **Input:** Product Brief (output de brainstorm)  
> **Output:** Discovery Report (feed para tech-feasibility)

---

## When NOT to Use

- No hay un Product Brief previo → regresa a `brainstorm` primero
- El usuario solo quiere definir la idea, sin validarla → usa `brainstorm`
- El usuario ya tiene validación de mercado y quiere ir al stack técnico → usa `tech-feasibility`

---

## Filosofía

Construir sin validar es apostar con tiempo y dinero.
El discovery no es burocracia — es el seguro de vida de tu proyecto.

Preguntas que esta skill responde:
- ¿Existe mercado real para esto?
- ¿Quién es exactamente el usuario y qué trabajo quiere hacer?
- ¿Quién más lo está haciendo y cómo me diferencio?
- ¿Cómo generará dinero este producto?
- ¿Es económicamente viable construirlo?
- ¿Cómo valido la idea antes de invertir meses de desarrollo?

---

## Fase 1 — Análisis de Mercado

### 1.1 Tamaño de Mercado (TAM / SAM / SOM)

No necesitas consultores. Necesitas orden mental.

| Sigla | Qué es | Cómo estimarlo |
|---|---|---|
| **TAM** | Mercado total disponible | ¿Cuántas personas en el mundo tienen este problema? |
| **SAM** | Mercado al que puedes llegar | ¿Cuántos están en tu región/idioma/canal de distribución? |
| **SOM** | Mercado que puedes capturar | ¿Cuántos capturarías realista en 2-3 años? |

**Fuentes para investigar (pídele al usuario que confirme el contexto):**
- Statista, Google Trends, reportes de industria
- Subreddits, grupos de Facebook, comunidades del nicho
- Reviews de apps competidoras en App Store / Play Store

**Pregunta clave:**
> "¿Es el mercado suficientemente grande para justificar el esfuerzo,
> pero suficientemente específico para que puedas servir bien a tus usuarios?"

---

### 1.2 Análisis de Competidores

Para cada competidor directo (máximo 5), documenta:

```
Competidor: [Nombre]
Propuesta de valor: [Qué prometen]
Precio: [Modelo de monetización]
Fortaleza principal: [Por qué la usan]
Debilidad principal: [Por qué la dejan / se quejan]
Gap que no cubre: [Oportunidad para ti]
```

**Fuentes para investigar competidores:**
- Reseñas en App Store / Play Store (las negativas son oro)
- ProductHunt, G2, Capterra
- Subreddits relacionados: busca quejas sobre apps existentes

**Tipos de competencia a identificar:**
- **Directa** — hacen exactamente lo mismo
- **Indirecta** — resuelven el mismo problema de otra forma
- **Sustitutos** — lo que el usuario usa hoy (Excel, WhatsApp, papel)

---

## Fase 2 — Público Objetivo Detallado

### 2.1 Proto-Personas (1-2 máximo)

Una persona es una representación ficticia basada en patrones reales, no en suposiciones.

```
## Persona: [Nombre ficticio]

**Perfil demográfico**
- Edad: [rango]
- Ocupación: [trabajo o rol]
- Contexto: [dónde vive, cómo es su día típico]

**Comportamiento digital**
- Apps que usa diario: [lista]
- ¿Cómo descubre apps nuevas?: [amigos / redes / búsqueda]
- Disposición a pagar: [gratis solamente / freemium / paga si vale]

**Jobs To Be Done**
- Trabajo funcional: "Cuando [situación], quiero [motivación], para [resultado esperado]"
- Trabajo emocional: ¿Cómo quiere sentirse después de usar el producto?
- Trabajo social: ¿Cómo quiere que otros lo perciban al usarlo?

**Frustraciones actuales**
- [Pain 1]
- [Pain 2]

**Lo que le haría abandonar tu app**
- [Fricción 1]
- [Fricción 2]
```

**Jobs To Be Done — ejemplo práctico:**
> "Cuando tengo que dividir gastos con amigos después de un viaje,
> quiero saber exactamente cuánto me deben sin hacer cuentas manuales,
> para no tener conversaciones incómodas de dinero."

---

## Fase 3 — Modelo de Negocio

### 3.1 ¿Cómo genera dinero?

Elige el modelo principal y justifícalo:

| Modelo | Descripción | Mejor para |
|---|---|---|
| **Freemium** | Gratis con features premium de pago | Apps con alto volumen de usuarios |
| **Suscripción** | Pago mensual/anual por acceso | Apps de uso frecuente, valor continuo |
| **Pago único** | Se compra una vez | Herramientas, utilidades |
| **Marketplace** | Comisión por transacción | Apps que conectan dos partes |
| **B2B SaaS** | Venta a empresas, por asiento o uso | Apps de productividad empresarial |
| **Publicidad** | Ingresos por anuncios | Solo viable con millones de usuarios |
| **Datos / Leads** | Monetización de datos agregados | Solo con regulación legal clara |

**Preguntas para definir el modelo:**
1. ¿El valor del producto aumenta con el tiempo de uso? → Suscripción
2. ¿El usuario necesita la app para una tarea puntual? → Pago único
3. ¿Hay dos partes que se benefician de conectarse? → Marketplace
4. ¿Las empresas pagarían más que los individuos? → B2B

---

### 3.2 Factibilidad Económica

Estimación de orden de magnitud — no necesitas un MBA, necesitas honestidad.

**Costos a estimar:**

| Rubro | Estimación | Notas |
|---|---|---|
| Desarrollo MVP | $X | Freelancer / agencia / tú mismo |
| Infraestructura/mes | $X | Firebase, AWS, Supabase |
| Marketing inicial | $X | Ads, contenido, comunidad |
| Legal/constitución | $X | Opcional en fase early |
| **Total burn rate/mes** | $X | |

**Ingresos potenciales (escenario conservador):**

```
Usuarios activos año 1:     [N] usuarios
Tasa de conversión a pago:  [X]%
Precio promedio/mes:        $[P]
MRR estimado año 1:         N × X% × P = $[resultado]
```

**Pregunta de sostenibilidad:**
> "¿Con cuántos usuarios de pago cubres los costos operativos mensuales?"
> Si ese número es alcanzable en 12-18 meses, el modelo es viable.

---

## Fase 4 — Estrategia de Validación

**Construir para validar es caro. Validar para construir es inteligente.**

### Métodos de validación por costo/velocidad:

| Método | Costo | Tiempo | Qué valida |
|---|---|---|---|
| **Entrevistas** (5-10 usuarios) | $0 | 1 semana | Problema real, Jobs To Be Done |
| **Landing page + waitlist** | $50-200 | 2 semanas | Demanda, mensaje, canal |
| **Prototipo Figma** | $0 | 1-2 semanas | UX, flujo principal |
| **MVP manual** (Wizard of Oz) | $0 | Variable | Disposición a pagar |
| **Pre-venta** | $0 | 2-4 semanas | Disposición a pagar real |
| **MVP técnico mínimo** | Alto | 1-3 meses | Todo, pero es el más caro |

**Regla:** Valida con el método más barato que te dé información útil.
No construyas código hasta haber validado con al menos 2 métodos más baratos.

### Métricas de validación (define UNA por método):
- Entrevistas: ¿Al menos 7 de 10 personas reconocen el problema?
- Landing: ¿Al menos 5% se registra al ver la propuesta de valor?
- Pre-venta: ¿Al menos 10 personas pagan antes de que exista?

---

## Reglas de Conducción

- Si el usuario no puede identificar competidores, probablemente el mercado no existe o no lo conoce bien — investiga junto con él
- Si el modelo de negocio no es claro después de esta fase, **no avances** a tech-feasibility
- Las personas deben basarse en patrones reales, no en "yo creo que el usuario es..."
- Desafía los números optimistas — pide siempre el escenario conservador

---

## Output Final — Discovery Report

Genera este documento al terminar. Es el input para `tech-feasibility`.

```markdown
# [Nombre del Producto] — Discovery Report
**Generado por:** KkapsCa / product-discovery skill v1.0
**Fecha:** [fecha]

## Resumen Ejecutivo
[3-4 oraciones: qué es, para quién, por qué ahora, cómo gana dinero]

## Mercado
**TAM:** [estimación]
**SAM:** [estimación]
**SOM (año 1-2):** [estimación]
**Tendencia:** [creciente / estable / decreciente + fuente]

## Análisis Competitivo
| Competidor | Fortaleza | Debilidad | Nuestro gap |
|---|---|---|---|
| [nombre] | | | |

## Persona Principal
[Bloque completo de persona con Jobs To Be Done]

## Modelo de Negocio
**Modelo:** [tipo]
**Precio:** [estructura de precios]
**Break-even estimado:** [N usuarios de pago]

## Factibilidad Económica
**Costo estimado MVP:** $[X]
**Burn rate mensual:** $[X]
**MRR conservador año 1:** $[X]
**Veredicto:** [viable / riesgoso / inviable + razón]

## Estrategia de Validación
**Método 1:** [qué hacer antes de construir]
**Métrica de éxito:** [número concreto]
**Método 2:** [siguiente nivel de validación]
**Métrica de éxito:** [número concreto]

## Supuestos Críticos
[Lista de lo que asumes que es verdad y aún no has probado]

## Riesgos de Negocio
[Top 3 riesgos con probabilidad e impacto]

---
**Siguiente paso:** Ejecuta `tech-feasibility` con este Discovery Report como input.
```

---

> ℹ️ **¿Ya tienes este output?**  
> Pasa directamente a la skill `tech-feasibility` con el Discovery Report como contexto.
