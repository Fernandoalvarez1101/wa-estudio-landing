import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaEditarMensajeWhatsApp extends StatefulWidget {
  const PantallaEditarMensajeWhatsApp({super.key});

  @override
  State<PantallaEditarMensajeWhatsApp> createState() => _PantallaEditarMensajeWhatsAppState();
}

class _PantallaEditarMensajeWhatsAppState extends State<PantallaEditarMensajeWhatsApp> {
  final TextEditingController _mensajeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _cargandoMensaje = true;

  // Mensaje por defecto
  final String mensajePorDefecto = '''¡Hola {nombre}! 👋

Te confirmamos tu cita:
📅 Fecha: {fecha}
🕐 Hora: {hora}{duracion}
💆‍♀️ Servicio: {servicio}
📍 Lugar: {sucursal}

¡Te esperamos! Si necesitas cambiar algo, no dudes en contactarnos.

Saludos,
Wä Estudio 🌿''';

  @override
  void initState() {
    super.initState();
    _cargarMensajeActual();
  }

  Future<void> _cargarMensajeActual() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('configuracion_mensajes')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('mensajeWhatsApp')) {
        _mensajeController.text = doc.data()!['mensajeWhatsApp'];
      } else {
        _mensajeController.text = mensajePorDefecto;
      }
    } catch (e) {
      _mensajeController.text = mensajePorDefecto;
    } finally {
      setState(() {
        _cargandoMensaje = false;
      });
    }
  }

  Future<void> _guardarMensaje() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await FirebaseFirestore.instance
          .collection('configuracion_mensajes')
          .doc(currentUser.uid)
          .set({
        'mensajeWhatsApp': _mensajeController.text.trim(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mensaje de WhatsApp guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _restaurarMensajePorDefecto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restaurar mensaje por defecto'),
          content: const Text('¿Estás seguro de que quieres restaurar el mensaje por defecto? Se perderán los cambios actuales.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _mensajeController.text = mensajePorDefecto;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mensaje WhatsApp'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _restaurarMensajePorDefecto,
            icon: const Icon(Icons.restore),
            tooltip: 'Restaurar por defecto',
          ),
        ],
      ),
      body: _cargandoMensaje
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información sobre variables
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📝 Variables disponibles:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('• {nombre} - Nombre del cliente'),
                            const Text('• {fecha} - Fecha de la cita'),
                            const Text('• {hora} - Hora de la cita'),
                            const Text('• {duracion} - Duración del servicio'),
                            const Text('• {servicio} - Tipo de servicio'),
                            const Text('• {sucursal} - Ubicación del local'),
                            const SizedBox(height: 8),
                            Text(
                              'Usa estas variables en tu mensaje y se reemplazarán automáticamente.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de texto para el mensaje
                    Expanded(
                      child: TextFormField(
                        controller: _mensajeController,
                        decoration: const InputDecoration(
                          labelText: 'Mensaje de WhatsApp',
                          hintText: 'Escribe tu mensaje personalizado aquí...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El mensaje no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _guardarMensaje,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Guardando...' : 'Guardar Mensaje'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }
}
