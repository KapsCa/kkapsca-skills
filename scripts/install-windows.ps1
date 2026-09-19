<#
.SYNOPSIS
    Instala el ecosistema completo de Gentle AI en Windows nativo.

.DESCRIPTION
    Lleva una máquina Windows desde cero hasta el ecosistema funcionando:
    requisitos, pi, binario de Engram, Gentle AI, paquetes de pi, herdr con su
    integración para pi, y las skills del repositorio de skills.

    Es idempotente: verifica antes de instalar, así que se puede volver a correr
    sin romper lo que ya está. Usá -WhatIf para previsualizar sin mutar nada.

    Alcance de privilegios: todo lo que el script escribe es de alcance de
    usuario (PATH de usuario, variables de usuario, %USERPROFILE%, %TEMP%).
    Excepción: los instaladores de winget de Git, Node.js y Go son de alcance
    de máquina y pueden disparar un pedido de UAC.

    Lo que NO hace este instalador: no instala codegraph, no escribe
    settings.json ni mcp.json ni subagents.json, no corre pi-engram init, y no
    hace la verificación funcional final. Esos pasos están en el runbook
    docs/windows-native-setup.md.

.PARAMETER Status
    Modo solo lectura: muestra las versiones instaladas y, si gentle-ai está
    presente, el chequeo installed vs latest de sus herramientas. No modifica
    nada, ni siquiera con -WhatIf.

.PARAMETER Update
    Modo actualización: actualiza lo que ya está instalado en vez de instalar
    desde cero. Con el canal stable usa pi update, gentle-ai upgrade, herdr
    update y reinstala el binario de Engram. Con el canal main delega en
    gentle-cfg herramienta por herramienta.

.PARAMETER Channel
    Canal de versiones. 'stable' (por defecto) usa las últimas versiones
    estables de cada herramienta: es la opción para cualquiera que use este
    script. 'beta' y 'nightly' son los canales de desarrollo de Gentle AI.
    'main' es el camino del autor del script: delega en gentle-cfg, que
    instala desde el código de main y requiere gentle-cfg, bash y jq.

.PARAMETER GentleCfgPath
    Ruta a gentle-cfg, que solo se usa con -Channel main. Por defecto:
    %USERPROFILE%\.pi\agent\bin\gentle-cfg

.PARAMETER SkillsRepo
    URL del repositorio de skills a clonar.

.PARAMETER InstallDir
    Directorio base para clones y trabajo. Por defecto: %USERPROFILE%\dev

.PARAMETER SkipHerdr
    No instala herdr ni su integración con pi.

.PARAMETER SkipSkills
    No instala las skills del repositorio.

.PARAMETER IncludeIntercom
    Instala además pi-intercom, que es un companion opcional.

.EXAMPLE
    .\install-windows.ps1 -WhatIf
    Previsualiza todo lo que haría, sin tocar la máquina.

.EXAMPLE
    .\install-windows.ps1 -Channel beta -IncludeIntercom
    Instala usando el canal beta de Gentle AI y agrega pi-intercom.

.EXAMPLE
    .\install-windows.ps1 -Status
    Muestra las versiones instaladas sin modificar nada.

.EXAMPLE
    .\install-windows.ps1 -Update
    Actualiza todo lo instalado a su última versión estable.

.EXAMPLE
    .\install-windows.ps1 -Channel main
    Instala siguiendo el código de main de las herramientas Gentle, vía
    gentle-cfg. Requiere gentle-cfg, bash y jq.

.NOTES
    Sin verificación de ejecución: este script no se pudo correr en un host
    Windows durante su desarrollo. Su sintaxis se valida en CI, pero su
    comportamiento no está verificado de punta a punta.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Status,

    [switch]$Update,

    [ValidateSet('stable', 'beta', 'nightly', 'main')]
    [string]$Channel = 'stable',

    [string]$SkillsRepo = 'https://github.com/KapsCa/kkapsca-skills.git',

    [string]$InstallDir = (Join-Path $HOME 'dev'),

    [switch]$SkipHerdr,

    [switch]$SkipSkills,

    [switch]$IncludeIntercom,

    [string]$GentleCfgPath = (Join-Path $HOME '.pi\agent\bin\gentle-cfg')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# $PSCommandPath, capturado en alcance de script: dentro de una función,
# $MyInvocation.MyCommand apunta a la función, no al archivo.
$script:ScriptPath = $PSCommandPath
$script:DryRun = [bool]$WhatIfPreference

$script:Results = [System.Collections.Generic.List[object]]::new()
$script:Failed = [System.Collections.Generic.List[string]]::new()

$EngramReleasesApi = 'https://api.github.com/repos/Gentleman-Programming/engram/releases/latest'
$HerdrInstallerUrl = 'https://herdr.dev/install.ps1'
$GentleAiInstallerUrl = 'https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.ps1'
$MinimumGoVersion = [version]'1.25.10'

