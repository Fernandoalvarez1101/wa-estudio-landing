@echo off
title Wä Estudio - Flutter App

REM Cambiar al directorio del script
cd /d "%~dp0"

echo.
echo 🚀 Iniciando aplicación Wä Estudio...
echo 📂 Directorio: %CD%
echo.

REM Verificar que estamos en el directorio correcto
if not exist "pubspec.yaml" (
    echo ❌ Error: No se encontró pubspec.yaml
    echo    Asegúrate de estar en el directorio del proyecto Flutter
    pause
    exit /b 1
)

REM Verificar Flutter
echo 🔍 Verificando Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter no está instalado o no está en PATH
    echo    Instala Flutter desde: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo ✅ Flutter está instalado

REM Verificar dispositivos
echo 📱 Verificando dispositivos disponibles...
echo    Si no aparecen dispositivos, conecta uno o inicia un emulador
flutter devices

echo.
set /p clean="¿Quieres limpiar el build anterior? (y/N): "
if /i "%clean%"=="y" (
    echo 🧹 Limpiando proyecto...
    flutter clean
    echo 📦 Obteniendo dependencias...
    flutter pub get
)

echo.
echo 🎯 Ejecutando aplicación...
echo    Para hot reload: presiona 'r'
echo    Para hot restart: presiona 'R'
echo    Para salir: presiona 'q'
echo.

flutter run

pause
