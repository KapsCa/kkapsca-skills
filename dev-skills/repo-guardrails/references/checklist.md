# Checklist advisory y ejemplo de output — Repo Guardrails

Detalle local de `SKILL.md` (## Execution Steps y ## Output Contract).

## Checklist de Guardrails (Advisory)

Antes de push / PR / merge, revisa:

| Ítem | Qué verificar | Warning si... |
|-------|---------------|---------------|
| Rama | ¿Es `main`, `master` o `release`? | Push directo a rama protegida |
| PR | ¿Existe PR abierto para la rama? | Push sin PR abierto |
| Conventional Commits | ¿Los commits siguen formato `type(scope): message`? | Commits sin formato convencional |
| Labels | ¿Tiene labels apropiados para el tipo de cambio? | PR sin labels después de 2h abierto |
| Checks | ¿Passing? | Checks fallando o pendientes |
| PR template | ¿Llenó la descripción? | PR vacío o con template sin tocar |

## Output Esperado

Una lista inline de warnings, ejemplo:

```
⚠️ Guardrails Check:
- [WARN] Push directo a main detectado → usa rama feature
- [WARN] No se encontró PR abierto para feat/mi-cambio
- [OK] Conventional commit detectado: feat(core): add flow
```