function Write-Step { param([string]$Message) Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Ok { param([string]$Message) Write-Host "  [ok]   $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "  [warn] $Message" -ForegroundColor Yellow }

function Add-Result {
    param(
        [string]$Component,
        [string]$Version,
        [bool]$Ok,
        [string]$Detail = ''
    )
    $script:Results.Add([pscustomobject]@{
            Component = $Component
            Version   = $Version
            Ok        = $Ok
            Detail    = $Detail
        })
    if (-not $Ok) {
        $script:Failed.Add((($Component + ' ' + $Detail).Trim()))
    }
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-ToolVersion {
    param([string]$Exe, [string[]]$Arguments = @())
    try {
        return (& $Exe @Arguments 2>&1 | Out-String).Trim()
    }
    catch {
        return ''
    }
}

function Get-GitBashPath {
    $candidate = 'C:\Program Files\Git\bin\bash.exe'
    if (Test-Path -LiteralPath $candidate) { return $candidate }
    $found = Get-Command bash -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
    return $null
}

function Test-GentleCfg {
    if (-not (Test-Path -LiteralPath $GentleCfgPath)) { return $false }
    $bash = Get-GitBashPath
    if (-not $bash) { return $false }
    if (-not (Test-Command 'jq')) { return $false }
    return $true
}

function Invoke-GentleCfg {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Arguments)

    $bash = Get-GitBashPath
    if (-not $bash) { throw 'gentle-cfg necesita bash. Instalá Git for Windows.' }

    if (-not (Test-Command 'jq')) {
        throw 'gentle-cfg necesita jq, que no viene con Windows ni con Git for Windows. Instalalo (por ejemplo: winget install --id jqlang.jq --exact) y volvé a correr el script.'
    }
    if (-not (Test-Command 'gh')) {
        Write-Warn 'gh no está instalado. gentle-cfg lo usa para consultar releases de GitHub; sin gh puede fallar por límite de tasa.'
    }

    if (-not $PSCmdlet.ShouldProcess("gentle-cfg $Arguments", 'Ejecutar con bash')) {
        Write-Warn "gentle-cfg $Arguments se ejecutaría (omitido)"
        return $null
    }

    # Se pasa la ruta Windows de forma explícita y se deja que bash la resuelva.
    $scriptPath = ($GentleCfgPath -replace '\\', '/')
    $output = & $bash -lc "bash '$scriptPath' $Arguments" 2>&1
    $output | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    return $LASTEXITCODE
}

function Get-ProcessArchitecture {
    # PROCESSOR_ARCHITECTURE refleja el proceso, no el sistema: un PowerShell
    # de 32 bits sobre ARM64 reportaría 'amd64'. RuntimeInformation no.
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    if ($arch -eq [System.Runtime.InteropServices.Architecture]::Arm64) { return 'arm64' }
    return 'amd64'
}

function Update-SessionPath {
    # Un binario recién instalado no está en el PATH de este proceso. Sin esto,
    # cada paso siguiente falla con "no se reconoce el comando".
    # Se conserva el PATH del proceso y se le agregan los de máquina y usuario:
    # reconstruirlo solo con esos dos descartaría entradas del proceso.
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $extra = @($machinePath, $userPath) | Where-Object { $_ }
    $env:Path = (@($env:Path) + $extra) -join ';'
}

function Add-UserPathEntry {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Entry)

    if (-not (Test-Path -LiteralPath $Entry)) { return }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($userPath -split ';' | Where-Object { $_ })
    if ($entries -contains $Entry) { return }

    $newPath = (@($entries) + $Entry) -join ';'
    if ($PSCmdlet.ShouldProcess($Entry, 'Agregar al PATH de usuario')) {
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Update-SessionPath
        Write-Ok "PATH de usuario ahora incluye $Entry"
    }
}

function Install-WithWinget {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Id, [string]$Label, [string]$CommandName)

    if (-not (Test-Command 'winget')) {
        throw "Falta '$Label' y winget no está disponible. Instalalo a mano y volvé a correr el script."
    }

    if (-not $PSCmdlet.ShouldProcess($Label, "winget install --id $Id --exact")) {
        Write-Warn "${Label}: se instalaría con winget (omitido)"
        Add-Result $Label '' $true 'se instalaría'
        return
    }

    Write-Host "  instalando $Label ..." -ForegroundColor Gray
    & winget install --id $Id --exact --silent --accept-source-agreements --accept-package-agreements
    $code = $LASTEXITCODE

    # winget devuelve un código distinto de cero cuando el paquete ya estaba
    # instalado, así que el código por sí solo no prueba fallo: se comprueba si
    # el ejecutable quedó realmente disponible.
    Update-SessionPath
    if ($code -ne 0 -and -not (Test-Command $CommandName)) {
        throw "winget falló al instalar '$Label' (código $code). Instalalo a mano y volvé a correr el script."
    }

    Write-Ok "$Label instalado"
}

function Get-GoVersion {
    $raw = Get-ToolVersion 'go' @('version')
    if ($raw -match 'go(\d+)\.(\d+)(?:\.(\d+))?') {
        $patch = if ($Matches.ContainsKey(3)) { $Matches[3] } else { '0' }
        return [version]("$($Matches[1]).$($Matches[2]).$patch")
    }
    return $null
}

function Invoke-RemoteFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Uri, [string]$DisplayName, [string[]]$ArgumentList = @())

    # Se descarga a disco y se ejecuta, en vez de usar iex sobre el contenido
    # remoto: el archivo queda auditable antes de correrlo. Además se usa un
    # nombre de archivo irrepetible para que nadie pueda pre-colocar contenido
    # en una ruta predecible de %TEMP%.
    $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), ([System.IO.Path]::GetRandomFileName() + '.ps1'))

    if (-not $PSCmdlet.ShouldProcess($DisplayName, "Descargar y ejecutar desde $Uri")) {
        Write-Warn "${DisplayName}: se descargaría y ejecutaría desde $Uri (omitido)"
        return $null
    }

    Write-Host "  origen: $Uri" -ForegroundColor Gray
    Invoke-WebRequest -Uri $Uri -OutFile $tempFile -UseBasicParsing
    Unblock-File -LiteralPath $tempFile -ErrorAction SilentlyContinue
    Write-Ok "descargado en $tempFile"

    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempFile @ArgumentList
        if ($LASTEXITCODE -ne 0) {
            throw "El instalador de $DisplayName terminó con código $LASTEXITCODE."
        }
    }
    finally {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
    }

    Update-SessionPath
    return $true
}

