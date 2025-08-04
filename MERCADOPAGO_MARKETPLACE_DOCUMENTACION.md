# 💳 SISTEMA DE PAGOS MERCADO PAGO MARKETPLACE - Implementación Completa

## 🎯 **Objetivo**
Integrar Mercado Pago Connect (OAuth2) para que cada terapeuta reciba pagos directamente en su cuenta, convirtiendo la app en un marketplace de servicios profesionales.

---

## 🏗️ **Arquitectura del Sistema**

### **🔄 Flujo Completo:**
```
1. Terapeuta → Vincula cuenta MP via OAuth2
2. Sistema → Guarda access_token en Firebase  
3. Cliente → Agenda cita y paga online
4. MP → Deposita dinero directo al terapeuta
5. Sistema → Confirma pago via webhook
```

### **🧩 Componentes Principales:**
- **Frontend Flutter** - UI y navegación web
- **Firebase Functions** - Backend seguro para OAuth2
- **Firebase Firestore** - Base datos de tokens y pagos
- **Mercado Pago API** - Procesamiento de pagos
- **Webhooks** - Confirmaciones automáticas

---

## 📦 **1. DEPENDENCIAS NUEVAS**

### **pubspec.yaml - Agregar al proyecto:**
```yaml
dependencies:
  # Existentes...
  
  # NUEVAS para Mercado Pago
  webview_flutter: ^4.4.2        # Para OAuth2 flow
  http: ^1.1.0                   # Para llamadas API
  crypto: ^3.0.3                 # Para seguridad (YA EXISTE)
  url_launcher: ^6.2.4           # Para navegación (YA EXISTE)
```

---

## 🔥 **2. ESTRUCTURA FIREBASE AMPLIADA**

### **Nuevas Colecciones:**
```
📁 Firebase Firestore:
├── 👤 usuarios/{uid}/
│   ├── 📅 citas/                    # EXISTENTE
│   ├── 👥 clientes/                 # EXISTENTE  
│   ├── 👨‍💼 terapeutas/               # EXISTENTE
│   ├── 💼 servicios/                # EXISTENTE
│   ├── 🏢 locales/                  # EXISTENTE
│   ├── 💬 configuracion_mensajes/   # EXISTENTE
│   ├── 🗑️ papelera_clientes/        # EXISTENTE
│   │
│   │ === NUEVAS COLECCIONES PARA PAGOS ===
│   ├── 💳 mercadopago_config/       # Configuración MP por terapeuta
│   │   └── oauth/
│   │       ├── access_token: "MP-ACCESS-TOKEN-***"
│   │       ├── refresh_token: "MP-REFRESH-TOKEN-***"
│   │       ├── expires_at: Timestamp
│   │       ├── user_id: "MP-USER-ID"
│   │       ├── public_key: "MP-PUBLIC-KEY"
│   │       ├── vinculado: true/false
│   │       └── fecha_vinculacion: Timestamp
│   │
│   ├── 💰 pagos/                    # Historial de pagos
│   │   └── {payment_id}/
│   │       ├── cita_id: "ref-cita"
│   │       ├── cliente_nombre: "Juan Pérez"
│   │       ├── monto: 1500.00
│   │       ├── estado: "approved/pending/rejected"
│   │       ├── terapeuta_id: "uid-terapeuta"
│   │       ├── servicio: "Masaje Relajante"
│   │       ├── mp_payment_id: "123456789"
│   │       ├── mp_preference_id: "pref-123"
│   │       ├── fecha_pago: Timestamp
│   │       └── metodo_pago: "credit_card/debit_card"
│   │
│   └── 🔗 preferencias_pago/        # Cache de preferencias MP
│       └── {preference_id}/
│           ├── init_point: "https://www.mercadopago.com/..."
│           ├── cita_id: "ref-cita"
│           ├── activa: true/false
│           └── fecha_creacion: Timestamp
```

---

## 💼 **3. CONFIGURACIÓN INICIAL REQUERIDA**

### **Credenciales de Mercado Pago:**
1. **Crear aplicación en:** https://www.mercadopago.com/developers/panel
2. **Obtener credenciales:**
   - `CLIENT_ID`
   - `CLIENT_SECRET`
   - `PUBLIC_KEY`
   - `ACCESS_TOKEN` (para testing)

### **Configurar OAuth2:**
- **Redirect URI:** `https://tu-proyecto.web.app/mp-callback`
- **Scopes:** `read`, `write`, `offline_access`

---

## 🖥️ **4. BACKEND - FIREBASE FUNCTIONS**

### **Archivo: functions/package.json**
```json
{
  "name": "functions",
  "description": "Cloud Functions for Firebase",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "index.js",
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1",
    "axios": "^1.4.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "firebase-functions-test": "^3.1.0"
  },
  "private": true
}
```

### **Archivo: functions/index.js**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const cors = require('cors')({ origin: true });

admin.initializeApp();

// === CONFIGURACIÓN MERCADO PAGO ===
const MP_CONFIG = {
  client_id: 'TU_CLIENT_ID_AQUI',
  client_secret: 'TU_CLIENT_SECRET_AQUI',
  redirect_uri: 'https://tu-proyecto.web.app/mp-callback',
  auth_url: 'https://auth.mercadopago.com/authorization',
  token_url: 'https://api.mercadopago.com/oauth/token',
  api_url: 'https://api.mercadopago.com'
};

