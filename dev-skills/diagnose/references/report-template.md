# Plantilla y seguimiento del reporte — Diagnose

Detalle local de `SKILL.md` (## Output Contract): plantilla exacta del reporte, pre-flight checklist e integración del diagnóstico con el trabajo formal.

Al terminar el ciclo de debugging, entrega un reporte breve usando esta plantilla exacta:

## Plantilla del reporte

```markdown
# Diagnóstico — [Breve descripción del error]

## Reproducción
Pasos: [1, 2, 3]
Entorno: [stack/versión]

## Causa raíz
[Qué lo provocó]

## Fix aplicado
[Archivo + qué cambió]

## Regresión
- [x] Tests existentes pasan
- [x] Nuevo caso de validación agregado (o justificación de por qué no)
```

## PRE-FLIGHT CHECKLIST

- [ ] Ya reproduje el error de forma consistente
- [ ] Ya minimicé el escenario
- [ ] Ya instrumenté para ver el estado interno
- [ ] Ya apliqué el fix mínimo
- [ ] Ya verifiqué regresión

## Integración con el trabajo formal (ODD / SDD)

- Esta skill es un **companion** del trabajo formal, no un proceso paralelo. ODD es el flujo por defecto; las fases SDD aplican si SDD fue seleccionado.
- Si el bug revela una necesidad de cambio estructural, luego enruta al trabajo formal con este diagnóstico como base: ODD (documento de feature + tareas), o `sdd-propose` si SDD fue seleccionado.
- Si el fix requiere una feature o refactor amplio, no lo hagas aquí: documéntalo y propón el cambio por el flujo formal (ODD, o SDD si fue seleccionado).
