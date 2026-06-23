#!/usr/bin/env pwsh
<#
.SYNOPSIS
Install init-maestro skill to user's Devin skills directory

.DESCRIPTION
This script copies the init-maestro skill from the current directory to the user's
Devin skills directory in AppData, making it available for use. It also creates
a zip file of the Maestro bundle (skills, assets) to make the skill
self-contained and independent of the source directory.

.EXAMPLE
.\install-init-maestro.ps1
#>

$ErrorActionPreference = "Stop"

# Define paths
$ScriptPath = $PSScriptRoot
$SkillName = "init-maestro"
$SourceSkillPath = Join-Path $ScriptPath "skills\$SkillName"
$DestSkillsPath = "$env:APPDATA\devin\skills"
$DestSkillPath = Join-Path $DestSkillsPath $SkillName
$BundleZipPath = Join-Path $DestSkillPath "bundle.zip"

# Check if source skill exists
if (-not (Test-Path $SourceSkillPath)) {
    Write-Error "Source skill not found at: $SourceSkillPath"
    exit 1
}

# Create destination skills directory if it doesn't exist
if (-not (Test-Path $DestSkillsPath)) {
    Write-Host "Creating destination directory: $DestSkillsPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $DestSkillsPath -Force | Out-Null
}

# Remove existing skill if it exists
if (Test-Path $DestSkillPath) {
    Write-Host "Removing existing skill at: $DestSkillPath" -ForegroundColor Yellow
    Remove-Item -Path $DestSkillPath -Recurse -Force
}

# Create destination skill directory
New-Item -ItemType Directory -Path $DestSkillPath -Force | Out-Null

# Copy skill files to destination
Write-Host "Copying skill from: $SourceSkillPath" -ForegroundColor Green
Write-Host "Copying skill to: $DestSkillPath" -ForegroundColor Green
Copy-Item -Path "$SourceSkillPath\*" -Destination $DestSkillPath -Recurse -Force

# Create zip file of the Maestro bundle (skills, assets)
Write-Host "Creating bundle.zip from Maestro directory" -ForegroundColor Green

# Create a temporary directory to build the correct folder structure
$TempDir = Join-Path $env:TEMP "maestro-bundle-temp"
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# Copy skills folder structure (excluding init-maestro)
$TempSkillsPath = Join-Path $TempDir "skills"
$SourceSkillsPath = Join-Path $ScriptPath "skills"
Copy-Item -Path $SourceSkillsPath -Destination $TempSkillsPath -Recurse -Force

# Remove init-maestro from the temp skills folder
$TempInitMaestroPath = Join-Path $TempSkillsPath $SkillName
if (Test-Path $TempInitMaestroPath) {
    Remove-Item -Path $TempInitMaestroPath -Recurse -Force
}

# Copy assets folder if it exists
$SourceAssetsPath = Join-Path $ScriptPath "assets"
if (Test-Path $SourceAssetsPath) {
    Copy-Item -Path $SourceAssetsPath -Destination $TempDir -Recurse -Force
}

# Create zip from the temp directory with proper structure
$ItemPaths = @("$TempDir\skills", "$TempDir\assets")
$ItemPaths = $ItemPaths | Where-Object { Test-Path $_ }

if ($ItemPaths.Count -gt 0) {
    Compress-Archive -Path $ItemPaths -DestinationPath $BundleZipPath -Force
    Write-Host "bundle.zip created at: $BundleZipPath" -ForegroundColor Green
} else {
    Write-Warning "No bundle directories found (skills, assets) to zip"
}

# Clean up temp directory
Remove-Item -Path $TempDir -Recurse -Force

Write-Host "Successfully installed $SkillName skill to: $DestSkillPath" -ForegroundColor Cyan
Write-Host "Skill is now self-contained with bundle.zip" -ForegroundColor Cyan
