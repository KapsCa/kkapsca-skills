# Instalación Detallada — KkapsCa Skills

Este documento cubre el detalle operativo de instalación de las skills en tu entorno local.

## Inicio Rápido

```bash
git clone https://github.com/KapsCa/kkapsca-skills.git
cd kkapsca-skills
bash scripts/bootstrap.sh
```

> **Nota**: El bootstrap se corre desde **este repo de skills**, no desde la carpeta de tu proyecto futuro.

### Después del bootstrap

1. Reinicia opencode para refrescar la lista de skills disponibles.
2. Prueba una skill explícita, por ejemplo: `Usa la skill brainstorm`.
3. Si todavía no tienes carpeta de proyecto, no pasa nada: puedes empezar con `brainstorm` o `product-discovery` antes de crearla.

---

## ¿Qué hace el bootstrap?

- Registra cada carpeta que contiene `SKILL.md`
- Instala tanto las skills raíz como las de `dev-skills/`
- Usa `~/.config/opencode/skills` por defecto (configurable vía `OPENCODE_SKILLS_DIR`)
- Crea **symlinks** por defecto (ideal para mantener las skills actualizadas al hacer `git pull`)

### Opciones de instalación

**Symlinks (por defecto)**:
```bash
bash scripts/bootstrap.sh
```
Ventaja: al hacer `git pull` en el repo de skills, los cambios se reflejan automáticamente.

**Copia física independiente**:
```bash
bash scripts/bootstrap.sh --copy
```
Ventaja: las skills son independientes del repo original.

> **Nota**: `bash scripts/bootstrap.sh` funciona **siempre**, sin importar si los archivos tienen el bit de ejecución activado.

---

## Skills Externas (Supabase, Firebase, Genkit)

Las skills de Supabase y Firebase residen en una carpeta externa (por defecto `~/.agents/skills/`). El bootstrap las procesa automáticamente:

```bash
# El bootstrap toma por defecto ~/.agents/skills como fuente externa
bash scripts/bootstrap.sh
```

### Rutas configurables

| Variable | Valor por defecto | Propósito |
|----------|-------------------|-----------|
| `OPENCODE_SKILLS_DIR` | `~/.config/opencode/skills` | Dónde se instalan las skills |
| `EXTERNAL_SKILLS_DIR` | `~/.agents/skills` | Fuente de skills externas |

---

## Desinstalación

```bash
bash scripts/uninstall-opencode-skills.sh
```

---

## ¿Necesito tener ya creada la carpeta del proyecto?

**No para instalar las skills.**

Puedes instalar las skills una sola vez en tu máquina local y luego usarlas para pensar o descubrir ideas aunque todavía no exista la carpeta final del proyecto.

### Flujo recomendado

1. Clona este repo de skills.
2. Ejecuta `bash scripts/bootstrap.sh` una sola vez.
3. Usa `brainstorm` o `product-discovery` para aterrizar la idea.
4. Cuando la idea ya tenga forma, crea la carpeta real del proyecto.
5. Desde esa carpeta sigue con `project-init`, `tech-feasibility` o la skill de desarrollo que aplique.

### Ejemplo práctico

```text
~/dev/kkapsca-skills        -> instalar skills
~/dev/                       -> explorar idea
~/dev/mi-nuevo-proyecto      -> aterrizar e implementar
```

---

## Requisito de entorno (Windows)

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** para mantener un entorno más consistente con Linux. Ver detalles en [docs/wsl-setup.md](wsl-setup.md).

---

## Enrutamiento de Skills por Stack

Este repositorio usa `.atl/skill-registry.md` para definir **orquestación lógica** (qué skill activar según el contexto), pero **no instala skills automáticamente**.

### Cuándo se activa cada skill de Supabase

| Skill | Cuándo se activa | Requiere stack confirmado |
|-------|------------------|---------------------------|
| `supabase` | Tras decidir Supabase en `tech-feasibility`; fases de diseño/implementación | ✅ Sí |
| `supabase-postgres-best-practices` | En fases de diseño/apply con trabajo SQL, RLS, migrations o esquema Postgres | ✅ Sí + contexto técnico |
| `skill-creator` | Solo referencia documental; NO participa en routing normal | ❌ No |

### Cuándo se activa cada skill de Firebase

| Skill | Cuándo se activa | Requiere stack confirmado |
|-------|------------------|---------------------------|
| `firebase-basics` | Tras decidir Firebase en `tech-feasibility` o setup de proyecto Firebase | ✅ Sí |
| `firebase-auth-basics` | Con trabajo específico de Auth/sign-in/providers/tokens | ✅ Sí + contexto técnico |
| `firebase-firestore-standard` | Con trabajo de Firestore Standard (queries, índices, SDK, reglas) | ✅ Sí + contexto técnico |
| `firebase-firestore-enterprise-native-mode` | SOLO si Enterprise Native Mode está explícito | ✅ Sí + confirmación Enterprise |
| `firebase-hosting-basics` | Para hosting clásico estático/SPA sin SSR | ✅ Sí + contexto de hosting |
| `firebase-app-hosting-basics` | Para Next.js/Angular/SSR/App Hosting explícito | ✅ Sí + contexto de SSR/App |
| `firebase-security-rules-auditor` | Para revisar/endurecer Security Rules | ✅ Sí + reglas concretas |
| `firebase-data-connect` | Para Data Connect/SQL Connect/GraphQL/Postgres | ✅ Sí + contexto SQL/GraphQL |
| `firebase-ai-logic-basics` | Para Firebase AI Logic/Gemini desde cliente | ✅ Sí + contexto de IA |
| `developing-genkit-js` | Para Genkit en JS/TS | ✅ Sí + stack JS/TS |

> **Importante**: No activar skills Firebase solo por mencionar Firebase. Cada skill requiere contexto técnico específico o confirmación de stack.

### Separación: Pipeline vs Disponibilidad Real

```
Pipeline/Registry (lógico)  →  Define CUÁNDO activar skills
         ↓
Bootstrap/Scripts (físico)  →  Hace que opencode DETECTE las skills
```

- **Pipeline/Registry**: `.atl/skill-registry.md` dice "activa `supabase` tras decidir el stack en tech-feasibility"
- **Bootstrap**: `scripts/install-opencode-skills.sh` instala skills del repo a `~/.config/opencode/skills/`
- **Brecha actual**: Las skills externas requieren bootstrap + reinicio de opencode para quedar disponibles

---

## Referencias

- [Gentle AI Repository](https://github.com/Gentleman-Programming/gentle-ai) — Contexto del stack y mejor experiencia de uso
- [docs/engram.md](engram.md) — Diferencia entre memoria persistente, bootstrap y skill-registry
- [.atl/skill-registry.md](../.atl/skill-registry.md) — Catálogo completo de skills y triggers
