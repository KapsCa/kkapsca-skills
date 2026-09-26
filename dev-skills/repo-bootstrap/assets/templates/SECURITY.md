# Security Policy

## Como reportar un problema de seguridad

Si encontraste una forma de acceder a datos que no deberias, romper el sistema,
o exponer informacion de otras personas: **no lo publiques en un issue, un pull
request ni una discusion publica.**

Reportalo en privado:

1. **Canal preferido** — pestana **Security** del repositorio, boton
   **Report a vulnerability**. El reporte queda privado y con seguimiento
   dentro de GitHub.
   Para que este boton exista, el dueno del repo tiene que activar
   *Private vulnerability reporting* en Settings -> Security.
2. **Alternativa** — escribir a `REEMPLAZAR-CON-TU-CONTACTO`.

## Que esperar

| Etapa | Plazo |
|---|---|
| Acuse de recibo | 48 horas |
| Evaluacion inicial | 7 dias |
| Correccion, si el reporte es valido | Se acuerda segun la gravedad |

Si el problema es valido, se corrige y se acredita a quien lo reporto, salvo que
pida lo contrario.

## Alcance

**Dentro del alcance:**

- Codigo de este repositorio.
- Configuracion y workflows publicados aca.

**Fuera del alcance:**

- Librerias de terceros: reportar a quien las mantiene. Igual avisame, porque
  puede que tenga que actualizar la version que uso.
- Problemas que ya fueron reportados y siguen abiertos.
- Ataques que requieren acceso previo al equipo o a la cuenta.

## Que no hacer

- No publicar el detalle antes de que haya un arreglo. Un reporte publico se
  convierte en una instruccion para cualquiera, antes de que exista el arreglo.
- No ir mas alla de lo necesario para demostrar el problema. No acceder a datos
  de otras personas ni borrar nada.
- No probar tecnicas de denegacion de servicio contra servicios en produccion.
