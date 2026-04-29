# Configuración WSL para opencode

Si vas a usar **opencode en Windows**, la recomendación es correrlo bajo **WSL2** (Windows Subsystem for Linux) para mantener un entorno más consistente con Linux y evitar fricción innecesaria con rutas, shells y dependencias.

## Por qué WSL2

- Las herramientas de desarrollo (git, bash, scripts) asumen entorno Unix
- WSL2 te deja mucho más cerca del comportamiento real esperado por las skills
- Evita mezclar rutas de Windows (`C:\Users\...`) y Linux (`/home/...`) dentro del mismo flujo

## Requisitos previos

- Windows 10 versión 2004 o superior (Build 19041 o superior) o Windows 11
- Virtualización habilitada en BIOS/UEFI

## Instalación paso a paso

### 1. Instalar WSL2

Abre PowerShell **como administrador** y ejecuta:

```powershell
wsl --install
```

Esto instala WSL2 con Ubuntu por defecto. Reinicia después de la instalación.

### 2. Verificar instalación

```powershell
wsl --list --verbose
```

Deberías ver algo como:

```text
NAME      STATE           VERSION
* Ubuntu    Running         2
```

### 3. Acceder al entorno Linux

Desde PowerShell o CMD:

```powershell
wsl
```

O abre "Ubuntu" desde el menú de inicio de Windows.

### 4. Clonar repositorios dentro de WSL

Usa el filesystem de Linux para evitar problemas de rendimiento y rutas:

```bash
cd ~
mkdir -p dev/proyects
cd dev/proyects
git clone https://github.com/KapsCa/kkapsca-skills.git
```

### 5. Ejecutar bootstrap desde WSL

```bash
cd ~/dev/proyects/kkapsca-skills
bash scripts/bootstrap.sh
```

## Recomendaciones adicionales

- **Editor**: Usa VS Code con la extensión "Remote - WSL" para editar archivos dentro de WSL de forma transparente
- **Paths**: Nunca mezcles rutas de Windows (`/mnt/c/Users/...`) con rutas de WSL (`/home/...`) en el mismo flujo
- **Git**: Configura tu identidad de git dentro de WSL:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

## Enlaces oficiales

- [Instalación de WSL](https://learn.microsoft.com/windows/wsl/install)
- [Documentación general de WSL](https://learn.microsoft.com/windows/wsl/)
- [Sistemas de archivos en WSL](https://learn.microsoft.com/windows/wsl/filesystems)
- [VS Code Remote - WSL](https://code.visualstudio.com/docs/remote/wsl)

## Nota para Windows + opencode

- En Windows, usa **WSL2** como entorno base para opencode
- Evita ejecutar scripts de este repo directamente en CMD o PowerShell (usa WSL)
- Si una guía o skill asume shell Unix, WSL te deja mucho más cerca de ese comportamiento real