// === 1. GENERAR URL DE AUTORIZACIÓN ===
exports.generarUrlAutorizacion = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    try {
      const { terapeutaId } = req.body;
      
      if (!terapeutaId) {
        return res.status(400).json({ error: 'terapeutaId requerido' });
      }

      // URL de autorización OAuth2
      const authUrl = `${MP_CONFIG.auth_url}?client_id=${MP_CONFIG.client_id}&response_type=code&platform_id=mp&state=${terapeutaId}&redirect_uri=${MP_CONFIG.redirect_uri}`;
      
      res.json({
        success: true,
        auth_url: authUrl,
        terapeuta_id: terapeutaId
      });
      
    } catch (error) {
      console.error('Error generando URL:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });
});

// === 2. INTERCAMBIAR CÓDIGO POR TOKEN ===
exports.intercambiarToken = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { code, state: terapeutaId } = req.body;
      
      if (!code || !terapeutaId) {
        return res.status(400).json({ error: 'code y terapeutaId requeridos' });
      }

      // Intercambiar código por token
      const tokenResponse = await axios.post(MP_CONFIG.token_url, {
        client_id: MP_CONFIG.client_id,
        client_secret: MP_CONFIG.client_secret,
        code: code,
        grant_type: 'authorization_code',
        redirect_uri: MP_CONFIG.redirect_uri
      });

      const {
        access_token,
        refresh_token,
        expires_in,
        user_id,
        public_key
      } = tokenResponse.data;

      // Calcular fecha de expiración
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + (expires_in * 1000))
      );

      // Guardar en Firestore
      await admin.firestore()
        .collection('usuarios')
        .doc(terapeutaId)
        .collection('mercadopago_config')
        .doc('oauth')
        .set({
          access_token,
          refresh_token,
          expires_at: expiresAt,
          user_id,
          public_key,
          vinculado: true,
          fecha_vinculacion: admin.firestore.FieldValue.serverTimestamp()
        });

      res.json({
        success: true,
        message: 'Cuenta vinculada exitosamente',
        user_id
      });

    } catch (error) {
      console.error('Error intercambiando token:', error);
      res.status(500).json({ 
        error: 'Error al vincular cuenta',
        details: error.response?.data || error.message 
      });
    }
  });
});

// === 3. CREAR PREFERENCIA DE PAGO ===
exports.crearPreferenciaPago = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const {
        terapeutaId,
        citaId,
        clienteNombre,
        clienteEmail,
        servicio,
        monto,
        descripcion
      } = req.body;

      // Validar parámetros
      if (!terapeutaId || !citaId || !monto) {
        return res.status(400).json({ 
          error: 'terapeutaId, citaId y monto son requeridos' 
        });
      }

      // Obtener token del terapeuta
      const tokenDoc = await admin.firestore()
        .collection('usuarios')
        .doc(terapeutaId)
        .collection('mercadopago_config')
        .doc('oauth')
        .get();

      if (!tokenDoc.exists || !tokenDoc.data().access_token) {
        return res.status(400).json({ 
          error: 'Terapeuta no tiene cuenta vinculada' 
        });
      }

      const { access_token } = tokenDoc.data();

      // Crear preferencia en Mercado Pago
      const preferenceData = {
        items: [{
          title: servicio || 'Servicio de Spa',
          description: descripcion || `Servicio agendado para ${clienteNombre}`,
          quantity: 1,
          currency_id: 'ARS', // Cambiar según tu país
          unit_price: parseFloat(monto)
        }],
        payer: {
          name: clienteNombre,
          email: clienteEmail || 'cliente@ejemplo.com'
        },
        external_reference: citaId,
        notification_url: `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/webhookPagos`,
        back_urls: {
          success: `https://tu-app.com/pago-exitoso?cita=${citaId}`,
          failure: `https://tu-app.com/pago-fallido?cita=${citaId}`,
          pending: `https://tu-app.com/pago-pendiente?cita=${citaId}`
        },
        auto_return: 'approved',
        expires: true,
        expiration_date_from: new Date().toISOString(),
        expiration_date_to: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 horas
      };

      const response = await axios.post(
        `${MP_CONFIG.api_url}/checkout/preferences`,
        preferenceData,
        {
          headers: {
            'Authorization': `Bearer ${access_token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const { id: preferenceId, init_point } = response.data;

      // Guardar preferencia en Firestore
      await admin.firestore()
        .collection('usuarios')
        .doc(terapeutaId)
        .collection('preferencias_pago')
        .doc(preferenceId)
        .set({
          init_point,
          cita_id: citaId,
          activa: true,
          fecha_creacion: admin.firestore.FieldValue.serverTimestamp()
        });

      res.json({
        success: true,
        preference_id: preferenceId,
        init_point,
        message: 'Preferencia creada exitosamente'
      });

    } catch (error) {
      console.error('Error creando preferencia:', error);
      res.status(500).json({ 
        error: 'Error al crear preferencia de pago',
        details: error.response?.data || error.message 
      });
    }
  });
});

// === 4. WEBHOOK PARA NOTIFICACIONES ===
exports.webhookPagos = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      const { type, data } = req.body;

      if (type === 'payment') {
        const paymentId = data.id;
        
        console.log(`Webhook recibido para pago: ${paymentId}`);
        
        // Aquí procesarías la información del pago
        // y actualizarías el estado en tu base de datos
        
        res.status(200).json({ message: 'Webhook procesado' });
      } else {
        res.status(200).json({ message: 'Tipo de webhook no manejado' });
      }
      
    } catch (error) {
      console.error('Error en webhook:', error);
      res.status(500).json({ error: 'Error procesando webhook' });
    }
  });
});
```

---

## 📱 **5. SERVICIOS FLUTTER**

Voy a crear el servicio principal de MercadoPago para Flutter...
