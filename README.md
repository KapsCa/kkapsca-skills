# KkapsCa Skills

> Habilidades (**Skills**) públicas para pasar de una idea a un producto y de un producto a una implementación técnica con criterio en un servicio de edición **IA-first**.

[![GitHub repo](https://img.shields.io/badge/GitHub-KkapsCa%2Fkkapsca--skills-blue?logo=github)](https://github.com/KapsCa/kkapsca-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Este repositorio reúne habilidades (**skills**) pensadas desde la experiencia personal de **KkapsCa**, optimizadas para flujos de trabajo asistidos por Inteligencia Artificial (como **Pi** u **opencode**) y redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

---

## Inicio Rápido

Si quieres usar estas habilidades en tu máquina local con **opencode**:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El proceso de inicialización (**bootstrap**) se corre desde **este repositorio de habilidades**, no desde la carpeta de tu proyecto futuro. Reinicia opencode después de ejecutarlo.

Para detalles operativos de instalación (opciones `--copy`, enlaces simbólicos), consulta la [guía de instalación](docs/installation.md).

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

> El **bootstrap del repo** no solo deja las reglas de trabajo (PR, ramas, versionado). Deja también las **seis piezas de seguridad**, listas y corriendo. Ver [Seguridad desde el primer commit](#seguridad-desde-el-primer-commit).

### ¿Por dónde entrar?

- Idea vaga → **brainstorming** (herramienta para aterrizar ideas)
- Ya tienes problema + usuario + MVP → **descubrimiento de producto**
- Tienes Discovery Report → **inicio de proyecto** o directo a **factibilidad técnica**
- Ya tienes claridad técnica → usa una **habilidad de desarrollo**

> La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no has hecho**.

---

## Filosofía

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**

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

Detalle completo en [Baseline de seguridad](docs/security-baseline.md).

---

## Documentación

Para detalles operativos, consulta:

- [Guía de instalación](docs/installation.md) — instalación detallada, bootstrap y opciones
- [Baseline de seguridad](docs/security-baseline.md) — qué chequea cada herramienta, qué cubre por stack y qué queda afuera
- [Índice de documentación](docs/README.md) — dónde encontrar contexto adicional (Gentle AI, ODD, SDD, Engram, contribución)

---

## Mejor Experiencia de Uso

Estas habilidades dan mejores resultados cuando el agente opera con contexto consistente y el entorno ya sigue las convenciones de Gentle AI.

Si quieres la mejor experiencia: [Gentle AI Repository](https://github.com/Gentleman-Programming/gentle-ai)

---

## Agradecimientos

Este proyecto utiliza herramientas y referentes que han contribuido a su desarrollo:

- **[Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)**: Por el entorno de trabajo, la filosofía de desarrollo y las herramientas que permitieron revisar, corregir y refinar este repositorio.
- **[mattpocock/skills](https://github.com/mattpocock/skills)**: Por servir como referencia e inspiración para varias habilidades adaptadas a este ecosistema.
- **Supabase** y **Firebase**: Por sus habilidades oficiales que extienden las capacidades de este repositorio.
- **Equipo de opencode**: Por la plataforma que hace posible la ejecución de estas habilidades.

---

**Autor**: [KkapsCa](https://github.com/KapsCa)
