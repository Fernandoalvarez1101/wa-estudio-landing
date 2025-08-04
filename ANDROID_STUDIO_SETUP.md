# Guía de Configuración Android Studio - Flutter

## 🔧 **PASOS PARA RESOLVER CONFIGURACIÓN EN ANDROID STUDIO**

### **1. Verificar apertura del proyecto**
- ✅ Abrir desde: `C:\Users\ferna\agenda_wa`
- ❌ NO abrir desde: `C:\Users\ferna\agenda_wa\android`

### **2. Verificar plugins Flutter/Dart**
1. **File** → **Settings** → **Plugins**
2. Buscar **"Flutter"** → debe estar **instalado y habilitado**
3. Buscar **"Dart"** → debe estar **instalado y habilitado**
4. Si no están, instalar y **reiniciar Android Studio**

### **3. Configurar SDK Flutter**
1. **File** → **Settings** → **Languages & Frameworks** → **Flutter**
2. **Flutter SDK path:** debe apuntar a tu instalación Flutter
3. Si está vacío, buscar la carpeta de Flutter en tu sistema

### **4. Crear configuración de ejecución**
1. **Run** → **Edit Configurations...**
2. **+ (Add New)** → **Flutter**
3. **Name:** `Main (Debug)`
4. **Dart entrypoint:** `lib/main.dart`
5. **Working directory:** `C:\Users\ferna\agenda_wa`
6. **Apply** → **OK**

### **5. Seleccionar dispositivo**
- En la barra superior: **Device selector**
- Opciones disponibles:
  - 📱 **Emulador Android** (si está configurado)
  - 🪟 **Windows (desktop)**
  - 🌐 **Chrome (web)**

### **6. Ejecutar proyecto**
- **▶️ Run** (Shift+F10)
- O botón **Run** en la barra superior

## 🚨 **SOLUCIÓN RÁPIDA SI NO FUNCIONA**

### **Invalidar caché:**
1. **File** → **Invalidate Caches...**
2. Seleccionar **"Invalidate and Restart"**
3. Esperar a que reinicie Android Studio

### **Ejecutar desde terminal:**
```bash
cd C:\Users\ferna\agenda_wa
flutter clean
flutter pub get
flutter run
```

### **Verificar Flutter:**
```bash
flutter doctor
flutter devices
```

## ✅ **CONFIGURACIONES CREADAS**

- 📁 `.idea/runConfigurations/Flutter_Configurations.xml`
- 📁 `.vscode/launch.json` (ya existía)
- 📁 `agenda_wa.code-workspace` (ya existía)

## 🎯 **RESULTADO ESPERADO**

Después de seguir estos pasos deberías poder:
1. ✅ Ver la configuración "Main (Debug)" en el selector de Run
2. ✅ Seleccionar un dispositivo (emulador/Windows/Chrome)
3. ✅ Ejecutar la app sin errores de configuración

## 📱 **DISPOSITIVOS DISPONIBLES**

Tu proyecto está configurado para ejecutar en:
- **Android** (emulador o dispositivo físico)
- **Windows Desktop** (recomendado para pruebas rápidas)
- **Web** (Chrome/Edge)

## 🆘 **SI SIGUE SIN FUNCIONAR**

1. Reiniciar Android Studio completamente
2. Verificar que el proyecto se abre como "Flutter Project"
3. Ejecutar `flutter doctor` para verificar instalación
4. Crear nuevo emulador Android si es necesario
