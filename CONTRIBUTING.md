# Cómo contribuir

Gracias por el interés. Este repositorio es un set de skills para agentes de código: archivos
Markdown que le enseñan a un agente cuándo activarse y cómo trabajar. El flujo de contribución
es pequeño y tiene frenos a propósito — este repo es público y se lo toma en serio lo que entra.

## Antes de abrir nada

- **¿Tenés una pregunta?** No abras un issue: usá
  [Discussions](https://github.com/KapsCa/kkapsca-skills/discussions).
- **¿Encontraste un bug o querés proponer una mejora?** Usá los templates:
  [bug report](.github/ISSUE_TEMPLATE/bug_report.yml) o
  [feature request](.github/ISSUE_TEMPLATE/feature_request.yml). Los issues en blanco están
  deshabilitados a propósito.
- Buscá primero en los issues existentes: puede que ya esté reportado.

## El flujo, en cinco pasos

1. **Abrí un issue** con su template. Nace con el label `status:needs-review`.
2. **Esperá la aprobación.** El mantenedor evalúa el issue y aplica `status:approved`. Un PR
   ligado a un issue sin aprobar no pasa los checks: la evaluación va antes que el código,
   no después.
3. **Creá una rama** descriptiva y trabajá con
   [Conventional Commits](https://www.conventionalcommits.org/).
4. **Abrí el PR** con el template completo, exactamente un label `type:*`, y `Closes #N`,
   `Fixes #N` o `Resolves #N` en el cuerpo referenciando el issue aprobado.
5. **Esperá los checks** de
   [PR validation](.github/workflows/pr-validation.yml) y el review. El detalle operativo
   (branch protection, releases, guardrails) vive en [docs/governance.md](docs/governance.md).

## Qué miran los checks

Además del formato de commits y los labels, cada PR se escanea contra rutas que solo existen
en la máquina de quien escribe: homes absolutos con un usuario real (`/home/<usuario>/`,
`C:\Users\<nombre>\`, `/Users/<nombre>/`), montajes de WSL con una letra de disco real, y las
carpetas de configuración local de Pi y de gentle-shell — también cuando la ruta aparece
escapada (`file://`, `%2F`, `\/`). Se miran el diff, el título, el cuerpo y los mensajes de
commit: si cualquiera agrega alguna, el check falla. Reemplazá la ruta por su forma genérica
(`~`, `$HOME`, rutas relativas al repo). Un doc que necesite nombrarlas usa un placeholder
(`/home/<usuario>/`, `/mnt/<disco>/...`), que el check acepta.

## Qué incluye y qué no este repo

Las skills de vendors (Supabase, Firebase, Genkit) y las familias de terceros que este repo
solo *nombra* no aceptan cambios acá: no son nuestras. El origen y la licencia de cada pieza
están declarados en [docs/provenance.md](docs/provenance.md).

## Licencia

Todo lo que entra queda bajo la [MIT del repo](LICENSE). Al abrir un PR aceptás ese término.

## En qué quiero feedback

[La lista honesta está en el README →](README.md#en-qué-quiero-feedback)
