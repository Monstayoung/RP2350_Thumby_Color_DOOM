#!/usr/bin/env pwsh
# Thumby Color DOOM Flash Script
# Flashes doom1.whx (game data) and UF2 (program) in correct order

$ErrorActionPreference = "Stop"

Write-Host @"
╔════════════════════════════════════════╗
║   Thumby Color DOOM Flash Utility     ║
╚════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Check if picotool exists
if (-not (Get-Command picotool -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: picotool not found!" -ForegroundColor Red
    Write-Host "Install from: https://github.com/raspberrypi/picotool" -ForegroundColor Yellow
    exit 1
}

# Check files exist
$whxPath = "binaries/doom1.whx"
$uf2Path = "binaries/thumbycolor-doom-rumble-sfx.uf2"

if (-not (Test-Path $whxPath)) {
    Write-Host "ERROR: $whxPath not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $uf2Path)) {
    Write-Host "ERROR: $uf2Path not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nMake sure Thumby Color is in BOOTSEL mode!" -ForegroundColor Yellow
Write-Host "(Hold BOOT button while connecting USB)`n" -ForegroundColor Yellow
Write-Host "Press Enter to continue or Ctrl+C to cancel..."
$null = Read-Host

# Flash game data
Write-Host "`n[1/2] Flashing doom1.whx to 0x10100000..." -ForegroundColor Cyan
picotool load -v $whxPath -t bin -o 0x10100000
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to flash WHX file!" -ForegroundColor Red
    exit 1
}

# Flash program
Write-Host "`n[2/2] Flashing UF2 program..." -ForegroundColor Cyan
picotool load -v $uf2Path
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to flash UF2 file!" -ForegroundColor Red
    exit 1
}

# Reboot
Write-Host "`nRebooting Thumby Color..." -ForegroundColor Green
picotool reboot

Write-Host @"

╔════════════════════════════════════════╗
║  ✓ Flash Complete!                     ║
║  DOOM should start automatically       ║
╚════════════════════════════════════════╝
"@ -ForegroundColor Green
