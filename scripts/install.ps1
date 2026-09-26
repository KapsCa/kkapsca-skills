#!/usr/bin/env pwsh
<#
.SYNOPSIS
    kkapsca-skills — universal installer for native Windows PowerShell.

.DESCRIPTION
    Installs the skills of KapsCa/kkapsca-skills into the skills directory of
    any agent, WITHOUT cloning the repository (uses the GitHub tarball).

    The one-liner:
        irm https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.ps1 | iex

.NOTES
    Mirrors scripts/install.sh: same flags, same agents, same conflict rules.

.AUTHOR
    KapsCa — kkapsca-skills
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$RepoOwner = 'KapsCa'
$RepoName  = 'kkapsca-skills'
$DefaultRef   = 'main'
$DefaultAgent = 'agents'

# Known agent -> skills directory ($HOME-expanded at startup).
$KnownAgents = [ordered]@{
    'agents'   = Join-Path $HOME '.agents\skills'              # cross-agent convention (default)
    'opencode' = Join-Path $HOME '.config\opencode\skills'
    'claude'   = Join-Path $HOME '.claude\skills'
    'codex'    = Join-Path $HOME '.codex\skills'
    'gemini'   = Join-Path $HOME '.gemini\skills'
    'copilot'  = Join-Path $HOME '.copilot\skills'
    'kilo'     = Join-Path $HOME '.config\kilo\skills'
    'pi'       = Join-Path $HOME '.agents\skills'              # same directory as agents
}

# ============================================================================
# Output helpers
# ============================================================================

function Write-Step   { param([string]$Msg) Write-Host "`n==> $Msg" -ForegroundColor Cyan }
function Write-Ok     { param([string]$Msg) Write-Host "[ok]    $Msg" -ForegroundColor Green }
function Write-Info   { param([string]$Msg) Write-Host "[info]  $Msg" -ForegroundColor Blue }
function Write-Warn2  { param([string]$Msg) Write-Host "[warn]  $Msg" -ForegroundColor Yellow }
function Write-Err2   { param([string]$Msg) Write-Host "[error] $Msg" -ForegroundColor Red }
function Write-Fatal  { param([string]$Msg) Write-Err2 $Msg; exit 1 }

# ============================================================================
# Help
# ============================================================================

function Show-Help {
@'

kkapsca-skills installer (PowerShell)

Install the skills of KapsCa/kkapsca-skills into the skills directory of any
agent, without cloning the repository.

Usage: install.ps1 [OPTIONS]

Options:
  -Agent NAME    Install into a known agent's skills directory:
                 agents, opencode, claude, codex, gemini, copilot, kilo, pi
                 (default: agents)
  -All           Install into every known agent directory that already exists
  -Dir PATH      Install into an arbitrary directory: use this when your agent
                 is not in the list above (any directory works)
  -List          Print the known agents, their directories and which ones
                 exist; changes nothing on disk
  -Copy          Make physical copies instead of symlinks
  -Update        Re-download the repository into the cache before installing
  -Ref REF       Branch or tag to install from (default: main)
  -Help          Show this help

Examples:
  irm https://raw.githubusercontent.com/KapsCa/kkapsca-skills/main/scripts/install.ps1 | iex
  ./install.ps1 -Agent claude
  ./install.ps1 -All
  ./install.ps1 -Dir "$HOME\someagent\skills"   # any agent at all
  ./install.ps1 -Update -Ref a-feature-branch

The repository tarball is cached under:
  ${env:LOCALAPPDATA}\kkapsca-skills\
'@
}

# ============================================================================
# Target resolution
# ============================================================================

function Resolve-AgentDir {
    param([string]$Name)
    foreach ($key in $KnownAgents.Keys) {
        if ($key -eq $Name) { return $KnownAgents[$key] }
    }
    return $null
}

