# Instalación Detallada — KkapsCa Skills

Este documento cubre el detalle operativo de instalación de las habilidades (**skills**) en tu entorno local usando el sistema **Skills.sh**.

## Inicio Rápido

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El proceso de inicialización (**bootstrap**) se corre desde **este repositorio de habilidades**, no desde la carpeta de tu proyecto futuro.

### Después del bootstrap

1. Reinicia opencode para refrescar la lista de habilidades disponibles.
2. Prueba una habilidad explícita, por ejemplo: `Usa la habilidad brainstorm`.
3. Si todavía no tienes carpeta de proyecto, no pasa nada: puedes empezar con `brainstorm` o `product-discovery` antes de crearla.

---

## ¿Qué hace el bootstrap?

- Registra cada carpeta que contiene `SKILL.md`
- Instala tanto las habilidades raíz como las de `dev-skills/`
- Usa `~/.config/opencode/skills` por defecto (configurable vía `OPENCODE_SKILLS_DIR`)
- Crea **enlaces simbólicos** por defecto (ideal para mantener las habilidades actualizadas al hacer `git pull`)

### Opciones de instalación

**Enlaces simbólicos (por defecto)**:
```bash
bash scripts/bootstrap.sh
```
Ventaja: al hacer `git pull` en el repositorio de habilidades, los cambios se reflejan automáticamente.

**Copia física independiente**:
```bash
bash scripts/bootstrap.sh --copy
```
Ventaja: las habilidades son independientes del repositorio original.

> **Nota**: `bash scripts/bootstrap.sh` funciona **siempre**, sin importar si los archivos tienen el bit de ejecución activado.

---

## Habilidades Externas (Supabase y Firebase)

Las habilidades de **Supabase** y **Firebase** provienen de las habilidades oficiales creadas por las respectivas plataformas. En este repositorio se integran para usarlas bajo el flujo de **Skills.sh**. Residen en una carpeta externa (por defecto `~/.agents/skills/`). El bootstrap las procesa automáticamente:

```bash
# El bootstrap toma por defecto ~/.agents/skills como fuente externa
bash scripts/bootstrap.sh
```

### Origen de las habilidades oficiales

| Plataforma | Habilidad | Origen Oficial |
|------------|-----------|----------------|
| **Supabase** | `supabase`, `supabase-postgres-best-practices` | Habilidades oficiales de Supabase adaptadas para el flujo de Skills.sh |
| **Firebase** | `firebase-*` (10 habilidades) | Habilidades oficiales de Firebase adaptadas para el flujo de Skills.sh |

### Rutas configurables

| Variable | Valor por defecto | Propósito |
|----------|-------------------|-----------|
| `OPENCODE_SKILLS_DIR` | `~/.config/opencode/skills` | Dónde se instalan las habilidades |
| `EXTERNAL_SKILLS_DIR` | `~/.agents/skills` | Fuente de habilidades externas |

---

## Desinstalación

```bash
bash scripts/uninstall-opencode-skills.sh
```

---

## ¿Necesito tener ya creada la carpeta del proyecto?

**No para instalar las habilidades.**

Puedes instalar las habilidades una sola vez en tu máquina local y luego usarlas para pensar o descubrir ideas aunque todavía no exista la carpeta final del proyecto.

### Flujo recomendado

1. Clona este repositorio de habilidades.
2. Ejecuta `bash scripts/bootstrap.sh` una sola vez.
3. Usa `brainstorm` o `product-discovery` para aterrizar la idea.
4. Cuando la idea ya tenga forma, crea la carpeta real del proyecto.
5. Desde esa carpeta sigue con `project-init`, `tech-feasibility` o la habilidad de desarrollo que aplique.

### Ejemplo práctico

```text
~/dev/kkapsca-skills        -> instalar habilidades
~/dev/                       -> explorar idea
~/dev/mi-nuevo-proyecto      -> aterrizar e implementar
```

---

## Requisito de entorno (Windows)

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** para mantener un entorno más consistente con Linux. Ver detalles en [docs/wsl-setup.md](wsl-setup.md).

---

## Enrutamiento de Habilidades por Stack

Este repositorio usa un registro interno de habilidades para definir **orquestación lógica** (qué habilidad activar según el contexto), pero **no instala habilidades automáticamente**.

### Cuándo se activa cada habilidad de Supabase

