@echo off
echo Iniciando creacion de emuladores para capturas Google Play Store
echo.

echo Creando Pixel 7 API 33...
avdmanager create avd -n "Pixel_7_Screenshots" -k "system-images;android-33;google_apis;x86_64" -d "pixel_7" --force

echo.
echo Creando Pixel Tablet API 33...
avdmanager create avd -n "Pixel_Tablet_Screenshots" -k "system-images;android-33;google_apis;x86_64" -d "pixel_tablet" --force

echo.
echo Emuladores creados. Para iniciarlos usa:
echo emulator -avd Pixel_7_Screenshots
echo emulator -avd Pixel_Tablet_Screenshots

pause