function Resolve-Targets {
    param([string]$Agent, [switch]$All, [string]$Dir)

    $targets = New-Object 'System.Collections.Generic.List[string]'

    if ($Dir) {
        $targets.Add($Dir)
        return ,$targets
    }

    if ($Agent) {
        $resolved = Resolve-AgentDir -Name $Agent
        if ($null -eq $resolved) {
            Write-Err2 "Unknown agent: $Agent"
            Write-Err2 "Known agents: $($KnownAgents.Keys -join ', ')"
            Write-Err2 "Any other agent is served by its skills directory: -Dir <path>"
            Write-Fatal "Fix the target or use -Help."
        }
        $targets.Add($resolved)
        return ,$targets
    }

    if ($All) {
        foreach ($key in $KnownAgents.Keys) {
            if (Test-Path -LiteralPath $KnownAgents[$key] -PathType Container) {
                $targets.Add($KnownAgents[$key])
            }
        }
        if ($targets.Count -eq 0) {
            Write-Fatal "No known agent directory exists on this machine. Check -List, or point at any path with -Dir <path>."
        }
        return ,$targets
    }

    # No flag: there is no safe way to prompt under `irm | iex` (the pipeline
    # carries the script, and a Read-Host would block it), so always use the
    # default and say so clearly.
    $target = Resolve-AgentDir -Name $DefaultAgent
    Write-Host ""
    Write-Host "No -Agent/-All/-Dir given: installing into the default '$DefaultAgent' directory: $target"
    Write-Host  "Use -Agent <name>, -All or -Dir <path> to choose another destination."
    $targets.Add($target)
    return ,$targets
}

# ============================================================================
# Repository fetch: GitHub tarball, cached under $env:LOCALAPPDATA.
# ============================================================================

function Get-CacheDir {
    if ($env:KKAPSCA_CACHE_DIR) { return $env:KKAPSCA_CACHE_DIR }
    if ($env:XDG_DATA_HOME)     { return (Join-Path $env:XDG_DATA_HOME 'kkapsca-skills') }
    return (Join-Path $env:LOCALAPPDATA 'kkapsca-skills')
}

function Test-Prerequisites {
    Write-Step "Checking prerequisites"
    $tarCmd = Get-Command tar.exe -ErrorAction SilentlyContinue
    if (-not $tarCmd) {
        Write-Fatal "'tar.exe' was not found. Windows 10 1803+ ships it: run the installer from a normal PowerShell window, or install bsdtar."
    }
    Write-Ok "tar.exe available"
}

