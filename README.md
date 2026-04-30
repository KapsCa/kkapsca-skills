# KkapsCa Skills

> Skills públicas para pasar de una idea a un producto y de un producto a una implementación técnica con criterio en un servicio de edición **AI-first**.

[![GitHub repo](https://img.shields.io/badge/GitHub-KkapsCa%2Fkkapsca--skills-blue?logo=github)](https://github.com/KapsCa/kkapsca-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Follow Gentle AI](https://img.shields.io/badge/Follow-Gentle%20AI-purple?logo=github)](https://github.com/Gentleman-Programming/gentle-ai)

Este repositorio reúne skills pensadas desde la experiencia personal de **KkapsCa**, optimizadas para flujos de trabajo asistidos por IA (como Cursor, Windsurf o **opencode**) y redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

Al mismo tiempo, estas skills están **optimizadas para trabajar especialmente bien dentro del stack de [Gentle AI](https://github.com/Gentleman-Programming/gentle-ai)** y flujos coordinados por **`sdd-orchestrator`**.

---

## Quickstart

Si quieres usar estas skills en tu máquina local con **opencode**:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El bootstrap se corre desde **este repo de skills**, no desde la carpeta de tu proyecto futuro. Reinicia opencode después de ejecutarlo.

Para detalles operativos de instalación (opciones `--copy`, symlinks, skills externas), consulta la [guía de instalación](docs/installation.md).

---

## Pipeline Recomendado

```text
Idea → brainstorm → product-discovery → project-init → tech-feasibility → repo-bootstrap → Desarrollo
```

**Ruta ligera** (side projects / proyectos personales):
```text
Idea → brainstorm → product-discovery → tech-feasibility → repo-bootstrap → Desarrollo
```

¿Por dónde entrar?
- Idea vaga → **brainstorm**
- Ya tienes problema + usuario + MVP → **product-discovery**
- Tienes Discovery Report → **project-init** o directo a **tech-feasibility**
- Ya tienes claridad técnica → usa una **dev-skill**

> La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no has hecho**.

---

## Skills Disponibles

### 1. Inicio de proyecto (brainstorm → discovery → factibilidad)

| Skill | Propósito |
|-------|-----------|
| **brainstorm** | Convierte una idea vaga en un Product Brief |
| **product-discovery** | Valida mercado, usuario, competencia y negocio |
| **project-init** | Cierra la brecha entre discovery y factibilidad |
| **tech-feasibility** | Evalúa stack, riesgos, arquitectura y esfuerzo |

### 2. Desarrollo y estándares

| Skill | Propósito |
|-------|-----------|
| **dev-skills/flutter-personal-standards** | Criterio personal para Flutter |
| **dev-skills/repo-bootstrap** | Prepara el repositorio: PR workflow, release-please, estándares |

### 3. Skills especializadas (requieren stack confirmado)

Las skills de **Supabase**, **Firebase** y **Genkit** se activan tras decidir el stack en `tech-feasibility`. Deben instalarse vía bootstrap para que opencode las detecte.

Consulta el [registro de skills](.atl/skill-registry.md) para detalles de orquestación, o la [guía de instalación](docs/installation.md) para disponibilidad real.

---

## Para quién sirve

- Developers que arrancan proyectos desde cero
- Founders técnicos
- Builders indie
- Estudiantes que quieren aprender a pensar antes de programar
- Equipos pequeños que necesitan estructura sin burocracia absurda

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
| Engram vs Bootstrap vs Skill-Registry | [docs/engram.md](docs/engram.md) |
| Flujo de contribución y branch protection | [docs/governance.md](docs/governance.md) |
| Versionado semántico y release-please | [docs/release-please.md](docs/release-please.md) |
| Configuración WSL para Windows | [docs/wsl-setup.md](docs/wsl-setup.md) |
| Índice de documentación | [docs/README.md](docs/README.md) |

---

## Mejor Experiencia de Uso

Estas skills dan mejores resultados cuando:
- El agente opera con contexto consistente
- Existe un `sdd-orchestrator` coordinando fases o subagentes
- Y el entorno ya sigue las convenciones del stack de Gentle AI

Si quieres la mejor experiencia: [Gentle AI Repository](https://github.com/Gentleman-Programming/gentle-ai)

---

## Agradecimientos

Gracias a [Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) por la herramienta que permitió revisar, corregir y refinar este repositorio.

---

**Autor**: [KkapsCa](https://github.com/KapsCa)
