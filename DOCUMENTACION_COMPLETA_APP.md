# 📱 Wä Estudio - Documentación Completa de la Aplicación

## 🎯 **Descripción General**
**Wä Estudio** es una aplicación móvil Flutter para gestión de negocios de servicios (spas, centros de belleza, consultorios, etc.). La app permite gestionar clientes, empleados, servicios y citas de forma profesional con autenticación multi-usuario, almacenamiento en la nube, y sistema avanzado de clasificación de clientes.

---

## ⭐ **Características Principales v2.1**

### 🔐 **Sistema de Autenticación Multi-Usuario**
- Login seguro con email/contraseña
- Registro de nuevos usuarios
- Separación completa de datos por usuario
- Persistencia de sesión

### 👥 **Gestión Avanzada de Clientes**
- CRUD completo de clientes
- Búsqueda en tiempo real
- Sistema de clasificación por estrellas (0-3 niveles)
- Notificaciones automáticas de cumpleaños
- Sistema de papelera con restauración
- Fotos de perfil con carga local

### 📅 **Sistema de Citas**
- Agendar citas con cliente, servicio y terapeuta
- Calendario visual por fechas
- Estados de cita (Pendiente, Confirmada, Completada, Cancelada)
- Filtros por estado

### 🏢 **Gestión de Equipo**
- Administración de terapeutas/empleados
- Asignación de servicios por terapeuta
- CRUD completo de servicios del negocio

### 🎨 **Características Visuales Avanzadas**
- Splash screen animado con logo "Wä Estudio"
- Tema Material Design 3 consistente
- Animaciones fluidas y profesionales
- Interfaz adaptativa y responsive

---

## 🏗️ **Arquitectura Técnica**

### **Frontend**
- **Framework:** Flutter (Dart)
- **UI:** Material Design 3
- **Estado:** StatefulWidget con setState
- **Navegación:** Navigator.push/pop estándar

### **Backend**
- **Base de datos:** Firebase Firestore (NoSQL)
- **Autenticación:** Firebase Authentication
- **Almacenamiento:** Local (para fotos) + Firebase Storage (preparado)
- **Configuración:** firebase_options.dart auto-generado

### **Dependencias Principales**
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  cloud_firestore: ^4.17.5
  firebase_core: ^2.32.0
  firebase_auth: ^4.16.0
  firebase_storage: ^11.2.6
  shared_preferences: ^2.2.2
  image_picker: ^1.0.4
  intl: ^0.18.1
```

---

## 🗂️ **Estructura del Proyecto**

```
lib/
├── main.dart                 # Punto de entrada, configuración del tema
├── firebase_options.dart     # Configuración de Firebase
├── models/                   # Modelos de datos
│   ├── cliente.dart         # Modelo Cliente con nivelCliente
│   ├── cita.dart           # Modelo Cita
│   └── servicio.dart       # Modelo Servicio
├── services/               # Servicios y lógica de negocio
│   ├── auth_service.dart   # Servicio de autenticación
│   ├── birthday_service.dart # Servicio de cumpleaños
│   └── papelera_service.dart # Servicio de papelera
└── screens/               # Pantallas de la aplicación
    ├── splash_screen.dart
    ├── pantalla_inicio.dart
    ├── pantalla_login.dart
    ├── pantalla_registro.dart
    ├── pantalla_menu_terapeuta.dart
    ├── pantalla_agregar_cliente.dart
    ├── pantalla_ver_clientes.dart
    ├── pantalla_editar_cliente.dart
    ├── pantalla_agendar_cita.dart
    ├── pantalla_ver_citas.dart
    ├── pantalla_gestionar_terapeutas.dart
    └── pantalla_gestionar_servicios.dart