function Show-Preflight {
    Write-Step 'Preflight'

    if (-not [Environment]::Is64BitOperatingSystem) {
        throw 'Se requiere Windows de 64 bits.'
    }

    Write-Ok "Arquitectura: $(Get-ProcessArchitecture)"

    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Ok "Sistema: $($os.Caption) ($($os.Version))"

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warn 'Estás corriendo como administrador. No hace falta, y no se recomienda.'
    }

    if ((Get-ExecutionPolicy) -eq 'Restricted') {
        Write-Warn "ExecutionPolicy está en 'Restricted'. Si el script no arranca, corré: powershell -ExecutionPolicy Bypass -File `"$script:ScriptPath`""
    }

    if ($PSVersionTable.PSVersion.Major -le 5) {
        Write-Warn 'PowerShell 5.1 detectado. Funciona, pero PowerShell 7 es más predecible.'
    }

    Write-Ok "Canal de Gentle AI: $Channel"
}

function Install-Prerequisites {
    Write-Step 'Requisitos'

    if (-not (Test-Command 'git')) {
        Install-WithWinget -Id 'Git.Git' -Label 'Git for Windows' -CommandName 'git'
    }
    if (Test-Command 'git') {
        $gitVersion = Get-ToolVersion 'git' @('--version')
        if ($gitVersion) {
            Write-Ok $gitVersion
            Add-Result 'git' $gitVersion $true
        }
        else {
            Add-Result 'git' '' $false 'git existe pero no responde a --version'
        }
    }
    elseif (-not $script:DryRun) {
        throw 'git no quedó disponible en PATH. Cerrá y reabrí la terminal, y volvé a correr el script.'
    }

    if (-not (Test-Command 'node')) {
        Install-WithWinget -Id 'OpenJS.NodeJS.LTS' -Label 'Node.js LTS' -CommandName 'node'
    }
    if (Test-Command 'node') {
        $nodeVersion = Get-ToolVersion 'node' @('--version')
        if ($nodeVersion) {
            Write-Ok "node $nodeVersion"
            Add-Result 'node' $nodeVersion $true
        }
        else {
            Add-Result 'node' '' $false 'node existe pero no responde a --version'
        }
    }
    elseif (-not $script:DryRun) {
        throw 'node no quedó disponible en PATH. Cerrá y reabrí la terminal, y volvé a correr el script.'
    }

    if ((Test-Command 'node') -and -not (Test-Command 'npm')) {
        if ($script:DryRun) {
            Write-Warn 'npm no está en PATH; en una corrida real el script se detendría acá'
        }
        else {
            Add-Result 'npm' '' $false 'npm no está en PATH'
            throw 'npm no quedó disponible en PATH tras instalar Node.js.'
        }
    }

    # pi usa Git Bash como shell. Sin bash, pi arranca pero ningún bloque bash funciona.
    $gitBash = 'C:\Program Files\Git\bin\bash.exe'
    if (Test-Path -LiteralPath $gitBash) {
        Write-Ok "Git Bash: $gitBash"
    }
    elseif (Test-Command 'bash') {
        Write-Ok "Git Bash encontrado en PATH: $((Get-Command bash).Source)"
    }
    elseif (-not $script:DryRun) {
        throw 'No se encontró bash. pi lo usa como shell; instalá Git for Windows.'
    }
    else {
        Write-Warn 'No se encontró bash (se instalaría con Git for Windows)'
    }

    if (-not (Test-Command 'go')) {
        Install-WithWinget -Id 'GoLang.Go' -Label 'Go' -CommandName 'go'
    }
    $goVersion = Get-GoVersion
    if (-not $goVersion) {
        Write-Warn 'Go no quedó disponible. Gentle AI se puede instalar igual desde su canal binario cuando esté disponible.'
    }
    elseif ($goVersion -lt $MinimumGoVersion) {
        if ($script:DryRun) {
            Write-Warn "Go $goVersion es menor a $MinimumGoVersion; en una corrida real el script se detendría acá"
        }
        else {
            throw "Go $goVersion es menor a $MinimumGoVersion, que es el mínimo para compilar Gentle AI. Actualizá Go y volvé a correr el script."
        }
    }
    else {
        Write-Ok "go $goVersion"
        Add-UserPathEntry (Join-Path $HOME 'go\bin')
    }
}

function Install-Pi {
    Write-Step 'pi'

    if (Test-Command 'pi') {
        $version = Get-ToolVersion 'pi' @('--version')
        if ($version) {
            Write-Ok "pi ya instalado: $version"
            Add-Result 'pi' $version $true
        }
        else {
            Add-Result 'pi' '' $false 'pi existe pero no responde a --version'
        }
        return
    }

    if ($script:DryRun) {
        Write-Warn 'pi se instalaría con npm (omitido)'
        Add-Result 'pi' '' $true 'se instalaría'
        return
    }

    & npm install -g --ignore-scripts '@earendil-works/pi-coding-agent'
    if ($LASTEXITCODE -ne 0) { throw 'La instalación global de pi falló.' }
    Update-SessionPath

    if (-not (Test-Command 'pi')) {
        $npmPrefix = (npm config get prefix 2>&1 | Out-String).Trim()
        throw "pi no quedó en PATH. El prefijo de npm es '$npmPrefix'; agregalo al PATH y volvé a correr el script."
    }
    $version = Get-ToolVersion 'pi' @('--version')
    if (-not $version) {
        Add-Result 'pi' '' $false 'pi quedó en PATH pero no responde a --version'
        return
    }
    Write-Ok "pi $version"
    Add-Result 'pi' $version $true
}

function Install-Engram {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([switch]$Force)

    Write-Step 'Binario de Engram'

    $binDir = Join-Path $env:USERPROFILE '.pi\agent\bin'
    $target = Join-Path $binDir 'engram.exe'

    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        $version = Get-ToolVersion $target @('version')
        if ($version) {
            Write-Ok "engram ya instalado: $version (no se vuelve a descargar)"
            Add-Result 'engram' $version $true
            Set-EngramEnvironment -Target $target
            return
        }
        Write-Warn 'El engram.exe existente no responde; se reinstala.'
    }

    $arch = Get-ProcessArchitecture
    $release = Invoke-RestMethod -Uri $EngramReleasesApi -Headers @{ 'User-Agent' = 'kkapsca-windows-installer' }

    $asset = $release.assets | Where-Object { $_.name -like "engram*_windows_$arch.zip" } | Select-Object -First 1
    $checksumAsset = $release.assets | Where-Object { $_.name -eq 'checksums.txt' } | Select-Object -First 1

    if (-not $asset) {
        throw "El release $($release.tag_name) no publica un asset engram*_windows_$arch.zip. Revisá https://github.com/Gentleman-Programming/engram/releases y bajalo a mano a $target."
    }

    # La verificación falla cerrada. Este binario se ejecuta en cada sesión de
    # pi, así que instalar uno sin verificar no es una degradación aceptable.
    if (-not $checksumAsset) {
        throw "El release $($release.tag_name) no publica checksums.txt, así que no se puede verificar la integridad de $($asset.name). Abortado por seguridad. Bajalo a mano y verificá el hash contra la página del release."
    }

    if (-not $PSCmdlet.ShouldProcess($target, "Descargar, verificar y extraer $($asset.name)")) {
        Write-Warn "engram: se descargaría $($asset.name) y se verificaría su hash (omitido)"
        Add-Result 'engram' '' $true 'se instalaría'
        return
    }

    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Force -Path $workDir | Out-Null

    try {
        $zipPath = Join-Path $workDir $asset.name
        $checksumPath = Join-Path $workDir 'checksums.txt'

        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
        Invoke-WebRequest -Uri $checksumAsset.browser_download_url -OutFile $checksumPath -UseBasicParsing

        # Coincidencia anclada al nombre exacto: un match por subcadena tomaría
        # también la línea de un archivo como $($asset.name).sig, y el hash de
        # ese archivo distinto haría abortar una descarga correcta.
        $pattern = '^\s*([0-9a-fA-F]{64})\s+\*?' + [regex]::Escape($asset.name) + '\s*$'
        $match = Select-String -Path $checksumPath -Pattern $pattern | Select-Object -First 1
        if (-not $match) {
            throw "checksums.txt no contiene una línea con el hash de $($asset.name). Abortado por seguridad."
        }

        $expected = $match.Matches[0].Groups[1].Value.ToUpperInvariant()
        $actual = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actual -ne $expected) {
            throw "El hash de $($asset.name) no coincide. esperado $expected, obtenido $actual. Abortado por seguridad."
        }
        Write-Ok 'hash SHA256 verificado'

        $extractDir = Join-Path $workDir 'extract'
        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

        $extracted = Get-ChildItem -Path $extractDir -Filter 'engram*.exe' -Recurse | Select-Object -First 1
        if (-not $extracted) { throw "El zip $($asset.name) no contiene engram.exe." }

        New-Item -ItemType Directory -Force -Path $binDir | Out-Null
        Copy-Item -LiteralPath $extracted.FullName -Destination $target -Force
        Unblock-File -LiteralPath $target -ErrorAction SilentlyContinue
    }
    finally {
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $version = Get-ToolVersion $target @('version')
    if (-not $version) {
        Add-Result 'engram' '' $false 'se instaló pero no responde a version'
        return
    }
    Write-Ok "engram $version"
    Add-Result 'engram' $version $true
    Set-EngramEnvironment -Target $target
}

function Set-EngramEnvironment {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Target)

    $current = [Environment]::GetEnvironmentVariable('ENGRAM_BIN', 'User')
    if ($current -eq $Target) {
        Write-Ok 'ENGRAM_BIN ya configurado'
        return
    }

    if ($PSCmdlet.ShouldProcess($Target, 'Definir ENGRAM_BIN de usuario')) {
        [Environment]::SetEnvironmentVariable('ENGRAM_BIN', $Target, 'User')
        $env:ENGRAM_BIN = $Target
        Write-Ok 'ENGRAM_BIN configurado'
    }
}

function Install-GentleAi {
    Write-Step 'Gentle AI'

    if ($Channel -eq 'main') {
        if (-not (Test-GentleCfg)) {
            throw "El canal 'main' requiere gentle-cfg en '$GentleCfgPath', bash y jq. Copiá gentle-cfg a esa ruta, instalá jq y volvé a correr el script. Si no tenés gentle-cfg, usá el canal stable."
        }
        # Se delega herramienta por herramienta y NUNCA se llama a 'all main':
        # ese camino incluye el engram_install de gentle-cfg, que compila desde
        # fuente y enlaza con 'ln -s' sin la extensión .exe, además de usar
        # 'pkill'. En Windows eso dejaría el binario de Engram roto. Engram lo
        # administra este script, desde el zip oficial y con verificación de hash.
        $tools = @(
            @{ Name = 'gentle-ai'; Args = 'gentle-ai main' },
            @{ Name = 'gentle-shell'; Args = 'gentle-shell main' }
        )

        foreach ($tool in $tools) {
            Write-Host "  Canal main: $($tool.Args)" -ForegroundColor Gray
            $code = Invoke-GentleCfg -Arguments $tool.Args
            if ($null -eq $code) {
                Add-Result "$($tool.Name) (main)" '' $true 'se ejecutaría'
                continue
            }
            if ($code -ne 0) {
                Add-Result "$($tool.Name) (main)" '' $false "gentle-cfg salió con código $code"
                Write-Warn "gentle-cfg falló al configurar $($tool.Name). Revisá su salida de arriba."
                continue
            }
            Add-Result "$($tool.Name) (main)" 'ok' $true
        }

        if (-not $script:DryRun) { Update-SessionPath }
        $version = Get-ToolVersion 'gentle-ai' @('version')
        if ($version) { Write-Ok "gentle-ai $version" }
        return
    }

    if (Test-Command 'gentle-ai') {
        $version = Get-ToolVersion 'gentle-ai' @('version')
        if ($version) {
            Write-Ok "gentle-ai ya instalado: $version"
            Add-Result 'gentle-ai' $version $true
        }
        else {
            Add-Result 'gentle-ai' '' $false 'gentle-ai existe pero no responde a version'
        }
    }
    else {
        $ran = Invoke-RemoteFile -Uri $GentleAiInstallerUrl -DisplayName 'Gentle AI' -ArgumentList @('-Method', 'go', '-Channel', $Channel)
        if ($null -eq $ran) {
            Add-Result 'gentle-ai' '' $true 'se instalaría'
        }
        else {
            $goBin = Join-Path $HOME 'go\bin'
            Add-UserPathEntry $goBin
            if (Test-Command 'gentle-ai') {
                $version = Get-ToolVersion 'gentle-ai' @('version')
                if ($version) {
                    Write-Ok "gentle-ai $version"
                    Add-Result 'gentle-ai' $version $true
                }
                else {
                    Add-Result 'gentle-ai' '' $false 'no responde a version'
                }
            }
            else {
                Add-Result 'gentle-ai' '' $false "no quedó en PATH; revisá $goBin"
                Write-Warn "gentle-ai no quedó en PATH. Revisá $goBin y volvé a correr el script."
            }
        }
    }

    if (-not (Test-Command 'gentle-ai')) { return }

    Write-Step 'Stack de pi (Gentle AI)'
    if ($script:DryRun) {
        Write-Warn 'gentle-ai install se ejecutaría (omitido)'
        Add-Result 'stack-pi' '' $true 'se instalaría'
        return
    }
    & gentle-ai install --agent pi --scope global --channel $Channel
    if ($LASTEXITCODE -ne 0) { throw "gentle-ai install falló (código $LASTEXITCODE)." }
    Write-Ok 'stack de pi instalado por gentle-ai'
    Add-Result 'stack-pi' 'instalado' $true
}

function Install-PiPackages {
    Write-Step 'Paquetes de pi'

    $packages = @('npm:pi-lens')
    if ($IncludeIntercom) { $packages += 'npm:pi-intercom' }

    if ($script:DryRun) {
        foreach ($package in $packages) {
            Write-Warn "$package se instalaría (omitido)"
            Add-Result $package '' $true 'se instalaría'
        }
        return
    }

    foreach ($package in $packages) {
        & pi install $package
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "pi install $package falló; se continúa con el resto."
            Add-Result $package '' $false 'pi install falló'
            continue
        }
        Write-Ok "$package instalado"
        Add-Result $package 'instalado' $true
    }

    $list = Get-ToolVersion 'pi' @('list')
    if ($list) { Write-Host $list -ForegroundColor Gray }
}

function Install-Herdr {
    Write-Step 'herdr'

    if (Test-Command 'herdr') {
        $version = Get-ToolVersion 'herdr' @('--version')
        if ($version) {
            Write-Ok "herdr ya instalado: $version"
            Add-Result 'herdr' $version $true
        }
        else {
            Add-Result 'herdr' '' $false 'herdr existe pero no responde a --version'
        }
    }
    else {
        $ran = Invoke-RemoteFile -Uri $HerdrInstallerUrl -DisplayName 'herdr'
        if ($null -eq $ran) {
            Add-Result 'herdr' '' $true 'se instalaría'
        }
        elseif (Test-Command 'herdr') {
            $version = Get-ToolVersion 'herdr' @('--version')
            if ($version) {
                Write-Ok "herdr $version"
                Add-Result 'herdr' $version $true
            }
            else {
                Add-Result 'herdr' '' $false 'no responde a --version'
            }
        }
        else {
            Add-Result 'herdr' '' $false 'no quedó en PATH'
            Write-Warn 'herdr no quedó en PATH. Reiniciá la terminal y volvé a correr el script.'
            return
        }
    }

    if ($script:DryRun) {
        Write-Warn 'herdr integration install pi se ejecutaría (omitido)'
        Add-Result 'herdr-integracion' '' $true 'se instalaría'
        return
    }

    & herdr integration install pi
    if ($LASTEXITCODE -ne 0) {
        Write-Warn 'La integración de herdr con pi falló. Se puede reintentar con: herdr integration install pi'
        Add-Result 'herdr-integracion' '' $false 'integration install falló'
        return
    }
    Write-Ok 'integración de herdr con pi instalada'
    Add-Result 'herdr-integracion' 'instalada' $true
}

function Install-Skills {
    Write-Step 'Skills del repositorio'

    $repoName = [System.IO.Path]::GetFileNameWithoutExtension(($SkillsRepo.TrimEnd('/') -split '/')[-1])
    if (-not $repoName) {
        throw "No se pudo derivar un nombre de directorio desde -SkillsRepo '$SkillsRepo'. Pasá una URL que termine en el nombre del repositorio."
    }

    $repoDir = Join-Path $InstallDir $repoName
    $skillsDir = Join-Path $env:USERPROFILE '.agents\skills'

    if (-not (Test-Path -LiteralPath $repoDir)) {
        if ($script:DryRun) {
            Write-Warn "El repositorio se clonaría en $repoDir (omitido)"
            Add-Result 'skills' '' $true 'se instalaría'
            return
        }
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
        & git clone $SkillsRepo $repoDir
        if ($LASTEXITCODE -ne 0) { throw "git clone de $SkillsRepo falló (código $LASTEXITCODE)." }
        Write-Ok "clonado en $repoDir"
    }
    else {
        Write-Ok "el repositorio ya está en $repoDir"
    }

    $gitBash = 'C:\Program Files\Git\bin\bash.exe'
    if (-not (Test-Path -LiteralPath $gitBash)) {
        $bashCommand = Get-Command bash -ErrorAction SilentlyContinue
        if (-not $bashCommand) { throw 'Se necesita bash para correr el bootstrap de skills.' }
        $gitBash = $bashCommand.Source
    }

    # Dos detalles que hacen que esto funcione en Windows:
    # 1. OPENCODE_SKILLS_DIR redirige el destino: el instalador apunta por
    #    defecto a la ruta de opencode, y pi lee ~/.agents/skills.
    # 2. --copy evita los symlinks, que en Windows requieren Developer Mode.
    # El instalador omite las fuentes cuyo destino coincide con el origen, así
    # que apuntar el destino a ~/.agents/skills no pisa las skills externas que
    # ya viven ahí.
    $targetRoot = ($skillsDir -replace '\\', '/')

    if ($script:DryRun) {
        Write-Warn "El bootstrap se correría con destino $targetRoot (omitido)"
        Add-Result 'skills' '' $true 'se instalaría'
        return
    }

    if (-not $PSCmdlet.ShouldProcess($skillsDir, 'bash scripts/bootstrap.sh --copy')) { return }

    $env:OPENCODE_SKILLS_DIR = $targetRoot
    Push-Location $repoDir
    try {
        & $gitBash -lc 'bash scripts/bootstrap.sh --copy'
        if ($LASTEXITCODE -ne 0) {
            throw "El bootstrap falló. Corré a mano: cd `"$repoDir`"; OPENCODE_SKILLS_DIR=`"$targetRoot`" bash scripts/bootstrap.sh --copy"
        }
    }
    finally {
        Pop-Location
    }

    # Contar directorios no prueba que las skills sean usables: hace falta al
    # menos un SKILL.md, que es lo que pi busca.
    $skillManifests = @(Get-ChildItem -Path $skillsDir -Filter 'SKILL.md' -Recurse -ErrorAction SilentlyContinue)
    $installed = @(Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue)

    if ($skillManifests.Count -eq 0) {
        Add-Result 'skills' '0' $false "no se encontró ningún SKILL.md en $skillsDir"
        Write-Warn "No hay ningún SKILL.md en $skillsDir. Revisá la salida del bootstrap."
        return
    }

    Write-Ok "$($skillManifests.Count) SKILL.md en $($installed.Count) directorios de $skillsDir"
    Add-Result 'skills' "$($skillManifests.Count) skills" $true
}

