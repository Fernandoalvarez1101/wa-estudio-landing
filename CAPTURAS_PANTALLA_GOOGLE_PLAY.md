# Script para Capturas de Pantalla Google Play Store
# Wä Estudio - Screenshots para diferentes dispositivos

## 📱 **DISPOSITIVOS REQUERIDOS PARA GOOGLE PLAY:**

### **Teléfonos (REQUERIDO):**
- Pixel 7 (1080 x 2400)
- Pixel 6 (1080 x 2400) 
- Pixel 5 (1080 x 2340)

### **Tablets (RECOMENDADO):**
- Pixel Tablet (2560 x 1600)
- Nexus 9 (2048 x 1536)

## 🎯 **CAPTURAS NECESARIAS (mínimo 2, máximo 8):**

### **Para teléfonos:**
1. 📍 **Pantalla Principal** - Menú con opciones
2. 👥 **Lista de Clientes** - Con sistema de estrellas
3. 📅 **Gestión de Citas** - Calendario y programación
4. ⭐ **Sistema de Estrellas** - Clasificación de clientes
5. 🎂 **Notificación de Cumpleaños** - Feature destacada
6. 🗑️ **Sistema de Papelera** - Recuperación de clientes
7. 🔍 **Búsqueda de Clientes** - Filtros en acción
8. ⚙️ **Configuración de Servicios** - Gestión del negocio

## 🚀 **COMANDOS PARA CREAR EMULADORES:**

### **1. Crear Pixel 7:**
```bash
avdmanager create avd -n "Pixel_7_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_7"
```

### **2. Crear Pixel Tablet:**
```bash
avdmanager create avd -n "Pixel_Tablet_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_tablet"
```

### **3. Iniciar emuladores:**
```bash
# Pixel 7
emulator -avd Pixel_7_API_33

# Pixel Tablet  
emulator -avd Pixel_Tablet_API_33
```

## 📸 **PROCESO DE CAPTURAS:**

### **Paso 1: Preparar datos de demo**
- Crear cuenta: `demo.screenshots@gmail.com` / `Demo2025!`
- Agregar 5-8 clientes con diferentes niveles de estrellas
- Programar algunas citas
- Configurar servicios del negocio

### **Paso 2: Tomar capturas en cada dispositivo**
1. **Ejecutar app:** `flutter run`
2. **Navegar** a cada pantalla importante
3. **Capturar** desde Android Studio: `Ctrl + Shift + S`
4. **Guardar** en carpeta organizada

### **Paso 3: Capturas específicas por pantalla**

#### **📱 Pantalla 1: Menú Principal**
- Mostrar splash screen o menú con todas las opciones
- Destacar diseño profesional

#### **👥 Pantalla 2: Lista de Clientes** 
- Mostrar varios clientes con diferentes estrellas
- Incluir barra de búsqueda visible

#### **📅 Pantalla 3: Gestión de Citas**
- Vista de calendario con citas programadas
- Mostrar interface intuitiva

#### **⭐ Pantalla 4: Sistema de Estrellas**
- Cliente con 3 estrellas visible
- Mostrar clasificación en acción

#### **🎂 Pantalla 5: Notificación de Cumpleaños**
- SnackBar de cumpleaños visible
- Mostrar feature única

## 📐 **ESPECIFICACIONES TÉCNICAS:**

### **Formato requerido Google Play:**
- **Formato:** PNG o JPEG
- **Resolución:** Mínimo 320px
- **Proporción:** 16:9 o 9:16
- **Tamaño máximo:** 8MB por imagen

### **Resoluciones por dispositivo:**
- **Pixel 7:** 1080 x 2400 (captura completa)
- **Pixel Tablet:** 2560 x 1600 (captura completa)

## 🎨 **CONSEJOS PARA CAPTURAS PROFESIONALES:**

1. **Datos realistas** - Nombres, teléfonos, fechas coherentes
2. **Sin errores** - Verificar que no hay mensajes de error
3. **Interfaz limpia** - Cerrar teclados virtuales
4. **Buen contraste** - Verificar legibilidad
5. **Features destacadas** - Mostrar funcionalidades únicas

## 📁 **ORGANIZACIÓN DE ARCHIVOS:**

```
screenshots/
├── phone/
│   ├── 01_main_menu.png
│   ├── 02_clients_list.png
│   ├── 03_appointments.png
│   ├── 04_star_system.png
│   └── 05_birthday_notification.png
└── tablet/
    ├── 01_main_menu_tablet.png
    ├── 02_clients_list_tablet.png
    └── 03_appointments_tablet.png
```

## ⚡ **SCRIPT AUTOMATIZADO:**

```bash
# Ejecutar app en Pixel 7
flutter run -d Pixel_7_API_33

# Esperar a que cargue, entonces tomar capturas manualmente
# Repetir para tablet

flutter run -d Pixel_Tablet_API_33
```
