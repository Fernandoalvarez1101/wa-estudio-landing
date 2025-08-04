const {onRequest} = require("firebase-functions/v2/https");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");

// Inicializar Firebase Admin SDK
admin.initializeApp();

// Configurar CORS
const corsHandler = cors({origin: true});

// Configuración de MercadoPago usando variables de entorno
const MERCADOPAGO_CONFIG = {
  CLIENT_ID: process.env.MERCADOPAGO_CLIENT_ID,
  CLIENT_SECRET: process.env.MERCADOPAGO_CLIENT_SECRET,
  REDIRECT_URI: process.env.MERCADOPAGO_REDIRECT_URI || 
    "https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth",
};

// === FUNCIONES PARA MERCADOPAGO ===

/**
 * Función para manejar la autorización OAuth2 de MercadoPago
 * Intercambia el código de autorización por tokens de acceso
 */
exports.mercadopagoOauth = onRequest({cors: true}, async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({error: "Método no permitido"});
      }

      const {code, state} = req.body;

      if (!code || !state) {
        return res.status(400).json({
          error: "Código de autorización y state son requeridos",
        });
      }

      // Verificar configuración de MercadoPago
      if (!MERCADOPAGO_CONFIG.CLIENT_ID || !MERCADOPAGO_CONFIG.CLIENT_SECRET) {
        logger.error("Variables de entorno de MercadoPago no configuradas");
        return res.status(500).json({
          error: "Configuración de MercadoPago incompleta",
        });
      }

      // Intercambiar código por tokens
      const tokenResponse = await fetch(
          "https://api.mercadopago.com/oauth/token",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: JSON.stringify({
              client_id: MERCADOPAGO_CONFIG.CLIENT_ID,
              client_secret: MERCADOPAGO_CONFIG.CLIENT_SECRET,
              code: code,
              grant_type: "authorization_code",
              redirect_uri: MERCADOPAGO_CONFIG.REDIRECT_URI,
            }),
          },
      );

      if (!tokenResponse.ok) {
        const errorData = await tokenResponse.text();
        logger.error("Error en OAuth:", errorData);
        return res.status(400).json({
          error: "Error intercambiando código por token",
          details: errorData,
        });
      }

      const tokenData = await tokenResponse.json();

      // Obtener información del usuario de MercadoPago
      const userResponse = await fetch("https://api.mercadopago.com/users/me", {
        headers: {
          "Authorization": `Bearer ${tokenData.access_token}`,
        },
      });

      const userData = await userResponse.json();

      // Guardar tokens en Firestore
      const db = admin.firestore();
      await db.collection("mercadopago_tokens").doc(state).set({
        access_token: tokenData.access_token,
        refresh_token: tokenData.refresh_token,
        expires_in: tokenData.expires_in,
        scope: tokenData.scope,
        user_id: tokenData.user_id,
        public_key: tokenData.public_key,
        mp_user_info: {
          id: userData.id,
          nickname: userData.nickname,
          email: userData.email,
          first_name: userData.first_name,
          last_name: userData.last_name,
        },
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info(`Token guardado para usuario: ${state}`);

      return res.status(200).json({
        success: true,
        message: "Autorización completada exitosamente",
        user_info: {
          nickname: userData.nickname,
          email: userData.email,
        },
      });
    } catch (error) {
      logger.error("Error en mercadopagoOauth:", error);
      return res.status(500).json({
        error: "Error interno del servidor",
        message: error.message,
      });
    }
  });
});

/**
 * Función para crear preferencias de pago en MercadoPago
 */
