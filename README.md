# KkapsCa Skills Repository

> "Antes de ejecutar, hay que planear. Antes de planear el código, hay que entender el problema."

Este repositorio ya no es solo un **project kickstart**.
Ahora es una base de **skills personales** para dos momentos del desarrollo:

1. **Descubrir y aterrizar ideas** antes de programar.
2. **Desarrollar software** con criterios técnicos claros.

---

## Estructura del repositorio

```text
KkapsCa-project-kickstart/
├── README.md
├── 01-brainstorm/
│   └── SKILL.md
├── 02-product-discovery/
│   └── SKILL.md
├── 03-tech-feasibility/
│   └── SKILL.md
└── dev-skills/
    └── flutter/
        └── SKILL.md
```

---

## 1) Skills de inicio de proyecto

Estas skills existen para evitar el error clásico de brincar directo al código.

### `01-brainstorm`
Sirve para bajar una idea vaga a algo entendible:

- problema,
- usuario,
- propuesta de valor,
- MVP,
- diferenciador.

### `02-product-discovery`
Sirve para validar si la idea vale la pena:

- mercado,
- personas,
- competencia,
- negocio,
- validación.

### `03-tech-feasibility`
Sirve para aterrizar la ejecución técnica:

- stack,
- riesgos,
- esfuerzo,
- arquitectura,
- dependencias.

### Flujo recomendado

```text
Idea → Brainstorm → Product Discovery → Tech Feasibility → Desarrollo
```

---

## 2) Skills de desarrollo

Estas skills sirven cuando la idea ya pasó el filtro inicial y toca construir.

### `dev-skills/flutter`
Skill personal para desarrollo Flutter y Dart.

Está alineada a prácticas recomendadas por la documentación oficial de Flutter:

- separación de responsabilidades,
- state management según el alcance del estado,
- performance con `const`, widgets pequeños y lazy lists,
- manejo asíncrono claro,
- testing desde temprano,
- evitar meter dependencias o arquitecturas por moda.

**Importante:**
Esta skill **no impone GetX** como default.
Primero se elige la herramienta correcta para el problema.

---

## Cómo usar este repositorio

### Si empiezas con una idea

Usa este orden:

1. `01-brainstorm`
2. `02-product-discovery`
3. `03-tech-feasibility`

Cuando termines, ya deberías tener contexto suficiente para desarrollar con criterio.

### Si ya vas a construir

Usa la skill adecuada dentro de `dev-skills/`.

Hoy existe:

- `flutter`

Después se pueden agregar más:

- backend,
- arquitectura,
- testing,
- bases de datos,
- automatización.

---

## Filosofía del repositorio

- No elegir stack por hype.
- No programar sin entender el problema.
- No meter complejidad antes de tiempo.
- Aprender fundamentos primero.
- Usar IA como herramienta, no como piloto automático.

---

## Autor

**KkapsCa**

GitHub: https://github.com/KapsCa/kkapsca-skills