```

---

## 🎨 **Diseño y Tema**

### **Colores Corporativos**
```dart
primaryColor: Color(0xFF008080)        // Teal principal
secondary: Color(0xFF20B2AA)           // Light Sea Green
surface: Color(0xFFA0D4D4)             // Light Cyan
scaffoldBackground: Color(0xFFFFFFFF)  // Blanco
```

### **Características Visuales**
- Material Design 3 con esquema de colores personalizado
- Iconografía coherente con Icons de Material
- Cards con elevación sutil
- Botones con colores corporativos
- AppBars con título centrado y fondo corporativo

---

## 🔐 **Sistema de Autenticación**

### **Servicio de Autenticación (auth_service.dart)**
```dart
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Funcionalidades:
  - getCurrentUser() -> User?
  - signInWithEmailAndPassword()
  - createUserWithEmailAndPassword()  
  - signOut()
  - sendPasswordResetEmail()
  - Persistencia automática con SharedPreferences
}
```

### **Flujo de Autenticación**
1. **SplashScreen** → Verifica credenciales guardadas
2. **PantallaInicio** → Opciones de login/registro
3. **PantallaLogin** → Formulario de ingreso
4. **PantallaRegistro** → Formulario de registro
5. **PantallaMenuTerapeuta** → Menú principal (autenticado)

---

## 💾 **Estructura de Base de Datos (Firestore)**

### **Colección: `clientes`**
```javascript
{
  id: "doc_id_auto",
  nombre: "string",
  telefono: "string", 
  email: "string",
  fechaCumpleanos: "string (dd/mm/yyyy)",
  terapeutaUid: "string", // ID del usuario propietario
  fechaCreacion: Timestamp,
  activo: boolean,
  fotoPath: "string?" // Ruta local de la foto
}
```

### **Colección: `terapeutas`**
```javascript
{
  id: "doc_id_auto",
  nombre: "string",
  estudioUid: "string", // ID del usuario propietario
  fechaCreacion: Timestamp,
  activo: boolean
}
```

### **Colección: `servicios`**
```javascript
{
  id: "doc_id_auto", 
  nombre: "string",
  estudioUid: "string", // ID del usuario propietario
  fechaCreacion: Timestamp,
  activo: boolean
}
```

### **Colección: `citas`**
```javascript
{
  id: "doc_id_auto",
  clienteNombre: "string",
  clienteTelefono: "string",
  terapeutaNombre: "string", 
  servicioNombre: "string",
  fecha: "string (dd/mm/yyyy)",
  hora: "string (HH:mm)",
  estado: "string", // "programada", "completada", "cancelada"
  terapeutaUid: "string", // ID del usuario propietario
  fechaCreacion: Timestamp
}
```

---

## 🔒 **Sistema de Seguridad Multi-Usuario**

### **Principio de Separación**
- Cada usuario solo ve SUS datos
- Filtrado por `terapeutaUid` o `estudioUid`
- Queries siempre incluyen `.where('terapeutaUid', isEqualTo: currentUser.uid)`

### **Implementación**
```dart
// Ejemplo en todas las consultas
FirebaseFirestore.instance
  .collection('clientes')
  .where('terapeutaUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  .where('activo', isEqualTo: true)
  .snapshots()
```

---

## 📱 **Pantallas y Funcionalidades**

### **1. SplashScreen**
- **Archivo:** `splash_screen.dart`
- **Función:** Verificación de autenticación automática
- **Duración:** 3 segundos con logo
- **Navegación:** → PantallaInicio o PantallaMenuTerapeuta

### **2. PantallaInicio**
- **Archivo:** `pantalla_inicio.dart` 
- **Función:** Pantalla de bienvenida
- **Elementos:** Logo, botones "Entrar como Profesional" y "Registrarse"

### **3. PantallaLogin**
- **Archivo:** `pantalla_login.dart`
- **Función:** Autenticación de usuarios
- **Campos:** Email, contraseña
- **Validaciones:** Email válido, contraseña mínima
- **Extras:** "Olvidé mi contraseña", persistencia de sesión

### **4. PantallaRegistro** 
- **Archivo:** `pantalla_registro.dart`
- **Función:** Registro de nuevos usuarios
- **Campos:** Email, contraseña, confirmación
- **Validaciones:** Email único, contraseñas coincidentes

### **5. PantallaMenuTerapeuta**
- **Archivo:** `pantalla_menu_terapeuta.dart`
- **Función:** Menú principal (dashboard)
- **Opciones:** 
  - Ver Clientes
  - Agregar Cliente  
  - Agendar Cita
  - Ver Citas
  - Gestionar Equipo
  - Gestionar Servicios
  - Cerrar Sesión

### **6. Gestión de Clientes**

#### **PantallaVerClientes**
- **Archivo:** `pantalla_ver_clientes.dart`
- **Función:** Lista de clientes con búsqueda
- **Características:**
  - StreamBuilder para datos en tiempo real
  - Barra de búsqueda por nombre
  - Cards con información del cliente
  - Botones editar/eliminar
  - FloatingActionButton para agregar

#### **PantallaAgregarCliente**
- **Archivo:** `pantalla_agregar_cliente.dart`
- **Función:** Formulario de nuevo cliente
- **Campos:** Nombre, teléfono, email, fecha de cumpleaños
- **Extras:** Selección de foto, validaciones

#### **PantallaEditarCliente**
- **Archivo:** `pantalla_editar_cliente.dart`
- **Función:** Edición de cliente existente
- **Características:** Formulario pre-poblado, actualización de foto

### **7. Gestión de Citas**

#### **PantallaAgendarCita**
- **Archivo:** `pantalla_agendar_cita.dart`
- **Función:** Crear nueva cita
- **Campos:** Cliente (dropdown), empleado (dropdown), servicio (dropdown), fecha, hora, estado
- **Validaciones:** Campos obligatorios, formato de fecha/hora

#### **PantallaVerCitas**
- **Archivo:** `pantalla_ver_citas.dart`
- **Función:** Vista organizada de citas
- **Características:**
  - Agrupación por estado (Programadas, Completadas, Canceladas)
  - Formato de fecha profesional con intl
  - Cards informativos con todos los detalles
  - Colores diferenciados por estado

### **8. Gestión de Equipo**

#### **PantallaGestionarTerapeutas**
- **Archivo:** `pantalla_gestionar_terapeutas.dart`  
- **Función:** CRUD completo de empleados
- **Características:**
  - Formulario para agregar empleado
  - Lista en tiempo real con StreamBuilder
  - Editar empleado (dialog)
  - Eliminar con confirmación
  - Validación de nombres únicos
  - Ordenamiento por fecha de creación

### **9. Gestión de Servicios**

#### **PantallaGestionarServicios**
- **Archivo:** `pantalla_gestionar_servicios.dart`
- **Función:** CRUD completo de servicios
- **Características:**
  - Formulario para agregar servicio
  - Lista en tiempo real
  - Editar servicio (dialog)
  - Eliminar con confirmación
  - Migración automática de datos existentes

---

## 🎯 **Modelos de Datos**

### **Cliente (cliente.dart)**
```dart
class Cliente {
  final String id;
  final String nombre;
  final String telefono;
  final String email;
  final String fechaCumpleanos;
  final String terapeutaUid;
  final DateTime fechaCreacion;
  final bool activo;
  final String? fotoPath;
  
  // Métodos: fromMap(), toMap(), copyWith()
}
```

### **Cita (cita.dart)**
```dart
class Cita {
  final String id;
  final String clienteNombre;
  final String clienteTelefono;
  final String terapeutaNombre;
  final String servicioNombre;
  final String fecha;
  final String hora;
  final String estado;
  final String terapeutaUid;
  final DateTime fechaCreacion;
  
  // Métodos: fromMap(), toMap()
}
```

### **Servicio (servicio.dart)**
```dart
class Servicio {
  final String id;
  final String nombre;
  final String estudioUid;
  final DateTime fechaCreacion;
  final bool activo;
  
  // Métodos: fromMap(), toMap()
}
```

---

## 🔄 **Funcionalidades Especiales**

### **1. Sistema de Clasificación por Estrellas ⭐**
- **Niveles:** 0-3 estrellas por cliente
- **Clasificaciones:** Regular, Frecuente, Premium, VIP
- **Colores:** Gris, Azul, Morado, Dorado
- **Persistencia:** Campo `nivelCliente` en Firestore
- **Edición:** Selector visual en formulario de edición

### **2. Sistema de Cumpleaños 🎂**
- **Detección:** Automática al hacer login
- **Notificación:** Dialog visual con lista de cumpleañeros
- **Información:** Nombre, edad actual, acciones de contacto
- **Persistencia:** Verificación diaria automática

### **3. Sistema de Papelera 🗑️**
- **Soft Delete:** Los clientes no se eliminan, se marcan como eliminados
- **Restauración:** Posibilidad de recuperar clientes eliminados
- **Estadísticas:** Contador de clientes en papelera
- **Limpieza:** Eliminación permanente opcional

### **4. Búsqueda en Tiempo Real 🔍**
- **Filtrado:** Por nombre, email y teléfono
- **Instantáneo:** Resultados mientras se escribe
- **Highlight:** Resaltado de coincidencias
- **Performance:** Optimizado para grandes listas

### **5. Gestión de Fotos**
- **Selección:** image_picker
- **Almacenamiento:** Local en directorio de la app
- **Visualización:** CircleAvatar con FileImage
- **Fallback:** Icono por defecto si no hay foto

### **6. Persistencia de Sesión**
- **Servicio:** SharedPreferences
- **Datos guardados:** Email y contraseña (encriptados)
- **Verificación:** Automática en SplashScreen
- **Limpieza:** Al cerrar sesión

### **7. Validaciones**
- **Email:** Regex pattern + Firebase validation
- **Teléfono:** Solo números, mínimo 10 dígitos
- **Fechas:** Formato dd/mm/yyyy
- **Nombres:** No vacíos, sin caracteres especiales
- **Unicidad:** Validación en tiempo real con Firebase

### **4. Manejo de Estados**
- **Loading:** CircularProgressIndicator durante operaciones async
- **Errores:** SnackBar con mensajes descriptivos
- **Éxito:** SnackBar de confirmación
- **Vacío:** Mensajes y iconos informativos

---

## 🎨 **Patrones de UI Utilizados**

### **Cards Informativos**
```dart
Card(
  child: ListTile(
    leading: CircleAvatar(), // Foto o icono
    title: Text(), // Nombre principal
    subtitle: Column(), // Información adicional
    trailing: PopupMenuButton(), // Acciones
  ),
)
```

### **Formularios Consistentes**
```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(validator: validate),
      ElevatedButton(onPressed: submit),
    ],
  ),
)
```

### **Navegación Estándar**
```dart
Navigator.push(context, 
  MaterialPageRoute(builder: (context) => NextScreen())
);
```

---

## 📊 **Optimizaciones Implementadas**

### **Firebase**
- Queries optimizadas con índices simples
- Filtrado por usuario para seguridad
- StreamBuilder para datos en tiempo real
- Paginación implícita con límites

### **Performance**
- Lazy loading de imágenes
- Validación de campos en tiempo real
- Caché local con SharedPreferences
- Tree-shaking de iconos (reducción 99.6%)

### **UX**
- Feedback inmediato en acciones
- Estados de carga visibles
- Validaciones preventivas
- Navegación intuitiva

---

## 🚀 **Funcionalidades Listas para Producción**

✅ **Sistema completo de autenticación**
✅ **CRUD completo para todas las entidades**
✅ **Seguridad multi-usuario robusta**
✅ **Interfaz profesional y consistente**
✅ **Validaciones exhaustivas**
✅ **Manejo de errores completo**
✅ **Persistencia de datos**
✅ **Optimización de rendimiento**
✅ **Terminología profesional genérica**

---

## 🔧 **Comandos de Desarrollo**

### **Ejecutar en desarrollo**
```bash
flutter run
```

### **Compilar APK de producción**
```bash
flutter build apk --release
```

### **Limpiar proyecto**
```bash
flutter clean
flutter pub get
```

### **Resolver dependencias**
```bash
flutter pub get
```

---

## 📝 **Notas Importantes para IAs**

### **Contexto de Uso**
- La app está COMPLETA y FUNCIONAL
- Todos los sistemas están integrados y probados
- La arquitectura es escalable y mantenible
- Se puede usar como base para nuevas funcionalidades

### **Patrones de Código**
- Consistencia en nomenclatura (español para UI, inglés para código)
- Separación clara de responsabilidades
- Validaciones exhaustivas en formularios
- Manejo de estados con StatefulWidget

### **Consideraciones Especiales**
- Firebase configurado para multi-usuario
- Terminología genérica (no específica de spas)
- Compatibilidad con datos existentes
- Sistema de migración automática implementado

---

**Esta documentación representa el estado ACTUAL y COMPLETO de la aplicación Wä Estudio v1.0 al 30 de Julio de 2025.**