exports.crearPreferenciaPago = onRequest({cors: true}, async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({error: "Método no permitido"});
      }

      const {
        userId,
        citaId,
        clienteNombre,
        clienteEmail,
        servicio,
        monto,
        descripcion,
      } = req.body;

      // Validaciones
      if (!userId || !citaId || !monto) {
        return res.status(400).json({
          error: "userId, citaId y monto son requeridos",
        });
      }

      if (monto < 1 || monto > 250000) {
        return res.status(400).json({
          error: "El monto debe estar entre $1 y $250,000 ARS",
        });
      }

      // Obtener token de acceso del terapeuta
      const db = admin.firestore();
      const tokenDoc = await db.collection("mercadopago_tokens").doc(userId).get();

      if (!tokenDoc.exists) {
        return res.status(404).json({
          error: "No se encontró cuenta de MercadoPago vinculada",
        });
      }

      const tokenData = tokenDoc.data();
      const accessToken = tokenData.access_token;

      // Crear preferencia en MercadoPago
      const preference = {
        items: [
          {
            title: servicio || "Servicio de Spa",
            description: descripcion || `Pago por ${servicio}`,
            quantity: 1,
            currency_id: "ARS",
            unit_price: parseFloat(monto),
          },
        ],
        payer: {
          name: clienteNombre || "Cliente",
          email: clienteEmail || "cliente@ejemplo.com",
        },
        back_urls: {
          success: "https://agenda-wa.com/pago-exitoso",
          failure: "https://agenda-wa.com/pago-fallido",
          pending: "https://agenda-wa.com/pago-pendiente",
        },
        auto_return: "approved",
        external_reference: citaId,
        notification_url: "https://us-central1-agendawa-5d8a1.cloudfunctions.net/webhook",
        expires: true,
        expiration_date_from: new Date().toISOString(),
        expiration_date_to: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      };

      const response = await fetch(
          "https://api.mercadopago.com/checkout/preferences",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${accessToken}`,
            },
            body: JSON.stringify(preference),
          },
      );

      if (!response.ok) {
        const errorData = await response.text();
        logger.error("Error creando preferencia:", errorData);
        return res.status(400).json({
          error: "Error creando preferencia de pago",
          details: errorData,
        });
      }

      const preferenceData = await response.json();

      // Guardar información del pago en Firestore
      await db.collection("pagos").doc(citaId).set({
        preference_id: preferenceData.id,
        terapeuta_id: userId,
        cita_id: citaId,
        monto: monto,
        estado: "pending",
        cliente_nombre: clienteNombre,
        cliente_email: clienteEmail,
        servicio: servicio,
        descripcion: descripcion,
        init_point: preferenceData.init_point,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info(`Preferencia creada: ${preferenceData.id} para cita: ${citaId}`);

      return res.status(200).json({
        success: true,
        preference_id: preferenceData.id,
        init_point: preferenceData.init_point,
        sandbox_init_point: preferenceData.sandbox_init_point,
      });
    } catch (error) {
      logger.error("Error en crearPreferenciaPago:", error);
      return res.status(500).json({
        error: "Error interno del servidor",
        message: error.message,
      });
    }
  });
});

/**
 * Webhook para recibir notificaciones de MercadoPago
 */
exports.webhook = onRequest({cors: true}, async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).json({error: "Método no permitido"});
    }

    const {type, data} = req.body;

    if (type === "payment") {
      const paymentId = data.id;

      // Obtener detalles del pago desde MercadoPago
      // Nota: Necesitarías el access_token del vendedor para esto
      logger.info(`Notificación de pago recibida: ${paymentId}`);

      // Actualizar estado del pago en Firestore
      const db = admin.firestore();
      // Aquí implementarías la lógica para actualizar el estado
      // basado en la información del pago

      return res.status(200).json({success: true});
    }

    return res.status(200).json({success: true, message: "Notificación procesada"});
  } catch (error) {
    logger.error("Error en webhook:", error);
    return res.status(500).json({
      error: "Error procesando webhook",
      message: error.message,
    });
  }
});

// === FUNCIONES DE UTILIDAD ===

/**
 * Función para verificar el estado de los tokens de MercadoPago
 */
exports.verificarTokenMercadoPago = onRequest({cors: true}, async (req, res) => {
  corsHandler(req, res, async () => {
    try {
      if (req.method !== "GET") {
        return res.status(405).json({error: "Método no permitido"});
      }

      const userId = req.query.userId;

      if (!userId) {
        return res.status(400).json({error: "userId es requerido"});
      }

      const db = admin.firestore();
      const tokenDoc = await db.collection("mercadopago_tokens").doc(userId).get();

      if (!tokenDoc.exists) {
        return res.status(404).json({
          existe: false,
          message: "No hay cuenta de MercadoPago vinculada",
        });
      }

      const tokenData = tokenDoc.data();

      return res.status(200).json({
        existe: true,
        user_info: tokenData.mp_user_info,
        created_at: tokenData.created_at,
      });
    } catch (error) {
      logger.error("Error verificando token:", error);
      return res.status(500).json({
        error: "Error verificando token",
        message: error.message,
      });
    }
  });
});