function Update-Pi {
    Write-Step 'Actualizar pi'

    if (-not (Test-Command 'pi')) {
        Write-Warn 'pi no está instalado; se omite la actualización.'
        return
    }

    if ($script:DryRun) {
        Write-Warn 'pi update --all se ejecutaría (omitido)'
        Add-Result 'pi (update)' '' $true 'se ejecutaría'
        return
    }

    & pi update --all
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "pi update --all falló (código $LASTEXITCODE)."
        Add-Result 'pi (update)' '' $false 'update falló'
        return
    }
    $version = Get-ToolVersion 'pi' @('--version')
    Write-Ok "pi $version"
    Add-Result 'pi (update)' $version $true
}

function Update-GentleAi {
    Write-Step 'Actualizar Gentle AI'

    if (-not (Test-Command 'gentle-ai')) {
        Write-Warn 'gentle-ai no está instalado; se omite la actualización.'
        return
    }

    if ($script:DryRun) {
        Write-Warn 'gentle-ai upgrade se ejecutaría (omitido)'
        Add-Result 'gentle-ai (update)' '' $true 'se ejecutaría'
        return
    }

    # 'gentle-ai update' es solo un chequeo de versiones; el que actualiza es 'upgrade'.
    & gentle-ai upgrade
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "gentle-ai upgrade falló (código $LASTEXITCODE)."
        Add-Result 'gentle-ai (update)' '' $false 'upgrade falló'
        return
    }
    $version = Get-ToolVersion 'gentle-ai' @('version')
    Write-Ok "gentle-ai $version"
    Add-Result 'gentle-ai (update)' $version $true
}

