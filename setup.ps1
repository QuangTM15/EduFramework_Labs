# EduFramework Labs - Documentation Tooling Setup
# Run from any directory: powershell -NoProfile -ExecutionPolicy Bypass -File <repo>\setup.ps1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$project = Join-Path $repoRoot 'tools\docs-builder\EduFrameworkDocsBuilder.csproj'
$publishDir = Join-Path $repoRoot 'tools\docs-builder\publish'
$exe = Join-Path $publishDir 'EduFrameworkDocsBuilder.exe'

function Write-Step([string]$message) { Write-Host "`n[SETUP] $message" -ForegroundColor Cyan }
function Test-Typst {
    $command = Get-Command typst -ErrorAction SilentlyContinue
    if (-not $command) { return $false }
    try { & $command.Source --version *> $null; return ($LASTEXITCODE -eq 0) }
    catch { return $false }
}
function Test-DotNet10 {
    $command = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $command) { return $false }
    try {
        $sdks = & $command.Source --list-sdks 2>$null
        return [bool](@($sdks | Where-Object { $_ -match '^10\.' }).Count)
    } catch { return $false }
}
function Test-WebView2 {
    # EdgeUpdate registration for the Evergreen WebView2 Runtime.
    $roots = @(
        'HKCU:\Software\Microsoft\EdgeUpdate\Clients',
        'HKLM:\Software\Microsoft\EdgeUpdate\Clients',
        'HKLM:\Software\WOW6432Node\Microsoft\EdgeUpdate\Clients'
    )
    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { continue }
        foreach ($key in @(Get-ChildItem $root -ErrorAction SilentlyContinue)) {
            $entry = Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue
            if ($null -ne $entry -and $entry.name -match 'WebView2' -and
                $entry.pv -and $entry.pv -ne '0.0.0.0') { return $true }
        }
    }
    # Fallback: installed-program registry entries.
    $uninstallRoots = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($path in $uninstallRoots) {
        if (@(Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -match 'Microsoft Edge WebView2 Runtime' }).Count -gt 0) {
            return $true
        }
    }
    return $false
}
function Install-Dependency([string]$id, [string]$label) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "$label is missing and winget is unavailable. Install $label manually, reopen PowerShell, and rerun setup.ps1."
    }
    Write-Step "Installing $label ($id)..."
    & winget install --id $id --exact --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) { throw "winget failed to install $label (exit code $LASTEXITCODE)." }
}
function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

try {
    if ($env:OS -ne 'Windows_NT') { throw 'This setup supports Windows only.' }
    if (-not (Test-Path $project)) { throw "Project not found: $project" }
    if (-not (Test-Path (Join-Path $repoRoot 'tools\lab.ps1'))) {
        throw 'Cannot locate tools\lab.ps1. Run setup from a complete EduFramework_Labs clone.'
    }

    Write-Step 'Checking Typst...'
    if (-not (Test-Typst)) {
        Install-Dependency 'Typst.Typst' 'Typst'
        Refresh-Path
        if (-not (Test-Typst)) {
            throw 'Typst installation completed but typst is not available in PATH. Open a new PowerShell window and rerun setup.ps1.'
        }
    }
    & typst --version

    Write-Step 'Checking .NET 10 SDK...'
    if (-not (Test-DotNet10)) {
        Install-Dependency 'Microsoft.DotNet.SDK.10' '.NET 10 SDK'
        Refresh-Path
        if (-not (Test-DotNet10)) {
            throw '.NET 10 SDK was not detected after installation. Open a new PowerShell window and rerun setup.ps1.'
        }
    }
    & dotnet --list-sdks

    Write-Step 'Checking Microsoft Edge WebView2 Runtime...'
    if (-not (Test-WebView2)) {
        Install-Dependency 'Microsoft.EdgeWebView2Runtime' 'WebView2 Runtime'
        if (-not (Test-WebView2)) {
            Write-Warning 'WebView2 was not confirmed in the registry. If Live Preview fails, verify the WebView2 Runtime installation.'
        }
    } else {
        Write-Host '[OK] WebView2 Runtime detected.' -ForegroundColor Green
    }

    Write-Step 'Publishing EduFramework Docs Builder (Windows x64, self-contained)...'
    & dotnet publish $project -c Release -r win-x64 --self-contained true `
        '-p:PublishSingleFile=true' '-p:IncludeNativeLibrariesForSelfExtract=true' `
        -o $publishDir
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed (exit code $LASTEXITCODE)." }
    if (-not (Test-Path $exe)) { throw "Publish completed without the expected executable: $exe" }

    Write-Host "`n[SUCCESS] Documentation tooling is ready." -ForegroundColor Green
    Write-Host "Executable: $exe"
    Write-Host 'Open the EXE from inside the cloned repository.'
} catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
