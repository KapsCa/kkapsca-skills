<div align="center">

# KkapsCa Skills

> **Habilidades para pasar de una idea a un producto, y de un producto a código con criterio.**

[![License: MIT](https://img.shields.io/badge/License-MIT-3C5387?style=flat-square)](LICENSE)
[![Skills: 12](https://img.shields.io/badge/skills-12-7D70C1?style=flat-square)](docs/skill-registry.md)
[![GitHub](https://img.shields.io/badge/GitHub-KapsCa%2Fkkapsca--skills-854472?style=flat-square&logo=github)](https://github.com/KapsCa/kkapsca-skills)

**[Inicio rápido](#inicio-rápido)** · **[Las 12 skills](#las-12-skills)** · **[Seguridad](#seguridad-desde-el-primer-commit)** · **[Documentación](#documentación)**

</div>

Este repositorio reúne **habilidades (skills)** pensadas desde la experiencia personal de **KkapsCa**, redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

Son skills de **texto plano**: un archivo `SKILL.md` con frontmatter. No dependen de una herramienta, no ejecutan nada por su cuenta y no reemplazan tu criterio. Lo que hacen es darle a un agente de IA el **contexto y el orden de pensamiento** que suele faltar: qué preguntar antes de construir, qué decidir antes de elegir tecnología, y qué verificar antes de decir que algo está listo.

---

## Inicio Rápido

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

El proceso de inicialización (**bootstrap**) se corre **desde este repositorio de habilidades**, no desde la carpeta de tu proyecto futuro.

### Dos destinos

| Destino | Qué recibe | Dónde queda |
|---|---|---|
| **opencode** | Las 12 skills | `~/.config/opencode/skills/` |
| **Pi** | Las 6 de mayor uso: el pipeline de producto y los estándares del repo | `~/.agents/skills/` |

```bash
bash scripts/bootstrap.sh            # ambos destinos
bash scripts/bootstrap.sh --pi-only  # solo el destino de Pi, sin tocar opencode
```

> **Después de instalar, reiniciá el agente** (opencode, Pi o los dos): la lista de skills disponibles se refresca al arrancar.

Si un directorio ya existe y no lo creó este repositorio, el bootstrap **no lo pisa**: lo reporta como conflicto y sigue. Detalle operativo en la [guía de instalación](docs/installation.md).

**[Guía de instalación →](docs/installation.md)**

---

## Las 12 skills

### Pipeline de producto

De una idea vaga a un producto definido. Esta fase es **anterior** a cualquier flujo de implementación: acá todavía no hay código, hay decisiones.

```text
Idea → brainstorming → descubrimiento de producto → inicio de proyecto → factibilidad técnica → Desarrollo
```

**Ruta ligera** (proyectos personales o paralelos): `Idea → brainstorming → descubrimiento de producto → factibilidad técnica → Desarrollo`

### Estándares del repo

Preparan un repositorio y verifican que el trabajo lo respete.

### Companions

Se cargan por situación, cuando el trabajo ya está en marcha.

| Grupo | Skill | Se activa cuando… | Destino |
|---|---|---|---|
| **Pipeline** | [brainstorm](brainstorm/SKILL.md) | tenés una idea y no sabés por dónde empezar | Pi · opencode |
| **Pipeline** | [product-discovery](product-discovery/SKILL.md) | querés saber si la necesidad es real, quién la usaría y cómo validarla | Pi · opencode |
| **Pipeline** | [project-init](project-init/SKILL.md) | hay que decidir enfoque, secuencia de trabajo y alcance inicial | Pi · opencode |
| **Pipeline** | [tech-feasibility](tech-feasibility/SKILL.md) | hay que medir dificultad, riesgos, esfuerzo y elegir stack | Pi · opencode |
| **Estándares** | [repo-bootstrap](dev-skills/repo-bootstrap/SKILL.md) | vas a crear un repositorio nuevo | Pi · opencode |
| **Estándares** | [repo-guardrails](dev-skills/repo-guardrails/SKILL.md) | estás por hacer push, abrir un PR o mergear | Pi · opencode |
| **Companion** | [clarify-with-artifacts](dev-skills/clarify-with-artifacts/SKILL.md) | hay una idea vaga y ya existen artifacts que la aterrizan | opencode |
| **Companion** | [diagnose](dev-skills/diagnose/SKILL.md) | hay un bug que no entendés y querés ir de la reproducción a la causa | opencode |
| **Companion** | [zoom-out](dev-skills/zoom-out/SKILL.md) | vas a editar código que no conocés bien | opencode |
| **Companion** | [improve-codebase-architecture](dev-skills/improve-codebase-architecture/SKILL.md) | sospechás deuda técnica, acoplamiento o responsabilidades mezcladas | opencode |
| **Companion** | [tasks-to-issues](dev-skills/tasks-to-issues/SKILL.md) | hay un plan aprobado y querés convertirlo en issues | opencode |
| **Companion** | [flutter-personal-standards](dev-skills/flutter-personal-standards/SKILL.md) | hay dudas de estructura o arquitectura en Flutter/Dart | opencode |

> La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no hiciste**.

**[Registro de skills →](docs/skill-registry.md)**

---

## El flujo: ODD por defecto, SDD opcional

El trabajo entra por **ODD** (*Organic Driven Development*): un pedido chico se resuelve liviano, y uno sustancial deja **un documento de feature** en `odd/tasks/<feature>.md` que permite retomarlo sin reconstruir el plan.

**SDD** (*Spec-Driven Development*) es una **rama opcional**, y se entra solo por pedido explícito (`/sdd-*`) o por propuesta aceptada. Tiene su propio pipeline documentado, y las skills de este repositorio conviven con él sin reemplazarlo: donde una skill necesita saber en qué fase está el trabajo, nombra ODD por defecto y las fases SDD como alternativa.

**[ODD y SDD →](docs/sdd.md)**

---

## Seguridad desde el primer commit

Un proyecto nuevo **no debería nacer sin defensas**. Por eso el bootstrap del repo no solo deja las reglas de trabajo: deja también las seis piezas de seguridad, y ninguna depende de que alguien se acuerde de correrlas.

| Pieza | Qué responde |
|---|---|
| **Detector de secretos** (`gitleaks`) | ¿Alguien escribió una contraseña o una clave en el código? Si la encuentra, **frena el cambio** |
| **Actualizador de dependencias** (`dependabot`) | ¿Salió una versión nueva de algo que uso? Abre un PR con la propuesta |
| **Análisis estático** (`codeql`) | ¿Hay formas conocidas de escribir código inseguro? |
| **Auditoría de dependencias** (`audit`) | ¿Algo que **ya tengo** tiene una falla conocida **hoy**? |
| **Canal de reporte** (`SECURITY.md`) | ¿A quién le aviso si encuentro un problema, y por dónde, sin publicarlo? |
| **Lista de lo que no se guarda** (`.gitignore`) | ¿Qué archivos nunca deben entrar al historial? |

### Tres ideas que sostienen esto

**Un secreto que llegó a un commit está comprometido.** No alcanza con borrar la línea: en el historial sigue estando, y en un repo público ya lo vio cualquiera. La única salida real es **rotar la credencial**.

**Cada herramienta se referencia por versión exacta, no por "la última".** Si alguien toma el control de una herramienta de terceros, puede cambiar qué significa "la última" y meter código sin que nadie lo revise. Con la versión exacta, se usa lo que se revisó.

**Si un chequeo de seguridad no corre, no se mergea.** Un chequeo ausente no es un chequeo aprobado.

### Lo que no está cubierto

Se declara a propósito, para no asumir defensas que no existen:

- El análisis estático **no entiende Dart/Flutter, shell ni PowerShell**. En un proyecto de Flutter corre y no encuentra nada.
- **Flutter no tiene auditoría de librerías en integración continua**: es el único stack del ecosistema sin ninguna capa automática.
- El análisis estático **solo funciona en repos públicos**.
- El detector de secretos **necesita una licencia si el repo es de una organización** (no si es de una cuenta personal).
- **Un repo sin código todavía no tiene lenguaje.** Ese es el estado inicial normal de un proyecto nuevo, y está contemplado: nada falla, y cada pieza se activa cuando aparece el código.

**[Baseline de seguridad →](docs/security-baseline.md)**

---

## Cómo se escriben las skills

Cada skill de este repositorio es un **contrato de instrucciones para un agente**, no documentación para humanos: dice cuándo activarse, qué reglas no puede violar, cómo decidir, qué hacer y qué devolver.

El contrato está escrito en [el contrato de estilo](docs/skill-style-guide.md) y las 12 skills se migran a él **de forma progresiva**.

**[Contrato de estilo →](docs/skill-style-guide.md)**

---

## Documentación

| Documento | Qué encontrás |
|---|---|
| [Guía de instalación](docs/installation.md) | Bootstrap, destinos, opciones `--copy` y `--pi-only`, desinstalación |
| [Instalación en Windows nativo](docs/windows-native-setup.md) | Reconstruir el ecosistema completo sin WSL |
| [Registro de skills](docs/skill-registry.md) | Qué skill se activa en qué situación, y quién manda cuando dos se solapan |
| [Contrato de estilo](docs/skill-style-guide.md) | La norma LLM-first a la que se migran las skills |
| [ODD y SDD](docs/sdd.md) | El flujo por defecto y la rama opcional |
| [Baseline de seguridad](docs/security-baseline.md) | Qué chequea cada herramienta, qué cubre por stack y qué queda afuera |
| [Flujo de contribución](docs/governance.md) | Ramas, PR, Conventional Commits, protección de `main` |
| [Versionado](docs/release-please.md) | Versiones y changelog automáticos |

**[Índice completo de documentación →](docs/README.md)**

---

<!--
  RESERVADO — sección de marca.

  Esta posición queda libre para la sección de identidad visual (wordmark, paleta,
  tokens) que está construyendo el brand kit en `brand/`, con su propio
  `GUIDELINES.md`. Se deja el lugar y el orden para que la sección entre acá sin
  reescribir el resto del README.

  Nota para quien la escriba: los colores de los badges de arriba son provisorios,
  medidos del logo, y NO están aprobados como sistema. Cuando exista la paleta
  oficial, se restylean desde acá.
-->

## Built with Gentle-AI

Este repositorio fue creado con **[Gentle-AI](https://github.com/Gentleman-Programming/gentle-ai)**.

<div align="center">

<a href="https://github.com/Gentleman-Programming/gentle-ai">
  <img width="220" src="https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/docs/assets/brand/built-with-gentle-ai.png" alt="Built with Gentle-AI" />
</a>

</div>

Estas habilidades dan su mejor resultado cuando el agente opera con contexto consistente: **[Gentle AI Repository →](https://github.com/Gentleman-Programming/gentle-ai)**

---

## Agradecimientos

Este proyecto utiliza herramientas y referentes que han contribuido a su desarrollo:

- **[Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)**: Por el entorno de trabajo, la filosofía de desarrollo y las herramientas que permitieron revisar, corregir y refinar este repositorio.
- **[mattpocock/skills](https://github.com/mattpocock/skills)**: Por servir como referencia e inspiración para varias habilidades adaptadas a este ecosistema.
- **Supabase** y **Firebase**: Por sus habilidades oficiales que extienden las capacidades de este repositorio.

---

## Filosofía

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**
