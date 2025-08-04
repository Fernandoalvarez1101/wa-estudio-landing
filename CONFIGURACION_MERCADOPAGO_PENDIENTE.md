# ❌ ACCESS TOKEN NO CONFIGURADO

## 🔍 Estado Actual:
- ❌ Client ID: NO configurado
- ❌ Client Secret: NO configurado  
- ❌ Access Token: Se generará automáticamente tras OAuth2

## 🚀 Qué Hacer AHORA:

### Paso 1: Obtener Credenciales de MercadoPago

1. Ve a: https://www.mercadopago.com.ar/developers
2. Crea una aplicación (si no tienes)
3. Configura la URL de redirección:
   ```
   https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth
   ```
4. Copia el **Client ID** y **Client Secret**

### Paso 2: Configurar en el Proyecto

Edita el archivo `functions/.env` y coloca tus credenciales:

```env
# Reemplaza con tus valores reales:
MERCADOPAGO_CLIENT_ID=1234567890123456
MERCADOPAGO_CLIENT_SECRET=abcdef1234567890abcdef1234567890
MERCADOPAGO_REDIRECT_URI=https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth
```

### Paso 3: Desplegar Functions

```bash
cd c:\Users\ferna\agenda_wa
firebase deploy --only functions
```

### Paso 4: Probar la Integración

Una vez desplegado:
1. Abrir tu app Flutter
2. Ir a Configuración del Negocio
3. Clickear "Vincular Cuenta MercadoPago"
4. Completar la autorización OAuth2

## ⚠️ IMPORTANTE:

- El **Access Token** NO se configura manualmente
- Se genera automáticamente cuando el terapeuta vincula su cuenta
- Se almacena seguramente en Firestore
- Se renueva automáticamente cuando es necesario

## 🎯 Próximo Paso:

**¿Ya tienes las credenciales de MercadoPago?**
- SÍ → Configura el archivo `.env` y despliega
- NO → Ve a crear la aplicación en MercadoPago Developers
