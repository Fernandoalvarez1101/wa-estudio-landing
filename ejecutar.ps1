# Script simple para ejecutar Flutter
# Cambiar al directorio del script
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)

Write-Host "🚀 Ejecutando Wä Estudio..." -ForegroundColor Green
Write-Host "📂 Directorio: $(Get-Location)" -ForegroundColor Yellow

# Ejecutar Flutter
flutter run

# Mantener la ventana abierta
Read-Host "Presiona Enter para cerrar"
