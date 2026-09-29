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

No hace falta usar el mismo entorno que el autor ni ninguna herramienta en particular: **si tu agente lee skills, podés usar estas**.

---

## Inicio Rápido

### La vía corta: sin clonar, para cualquier agente

```bash
curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh | bash
```

Instala en `~/.agents/skills` (la convención compartida entre agentes). Para elegir otro destino:

```bash
# Ver los agentes conocidos y cuáles existen en tu máquina
curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh | bash -s -- --list

# Un agente conocido: agents · opencode · claude · codex · gemini · copilot · kilo · pi
curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh | bash -s -- --agent claude

# Cualquier otro agente: la ruta donde lee sus skills
curl -fsSL https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.sh | bash -s -- --dir ~/mi-agente/skills
```

> El instalador **baja el repo por su cuenta** (no hace falta `git` ni clonar nada), **no pisa** directorios que no creó este repositorio, y **nunca lee de la entrada estándar**, así que el `| bash` es seguro.

### Si ya clonaste el repo (opencode o Pi)

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

| Destino | Qué recibe | Dónde queda |
|---|---|---|
| **opencode** | Las 12 skills | `~/.config/opencode/skills/` |
| **Pi** | Las 6 de mayor uso: el pipeline y los estándares | `~/.agents/skills/` |

```bash
bash scripts/bootstrap.sh            # ambos destinos
bash scripts/bootstrap.sh --pi-only  # solo el destino de Pi, sin tocar opencode
```

### Cualquier otro agente, a mano

También podés hacerlo sin ningún instalador: una skill es un archivo Markdown. Copiá el `SKILL.md` —o la carpeta entera— de la skill que quieras al directorio donde tu agente lee skills.

Si tu agente lee de un directorio conocido, es el mismo que ya usás para tus otras skills:

| Agente | Directorio |
|---|---|
| Agentes que siguen la convención compartida (incluye Pi) | `~/.agents/skills/` |
| opencode | `~/.config/opencode/skills/` |
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| Copilot | `~/.copilot/skills/` |
| Kilo Code | `~/.config/kilo/skills/` |

> Si tu agente no está en la lista, copiá la carpeta donde lea sus skills: funciona igual, porque el archivo es texto plano.

> **Después de instalar, reiniciá el agente** para que refresque la lista de skills disponibles.

Si un directorio ya existe y no lo creó este repositorio, el bootstrap **no lo pisa**: lo reporta como conflicto y sigue.

**[Guía de instalación →](docs/installation.md)**

---

## Las 12 skills

### El núcleo: el pipeline de producto y los estándares

| Skill | Se activa cuando… |
|---|---|
| [brainstorm](brainstorm/SKILL.md) | tenés una idea y no sabés por dónde empezar |
| [product-discovery](product-discovery/SKILL.md) | querés saber si la necesidad es real, quién la usaría y cómo validarla |
| [project-init](project-init/SKILL.md) | hay que decidir enfoque, secuencia de trabajo y alcance inicial |
| [tech-feasibility](tech-feasibility/SKILL.md) | hay que medir dificultad, riesgos, esfuerzo y elegir stack |
| [repo-bootstrap](dev-skills/repo-bootstrap/SKILL.md) | vas a crear un repositorio nuevo |
| [repo-guardrails](dev-skills/repo-guardrails/SKILL.md) | estás por hacer push, abrir un PR o mergear |

El pipeline de producto va de una idea vaga a un producto definido, **antes** de cualquier decisión de implementación:

```text
Idea → brainstorming → descubrimiento de producto → inicio de proyecto → factibilidad técnica → Desarrollo
```

**Ruta ligera** (proyectos personales o paralelos): `Idea → brainstorming → descubrimiento de producto → factibilidad técnica → Desarrollo`

### Companions: apoyo, por situación

Se cargan cuando el trabajo ya está en marcha. **Ninguna es obligatoria**: si solo querés el pipeline y los estándares, podés ignorarlas todas.