function Update-Herdr {
    Write-Step 'Actualizar herdr'

    if (-not (Test-Command 'herdr')) {
        Write-Warn 'herdr no está instalado; se omite la actualización.'
        return
    }

    if ($script:DryRun) {
        Write-Warn 'herdr update se ejecutaría (omitido)'
        Add-Result 'herdr (update)' '' $true 'se ejecutaría'
        return
    }

    & herdr update
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "herdr update falló (código $LASTEXITCODE). Reintentá con: herdr update"
        Add-Result 'herdr (update)' '' $false 'update falló'
        return
    }
    $version = Get-ToolVersion 'herdr' @('--version')
    Write-Ok "herdr $version"
    Add-Result 'herdr (update)' $version $true
}

function Update-Prerequisites {
    Write-Step 'Actualizar requisitos (winget)'

    if (-not (Test-Command 'winget')) {
        Write-Warn 'winget no está disponible; se omiten las actualizaciones de Git, Node.js y Go.'
        return
    }

    # Go usa 'go version' sin guiones, a diferencia de git/node.
    $managed = @(
        @{ Id = 'Git.Git'; Command = 'git'; VersionArgs = @('--version') },
        @{ Id = 'OpenJS.NodeJS.LTS'; Command = 'node'; VersionArgs = @('--version') },
        @{ Id = 'GoLang.Go'; Command = 'go'; VersionArgs = @('version') }
    )

    foreach ($item in $managed) {
        if (-not (Test-Command $item.Command)) { continue }

        if ($script:DryRun) {
            Write-Warn "$($item.Id) se actualizaría con winget (omitido)"
            continue
        }

        $before = Get-ToolVersion $item.Command $item.VersionArgs

        & winget upgrade --id $item.Id --exact --silent --accept-source-agreements --accept-package-agreements
        $code = $LASTEXITCODE
        Update-SessionPath
        $after = Get-ToolVersion $item.Command $item.VersionArgs

        # winget devuelve un código distinto de cero cuando no hay nada que
        # actualizar, así que el código por sí solo no prueba fallo. Para no
        # reportar un falso verde, se exige código de éxito O un cambio real
        # de versión.
        if ($code -eq 0 -or $after -ne $before) {
            Write-Ok "$($item.Command) $after"
            Add-Result "$($item.Command) (update)" $after $true
        }
        else {
            Write-Warn "$($item.Command) no se actualizó (winget salió con código $code)"
            Add-Result "$($item.Command) (update)" $after $false "winget salió con código $code"
        }
    }
}

