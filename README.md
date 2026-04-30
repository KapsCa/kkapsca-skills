# KkapsCa Skills Repository

> Skills públicas para pasar de una idea a un producto y de un producto a una implementación técnica con criterio en un servicio de edición **AI-first**.

Este repositorio reúne skills pensadas desde la experiencia personal de **KkapsCa**, optimizadas para flujos de trabajo asistidos por IA (como Cursor, Windsurf o **opencode**) y redactadas para que **cualquier persona pueda reutilizarlas** en sus propios proyectos.

Al mismo tiempo, estas skills están **optimizadas para trabajar especialmente bien dentro del stack de [Gentle AI](https://github.com/Gentleman-Programming/gentle-ai)** y flujos coordinados por **`sdd-orchestrator`**.

En otras palabras:

- **sí son reutilizables** fuera de ese ecosistema,
- pero su mejor rendimiento aparece cuando se usan como **potenciador del stack de Gentle AI**.

---

## Inicio rápido

Si quieres usar estas skills en tu máquina local con **opencode**, haz esto:

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El bootstrap se corre desde **este repo de skills**, no desde la carpeta de tu proyecto futuro.

### ¿Qué hace el bootstrap?

- Registra cada carpeta que contiene `SKILL.md`
- Instala tanto las skills raíz como las de `dev-skills/`
- Usa `~/.config/opencode/skills` por defecto (configurable vía `OPENCODE_SKILLS_DIR`)
- Crea **symlinks** por defecto (ideal para mantener las skills actualizadas al hacer `git pull`)

Si prefieres una copia física independiente:

```bash
bash scripts/bootstrap.sh --copy
```

> **Nota**: `bash scripts/bootstrap.sh` funciona **siempre**, sin importar si los archivos tienen el bit de ejecución activado.

### Después del bootstrap

1. Reinicia opencode para refrescar la lista de skills disponibles.
2. Prueba una skill explícita, por ejemplo: `Usa la skill brainstorm`.
3. Si todavía no tienes carpeta de proyecto, no pasa nada: puedes empezar con `brainstorm` o `product-discovery` antes de crearla.

> **⚠️ Skills externas**: Las skills de Supabase y Firebase se enrutan desde el registry, pero para que opencode las detecte debes instalarlas vía bootstrap. Los detalles operativos y de entorno están en [docs/engram.md](docs/engram.md).

### ¿Necesito tener ya creada la carpeta del proyecto?

**No para instalar las skills.**

Puedes instalar las skills una sola vez en tu máquina local y luego usarlas para pensar o descubrir ideas aunque todavía no exista la carpeta final del proyecto.

Flujo recomendado:

1. Clona este repo de skills.
2. Ejecuta `bash scripts/bootstrap.sh` una sola vez.
3. Usa `brainstorm` o `product-discovery` para aterrizar la idea.
4. Cuando la idea ya tenga forma, crea la carpeta real del proyecto.
5. Desde esa carpeta sigue con `project-init`, `tech-feasibility` o la skill de desarrollo que aplique.

Ejemplo práctico:

```text
~/dev/kkapsca-skills        -> instalar skills
~/dev/                       -> explorar idea
~/dev/mi-nuevo-proyecto      -> aterrizar e implementar
```

### Desinstalar

```bash
bash scripts/uninstall-opencode-skills.sh
```

### Requisito de entorno (Windows)

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** para mantener un entorno más consistente con Linux. Ver detalles en [docs/wsl-setup.md](docs/wsl-setup.md).

---

## Enrutamiento de Skills por Stack

Este repositorio usa `.atl/skill-registry.md` para definir **orquestación lógica** (qué skill activar según el contexto), pero **no instala skills automáticamente**.

### Cuándo se activa cada skill de Supabase

| Skill | Cuándo se activa | Requiere stack confirmado |
|-------|------------------|---------------------------|
| `supabase` | Tras decidir Supabase en `tech-feasibility`; fases de diseño/implementación | ✅ Sí (tech-feasibility) |
| `supabase-postgres-best-practices` | En fases de diseño/apply con trabajo SQL, RLS, migrations o esquema Postgres | ✅ Sí + contexto técnico específico |
| `skill-creator` | Solo referencia documental; NO participa en routing normal | ❌ No |

> **Importante**: El registry define cuándo activar cada skill, pero esto es **orquestación lógica**. Para que opencode realmente detecte las skills, deben estar instaladas en `~/.config/opencode/skills/`.

### Cuándo se activa cada skill de Firebase

| Skill | Cuándo se activa | Requiere stack confirmado |
|-------|------------------|---------------------------|
| `firebase-basics` | Tras decidir Firebase en `tech-feasibility` o setup de proyecto Firebase | ✅ Sí (tech-feasibility) |
| `firebase-auth-basics` | Con trabajo específico de Auth/sign-in/providers/tokens | ✅ Sí + contexto técnico |
| `firebase-firestore-standard` | Con trabajo de Firestore Standard (queries, índices, SDK, reglas) | ✅ Sí + contexto técnico |
| `firebase-firestore-enterprise-native-mode` | SOLO si Enterprise Native Mode está explícito | ✅ Sí + confirmación Enterprise |
| `firebase-hosting-basics` | Para hosting clásico estático/SPA sin SSR | ✅ Sí + contexto de hosting |
| `firebase-app-hosting-basics` | Para Next.js/Angular/SSR/App Hosting explícito | ✅ Sí + contexto de SSR/App |
| `firebase-security-rules-auditor` | Para revisar/endurecer Security Rules | ✅ Sí + reglas concretas |
| `firebase-data-connect` | Para Data Connect/SQL Connect/GraphQL/Postgres | ✅ Sí + contexto SQL/GraphQL |
| `firebase-ai-logic-basics` | Para Firebase AI Logic/Gemini desde cliente | ✅ Sí + contexto de IA |
| `developing-genkit-js` | Para Genkit en JS/TS | ✅ Sí + stack JS/TS |
| `skill-creator` | Solo referencia documental; NO participa en routing normal | ❌ No |

> **Importante**: No activar skills Firebase solo por mencionar Firebase. Cada skill requiere contexto técnico específico o confirmación de stack. El registry define orquestación lógica, no garantiza disponibilidad real.

### Separación: Pipeline vs Disponibilidad Real

```
Pipeline/Registry (lógico)  →  Define CUÁNDO activar skills
        ↓
Bootstrap/Scripts (físico)  →  Hace que opencode DETECTE las skills
```

- **Pipeline/Registry**: `.atl/skill-registry.md` dice "activa `supabase` tras decidir el stack en tech-feasibility"
- **Bootstrap**: `scripts/install-opencode-skills.sh` instala skills del repo a `~/.config/opencode/skills/`
- **Brecha actual**: Las skills externas requieren bootstrap + reinicio de opencode para quedar disponibles. Si usas una fuente distinta a la predeterminada, `EXTERNAL_SKILLS_DIR` actúa como override.

---

## Qué incluye

### 1. Skills de inicio de proyecto (brainstorm → discovery → factibilidad)

Sirven para aterrizar una idea antes de construir.

| Skill | Propósito |
|-------|-----------|
| **brainstorm** | Convierte una idea vaga en un Product Brief |
| **product-discovery** | Valida mercado, usuario, competencia y negocio |
| **project-init** | Cierra la brecha entre discovery y factibilidad (opcional por bypass) |
| **tech-feasibility** | Evalúa stack, riesgos, arquitectura y esfuerzo |

### 2. Skills de desarrollo

Sirven cuando el proyecto ya tiene claridad suficiente y toca implementar.

| Skill | Propósito |
|-------|-----------|
| **dev-skills/flutter-personal-standards** | Criterio personal para Flutter y puente hacia las skills oficiales |
| **dev-skills/repo-bootstrap** | Prepara el repositorio: PR workflow, hook local, release-please y estándares base |

### 3. Skills futuras posibles

backend, arquitectura, testing, bases de datos, automatización.

---

## Flujo recomendado

### Pipeline ideal para un proyecto nuevo

```text
Idea → brainstorm → product-discovery → project-init → tech-feasibility → repo-bootstrap → Desarrollo
```

### Ruta ligera (bypass de project-init)

```text
Idea → brainstorm → product-discovery → tech-feasibility → repo-bootstrap → Desarrollo
```

**Condiciones para bypass de project-init**:
- Proyecto personal con alcance muy pequeño (1-2 features)
- El usuario es el único interesado y decisor
- No hay restricciones regulatorias ni organizacionales
- tech-feasibility puede funcionar con Discovery Report directo

### Cómo elegir tu punto de entrada

Este repositorio **no es dogmático**. Si ya tienes trabajo previo real, puedes entrar más adelante en el pipeline.

- Si solo tienes una idea vaga → empieza en **brainstorm**
- Si ya tienes claro problema, usuario y MVP → puedes entrar en **product-discovery**
- Si ya tienes Discovery Report completo y quieres cerrar brecha → usa **project-init** (recomendado)
- Si ya tienes claridad funcional y solo falta tech → entra en **tech-feasibility**
- Si ya tienes claridad funcional y técnica → usa una **dev-skill**
- Si ya estás en etapa de implementación → ve directo a `dev-skills/` y usa la skill que corresponda al stack

La regla no es "seguir pasos porque sí". La regla es **no saltarte el pensamiento que todavía no has hecho**.

---

## Para quién sirve

Este repo puede servirle a:

- developers que arrancan proyectos desde cero
- founders técnicos
- builders indie
- estudiantes que quieren aprender a pensar antes de programar
- equipos pequeños que necesitan estructura sin caer en burocracia absurda

---

## Mejor experiencia de uso

Estas skills están pensadas para ser útiles por sí solas, pero fueron afinadas para que den mejores resultados cuando:

- el agente opera con contexto consistente
- existe un `sdd-orchestrator` coordinando fases o subagentes
- y el entorno ya sigue las convenciones del stack de Gentle AI

Si quieres la mejor experiencia de instalación, ejecución y contexto compartido, ve al repo de **Gentle AI** y sigue su guía:

- https://github.com/Gentleman-Programming/gentle-ai

La idea correcta no es vender estas skills como piezas aisladas mágicas, sino como un **potenciador del stack** para lograr mejor ejecución, menos ambigüedad y mejores resultados con agentes IA.

---

## Referencia operativa

Para detalles sobre configuración, gobernanza y contexto técnico, consulta la documentación en `docs/`:

| Tema | Documento |
|------|-----------|
| Contexto Gentle AI y relación con este repo | [docs/gentle-ai.md](docs/gentle-ai.md) |
| Engram vs Bootstrap vs Skill-Registry | [docs/engram.md](docs/engram.md) |
| Configuración WSL para Windows | [docs/wsl-setup.md](docs/wsl-setup.md) |
| Flujo de contribución, branch protection y Conventional Commits | [docs/governance.md](docs/governance.md) |
| Versionado semántico y release-please | [docs/release-please.md](docs/release-please.md) |
| Índice de documentación de soporte | [docs/README.md](docs/README.md) |

---

## Filosofía

- **Problema primero, tecnología después**
- **La arquitectura debe ser proporcional al proyecto**
- **La validación barata vale más que el código caro**
- **Aprender fundamentos siempre gana a memorizar frameworks**
- **La IA ayuda, pero no reemplaza criterio técnico**

No corras al código sin entender el problema. No elijas tecnologías por moda. No metas complejidad antes de tiempo. Construye con fundamentos, no con ocurrencias.

---

## Agradecimientos

Gracias a [Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai).

Usando esa herramienta fue posible revisar, corregir y refinar este repositorio mientras también se fortalecía el proceso de aprendizaje técnico y programación con mejores fundamentos.

---

## Autor

**KkapsCa**

GitHub: https://github.com/KapsCa/kkapsca-skills
