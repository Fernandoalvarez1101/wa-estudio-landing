# 🏆 Wä Estudio - App de Gestión de Spa

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![MercadoPago](https://img.shields.io/badge/MercadoPago-00AAFF?style=for-the-badge&logo=mercadopago&logoColor=white)](https://mercadopago.com)

## 🚀 Descripción

Aplicación completa para gestión de spa con sistema de citas, pagos y administración de clientes. Incluye integración con MercadoPago para pagos seguros y una landing page profesional.

## ✨ Características

### 📱 **App Flutter**
- ✅ Gestión completa de clientes con sistema de calificaciones
- ✅ Agendamiento de citas con confirmación por WhatsApp
- ✅ Sistema de pagos con MercadoPago Connect
- ✅ Configuración de mensajes personalizados
- ✅ Gestión de múltiples sucursales y servicios

### 🔥 **Firebase Functions**
- ✅ OAuth2 seguro para MercadoPago
- ✅ Creación de preferencias de pago
- ✅ Webhooks para notificaciones
- ✅ Gestión segura de tokens

### 🌐 **Landing Page**
- ✅ Diseño responsive y moderno
- ✅ Integrada con Firebase Hosting
- ✅ Despliegue automático con GitHub Actions

## 🛠️ Tecnologías

- **Frontend**: Flutter 3.32.8
- **Backend**: Firebase Functions (Node.js)
- **Base de Datos**: Cloud Firestore
- **Pagos**: MercadoPago Connect OAuth2
- **Hosting**: Firebase Hosting
- **CI/CD**: GitHub Actions

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK 3.32.8+
- Firebase CLI
- Node.js 18+
- Cuenta de MercadoPago Developers

### Configuración

1. **Clonar el repositorio**
```bash
git clone https://github.com/Fernandoalvarez1101/wa-estudio-landing.git
cd wa-estudio-landing
```

2. **Instalar dependencias Flutter**
```bash
flutter pub get
```

3. **Configurar Firebase Functions**
```bash
cd functions
npm install
```

4. **Configurar MercadoPago**
```bash
# Editar functions/.env con tus credenciales
MERCADOPAGO_CLIENT_ID=tu_client_id
MERCADOPAGO_CLIENT_SECRET=tu_client_secret
```

5. **Desplegar Functions**
```bash
firebase deploy --only functions
```

6. **Ejecutar la app**
```bash
flutter run
```

## 📱 Funcionalidades Principales

### Para Terapeutas
- 👥 Gestión de clientes con historial completo
- 📅 Calendario de citas con estados
- 💳 Generación de links de pago
- 📱 Confirmaciones automáticas por WhatsApp
- ⭐ Sistema de calificaciones de clientes

### Para Clientes
- 📞 Agendamiento por WhatsApp
- 💳 Pagos seguros con MercadoPago
- 📧 Confirmaciones por email
- ⏰ Recordatorios automáticos

## 🔧 Scripts Disponibles

- `flutter run` - Ejecutar en modo desarrollo
- `flutter build apk` - Construir APK
- `firebase deploy` - Desplegar a Firebase
- `npm run lint` - Verificar código de Functions

## 🌐 URLs Importantes

- **Landing**: https://agendawa-5d8a1.web.app
- **Functions**: https://us-central1-agendawa-5d8a1.cloudfunctions.net
- **MercadoPago OAuth**: https://us-central1-agendawa-5d8a1.cloudfunctions.net/mercadopagoOauth

## 📄 Documentación

- [Configuración MercadoPago](MERCADOPAGO_URLS_CONFIGURACION.md)
- [Setup Firebase Functions](FIREBASE_FUNCTIONS_SETUP.md)
- [Sistema de Pagos](MERCADOPAGO_MARKETPLACE_DOCUMENTACION.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📝 Licencia

Este proyecto es privado y pertenece a Wä Estudio.

## 📞 Contacto

**Fernando Álvarez** - fernandoalvarez1101@gmail.com

---

⭐ Si te gusta este proyecto, ¡dale una estrella!