function Update-EngramBinary {
    Write-Step 'Actualizar binario de Engram'

    # Engram no tiene subcomando de actualización propio, así que la única vía
    # es reinstalar desde el release. Para no bajar ~30 MB en cada corrida
    # cuando no hay nada nuevo, se compara la versión instalada contra el tag
    # del último release y solo se reinstala si difieren.
    $engram = Join-Path $env:USERPROFILE '.pi\agent\bin\engram.exe'

    if (-not (Test-Path -LiteralPath $engram)) {
        Write-Warn 'El binario de Engram no está instalado; se instala desde el release.'
        Install-Engram
        return
    }

    $installedRaw = Get-ToolVersion $engram @('version')
    $installed = ''
    if ($installedRaw -match '(\d+\.\d+\.\d+)') { $installed = $Matches[1] }

    $latest = ''
    try {
        $release = Invoke-RestMethod -Uri $EngramReleasesApi -Headers @{ 'User-Agent' = 'kkapsca-windows-installer' }
        $latest = $release.tag_name -replace '^v', ''
    }
    catch {
        Write-Warn "No se pudo consultar el último release de Engram: $($_.Exception.Message)"
    }

    if (-not $installed) {
        Write-Warn 'No se pudo determinar la versión instalada; se reinstala desde el release.'
        Install-Engram -Force
        return
    }

    if (-not $latest) {
        Write-Warn "No se pudo determinar la última versión publicada. Instalada: $installed. Se omite la actualización; verificá a mano en https://github.com/Gentleman-Programming/engram/releases"
        Add-Result 'engram (update)' $installed $true 'sin verificación de última versión'
        return
    }

    if ($installed -eq $latest) {
        Write-Ok "engram $installed ya es la última versión"
        Add-Result 'engram (update)' $installed $true 'ya estaba al día'
        return
    }

    Write-Host "  instalada $installed, última ${latest}: se reinstala" -ForegroundColor Gray
    Install-Engram -Force
}

