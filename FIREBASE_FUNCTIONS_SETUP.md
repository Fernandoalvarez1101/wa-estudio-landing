# 🔥 FIREBASE FUNCTIONS - GUÍA DE ACTIVACIÓN

## ✅ Estado Actual

Firebase Functions ha sido **CONFIGURADO COMPLETAMENTE** en tu proyecto. Aquí tienes todo lo que necesitas para activarlo:

## 📁 Estructura Creada

```
functions/
├── package.json          # Dependencias de Node.js
├── index.js              # Código de las funciones
├── .eslintrc.json        # Configuración de linting
├── .gitignore            # Archivos a ignorar
└── .env.example          # Variables de entorno (ejemplo)
```

## 🔧 Funciones Implementadas

### 1. **mercadopagoOauth**
- **URL**: `https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth`
- **Función**: Maneja la autorización OAuth2 de MercadoPago
- **Método**: POST
- **Parámetros**: `{code, state}`

### 2. **crearPreferenciaPago**
- **URL**: `https://us-central1-agendawa-5d8a1.cloudfunctions.net/crearPreferenciaPago`
- **Función**: Crea preferencias de pago en MercadoPago
- **Método**: POST
- **Parámetros**: `{userId, citaId, clienteNombre, clienteEmail, servicio, monto, descripcion}`

### 3. **webhook**
- **URL**: `https://us-central1-agendawa-5d8a1.cloudfunctions.net/webhook`
- **Función**: Recibe notificaciones de pagos de MercadoPago
- **Método**: POST

### 4. **verificarTokenMercadoPago**
- **URL**: `https://us-central1-agendawa-5d8a1.cloudfunctions.net/verificarTokenMercadoPago`
- **Función**: Verifica si un usuario tiene token de MP
- **Método**: GET
- **Parámetros**: `?userId=xxx`

## 🚀 Pasos para Activar

### Paso 1: Configurar Variables de Entorno

Ejecuta estos comandos para configurar MercadoPago:

```bash
# Ir al directorio del proyecto
cd c:\Users\ferna\agenda_wa

# Configurar Client ID de MercadoPago
firebase functions:config:set mercadopago.client_id="TU_CLIENT_ID_AQUI"

# Configurar Client Secret de MercadoPago
firebase functions:config:set mercadopago.client_secret="TU_CLIENT_SECRET_AQUI"

# Configurar URL de redirección
firebase functions:config:set mercadopago.redirect_uri="https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth"
```

### Paso 2: Desplegar Functions

```bash
# Método 1: Usando el script automático
.\desplegar_functions.bat

# Método 2: Manual
firebase deploy --only functions
```

### Paso 3: Verificar Despliegue

Una vez desplegado, puedes verificar que funciona visitando:
```
https://us-central1-agendawa-5d8a1.cloudfunctions.net/verificarTokenMercadoPago?userId=test
```

## 🔑 Obtener Credenciales de MercadoPago

1. **Ir a MercadoPago Developers**: https://www.mercadopago.com.ar/developers
2. **Crear una aplicación**
3. **Obtener Client ID y Client Secret**
4. **Configurar URL de redirección**: `https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth`

## 📱 Integración con Flutter

El servicio `MercadoPagoService` ya está configurado para usar las Functions:

```dart
// Archivo: lib/services/mercadopago_service.dart
static const String _baseUrl = 'https://us-central1-agendawa-5d8a1.cloudfunctions.net';
```

## 🧪 Probar Localmente (Opcional)

```bash
# Iniciar emulador local
firebase emulators:start --only functions

# Las functions estarán disponibles en:
# http://localhost:5001/agendawa-5d8a1/us-central1/nombreFuncion
```

## 🔍 Debugging

### Ver logs de las functions:
```bash
firebase functions:log
```

### Ver configuración actual:
```bash
firebase functions:config:get
```

## ⚠️ Importante

1. **Firestore Security Rules**: Asegúrate de que las reglas permitan escribir en `mercadopago_tokens` y `pagos`
2. **Billing**: Firebase Functions requiere plan Blaze (pago por uso)
3. **CORS**: Las functions ya tienen CORS configurado para Flutter

## 🎯 Siguiente Paso

**Ejecuta el comando de despliegue:**

```bash
cd c:\Users\ferna\agenda_wa
firebase deploy --only functions
```

Una vez desplegado, tu sistema de pagos estará **100% funcional** 🚀