function Update-Cache {
    param([string]$Ref, [switch]$Force)

    $cacheDir  = Get-CacheDir
    $marker    = Join-Path $cacheDir '.repo-ref'
    Write-Step "Fetching $RepoOwner/$RepoName (ref: $Ref)"

    if (-not $Force -and (Test-Path -LiteralPath (Join-Path $cacheDir 'scripts\install-opencode-skills.sh') -PathType Leaf) `
        -and (Test-Path -LiteralPath $marker -PathType Leaf) `
        -and ((Get-Content -LiteralPath $marker -Raw).Trim() -eq $Ref)) {
        Write-Info "Reusing cached copy of ref $Ref (use -Update to re-download)"
        return
    }

    if ($Force) {
        Write-Info "Re-downloading the repository (-Update)"
    }

    $tmp = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) "kkapsca.$([guid]::NewGuid().ToString('N'))")
    try {
        $tgz = Join-Path $tmp 'repo.tar.gz'
        $url = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Ref.tar.gz"
        Write-Info "Downloading $url"
        try {
            Invoke-WebRequest -Uri $url -OutFile $tgz -UseBasicParsing
        } catch {
            # Branch ref failed: try the tag endpoint before giving up.
            $url = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$Ref.tar.gz"
            Write-Info "Branch ref failed; trying tag endpoint: $url"
            try {
                Invoke-WebRequest -Uri $url -OutFile $tgz -UseBasicParsing
            } catch {
                Write-Err2 "Ref '$Ref' not found as branch or tag on $RepoOwner/$RepoName."
                Write-Fatal "Check the ref name and your network; try -Ref main."
            }
        }

        $extract = Join-Path $tmp 'extract'
        New-Item -ItemType Directory -Path $extract | Out-Null
        tar -xzf "$tgz" -C "$extract"
        if ($LASTEXITCODE -ne 0) {
            Write-Fatal "Extraction of the downloaded tarball failed."
        }

        # GitHub tarballs wrap everything in a single top-level directory.
        $top = Get-ChildItem -LiteralPath $extract -Directory | Select-Object -First 1
        if ($null -eq $top) {
            Write-Fatal "The archive is empty or has an unexpected layout."
        }

        $repoDir = Join-Path $tmp 'repo'
        Move-Item -LiteralPath $top.FullName -Destination $repoDir

        if (-not (Test-Path -LiteralPath (Join-Path $repoDir 'scripts\install-opencode-skills.sh') -PathType Leaf)) {
            Write-Fatal "The archive is broken (missing scripts/install-opencode-skills.sh)."
        }

        Set-Content -LiteralPath (Join-Path $repoDir '.repo-ref') -Value $Ref -NoNewline

        if (Test-Path -LiteralPath $cacheDir) {
            Remove-Item -LiteralPath $cacheDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $cacheDir) -Force | Out-Null
        Move-Item -LiteralPath $repoDir -Destination $cacheDir
        Write-Ok "Downloaded and verified tarball of ref $Ref"
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# Per-target install: resumes the shared inner installer with
#   OPENCODE_SKILLS_DIR -> the target directory
#   PI_SKILLS_DIR       -> a throwaway directory, deleted after
#   EXTERNAL_SKILLS_DIR -> an empty directory, so no external skills come in
# Conflict handling stays inside the inner installer: a destination this repo
# did not create is reported and left untouched.
# ============================================================================

function Install-Into {
    param([string]$Target, [switch]$Copy)

    $installer = Join-Path (Get-CacheDir) 'scripts\install-opencode-skills.sh'
    Write-Step "Installing skills into: $Target"

    if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
        Write-Info "Created $Target"
    }

    $workDir  = Join-Path ([System.IO.Path]::GetTempPath()) "kkapsca.$([guid]::NewGuid().ToString('N'))"
    $emptyDir = Join-Path $workDir 'external-empty'
    $piTarget = Join-Path $workDir 'pi-throwaway'
    New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
    New-Item -ItemType Directory -Path $piTarget -Force | Out-Null

    $env:OPENCODE_SKILLS_DIR = "$((Get-Item -LiteralPath $Target).FullName)"
    $env:PI_SKILLS_DIR       = "$((Get-Item -LiteralPath $piTarget).FullName)"
    $env:EXTERNAL_SKILLS_DIR = "$((Get-Item -LiteralPath $emptyDir).FullName)"

    try {
        $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
        if ($wsl) {
            if ($Copy) {
                wsl -e bash -c "OPENCODE_SKILLS_DIR='$env:OPENCODE_SKILLS_DIR' PI_SKILLS_DIR='$env:PI_SKILLS_DIR' EXTERNAL_SKILLS_DIR='$env:EXTERNAL_SKILLS_DIR' bash '$installer' --copy"
            } else {
                wsl -e bash -c "OPENCODE_SKILLS_DIR='$env:OPENCODE_SKILLS_DIR' PI_SKILLS_DIR='$env:PI_SKILLS_DIR' EXTERNAL_SKILLS_DIR='$env:EXTERNAL_SKILLS_DIR' bash '$installer'"
            }
        } elseif (Get-Command bash.exe -ErrorAction SilentlyContinue) {
            if ($Copy) { bash "$installer" --copy } else { bash "$installer" }
        } else {
            Write-Err2 "Native Windows install requires either 'wsl.exe' (WSL bash) or 'bash.exe' on PATH (Git Bash)."
            Write-Fatal "Install one of them, or run scripts/install.sh inside your WSL agents."
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Warn2 "Some destination under $Target already existed and was NOT created by this repo; it was left untouched."
            $script:TargetFailures.Add($Target) | Out-Null
        }
    } finally {
        Remove-Item Env:\OPENCODE_SKILLS_DIR, Env:\PI_SKILLS_DIR, Env:\EXTERNAL_SKILLS_DIR -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# -List
# ============================================================================

function Show-List {
    Write-Host ""
    Write-Host "Known agents:"
    foreach ($key in $KnownAgents.Keys) {
        $status = if (Test-Path -LiteralPath $KnownAgents[$key] -PathType Container) { 'exists' } else { 'not present' }
        Write-Host ("  {0,-8} {1}  [{2}]" -f $key, $KnownAgents[$key], $status)
    }
    Write-Host ""
    Write-Host "If your agent is not in this list, install into its skills directory with:"
    Write-Host "  -Dir C:\path\to\its\skills"
    Write-Host ""
}

# ============================================================================
# Main
# ============================================================================

$script:TargetFailures = New-Object 'System.Collections.Generic.List[string]'

$argAgent  = $null
$argAll    = $false
$argDir    = $null
$argCopy   = $false
$argUpdate = $false
$argRef    = $DefaultRef
$argList   = $false

$envAgent  = $env:KKAPSCA_AGENT
$envAll    = $env:KKAPSCA_ALL
$envDir    = $env:KKAPSCA_DIR
$envCopy   = $env:KKAPSCA_COPY
$envUpdate = $env:KKAPSCA_UPDATE
$envRef    = $env:KKAPSCA_REF
$envList   = $env:KKAPSCA_LIST

# Manual $args parsing, because 'irm | iex' never binds real [Switch]/[string]
# parameters (the parsed script runs as plain statements, not as a function
# call). Each switch case ends with 'break' before the loop advances: 'continue'
# inside a switch keeps evaluating the remaining cases instead of advancing the
# while loop.
if ($args.Count -gt 0) {
    $i = 0
    while ($i -lt $args.Count) {
        $tok = "$($args[$i])"
        switch -regex ($tok) {
            '^(-Agent|--agent)$' {
                if ($i + 1 -ge $args.Count) { Write-Err2 "-Agent requires an argument."; exit 1 }
                $argAgent = "$($args[$i + 1])"; $i += 2; break
            }
            '^(-All|--all)$'     { $argAll = $true; $i += 1; break }
            '^(-Dir|--dir)$' {
                if ($i + 1 -ge $args.Count) { Write-Err2 "-Dir requires an argument."; exit 1 }
                $argDir = "$($args[$i + 1])"; $i += 2; break
            }
            '^(-List|--list)$'   { $argList = $true; $i += 1; break }
            '^(-Copy|--copy)$'   { $argCopy = $true; $i += 1; break }
            '^(-Update|--update)$' { $argUpdate = $true; $i += 1; break }
            '^(-Ref|--ref)$' {
                if ($i + 1 -ge $args.Count) { Write-Err2 "-Ref requires an argument."; exit 1 }
                $argRef = "$($args[$i + 1])"; $i += 2; break
            }
            '^(-Help|--help|-h)$' { Show-Help; exit 0 }
            default              { Write-Err2 "Unknown option: $tok. Use -Help for usage."; exit 1 }
        }
    }
}

if ($envAgent)  { $argAgent  = $envAgent }
if ($envAll)    { $argAll    = $true }
if ($envDir)    { $argDir    = $envDir }
if ($envCopy)   { $argCopy   = $true }
if ($envUpdate) { $argUpdate = $true }
if ($envRef)    { $argRef    = $envRef }
if ($envList)   { $argList   = $true }

Write-Step "kkapsca-skills installer"
Write-Info "No clone needed; the installer fetches its own copy of the repository."

if (-not $argList) {
    Test-Prerequisites
    Update-Cache -Ref $argRef -Force:$argUpdate
}

$targets = Resolve-Targets -Agent $argAgent -All:$argAll -Dir $argDir

if ($argList) {
    Show-List
    exit 0
}

foreach ($t in $targets) {
    Install-Into -Target $t -Copy:$argCopy
}

# Summary
Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Ref:   $argRef"
Write-Host "  Cache: $(Get-CacheDir)"
Write-Host ""
Write-Host "Installed into:"
foreach ($t in $targets) {
    if (Test-Path -LiteralPath $t -PathType Container) {
        Write-Host "  + $t" -ForegroundColor Green
    } else {
        Write-Host "  - $t (missing)" -ForegroundColor Red
    }
}
if ($script:TargetFailures.Count -gt 0) {
    Write-Host ""
    Write-Host "Skipped (already existed; this repo did not create them):" -ForegroundColor Yellow
    foreach ($t in $script:TargetFailures) {
        Write-Host "  ! $t" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Nothing outside those directories was touched."
}
Write-Host ""
Write-Host "Restart each agent so it picks up the new skills."
Write-Host ""

if ($script:TargetFailures.Count -eq $targets.Count) {
    Write-Err2 "Every destination was skipped (pre-existing conflict); nothing was changed."
    exit 1
}
