# Solución Pantalla Negra Emulador Android

## 🚨 **PROBLEMA: Pantalla negra en emulador**

### **CAUSAS COMUNES:**
1. Emulador no totalmente iniciado
2. Aceleración de hardware deshabilitada
3. Proceso del emulador colgado
4. Falta de memoria RAM/GPU

## 🛠️ **SOLUCIONES PASO A PASO:**

### **1. Reinicio completo del emulador**
```bash
# Cerrar procesos colgados
taskkill /f /im emulator.exe
taskkill /f /im qemu-system-x86_64.exe

# Reiniciar emulador
flutter emulators --launch Medium_Phone_API_36.0
```

### **2. Verificar aceleración de hardware**
En Android Studio:
1. **Tools** → **AVD Manager**
2. **Edit** (icono lápiz) en tu emulador
3. **Advanced Settings**
4. **Graphics:** seleccionar **"Hardware - GLES 2.0"**
5. **RAM:** mínimo 2048 MB
6. **Save**

### **3. Configuración recomendada para emulador**
- **API Level:** 33 o superior
- **RAM:** 4096 MB (si tu PC lo permite)
- **Graphics:** Hardware - GLES 2.0
- **Boot option:** Cold Boot

### **4. Alternativas si persiste el problema**

#### **Opción A: Windows Desktop (RECOMENDADO)**
```bash
flutter run -d windows
```
- ✅ Más rápido
- ✅ Más estable
- ✅ Mismas funcionalidades
- ✅ Ideal para crear cuentas de prueba

#### **Opción B: Chrome Web**
```bash
flutter run -d chrome
```
- ✅ No requiere emulador
- ✅ Desarrollo rápido
- ⚠️ Algunas funciones limitadas

### **5. Crear nuevo emulador (última opción)**
Si el problema persiste:
1. **Android Studio** → **Tools** → **AVD Manager**
2. **Create Virtual Device**
3. **Phone** → **Pixel 6**
4. **API 33** (Android 13)
5. **Advanced Settings:**
   - RAM: 4096 MB
   - Graphics: Hardware
   - Boot: Cold Boot

## 🎯 **PARA TU PROYECTO ACTUAL:**

### **Mejor opción para crear cuentas de prueba:**
```bash
# Ejecutar en Windows Desktop
flutter run -d windows
```

### **Verificar dispositivos disponibles:**
```bash
flutter devices
```

### **Si necesitas específicamente Android:**
1. Esperar 2-3 minutos después de iniciar emulador
2. Verificar que muestre pantalla de inicio Android
3. Entonces ejecutar: `flutter run`

## ✅ **RESULTADO ESPERADO:**

Después de aplicar estas soluciones:
1. ✅ Emulador inicia correctamente
2. ✅ Pantalla muestra interfaz Android
3. ✅ Flutter puede detectar el dispositivo
4. ✅ App se ejecuta sin pantalla negra

## 🆘 **SI NADA FUNCIONA:**

**Usar Windows Desktop** es la mejor alternativa:
- Todas las funciones de Firebase funcionan igual
- Puedes crear las cuentas de prueba sin problemas
- El AAB compilado funciona en Android real