| Habilidad | Cuándo se activa | Requiere stack confirmado |
|-----------|------------------|---------------------------|
| `supabase` | Tras decidir Supabase en `tech-feasibility`; fases de diseño/implementación | ✅ Sí |
| `supabase-postgres-best-practices` | En fases de diseño/apply con trabajo SQL, RLS, migrations o esquema Postgres | ✅ Sí + contexto técnico |
| `skill-creator` | Solo referencia documental; NO participa en routing normal | ❌ No |

### Cuándo se activa cada habilidad de Firebase

| Habilidad | Cuándo se activa | Requiere stack confirmado |
|-----------|------------------|---------------------------|
| `firebase-basics` | Tras decidir Firebase en `tech-feasibility` o setup de proyecto Firebase | ✅ Sí |
| `firebase-auth-basics` | Con trabajo específico de Auth/sign-in/providers/tokens | ✅ Sí + contexto técnico |
| `firebase-firestore-standard` | Con trabajo de Firestore Standard (queries, índices, SDK, reglas) | ✅ Sí + contexto técnico |
| `firebase-firestore-enterprise-native-mode` | SOLO si Enterprise Native Mode está explícito | ✅ Sí + confirmación Enterprise |
| `firebase-hosting-basics` | Para hosting clásico estático/SPA sin SSR | ✅ Sí + contexto de hosting |
| `firebase-app-hosting-basics` | Para Next.js/Angular/SSR/App Hosting explícito | ✅ Sí + contexto de SSR/App |
| `firebase-security-rules-auditor` | Para revisar/endurecer Security Rules | ✅ Sí + reglas concretas |
| `firebase-data-connect` | Para Data Connect/SQL Connect/GraphQL/Postgres | ✅ Sí + contexto SQL/GraphQL |
| `firebase-ai-logic-basics` | Para Firebase AI Logic/Gemini desde cliente | ✅ Sí + contexto de IA |

> **Importante**: No activar habilidades Firebase solo por mencionar Firebase. Cada habilidad requiere contexto técnico específico o confirmación de stack.

### Separación: Pipeline vs Disponibilidad Real

```
Pipeline/Registry (lógico)  →  Define CUÁNDO activar habilidades
         ↓
Bootstrap/Scripts (físico)  →  Hace que opencode DETECTE las habilidades
```

- **Pipeline/Registry**: la orquestación interna decide cuándo activar una habilidad tras confirmar el stack en `tech-feasibility`
- **Bootstrap**: `scripts/install-opencode-skills.sh` instala habilidades del repo a `~/.config/opencode/skills/`
- **Brecha actual**: Las habilidades externas requieren bootstrap + reinicio de opencode para quedar disponibles

### Candidatas Externas (Non-Routable)

Las habilidades candidatas documentadas en el `.atl/skill-registry.md` bajo `## External Adaptation Gate` (como `agent-governance` o `agentic-eval`) **no son instalables ni enrutableables** en este release.

- **Solo las carpetas físicas** que contienen un archivo `SKILL.md` y son procesadas por el `bootstrap` quedan disponibles para opencode.
- Las entradas en el registry bajo `## External Adaptation Gate` son **lógicas únicamente** y no activan routing ni instalación.
- Para que una candidata sea instalable, debe cumplir con los criterios de entrada futura (tener un `SKILL.md` nativo, scope único, etc.) y migrar a `## User Skills` en el registry.

#### Ownership Deny-List (reiteración mínima)
Consulte `.atl/skill-registry.md` → `## External Adaptation Gate` → `### Ownership Deny-List` para el detalle oficial. En resumen:
- `agent-governance` **no compite** con `repo-bootstrap`, `branch-pr`, `issue-creation` (ownership fuera de alcance).
- `agentic-eval` **no compite** con `sdd-verify` (ownership fuera de alcance).

#### Nota de alcance (isolation disclaimer)
El cambio `adapt-awesome-copilot-skills-to-our-flow` modifica **únicamente** `.atl/skill-registry.md`, `README.md` y `docs/installation.md`. Cualquier otro diff presente en la rama (por ejemplo, `.github/workflows/release-please.yml`) pertenece a cambios independientes y **no forma parte del scope** de esta adaptación.

---

## Referencias

- [Gentle AI Repository](https://github.com/Gentleman-Programming/gentle-ai) — Contexto del stack y mejor experiencia de uso
- [docs/engram.md](engram.md) — Diferencia entre memoria persistente, bootstrap y skill-registry
- [docs/sdd.md](sdd.md) — Desarrollo Guiado por Especificaciones (SDD) y sdd-orchestrator
