@echo off
echo === DESPLEGANDO FIREBASE FUNCTIONS ===
echo.

echo 1. Verificando proyecto Firebase...
firebase use agendawa-5d8a1

echo.
echo 2. Instalando dependencias...
cd functions
npm install

echo.
echo 3. Desplegando functions...
cd ..
firebase deploy --only functions

echo.
echo === DESPLIEGUE COMPLETADO ===
pause
