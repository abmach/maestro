#!/usr/bin/env pwsh
<#
.SYNOPSIS
Install init-maestro skill to user's Devin skills directory

.DESCRIPTION
This script copies the init-maestro skill from the current directory to the user's
Devin skills directory in AppData, making it available for use.

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
$BundlePath = $ScriptPath  # The current directory is the bundle path

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

# Copy skill to destination
Write-Host "Copying skill from: $SourceSkillPath" -ForegroundColor Green
Write-Host "Copying skill to: $DestSkillPath" -ForegroundColor Green
Copy-Item -Path $SourceSkillPath -Destination $DestSkillPath -Recurse -Force

# Create path.txt file in the destination skill folder
$PathTxtPath = Join-Path $DestSkillPath "path.txt"
Write-Host "Creating path.txt with bundle path: $BundlePath" -ForegroundColor Green
$BundlePath | Out-File -FilePath $PathTxtPath -Encoding utf8 -Force

Write-Host "Successfully installed $SkillName skill to: $DestSkillPath" -ForegroundColor Cyan
Write-Host "Bundle path written to path.txt: $BundlePath" -ForegroundColor Cyan