function Show-Status {
    Write-Step 'Estado de versiones'

    if (Test-Command 'gentle-ai') {
        $gentleAiVersion = Get-ToolVersion 'gentle-ai' @('version')
        if ($gentleAiVersion) { Write-Host "  gentle-ai $gentleAiVersion" -ForegroundColor Gray }
    }
    else {
        Write-Warn 'gentle-ai no está instalado.'
    }

    foreach ($tool in @('pi', 'herdr')) {
        if (Test-Command $tool) {
            $version = Get-ToolVersion $tool @('--version')
            Write-Host "  $tool $version" -ForegroundColor Gray
        }
    }

    $engram = Join-Path $env:USERPROFILE '.pi\agent\bin\engram.exe'
    if (Test-Path -LiteralPath $engram) {
        $engramVersion = Get-ToolVersion $engram @('version')
        if ($engramVersion) { Write-Host "  engram $engramVersion" -ForegroundColor Gray }
    }

    if (Test-Path -LiteralPath $GentleCfgPath) {
        Write-Host "  gentle-cfg presente en $GentleCfgPath" -ForegroundColor Gray
    }
    if (Test-Command 'codegraph') {
        Write-Host '  codegraph presente' -ForegroundColor Gray
    }

    Write-Host ''
    Write-Host 'Para comparar lo instalado contra la última versión publicada: gentle-ai update' -ForegroundColor Gray
    Write-Host '(ese comando NO es de solo lectura: escribe ~/.gentle-ai/state.json y puede registrar telemetría)' -ForegroundColor Gray
    Write-Host 'Por eso este modo no lo ejecuta.'
}

