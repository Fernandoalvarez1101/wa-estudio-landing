# CONFIGURAR VARIABLES DE ENTORNO PARA MERCADOPAGO
# Ejecutar estos comandos en PowerShell para configurar las variables de entorno

# Configurar variables de MercadoPago (reemplaza con tus valores reales)
firebase functions:config:set mercadopago.client_id="TU_CLIENT_ID_AQUI"
firebase functions:config:set mercadopago.client_secret="TU_CLIENT_SECRET_AQUI"
firebase functions:config:set mercadopago.redirect_uri="https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth"

# Ver la configuración actual
firebase functions:config:get
