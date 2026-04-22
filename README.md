# KkapsCa — Project Kickstart Pipeline

> "Antes de ejecutar, hay que planear."  
> Un sistema de 3 skills para llevar cualquier idea a un proyecto listo para desarrollar.

**Autor:** KkapsCa  
**Versión:** 1.0

---

## El problema que resuelve este sistema

La mayoría de proyectos fracasan antes de escribir una línea de código.
No por falta de talento técnico, sino por falta de planeación.

Los errores más comunes:
- Construir algo que nadie necesita
- No conocer al usuario real
- Subestimar el esfuerzo técnico
- No tener modelo de negocio claro
- Elegir el tech stack por moda, no por necesidad

Este pipeline existe para eliminar esos errores **antes** de tocar el teclado.

---

## Las 3 Skills

```
┌─────────────────────────────────────────────────────────────┐
│                    PROJECT KICKSTART PIPELINE               │
├──────────────────┬──────────────────┬───────────────────────┤
│  01-brainstorm   │ 02-product-      │  03-tech-feasibility  │
│                  │    discovery     │                        │
├──────────────────┼──────────────────┼───────────────────────┤
│ INPUT            │ INPUT            │ INPUT                  │
│ Idea vaga        │ Product Brief    │ Discovery Report       │
│                  │ (del brainstorm) │ (del discovery)        │
├──────────────────┼──────────────────┼───────────────────────┤
│ PROCESO          │ PROCESO          │ PROCESO                │
│ · Problema       │ · Mercado        │ · Factibilidad técnica │
│ · Usuario        │ · Competidores   │ · Stack decision       │
│ · Features MVP   │ · Personas       │ · Riesgos técnicos     │
│ · Diferenciador  │ · Modelo negocio │ · Estimación esfuerzo  │
│ · Tech (inicio)  │ · Factibilidad   │ · Arquitectura base    │
│                  │   económica      │ · Dependencias         │
│                  │ · Validación     │                        │
├──────────────────┼──────────────────┼───────────────────────┤
│ OUTPUT           │ OUTPUT           │ OUTPUT                 │
│ Product Brief    │ Discovery Report │ Tech Spec              │
│                  │                  │ → Listo para dev       │
└──────────────────┴──────────────────┴───────────────────────┘
```

---

## Cómo usar el sistema

### Flujo normal (proyecto nuevo desde cero)

```
1. Activa /brainstorm
   → Aterriza la idea, define el problema y usuario
   → Guarda el Product Brief generado

2. Activa /product-discovery
   → Pega el Product Brief como input
   → Valida el mercado y el modelo de negocio
   → Guarda el Discovery Report

3. Activa /tech-feasibility
   → Pega el Discovery Report como input
   → Define el stack, arquitectura y estimaciones
   → Guarda el Tech Spec

4. Empieza a desarrollar con el Tech Spec como guía
```

### Flujo rápido (idea ya parcialmente definida)

Si ya tienes claro el problema y el usuario, puedes saltar al paso 2.
Si ya tienes validación de mercado, puedes ir directo al paso 3.

**Nunca saltes al paso 3 sin haber completado al menos el paso 1.**
El stack sin contexto de negocio es una decisión ciega.

---

## Instalación

```bash
# Clona o descarga este repositorio
git clone https://github.com/KkapsCa/project-kickstart

# Copia las skills a tu directorio de skills de gentle-ai
cp -r 01-brainstorm ~/.claude/skills/brainstorm
cp -r 02-product-discovery ~/.claude/skills/product-discovery
cp -r 03-tech-feasibility ~/.claude/skills/tech-feasibility
```

---

## Outputs del pipeline

Al completar las 3 skills, tendrás:

| Documento | Contiene | Útil para |
|---|---|---|
| **Product Brief** | Problema, usuario, MVP, diferenciador | Dev team, stakeholders |
| **Discovery Report** | Mercado, personas, modelo de negocio | Inversores, co-founders |
| **Tech Spec** | Stack, arquitectura, estimaciones, riesgos | Tech lead, freelancers |

Estos tres documentos son suficientes para:
- Contratar un desarrollador y que entienda qué construir
- Presentar la idea a un inversionista
- Empezar el desarrollo tú mismo sin perderte

---

*KkapsCa — github.com/KkapsCa*
