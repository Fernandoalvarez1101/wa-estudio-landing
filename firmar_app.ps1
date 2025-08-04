# Script para firmar la aplicación Wä Estudio
# Ejecutar como: .\firmar_app.ps1

Write-Host "🔐 Iniciando proceso de firma de Wä Estudio..." -ForegroundColor Green

# Cambiar al directorio del proyecto
Set-Location "c:\Users\ferna\agenda_wa"

# Verificar si existe el keystore
$keystorePath = "android\wa-estudio-key.jks"
if (-not (Test-Path $keystorePath)) {
    Write-Host "⚠️  No se encontró el keystore. Creando uno nuevo..." -ForegroundColor Yellow
    
    # Crear directorio android si no existe
    if (-not (Test-Path "android")) {
        New-Item -ItemType Directory -Path "android"
    }
    
    Write-Host "📝 Se necesita crear un keystore. Por favor proporciona la siguiente información:" -ForegroundColor Cyan
    Write-Host "   - Contraseña del keystore (mínimo 6 caracteres)" -ForegroundColor White
    Write-Host "   - Nombre y apellido" -ForegroundColor White
    Write-Host "   - Unidad organizacional (ej: Desarrollo)" -ForegroundColor White
    Write-Host "   - Organización (ej: Wä Estudio)" -ForegroundColor White
    Write-Host "   - Ciudad" -ForegroundColor White
    Write-Host "   - Estado/Provincia" -ForegroundColor White
    Write-Host "   - Código de país (ej: ES, MX, US)" -ForegroundColor White
    Write-Host ""
    
    # Crear keystore con información predeterminada
    $keystoreCmd = @"
keytool -genkey -v -keystore android\wa-estudio-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wa-estudio -dname "CN=Wä Estudio Developer, OU=Mobile Development, O=Wä Estudio, L=Ciudad, S=Estado, C=ES" -storepass waestudio123 -keypass waestudio123
"@
    
    Write-Host "🔑 Creando keystore con datos predeterminados..." -ForegroundColor Blue
    Invoke-Expression $keystoreCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Keystore creado exitosamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al crear keystore" -ForegroundColor Red
        exit 1
    }
}

# Crear archivo key.properties si no existe
$keyPropertiesPath = "android\key.properties"
if (-not (Test-Path $keyPropertiesPath)) {
    Write-Host "📄 Creando archivo key.properties..." -ForegroundColor Blue
    
    $keyPropertiesContent = @"
storePassword=waestudio123
keyPassword=waestudio123
keyAlias=wa-estudio
storeFile=wa-estudio-key.jks
"@
    
    Set-Content -Path $keyPropertiesPath -Value $keyPropertiesContent -Encoding UTF8
    Write-Host "✅ Archivo key.properties creado" -ForegroundColor Green
}

# Verificar build.gradle.kts
Write-Host "🔧 Verificando configuración de firma..." -ForegroundColor Blue

$buildGradlePath = "android\app\build.gradle.kts"
if (Test-Path $buildGradlePath) {
    $buildGradleContent = Get-Content $buildGradlePath -Raw
    
    if ($buildGradleContent -notmatch "signingConfigs") {
        Write-Host "⚠️  Configuración de firma no encontrada en build.gradle.kts" -ForegroundColor Yellow
        Write-Host "📝 Se necesita actualizar manualmente el archivo build.gradle.kts" -ForegroundColor White
    } else {
        Write-Host "✅ Configuración de firma encontrada" -ForegroundColor Green
    }
}

# Limpiar proyecto
Write-Host "🧹 Limpiando proyecto..." -ForegroundColor Blue
flutter clean

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Blue
flutter pub get

# Compilar APK firmado
Write-Host "🏗️  Compilando APK firmado..." -ForegroundColor Blue
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 ¡APK firmado creado exitosamente!" -ForegroundColor Green
    Write-Host "📱 Archivo ubicado en: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    
    # Mostrar información del archivo
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $apkInfo = Get-Item $apkPath
        $sizeMB = [math]::Round($apkInfo.Length / 1MB, 2)
        Write-Host "📊 Tamaño: $sizeMB MB" -ForegroundColor White
        Write-Host "📅 Fecha: $($apkInfo.LastWriteTime)" -ForegroundColor White
        
        # Crear copia con versión
        $fecha = Get-Date -Format "dd-MM-yyyy"
        $nombreVersionado = "WA_Estudio_v2.1_STARS_$fecha.apk"
        Copy-Item $apkPath $nombreVersionado
        Write-Host "📋 Copia creada: $nombreVersionado" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Error al compilar APK" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔐 Información del keystore:" -ForegroundColor Cyan
Write-Host "   📁 Archivo: android\wa-estudio-key.jks" -ForegroundColor White
Write-Host "   🔑 Alias: wa-estudio" -ForegroundColor White
Write-Host "   🔒 Contraseña: waestudio123" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Guarda el keystore y las contraseñas en un lugar seguro" -ForegroundColor Yellow
Write-Host "   Sin el keystore no podrás actualizar la app en Play Store" -ForegroundColor Red

Write-Host ""
Write-Host "✅ Proceso de firma completado exitosamente" -ForegroundColor Green
