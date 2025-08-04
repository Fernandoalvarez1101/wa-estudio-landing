# Sistema de Mensajes Personalizados - Documentación Completa

## 📱 Introducción

El sistema de mensajes personalizados permite a los propietarios de negocios personalizar completamente los mensajes de confirmación de citas que se envían por WhatsApp y correo electrónico, manteniendo la funcionalidad de variables dinámicas.

## 🚀 Características Implementadas

### ✅ Mensajes Personalizables
- **WhatsApp**: Mensajes de confirmación completamente editables
- **Correo Electrónico**: Plantillas de email profesionales personalizables
- **Variables Dinámicas**: Sistema automático de reemplazo de variables
- **Interfaz Intuitiva**: Editores dedicados con previsualización en tiempo real

### ✅ Variables Disponibles
Todas las plantillas pueden usar las siguientes variables que se reemplazan automáticamente:

- `{nombre}` - Nombre del cliente
- `{fecha}` - Fecha de la cita (formato: Lunes, 15 de Enero)
- `{hora}` - Hora de la cita (formato: 09:00)
- `{duracion}` - Duración del servicio (formato: por 1h 30min)
- `{servicio}` - Tipo de servicio/masaje
- `{sucursal}` - Ubicación de la cita

### ✅ Mensajes Predeterminados

#### WhatsApp (por defecto):
```
Hola {nombre}! Te confirmamos tu cita: {fecha} a las {hora}{duracion} para {servicio} en {sucursal}. Te esperamos!
```

#### Correo Electrónico (por defecto):
```
Estimado/a {nombre},

Nos complace confirmarle su cita programada para el {fecha} a las {hora}{duracion}.

Servicio: {servicio}
Ubicación: {sucursal}

Si necesita realizar algún cambio, no dude en contactarnos.

Saludos cordiales,
El equipo de WA Estudio
```

## 🛠️ Cómo Usar el Sistema

### 1. Acceder a la Configuración
1. Abre la aplicación y navega al menú principal
2. Selecciona **"Configuración del Negocio"**
3. Busca los botones **"Editar Mensaje WhatsApp"** y **"Editar Mensaje Correo"**

### 2. Personalizar Mensaje de WhatsApp
1. Toca **"Editar Mensaje WhatsApp"**
2. Modifica el texto usando las variables disponibles
3. Utiliza la **Vista Previa** para ver cómo se verá el mensaje final
4. Toca **"Guardar Cambios"** para aplicar los cambios

### 3. Personalizar Mensaje de Correo
1. Toca **"Editar Mensaje Correo"**
2. Edita tanto el contenido como el formato del mensaje
3. Usa saltos de línea y formato profesional
4. Revisa la previsualización antes de guardar
5. Toca **"Guardar Cambios"** para aplicar

### 4. Restaurar Valores Predeterminados
- Cada editor tiene un botón **"Restaurar por Defecto"**
- Esto restaura el mensaje original del sistema
- Útil si quieres volver a empezar

## 📧 Funcionamiento Técnico

### Integración con Firebase
- Los mensajes se almacenan en Firestore en la colección `configuracion_mensajes`
- Cada usuario tiene su propio documento identificado por su UID
- Los cambios se sincronizan automáticamente

### Fallbacks de Seguridad
- Si no hay conexión a Firebase: usa mensajes predeterminados
- Si el documento no existe: crea uno nuevo con valores por defecto
- Si hay error en el mensaje personalizado: usa el mensaje original

### Proceso de Envío
1. **Usuario toca botón de confirmación** en la lista de citas
2. **Sistema carga plantilla personalizada** desde Firebase
3. **Variables se reemplazan automáticamente** con datos reales
4. **Mensaje final se envía** por WhatsApp o correo
5. **Confirmación visual** se muestra al usuario

## 🎯 Casos de Uso Avanzados

### Mensajes por Tipo de Negocio

#### Spa/Estética:
```
🌸 Hola {nombre}! 

Tu sesión de {servicio} está confirmada para el {fecha} a las {hora}{duracion}.

📍 Ubicación: {sucursal}
💆‍♀️ Prepárate para relajarte!

¡Te esperamos! ✨
```

#### Consultorio Médico:
```
Estimado/a {nombre},

Le recordamos su cita médica:
📅 Fecha: {fecha}
🕒 Hora: {hora}
⏱️ Duración estimada: {duracion}
🏥 Consulta: {servicio}
📍 Ubicación: {sucursal}

Por favor, llegue 10 minutos antes.
```

#### Barbería/Peluquería:
```
¡Hola {nombre}! ✂️

Tu corte está agendado:
📅 {fecha} a las {hora}
💺 Servicio: {servicio}
📍 Local: {sucursal}

¡Nos vemos pronto! 👨‍💼
```

## 🔧 Archivos Técnicos Modificados

### Nuevos Archivos Creados:
- `lib/screens/pantalla_editar_mensaje_whatsapp.dart`
- `lib/screens/pantalla_editar_mensaje_correo.dart`

### Archivos Modificados:
- `lib/widgets/configuracion_negocio_widget.dart` - Agregados botones de navegación
- `lib/screens/pantalla_ver_citas.dart` - Integración con Firebase para cargar mensajes personalizados

### Funciones Principales:
- `_obtenerMensajeWhatsAppPersonalizado()` - Carga plantilla WhatsApp desde Firebase
- `_obtenerMensajeCorreoPersonalizado()` - Carga plantilla correo desde Firebase
- `_enviarWhatsApp()` - Reemplaza variables y envía mensaje personalizado
- `_enviarCorreo()` - Reemplaza variables y envía correo personalizado

## ✅ Estado Actual

### Completamente Implementado:
- ✅ Interfaz de edición de mensajes WhatsApp
- ✅ Interfaz de edición de mensajes de correo
- ✅ Sistema de variables dinámicas
- ✅ Integración con Firebase
- ✅ Previsualización en tiempo real
- ✅ Botones de restaurar por defecto
- ✅ Navegación desde configuración del negocio
- ✅ Envío de mensajes personalizados
- ✅ Fallbacks de seguridad

### Funcionamiento Verificado:
- ✅ Compilación sin errores
- ✅ Integración completa con sistema existente
- ✅ Compatibilidad con todas las funciones anteriores
- ✅ Manejo robusto de errores

## 🎉 Resultado Final

Los propietarios de negocios ahora pueden:

1. **Personalizar completamente** los mensajes de confirmación
2. **Mantener profesionalismo** con plantillas estructuradas
3. **Usar variables dinámicas** para información específica
4. **Previsualizar cambios** antes de aplicarlos
5. **Restaurar valores por defecto** cuando sea necesario
6. **Enviar mensajes únicos** que reflejen la personalidad de su negocio

El sistema mantiene toda la funcionalidad anterior mientras agrega esta nueva capacidad de personalización, haciendo que cada negocio pueda comunicarse con sus clientes de manera única y profesional.
