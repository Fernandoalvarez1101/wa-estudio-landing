@echo off
title Wä Estudio - Compilar APK Release

REM Cambiar al directorio del script
cd /d "%~dp0"

echo.
echo 🏗️  Compilando APK de Release para Wä Estudio...
echo 📂 Directorio: %CD%
echo.

REM Verificar que estamos en el directorio correcto
if not exist "pubspec.yaml" (
    echo ❌ Error: No se encontró pubspec.yaml
    echo    Asegúrate de estar en el directorio del proyecto Flutter
    pause
    exit /b 1
)

echo 🧹 Limpiando proyecto...
flutter clean

echo 📦 Obteniendo dependencias...
flutter pub get

echo 🚀 Compilando APK de Release...
echo    Esto puede tomar varios minutos...
echo.

flutter build apk --release

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ ¡APK de Release compilado exitosamente!
    echo.
    echo 📍 Ubicación del APK:
    echo    %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 📊 Información del archivo:
    dir "build\app\outputs\flutter-apk\app-release.apk"
    echo.
    echo 🎉 ¡Listo para distribuir!
    echo    Este APK contiene todas las funciones nuevas:
    echo    ✅ Gestión de Terapeutas
    echo    ✅ Gestión de Servicios
    echo    ✅ Sistema completo actualizado
) else (
    echo ❌ Error: No se pudo generar el APK
    echo    Revisa los errores anteriores
)

echo.
pause