function Invoke-Update {
    Write-Step 'Modo actualización'

    if ($Channel -eq 'main') {
        if (-not (Test-GentleCfg)) {
            throw "El canal 'main' requiere gentle-cfg en '$GentleCfgPath', bash y jq. Copiá gentle-cfg a esa ruta, instalá jq y volvé a correr el script. Si no tenés gentle-cfg, usá el canal stable."
        }
        # Igual que en la instalación, se evita 'all main' y 'update main'
        # porque arrastran el engram_install de gentle-cfg, que no funciona en
        # Windows. Engram se actualiza aparte, desde el zip oficial.
        Write-Host '  Canal main: gentle-cfg por herramienta' -ForegroundColor Gray
        foreach ($cfgArgs in @('gentle-ai main', 'gentle-shell main')) {
            $code = Invoke-GentleCfg -Arguments $cfgArgs
            if ($null -eq $code) {
                Add-Result "gentle-cfg $cfgArgs" '' $true 'se ejecutaría'
                continue
            }
            if ($code -ne 0) {
                Add-Result "gentle-cfg $cfgArgs" '' $false "salió con código $code"
                continue
            }
            Add-Result "gentle-cfg $cfgArgs" 'ok' $true
        }
    }

    Update-Prerequisites
    Update-Pi
    Update-GentleAi
    Update-Herdr

    Update-EngramBinary

    Write-Step 'Paquetes de pi'
    if ($script:DryRun) {
        Write-Warn 'pi update --extensions se ejecutaría (omitido)'
        Add-Result 'paquetes de pi (update)' '' $true 'se ejecutaría'
        return
    }
    & pi update --extensions
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "pi update --extensions falló (código $LASTEXITCODE)."
        Add-Result 'paquetes de pi (update)' '' $false 'update falló'
        return
    }
    Write-Ok 'paquetes de pi actualizados'
    Add-Result 'paquetes de pi (update)' 'ok' $true
}

function Show-Summary {
    # En modo -Status no hubo instalación ni actualización, así que el resumen
    # de instalación no aplica.
    if ($Status) { return }

    Write-Step 'Resumen'

    foreach ($result in $script:Results) {
        $version = if ($result.Version) { $result.Version } else { '-' }
        $status = if ($result.Ok) { 'ok' } else { 'err' }
        $line = '  [{0}]  {1,-22} {2}' -f $status, $result.Component, $version
        if ($result.Detail) { $line += "  ($($result.Detail))" }
        if ($result.Ok) { Write-Host $line -ForegroundColor Green } else { Write-Host $line -ForegroundColor Red }
    }

    Write-Host ''
    if ($script:DryRun) {
        Write-Host 'Modo -WhatIf: no se modificó nada. Los pasos marcados "se instalaría" no se ejecutaron.' -ForegroundColor Yellow
        Write-Host 'Pasos que este instalador no cubre: codegraph, settings.json, mcp.json, subagents.json, pi-engram init y la verificación funcional final. Están en docs/windows-native-setup.md.' -ForegroundColor Yellow
        return
    }

    if ($script:Failed.Count -eq 0) {
        Write-Host 'Ecosistema instalado. Reiniciá la terminal y arrancá pi.' -ForegroundColor Green
        Write-Host 'Faltan los pasos manuales del runbook: codegraph, settings.json, mcp.json, subagents.json, pi-engram init y la verificación final.' -ForegroundColor Yellow
    }
    else {
        Write-Host "Por revisar ($($script:Failed.Count)):" -ForegroundColor Yellow
        foreach ($failure in $script:Failed) { Write-Host "  - $failure" -ForegroundColor Yellow }
    }
}

# --- Ejecución -------------------------------------------------------------

Write-Host ''
Write-Host '  Ecosistema Gentle AI para Windows nativo' -ForegroundColor Cyan
Write-Host '  ========================================' -ForegroundColor Cyan

if ($script:DryRun) {
    Write-Host ''
    Write-Host '  Modo -WhatIf: se muestra lo que haría, sin tocar la máquina.' -ForegroundColor Yellow
}

Show-Preflight

if ($Status) {
    Show-Status
}
elseif ($Update) {
    Invoke-Update
}
else {
    Install-Prerequisites
    Install-Pi
    Install-Engram
    Install-GentleAi
    Install-PiPackages

    if (-not $SkipHerdr) { Install-Herdr }
    else { Write-Step 'herdr (omitido por -SkipHerdr)' }

    if (-not $SkipSkills) { Install-Skills }
    else { Write-Step 'Skills (omitidas por -SkipSkills)' }
}

Show-Summary

if ($script:DryRun) { exit 0 }
if ($script:Failed.Count -gt 0) { exit 1 }
exit 0
