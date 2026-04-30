# Desarrollo Guiado por Especificaciones (SDD)

Este documento explica qué es el Desarrollo Guiado por Especificaciones (**SDD**, por sus siglas en inglés: *Spec-Driven Development*) y cómo se utiliza el **orquestador sdd-orchestrator** en este repositorio.

## ¿Qué es SDD?

El **Desarrollo Guiado por Especificaciones (SDD)** es un enfoque de trabajo estructurado que separa el *qué* (especificaciones) del *cómo* (implementación). En lugar de saltar directo al código, SDD guía el desarrollo a través de fases documentadas:

```text
Exploración → Propuesta → Especificaciones → Diseño → Tareas → Implementación → Verificación → Archivado
```

### Beneficios principales

- **Claridad antes del código**: Define qué se va a construir antes de decidir cómo hacerlo
- **Trazabilidad**: Cada cambio tiene una justificación documentada
- **Revisiones estructuradas**: Los cambios pasan por verificación contra especificaciones
- **Memoria persistente**: Las decisiones y el contexto se guardan para sesiones futuras

## Fases del SDD

| Fase | Propósito |
|------|-----------|
| **sdd-explore** | Investigar ideas y explorar el código antes de comprometerse con un cambio |
| **sdd-propose** | Crear una propuesta con intención, alcance y enfoque |
| **sdd-spec** | Escribir especificaciones con requisitos y escenarios |
| **sdd-design** | Crear documento de diseño técnico con decisiones de arquitectura |
| **sdd-tasks** | Desglosar un cambio en una lista de tareas de implementación |
| **sdd-apply** | Implementar tareas siguiendo las especificaciones y el diseño |
| **sdd-verify** | Validar que la implementación coincide con especificaciones, diseño y tareas |
| **sdd-archive** | Sincronizar especificaciones y archivar un cambio completado |

## El Orquestador sdd-orchestrator

El **sdd-orchestrator** es el coordinador de flujos SDD. Es un agente que:

- **No ejecuta código directamente**: Delega todo el trabajo real a sub-agentes especializados
- **Mantiene el hilo de conversación**: Coordina las fases y sintetiza resultados
- **Carga habilidades automáticamente**: Resuelve qué habilidades del proyecto aplican según el contexto
- **Gestiona el almacenamiento**: Decide dónde persistir los artefactos (Engram, archivos, o ambos)

### Comandos Disponibles

| Comando | Descripción |
|---------|--------------|
| `/sdd-init` | Inicializa el contexto SDD en un proyecto |
| `/sdd-explore <tema>` | Investiga una idea sin crear archivos |
| `/sdd-apply [cambio]` | Implementa tareas en lotes |
| `/sdd-verify [cambio]` | Valida implementación contra especificaciones |
| `/sdd-archive [cambio]` | Cierra un cambio y persiste el estado final |
| `/sdd-onboard` | Recorrido guiado de SDD usando el código base real |

### Modos de Ejecución

- **Automático (`auto`)**: Ejecuta todas las fases seguidas sin pausas
- **Interactivo (`interactive`)**: Muestra el resultado después de cada fase y permite ajustes

## Uso en Este Repositorio

Este repositorio utiliza SDD para cambios sustanciales en la documentación y estructura. El flujo típico es:

1. **Inicialización**: `/sdd-init` detecta el stack, convenciones y capacidades de prueba
2. **Nuevo cambio**: `/sdd-new <cambio>` inicia exploración y propuesta
3. **Continuación**: `/sdd-continue [cambio]` ejecuta la siguiente fase dependiente
4. **Implementación**: `/sdd-apply [cambio]` aplica las tareas documentadas

### Almacenamiento de Artefactos

Los artefactos SDD pueden guardarse en:

- **Engram** (por defecto): Memoria persistente rápida, sin archivos locales
- **OpenSpec**: Archivos en `openspec/` con historial git completo
- **Híbrido**: Ambos — archivos para compartir + Engram para recuperación

## Relación con el Pipeline de Producto

SDD complementa el pipeline de producto de este repositorio:

```text
Idea → brainstorming → descubrimiento → inicio proyecto → factibilidad técnica
              ↓
         (SDD inicia aquí para cambios de arquitectura/documentación)
              ↓
         sdd-init → sdd-new → sdd-apply → sdd-verify → repo-bootstrap → Desarrollo
```

---

## Notas Importantes

- **SDD es para cambios sustanciales**: No se requiere para ajustes menores de documentación
- **Las especificaciones son el criterio de aceptación**: La implementación se valida contra ellas
- **La memoria persistente (Engram) es clave**: Permite recuperar contexto entre sesiones de trabajo
- **El orquestador no es un ejecutor**: Coordina, no escribe código directamente
