# Contrato de estilo para skills (LLM-first)

Este repositorio adopta este contrato. Sus 12 skills se migran a él de forma **progresiva**: hasta que la migración termine, este documento es la norma a aplicar, no un reporte de cumplimiento.

Una skill es un **contrato de instrucciones de runtime para un LLM**, no documentación para humanos: le dice al modelo cuándo activarse, qué reglas son innegociables, cómo decidir, qué hacer y qué devolver.

## Estructura obligatoria

Todo `SKILL.md` DEBE usar este orden, salvo que una sección sea realmente irrelevante:

1. **Frontmatter** — metadatos completos para descubrimiento de skills.
2. **Activation Contract** — situaciones exactas que cargan la skill.
3. **Hard Rules** — restricciones que el LLM NO debe violar.
4. **Decision Gates** — tablas o bullets cortos para decisiones de bifurcación.
5. **Execution Steps** — flujo operacional ordenado.
6. **Output Contract** — formato o artifacts requeridos al final.
7. **References** — archivos locales solamente; el detalle vive fuera de la skill.

`## Compact Rules` no es requerida. El registry indexa nombres, triggers, scope y paths de las skills; los agentes cargan el `SKILL.md` completo como fuente de verdad.

## Reglas de frontmatter

- `description` DEBE ser una sola línea física, YAML-safe y entre comillas.
- Palabras de trigger primero: `"Trigger: ... . {Qué hace la skill}."`
- `description` DEBERÍA tener <=160 caracteres y DEBE tener <=250.
- Incluir completo `name`, `description`, `license`, `metadata.author` y `metadata.version`.
- NO agregar una sección `Keywords`; el descubrimiento usa el frontmatter.

## Presupuesto del cuerpo

- Objetivo: **180–450 tokens** para el cuerpo de la skill.
- Máximo recomendado: **700 tokens**.
- Máximo duro: **1000 tokens**. Mover ejemplos, schemas y contexto a `assets/` o `references/`.

## Reglas de escritura

### HACER

- Escribir instrucciones de runtime en imperativo: "Carga X", "Chequea Y", "Devuelve Z".
- Abrir con el trigger de activación y las restricciones duras.
- Usar tablas compactas para los decision gates.
- Mantener los ejemplos mínimos y ejecutables.
- Enlazar a archivos locales de soporte para el detalle.

### NO HACER

- Explicar historia, motivación o tutorial de fondo.
- Duplicar docs largas dentro de la skill.
- Agregar consejo genérico que el LLM no pueda ejecutar.
- Usar URLs externas como referencias primarias.
- Esconder reglas críticas debajo de ejemplos.

## Archivos de soporte

- Usar `assets/` para plantillas, schemas, fixtures o ejemplos generados.
- Usar `references/` para docs locales que explican conceptos o edge cases.
- Mantener las referencias estables y relativas al directorio de la skill cuando sea posible.

## Comportamiento del registry

- El routing registry de este repositorio vive en `docs/skill-registry.md`. NO usar `.atl/skill-registry.md`: ese archivo lo regenera gentle-pi y no es fuente de verdad.
- Pi lee las skills de usuario desde `~/.agents/skills`; opencode lee desde `~/.config/opencode/skills`.
- `gentle-ai skill-registry refresh` indexa skills; no las resume ni reescribe.
- El registry registra `name`, el texto de trigger de `description`, scope y el path exacto del `SKILL.md`.
- Los delegadores pasan los paths coincidentes a los subagents, y los subagents leen la skill completa antes de trabajar.
- Usar `skill-improver` para auditar y refactorizar skills existentes contra esta guía.

## Quality Gates

- Frontmatter completo, entre comillas, de una sola línea y que preserva los triggers.
- Las secciones requeridas existen en el orden esperado.
- Las hard rules son testeables u observables.
- Los decision gates cubren solo bifurcaciones con sentido.
- El output contract le dice al LLM exactamente qué devolver.
- Las references apuntan a archivos locales.

## Checklist de refactor

- [ ] Mover la prosa explicativa a references locales.
- [ ] Colapsar reglas repetidas en una sola hard rule.
- [ ] Reemplazar bifurcaciones en prosa por una tabla de decisión.
- [ ] Recortar los ejemplos al caso útil mínimo.
- [ ] Revisar el largo de `description` y las palabras de trigger.
