# Instrucciones para Cambiar el Icono de la Aplicación

## Paso 1: Preparar tu icono

Necesitas crear un icono en formato PNG con estas características:
- **Tamaño recomendado**: 1024x1024 píxeles (mínimo 512x512)
- **Formato**: PNG con fondo transparente o de color sólido
- **Nombre del archivo**: `app_icon.png`
- **Ubicación**: Guárdalo en la carpeta `assets/icon/`

### Para iconos adaptativos (Android moderno - Recomendado):
También puedes crear:
- `app_icon_foreground.png` - Solo el elemento principal del icono (1024x1024)
- El fondo se configurará con color sólido en `pubspec.yaml`

## Paso 2: Generar los iconos

Una vez que tengas tu archivo `app_icon.png` en `assets/icon/`, ejecuta:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## Paso 3: Reconstruir la aplicación

```bash
flutter clean
flutter build apk --debug
```

## Configuración actual en pubspec.yaml:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon_foreground.png"
  # Iconos adaptativos para Android moderno
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

## Personalización:

- Cambia `#FFFFFF` por el color de fondo que prefieras (en hexadecimal)
- Si no quieres icono adaptativo, quita las líneas `adaptive_icon_*`
- Puedes cambiar `ios: true` a `ios: false` si solo quieres cambiar Android

## Notas importantes:

1. El archivo de icono debe estar en `assets/icon/app_icon_foreground.png`
2. Después de generar los iconos, el cambio se verá al instalar la app
3. En modo debug, el icono puede tardar en actualizarse
4. Para ver el cambio inmediatamente, desinstala y reinstala la app
5. **Si el build falla por archivos bloqueados**:
   - Ejecuta: `taskkill /f /im dart.exe` y `taskkill /f /im java.exe`
   - Luego: `Remove-Item -Recurse -Force .\build`
   - Finalmente: `flutter run`