- [clarify-with-artifacts](dev-skills/clarify-with-artifacts/SKILL.md) — hay una idea vaga y ya existen artifacts que la aterrizan
- [diagnose](dev-skills/diagnose/SKILL.md) — hay un bug que no entendés y querés ir de la reproducción a la causa
- [zoom-out](dev-skills/zoom-out/SKILL.md) — vas a editar código que no conocés bien
- [improve-codebase-architecture](dev-skills/improve-codebase-architecture/SKILL.md) — sospechás deuda técnica, acoplamiento o responsabilidades mezcladas
- [tasks-to-issues](dev-skills/tasks-to-issues/SKILL.md) — hay un plan aprobado y querés convertirlo en issues
- [flutter-personal-standards](dev-skills/flutter-personal-standards/SKILL.md) — hay dudas de estructura o arquitectura en Flutter/Dart

> La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no hiciste**.

**[Registro de skills →](docs/skill-registry.md)**

---

## El flujo: ODD por defecto, SDD opcional

**Este repositorio se desarrolla con ODD** (*Organic Driven Development*), un método de **[Alan Buscaglia](https://gentlemanprogramming.com/)** — *Gentleman Programming*, el autor de **Gentle-AI**. Su documentación autoritativa vive en el proyecto de Gentle-AI:

- **[ODD, explicado por su autor →](https://github.com/Gentleman-Programming/gentle-ai/blob/main/docs/usage.md#organic-driven-development-odd)**
- **[gentlemanprogramming.com →](https://gentlemanprogramming.com/)**

**Y estas skills rinden más en un entorno que lo siga**: cuando hay un flujo que rastrea el trabajo, las skills saben dónde vive el plan (`odd/tasks/<feature>.md`) y en qué fase está, sin que se lo expliques cada vez.

**Pero no lo requieren.** Son archivos Markdown: funcionan con el flujo que uses. Donde una skill dice "entrada por defecto: `odd/tasks/<feature>.md`", leelo como *"si seguís ODD, el plan está ahí; si no, es tu plan, donde lo tengas"*. Lo único que cambia sin ODD es que esa ruta la ponés vos.

**SDD** (*Spec-Driven Development*) es una **rama opcional** dentro de ODD: se entra solo por pedido explícito (`/sdd-*`) o por propuesta aceptada, y las skills conviven con él sin reemplazarlo.

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

### Lenguajes soportados

El análisis estático entiende estos lenguajes:

```text
C/C++ · C# · Go · Java/Kotlin · JavaScript/TypeScript · Python · Ruby · Rust · Swift · GitHub Actions
```

**Todo lo que quede fuera de esa lista es un hueco conocido** — incluidos **Dart/Flutter, shell y PowerShell**, donde el análisis corre y no encuentra nada.

Hay más límites además de los lenguajes: la licencia que el detector de secretos necesita en cuentas de organización, que el análisis estático solo funcione en repos públicos, y qué pasa en un repositorio que todavía no tiene código. **Están todos declarados, con su detalle, en el baseline.**

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
| [Guía de instalación](docs/installation.md) | Bootstrap, destinos, cualquier agente, desinstalación |
| [Instalación del ecosistema en WSL2](docs/wsl-setup.md) | Runbook del ecosistema completo bajo WSL2, con el instalador de un solo paso (bash) |
| [Instalación en Windows nativo](docs/windows-native-setup.md) | Reconstruir el ecosistema completo sin WSL (PowerShell) |
| [Registro de skills](docs/skill-registry.md) | Qué skill se activa en qué situación, y quién manda cuando dos se solapan |
| [Contrato de estilo](docs/skill-style-guide.md) | La norma LLM-first a la que se migran las skills |
| [ODD y SDD](docs/sdd.md) | El método que sigue el repo y la rama opcional |
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

Estas habilidades dan su mejor resultado cuando el agente opera con contexto consistente: el badge de arriba lleva al proyecto, y los enlaces están en [el flujo](#el-flujo-odd-por-defecto-sdd-opcional).

---

## Agradecimientos

Este proyecto existe gracias al trabajo de otros:

- **Alan Buscaglia (Gentleman Programming)**: creó **ODD**, el método que este repositorio sigue, y **Gentle-AI**, el entorno con el que se revisó, corrigió y refinó este repositorio. Sus enlaces están más arriba, en [el flujo](#el-flujo-odd-por-defecto-sdd-opcional) y en [la sección del badge](#built-with-gentle-ai).
- **[mattpocock/skills](https://github.com/mattpocock/skills)**: por servir como referencia e inspiración para varias habilidades adaptadas a este ecosistema.
- **Supabase** y **Firebase**: por sus habilidades oficiales que extienden las capacidades de este repositorio.

---

## Filosofía

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**
