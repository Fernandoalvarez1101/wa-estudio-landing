# 🔗 CONFIGURACIÓN DE URLs MERCADOPAGO

## URLs que debes configurar en tu aplicación de MercadoPago:

### 1. URL de Redirección OAuth2 (PRINCIPAL)
```
https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth
```

### 2. URLs de Resultado de Pago
```
https://agenda-wa.com/pago-exitoso
https://agenda-wa.com/pago-fallido  
https://agenda-wa.com/pago-pendiente
```

### 3. URL de Webhook (Notificaciones)
```
https://us-central1-agendawa-5d8a1.cloudfunctions.net/webhook
```

## 🔧 Cómo configurarlo:

1. Ve a: https://www.mercadopago.com.ar/developers
2. Selecciona tu aplicación
3. En "URLs de redirección" agrega la URL OAuth2
4. En "Notification URL" agrega la URL del webhook
5. Guarda los cambios

## ⚠️ IMPORTANTE:

- La URL OAuth2 es la MÁS IMPORTANTE
- Las URLs de resultado (agenda-wa.com) son placeholders que puedes cambiar más tarde
- El webhook es para recibir notificaciones automáticas de pagos

## 📋 Datos que necesitarás después:

- Client ID: [Lo obtienes de la aplicación]
- Client Secret: [Lo obtienes de la aplicación]
- Public Key: [Para testing, si necesario]

Una vez configurado, ejecuta:
```bash
firebase functions:config:set mercadopago.client_id="TU_CLIENT_ID"
firebase functions:config:set mercadopago.client_secret="TU_CLIENT_SECRET"
firebase deploy --only functions
```
