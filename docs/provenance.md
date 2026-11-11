# Procedencia y licencias

Este repositorio es MIT. Eso cubre lo que escribimos nosotros, no lo que tomamos
de otros. Este documento dice, skill por skill, de dónde sale cada cosa y bajo qué
licencia viaja.

## Las skills de este repositorio

| Skill | Origen | Licencia |
|---|---|---|
| `brainstorm` | propia | MIT |
| `product-discovery` | propia | MIT |
| `project-init` | propia | MIT |
| `tech-feasibility` | propia | MIT |
| `dev-skills/repo-bootstrap` | propia | MIT |
| `dev-skills/repo-guardrails` | propia | MIT |
| `dev-skills/clarify-with-artifacts` | propia | MIT |
| `dev-skills/diagnose` | propia | MIT |
| `dev-skills/zoom-out` | propia | MIT |
| `dev-skills/improve-codebase-architecture` | propia | MIT |
| `dev-skills/tasks-to-issues` | propia | MIT |
| `dev-skills/security-audit` | **derivada** | MIT (ver abajo) |

### `security-audit`: obra derivada

Sale de dos proyectos, los dos MIT:

- **`cdmx-in/security-review`** — © 2026 Codemax IT Solutions Pvt. Ltd.
- **`anthropics/claude-code-security-review`** — © 2025 Anthropic

MIT permite usar, copiar, modificar, publicar, distribuir y sublicenciar, incluso
comercialmente. La condición es una sola: **el aviso de copyright y el texto de la
licencia tienen que viajar con las copias**. Por eso `dev-skills/security-audit/`
lleva su propio `LICENSE` con los dos textos completos, y el `SKILL.md` declara
`upstream` y `upstream-triage` en el frontmatter.

MIT no transfiere autoría: las partes originales siguen siendo de Codemax y de
Anthropic. Lo que sí es nuestro es el delta — la Fase 11 (cada hallazgo testeable
se gradúa a test invariante), el `[OVERRIDE]` contra la regla de falsos positivos
de Anthropic, y la adaptación al formato de Pi.

Ninguno de los dos upstreams mantiene ni respalda esta adaptación. Los defectos se
reportan acá.

## Lo que NO está acá, a propósito

Estas skills se instalan desde su propio upstream. Este repositorio las **nombra**,
no las copia: una copia se desincroniza y convierte el repo en un espejo.

| Familia | Upstream | Autor |
|---|---|---|
| `gentle-ai-*` (14 skills) | `Gentleman-Programming/gentle-ai` | Alan Buscaglia |
| `supabase`, `supabase-postgres-best-practices` | `supabase/agent-skills` | Supabase |
| `firebase-*` (10 skills), `developing-genkit-*` (4) | `firebase/agent-skills` | Firebase |
| `frontend-design` | `anthropics/skills` | Anthropic |

Esas son de otros. Publicarlas desde acá sería redistribuirlas con nuestro nombre
arriba, y además se desactualizan solas.

## Cómo se instala lo que no es de este repositorio

`gentle-ai` instala y actualiza su propio ecosistema. Para el resto, seguí el
`README.md` del upstream. El índice vivo de lo que tenés instalado en una máquina
lo mantiene el lock de tu agente, no este archivo.
