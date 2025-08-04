#!/usr/bin/env pwsh

# Script para ejecutar la aplicación Flutter
# Guarda este archivo como run_flutter.ps1

# Cambiar al directorio del script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

Write-Host "🚀 Iniciando aplicación Wä Estudio..." -ForegroundColor Cyan
Write-Host "📂 Directorio: $(Get-Location)" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No se encontró pubspec.yaml" -ForegroundColor Red
    Write-Host "   Asegúrate de estar en el directorio del proyecto Flutter" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Flutter
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Green
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter no encontrado"
    }
    Write-Host "✅ Flutter está instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter no está instalado o no está en PATH" -ForegroundColor Red
    Write-Host "   Instala Flutter desde: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Verificar dispositivos
Write-Host "📱 Verificando dispositivos disponibles..." -ForegroundColor Green
$devices = flutter devices --machine 2>$null | ConvertFrom-Json
if ($devices.Count -eq 0) {
    Write-Host "⚠️  No hay dispositivos conectados" -ForegroundColor Yellow
    Write-Host "   Opciones:" -ForegroundColor Cyan
    Write-Host "   1. Conecta un dispositivo Android" -ForegroundColor White
    Write-Host "   2. Inicia un emulador Android" -ForegroundColor White
    Write-Host "   3. Usa Chrome: flutter run -d chrome" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter cuando tengas un dispositivo listo"
}

# Limpiar build anterior (opcional)
$clean = Read-Host "¿Quieres limpiar el build anterior? (y/N)"
if ($clean -eq "y" -or $clean -eq "Y") {
    Write-Host "🧹 Limpiando proyecto..." -ForegroundColor Yellow
    flutter clean
    Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Yellow
    flutter pub get
}

# Ejecutar la aplicación
Write-Host "🎯 Ejecutando aplicación..." -ForegroundColor Green
Write-Host "   Para hot reload: presiona 'r'" -ForegroundColor Cyan
Write-Host "   Para hot restart: presiona 'R'" -ForegroundColor Cyan
Write-Host "   Para salir: presiona 'q'" -ForegroundColor Cyan
Write-Host ""

flutter run
