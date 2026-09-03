param(
    [Parameter(Position = 0)]
    [ValidateSet("build", "rebuild", "clean", "build-all", "clean-all", "list", "help")]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$Lab = "",

    [Parameter(Position = 2)]
    [ValidateSet("vi", "en")]
    [string]$Language = "vi"
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Paths
# ============================================================================

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$DocumentationRoot = Join-Path $RepoRoot "documentation"
$DocsRoot = Join-Path $RepoRoot "docs"


# ============================================================================
# Utilities
# ============================================================================

function Write-Info([string]$Message)
{
    Write-Host "[EduFramework Labs] $Message"
}


function Assert-Typst
{
    if (-not (Get-Command typst -ErrorAction SilentlyContinue))
    {
        throw "Typst was not found in PATH."
    }
}


function Normalize-LabName([string]$Name)
{
    if ([string]::IsNullOrWhiteSpace($Name))
    {
        throw "Lab name is required. Example: .\lab.cmd build lab_01_blink_led vi"
    }

    if ($Name.EndsWith(".typ"))
    {
        return [System.IO.Path]::GetFileNameWithoutExtension($Name)
    }

    return $Name
}


function Get-SourcePath([string]$Name, [string]$Lang)
{
    $BaseName = Normalize-LabName $Name

    return Join-Path `
        (Join-Path $DocumentationRoot $Lang) `
        ($BaseName + ".typ")
}


function Get-OutputPath([string]$Name, [string]$Lang)
{
    $BaseName = Normalize-LabName $Name

    return Join-Path `
        (Join-Path $DocsRoot $Lang) `
        ($BaseName + ".pdf")
}


# ============================================================================
# Build
# ============================================================================

function Build-Lab([string]$Name, [string]$Lang)
{
    Assert-Typst

    $Source = Get-SourcePath $Name $Lang
    $Output = Get-OutputPath $Name $Lang

    if (-not (Test-Path $Source))
    {
        throw "Source file not found: $Source"
    }

    $OutputDir = Split-Path $Output -Parent

    New-Item `
        -ItemType Directory `
        -Force `
        -Path $OutputDir | Out-Null

    Write-Info "Building [$Lang] $(Split-Path $Source -Leaf)"

    Push-Location $RepoRoot

    try
    {
        & typst compile --root . $Source $Output

        if ($LASTEXITCODE -ne 0)
        {
            throw "Typst compilation failed with exit code $LASTEXITCODE."
        }
    }
    finally
    {
        Pop-Location
    }

    Write-Info "Created: $Output"
}


# ============================================================================
# Clean
# ============================================================================

function Clean-Lab([string]$Name, [string]$Lang)
{
    $Output = Get-OutputPath $Name $Lang

    if (Test-Path $Output)
    {
        Remove-Item $Output -Force
        Write-Info "Removed: $Output"
    }
    else
    {
        Write-Info "Nothing to clean: $Output"
    }
}


# ============================================================================
# Build all
# ============================================================================

function Build-All([string]$Lang)
{
    Assert-Typst

    $SourceDir = Join-Path $DocumentationRoot $Lang

    if (-not (Test-Path $SourceDir))
    {
        throw "Documentation directory not found: $SourceDir"
    }

    $Files = Get-ChildItem `
        $SourceDir `
        -Filter "lab_*.typ" `
        -File |
        Sort-Object Name

    if ($Files.Count -eq 0)
    {
        Write-Info "No lab_*.typ files found for language '$Lang'."
        return
    }

    foreach ($File in $Files)
    {
        Build-Lab $File.BaseName $Lang
    }
}


# ============================================================================
# Clean all
# ============================================================================

function Clean-All([string]$Lang)
{
    $OutputDir = Join-Path $DocsRoot $Lang

    if (-not (Test-Path $OutputDir))
    {
        Write-Info "Nothing to clean for language '$Lang'."
        return
    }

    $Files = Get-ChildItem `
        $OutputDir `
        -Filter "lab_*.pdf" `
        -File

    if ($Files.Count -eq 0)
    {
        Write-Info "Nothing to clean for language '$Lang'."
        return
    }

    foreach ($File in $Files)
    {
        Remove-Item $File.FullName -Force
        Write-Info "Removed: $($File.FullName)"
    }
}


# ============================================================================
# List labs
# ============================================================================

function List-Labs([string]$Lang)
{
    $SourceDir = Join-Path $DocumentationRoot $Lang

    if (-not (Test-Path $SourceDir))
    {
        Write-Info "Documentation directory not found: $SourceDir"
        return
    }

    $Files = Get-ChildItem `
        $SourceDir `
        -Filter "lab_*.typ" `
        -File |
        Sort-Object Name

    Write-Info "Available labs [$Lang]:"

    if ($Files.Count -eq 0)
    {
        Write-Host "  (none)"
        return
    }

    foreach ($File in $Files)
    {
        Write-Host "  $($File.BaseName)"
    }
}


# ============================================================================
# Help
# ============================================================================

function Show-Help
{
    @"

EduFramework Laboratory Documentation Tool

Usage:
  .\lab.cmd <command> [lab_name] [vi|en]

Commands:

  build
      Build one lab.

  rebuild
      Clean and build one lab again.

  clean
      Delete the generated PDF of one lab.

  build-all
      Build all lab_*.typ files of one language.

  clean-all
      Delete all generated lab PDFs of one language.

  list
      List available labs.

  help
      Show this help.


Examples:

  .\lab.cmd build lab_01_blink_led vi

  .\lab.cmd build lab_01_blink_led en

  .\lab.cmd rebuild lab_01_blink_led vi

  .\lab.cmd clean lab_01_blink_led vi

  .\lab.cmd build-all vi

  .\lab.cmd build-all en

  .\lab.cmd clean-all vi

  .\lab.cmd list vi


Output:

  documentation/vi/lab_01_blink_led.typ

              ->

  docs/vi/lab_01_blink_led.pdf


Notes:

  - The .typ extension is optional.
  - Default language is vi.
  - Typst must be available in PATH.
  - Compilation uses "typst compile --root ."

"@ | Write-Host
}


# ============================================================================
# Command dispatcher
# ============================================================================

try
{
    switch ($Command)
    {
        "build"
        {
            Build-Lab $Lab $Language
        }

        "rebuild"
        {
            Clean-Lab $Lab $Language
            Build-Lab $Lab $Language
        }

        "clean"
        {
            Clean-Lab $Lab $Language
        }

        "build-all"
        {
            Build-All $Language
        }

        "clean-all"
        {
            Clean-All $Language
        }

        "list"
        {
            List-Labs $Language
        }

        default
        {
            Show-Help
        }
    }
}
catch
{
    Write-Host `
        "[EduFramework Labs] ERROR: $($_.Exception.Message)" `
        -ForegroundColor Red

    exit 1
}