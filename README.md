# KkapsCa Skills

> Habilidades (**Skills**) públicas para pasar de una idea a un producto y de un producto a una implementación técnica con criterio en un servicio de edición **IA-first**.

[![GitHub repo](https://img.shields.io/badge/GitHub-KkapsCa%2Fkkapsca--skills-blue?logo=github)](https://github.com/KapsCa/kkapsca-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Follow Gentle AI](https://img.shields.io/badge/Follow-Gentle%20AI-purple?logo=github)](https://github.com/Gentleman-Programming/gentle-ai)

Este repositorio reúne habilidades (**skills**) pensadas desde la experiencia personal de **KkapsCa**, optimizadas para flujos de trabajo asistidos por Inteligencia Artificial (como Cursor, Windsurf o **opencode**) y redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

Al mismo tiempo, estas habilidades están **optimizadas para trabajar especialmente bien dentro del entorno tecnológico de [Gentle AI](https://github.com/Gentleman-Programming/gentle-ai)** y flujos coordinados por el **orquestador sdd-orchestrator** (una herramienta que coordina fases de desarrollo estructurado).

---

## Inicio Rápido

Si quieres usar estas habilidades en tu máquina local con **opencode**:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El proceso de inicialización (**bootstrap**) se corre desde **este repositorio de habilidades**, no desde la carpeta de tu proyecto futuro. Reinicia opencode después de ejecutarlo.

Para detalles operativos de instalación (opciones `--copy`, enlaces simbólicos, habilidades externas), consulta la [guía de instalación](docs/installation.md).

---

## ¿Qué es esto y para quién es?

Este repositorio es una colección de **habilidades (skills)** —conjuntos de instrucciones y flujos de trabajo— diseñadas para ayudarte a:

- **Desarrolladores** que arrancan proyectos desde cero
- **Creadores técnicos** que necesitan estructura sin burocracia
- **Creadores independientes** que quieren validar antes de construir
- **Estudiantes** que quieren aprender a pensar antes de programar
- **Equipos pequeños** que necesitan flujos de trabajo consistentes

---

## Pipeline Recomendado

```text
Idea → brainstorming → descubrimiento de producto → inicio de proyecto → factibilidad técnica → bootstrap del repo → Desarrollo
```

**Ruta ligera** (proyectos personales o proyectos paralelos):
```text
Idea → brainstorming → descubrimiento de producto → factibilidad técnica → bootstrap del repo → Desarrollo
```

### ¿Por dónde entrar?

- Idea vaga → **brainstorming** (herramienta para aterrizar ideas)
- Ya tienes problema + usuario + MVP → **descubrimiento de producto**
- Tienes Discovery Report → **inicio de proyecto** o directo a **factibilidad técnica**
- Ya tienes claridad técnica → usa una **habilidad de desarrollo**

> La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no has hecho**.

---

## Habilidades Disponibles

> **Estado actual**: Ninguna habilidad derivada de `awesome-copilot` está disponible en este release. El cambio `adapt-awesome-copilot-skills-to-our-flow` es de documentación (MVP docs-first y non-routable). Las candidatas (`agent-governance`, `agentic-eval`) están documentadas en el registry como no instalables y no enrutableables hasta una futura migración.
> **Ownership**: Las candidatas respetan un deny-list explícito (ver `.atl/skill-registry.md` → `## External Adaptation Gate` → `### Ownership Deny-List`): `agent-governance` no compite con `repo-bootstrap`, `branch-pr` ni `issue-creation`; `agentic-eval` no compite con `sdd-verify`.
> **Nota de alcance**: Este cambio modifica únicamente `.atl/skill-registry.md`, `README.md` y `docs/installation.md`. Otros diffs en la rama (ej. `.github/workflows/release-please.yml`) son ajenos a este cambio y se tratan por separado.

### 1. Inicio de proyecto (brainstorming → descubrimiento → factibilidad)

| Habilidad | Propósito |
|-----------|-----------|
| **brainstorm** | Convierte una idea vaga en un Product Brief |
| **product-discovery** | Valida mercado, usuario, competencia y negocio |
| **project-init** | Cierra la brecha entre descubrimiento y factibilidad |
| **tech-feasibility** | Evalúa tecnología, riesgos, arquitectura y esfuerzo |

### 2. Desarrollo y estándares

| Habilidad | Propósito |
|-----------|-----------|
| **dev-skills/flutter-personal-standards** | Criterio personal para Flutter |
| **dev-skills/repo-bootstrap** | Prepara el repositorio: flujo de PR, release-please, estándares |
| **dev-skills/repo-guardrails** | Advisory/warning-first sobre ramas, PRs y commits (capa lateral) |
| **dev-skills/sdd-to-issues** | Export-only: convierte artifacts SDD en issues GitHub |
| **dev-skills/request-triage** | Enrutador opt-in que decide a dónde va un request |
| **dev-skills/clarify-with-artifacts** | Estructura contexto usando artifacts existentes (opt-in) |

### 3. Habilidades especializadas (requieren tecnología confirmada)

Las habilidades de **Supabase** y **Firebase** se activan tras decidir la tecnología en `tech-feasibility`. Deben instalarse vía bootstrap para que opencode las detecte.

Consulta la [guía de instalación](docs/installation.md) para disponibilidad real y `docs/engram.md` para entender cómo se separan inicialización, memoria persistente y orquestación.

---

## Filosofía

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**

---

## Documentación Detallada

Para detalles operativos, consulta la documentación en `docs/`:

| Tema | Documento |
|------|-----------|
| Contexto Gentle AI y relación con este repo | [docs/gentle-ai.md](docs/gentle-ai.md) |
| Instalación detallada, bootstrap y skill-registry | [docs/installation.md](docs/installation.md) |
| Memoria persistente (Engram) vs Bootstrap vs Skill-Registry | [docs/engram.md](docs/engram.md) |
| Desarrollo estructurado (SDD) y sdd-orchestrator | [docs/sdd.md](docs/sdd.md) |
| Flujo de contribución y branch protection | [docs/governance.md](docs/governance.md) |
| Versionado semántico y release-please | [docs/release-please.md](docs/release-please.md) |
| Configuración WSL para Windows | [docs/wsl-setup.md](docs/wsl-setup.md) |
| Índice de documentación | [docs/README.md](docs/README.md) |

---

## Mejor Experiencia de Uso

Estas habilidades dan mejores resultados cuando:

- El agente opera con contexto consistente
- Existe un **orquestador sdd-orchestrator** coordinando fases o subagentes
- Y el entorno ya sigue las convenciones del entorno tecnológico de Gentle AI

Si quieres la mejor experiencia: [Gentle AI Repository](https://github.com/Gentleman-Programming/gentle-ai)

---

## Agradecimientos

Este proyecto utiliza herramientas y referentes que han contribuido a su desarrollo:

- **[Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)**: Por el entorno de trabajo, la filosofía de desarrollo y las herramientas que permitieron revisar, corregir y refinar este repositorio.
- **[mattpocock/skills](https://github.com/mattpocock/skills)**: Por servir como referencia e inspiración para varias habilidades adaptadas a este ecosistema, especialmente en utilidades tácticas de arquitectura, diagnóstico y flujo de trabajo.
- **Supabase**: Por sus habilidades oficiales que extienden las capacidades de este repositorio.
- **Firebase**: Por sus habilidades oficiales que cubren casos de uso específicos en la plataforma.
- **Equipo de opencode**: Por la plataforma que hace posible la ejecución de estas habilidades.

Este repositorio es un esfuerzo personal y no cuenta con patrocinio oficial de ninguna de las herramientas mencionadas. Las menciones se realizan únicamente para referencia técnica y reconocimiento de uso.

---

**Autor**: [KkapsCa](https://github.com/KapsCa)
