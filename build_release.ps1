# Script para compilar APK de Release
# Cambiar al directorio del script
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)

Write-Host "🏗️  Compilando APK de Release para Wä Estudio..." -ForegroundColor Cyan
Write-Host "📂 Directorio: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No se encontró pubspec.yaml" -ForegroundColor Red
    Write-Host "   Asegúrate de estar en el directorio del proyecto Flutter" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "🧹 Limpiando proyecto..." -ForegroundColor Green
flutter clean

Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Green
flutter pub get

Write-Host "🚀 Compilando APK de Release..." -ForegroundColor Green
Write-Host "   Esto puede tomar varios minutos..." -ForegroundColor Yellow
Write-Host ""

flutter build apk --release

Write-Host ""
if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    Write-Host "✅ ¡APK de Release compilado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Ubicación del APK:" -ForegroundColor Cyan
    Write-Host "   $(Get-Location)\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
    Write-Host ""
    
    $apkFile = Get-Item "build\app\outputs\flutter-apk\app-release.apk"
    Write-Host "📊 Información del archivo:" -ForegroundColor Cyan
    Write-Host "   Tamaño: $([math]::Round($apkFile.Length / 1MB, 2)) MB" -ForegroundColor White
    Write-Host "   Fecha: $($apkFile.LastWriteTime)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎉 ¡Listo para distribuir!" -ForegroundColor Green
    Write-Host "   Este APK contiene todas las funciones nuevas:" -ForegroundColor Yellow
    Write-Host "   ✅ Gestión de Terapeutas" -ForegroundColor White
    Write-Host "   ✅ Gestión de Servicios" -ForegroundColor White  
    Write-Host "   ✅ Sistema completo actualizado" -ForegroundColor White
} else {
    Write-Host "❌ Error: No se pudo generar el APK" -ForegroundColor Red
    Write-Host "   Revisa los errores anteriores" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para cerrar"
