# Comandos — Repo Bootstrap

Detalle local de `SKILL.md` (## References).

## Commands

### Instalar estándares en el repo actual

```bash
bash dev-skills/repo-bootstrap/assets/install-repo-standards.sh
```

Es idempotente: correrlo dos veces no cambia nada de lo que ya estaba. Para reinstalar el hook `pre-push` a propósito:

```bash
bash dev-skills/repo-bootstrap/assets/install-repo-standards.sh --reinstall-hook
```

### Probar las plantillas antes de publicarlas

Las plantillas se prueban ejecutándose en [KapsCa/baseline-sandbox](https://github.com/KapsCa/baseline-sandbox), un repo público que existe solo para eso. Una plantilla que nunca se ejecutó no está verificada: el banco de pruebas ya encontró un defecto que la lectura no vio.

### Aplicar protección clásica en repo público

```bash
bash dev-skills/repo-bootstrap/assets/configure-public-branch-protection.sh
```

### Flujo mínimo recomendado

```bash
git switch -c feat/mi-cambio
git add .
git commit -m "feat(core): add initial flow"
git push -u origin feat/mi-cambio
gh pr create --fill
```

---

