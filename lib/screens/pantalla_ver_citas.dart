import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_agendar_cita.dart';
import 'package:agenda_wa/screens/pantalla_editar_cita.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/mercadopago_service.dart';

class PantallaVerCitas extends StatelessWidget {
  final DateTime? fechaFiltro;
  
  const PantallaVerCitas({super.key, this.fechaFiltro});

  // Función para formatear fecha sin mostrar 00:00:00.000
  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return '-';
    
    try {
      // Si ya es una fecha formateada simple, devolverla
      if (!fechaStr.contains('T') && !fechaStr.contains('00:00:00')) {
        return fechaStr;
      }
      
      // Parsear la fecha ISO y formatearla
      DateTime fecha = DateTime.parse(fechaStr);
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (e) {
      // Si falla el parsing, devolver la fecha original sin los 00:00:00.000
      return fechaStr.split('T')[0].replaceAll('-', '/');
    }
  }

  // Función para formatear la duración de manera legible
  String _formatearDuracion(int? minutos) {
    if (minutos == null || minutos == 0) return '';
    
    if (minutos < 60) {
      return '$minutos min';
    } else {
      final horas = minutos ~/ 60;
      final minutosRestantes = minutos % 60;
      if (minutosRestantes == 0) {
        return '${horas}h';
      } else {
        return '${horas}h ${minutosRestantes}min';
      }
    }
  }

  // Función para obtener mensaje personalizado de WhatsApp desde Firebase
  Future<String> _obtenerMensajeWhatsAppPersonalizado() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Mensaje por defecto si no hay usuario
        return 'Hola {nombre}! Te confirmamos tu cita: {fecha} a las {hora}{duracion} para {servicio} en {sucursal}. Te esperamos!';
      }

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('configuracion_mensajes')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['mensajeWhatsApp'] ?? 'Hola {nombre}! Te confirmamos tu cita: {fecha} a las {hora}{duracion} para {servicio} en {sucursal}. Te esperamos!';
      } else {
        return 'Hola {nombre}! Te confirmamos tu cita: {fecha} a las {hora}{duracion} para {servicio} en {sucursal}. Te esperamos!';
      }
    } catch (e) {
      // Debug: Error obteniendo mensaje WhatsApp personalizado: $e
      return 'Hola {nombre}! Te confirmamos tu cita: {fecha} a las {hora}{duracion} para {servicio} en {sucursal}. Te esperamos!';
    }
  }

  // Función para obtener mensaje personalizado de correo desde Firebase
  Future<String> _obtenerMensajeCorreoPersonalizado() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Mensaje por defecto si no hay usuario
        return 'Estimado/a {nombre},\n\nNos complace confirmarle su cita programada para el {fecha} a las {hora}{duracion}.\n\nServicio: {servicio}\nUbicación: {sucursal}\n\nSi necesita realizar algún cambio, no dude en contactarnos.\n\nSaludos cordiales,\nEl equipo de WA Estudio';
      }

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('configuracion_mensajes')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['mensajeCorreo'] ?? 'Estimado/a {nombre},\n\nNos complace confirmarle su cita programada para el {fecha} a las {hora}{duracion}.\n\nServicio: {servicio}\nUbicación: {sucursal}\n\nSi necesita realizar algún cambio, no dude en contactarnos.\n\nSaludos cordiales,\nEl equipo de WA Estudio';
      } else {
        return 'Estimado/a {nombre},\n\nNos complace confirmarle su cita programada para el {fecha} a las {hora}{duracion}.\n\nServicio: {servicio}\nUbicación: {sucursal}\n\nSi necesita realizar algún cambio, no dude en contactarnos.\n\nSaludos cordiales,\nEl equipo de WA Estudio';
      }
    } catch (e) {
      // Debug: Error obteniendo mensaje correo personalizado: $e
      return 'Estimado/a {nombre},\n\nNos complace confirmarle su cita programada para el {fecha} a las {hora}{duracion}.\n\nServicio: {servicio}\nUbicación: {sucursal}\n\nSi necesita realizar algún cambio, no dude en contactarnos.\n\nSaludos cordiales,\nEl equipo de WA Estudio';
    }
  }

  // Función para obtener la dirección de la sucursal desde Firebase
  Future<String> _obtenerDireccionSucursal(String nombreSucursal) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return nombreSucursal; // Fallback al nombre si no hay usuario
      }

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('locales')
          .where('terapeutaUid', isEqualTo: user.uid)
          .where('nombre', isEqualTo: nombreSucursal)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final localData = snapshot.docs.first.data() as Map<String, dynamic>;
        final String direccion = localData['direccion'] ?? '';
        return direccion.isNotEmpty ? direccion : nombreSucursal;
      } else {
        return nombreSucursal; // Fallback al nombre si no se encuentra
      }
    } catch (e) {
      // Debug: Error obteniendo dirección de sucursal: $e
      return nombreSucursal; // Fallback al nombre en caso de error
    }
  }

  // Función para formatear hora con duración
  String _formatearHoraConDuracion(String? hora, int? duracionMinutos) {
    if (hora == null || hora.isEmpty) return '-';
    
    // Si no hay duración, solo mostrar la hora
    if (duracionMinutos == null || duracionMinutos == 0) {
      return hora;
    }

    try {
      // Calcular hora de finalización
      final partesHora = hora.split(':');
      final horaInicio = int.parse(partesHora[0]);
      final minutoInicio = int.parse(partesHora[1]);
      
      final totalMinutos = (horaInicio * 60) + minutoInicio + duracionMinutos;
      final horaFin = totalMinutos ~/ 60;
      final minutoFin = totalMinutos % 60;
      
      final horaFinString = '${horaFin.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';
      return '$hora - $horaFinString (${_formatearDuracion(duracionMinutos)})';
    } catch (e) {
      return '$hora (${_formatearDuracion(duracionMinutos)})';
    }
  }

  // Función para obtener el DateTime de una cita para ordenamiento
  DateTime _obtenerFechaHoraCita(Map<String, dynamic> data) {
    try {
      String fechaStr = data['fecha'] ?? '';
      String horaStr = data['hora'] ?? '00:00';
      
      if (fechaStr.isEmpty) return DateTime.now();
      
      // Si la fecha contiene 'T', es ISO format
      if (fechaStr.contains('T')) {
        return DateTime.parse(fechaStr);
      }
      
      // Combinar fecha y hora
      List<String> fechaParts = fechaStr.split('/');
      if (fechaParts.length == 3) {
        int dia = int.parse(fechaParts[0]);
        int mes = int.parse(fechaParts[1]);
        int ano = int.parse(fechaParts[2]);
        
        List<String> horaParts = horaStr.split(':');
        int hora = horaParts.isNotEmpty ? int.parse(horaParts[0]) : 0;
        int minuto = horaParts.length > 1 ? int.parse(horaParts[1]) : 0;
        
        return DateTime(ano, mes, dia, hora, minuto);
      }
      
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Función para cambiar el estado de una cita
  Future<void> _cambiarEstadoCita(BuildContext context, String citaId, bool nuevoEstado) async {
    try {
      await FirebaseFirestore.instance
          .collection('citas')
          .doc(citaId)
          .update({'atendido': nuevoEstado});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado ? 'Cita marcada como atendida' : 'Cita marcada como pendiente'),
            backgroundColor: nuevoEstado ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Citas Agendadas')),
        body: const Center(child: Text('Error: Usuario no autenticado')),
      );
    }

    // Preparar el título según el filtro
    String titulo = 'Mis Citas Agendadas';
    if (fechaFiltro != null) {
      final String fechaFormateada = '${fechaFiltro!.day.toString().padLeft(2, '0')}/${fechaFiltro!.month.toString().padLeft(2, '0')}/${fechaFiltro!.year}';
      titulo = 'Citas del $fechaFormateada';
    }

    // Preparar la consulta base
    Query citasQuery = FirebaseFirestore.instance
        .collection('citas')
        .where('terapeutaId', isEqualTo: currentUser.uid);
    
    // Agregar filtro de fecha si se proporciona
    if (fechaFiltro != null) {
      final String fechaFiltroISO = DateTime(fechaFiltro!.year, fechaFiltro!.month, fechaFiltro!.day).toIso8601String();
      citasQuery = citasQuery.where('fecha', isEqualTo: fechaFiltroISO);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: citasQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay citas agendadas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final todasLasCitas = snapshot.data!.docs;
          
          // Separar citas pendientes y atendidas
          List<QueryDocumentSnapshot> citasPendientes = [];
          List<QueryDocumentSnapshot> citasAtendidas = [];
          
          for (var cita in todasLasCitas) {
            final data = cita.data() as Map<String, dynamic>;
            final bool atendida = data['atendido'] ?? false;
            
            if (atendida) {
              citasAtendidas.add(cita);
            } else {
              citasPendientes.add(cita);
            }
          }
          
          // Ordenar cada grupo por fecha y hora
          citasPendientes.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            return _obtenerFechaHoraCita(dataA).compareTo(_obtenerFechaHoraCita(dataB));
          });
          
          citasAtendidas.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            return _obtenerFechaHoraCita(dataB).compareTo(_obtenerFechaHoraCita(dataA)); // Más recientes primero
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Citas Pendientes
                if (citasPendientes.isNotEmpty) ...[
                  _buildSeccionHeader('Citas Pendientes', Icons.schedule, Colors.orange, citasPendientes.length),
                  const SizedBox(height: 12),
                  ...citasPendientes.map((cita) => _buildCitaCard(context, cita, false)),
                  const SizedBox(height: 24),
                ],
                
                // Sección de Citas Atendidas
                if (citasAtendidas.isNotEmpty) ...[
                  _buildSeccionHeader('Citas Atendidas', Icons.check_circle, Colors.green, citasAtendidas.length),
                  const SizedBox(height: 12),
                  ...citasAtendidas.map((cita) => _buildCitaCard(context, cita, true)),
                ],
                
                // Mensaje si no hay citas de ningún tipo
                if (citasPendientes.isEmpty && citasAtendidas.isEmpty)
                  const Center(
                    child: Text('No hay citas registradas', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaAgendarCita()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSeccionHeader(String titulo, IconData icono, Color color, int cantidad) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$cantidad',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para enviar confirmación por WhatsApp
  Future<void> _enviarWhatsApp(BuildContext context, Map<String, dynamic> data) async {
    try {
      final String telefono = data['telefono'] ?? '';
      
      if (telefono.isEmpty) {
        throw 'No hay número de teléfono registrado para este cliente';
      }
      
      final String nombre = data['nombre'] ?? 'Cliente';
      final String servicio = data['servicio'] ?? data['tipoMasaje'] ?? 'Servicio';
      final String fecha = _formatearFecha(data['fecha']);
      final String hora = data['hora'] ?? '';
      final String nombreSucursal = data['sucursal'] ?? 'nuestra sede';
      final int? duracion = data['duracionMinutos'];
      final String duracionTexto = duracion != null ? ' por ${_formatearDuracion(duracion)}' : '';

      // Obtener la dirección de la sucursal
      final String direccionSucursal = await _obtenerDireccionSucursal(nombreSucursal);

      // Obtener mensaje personalizado de Firebase
      String mensajeTemplate = await _obtenerMensajeWhatsAppPersonalizado();
      
      // Reemplazar variables en el mensaje
      final String mensaje = mensajeTemplate
          .replaceAll('{nombre}', nombre)
          .replaceAll('{fecha}', fecha)
          .replaceAll('{hora}', hora)
          .replaceAll('{duracion}', duracionTexto)
          .replaceAll('{servicio}', servicio)
          .replaceAll('{sucursal}', direccionSucursal);

      // Limpiar el número de teléfono (solo números, conservando el +)
      String telefonoLimpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Si no tiene código de país, agregar +57 (Colombia)
      if (!telefonoLimpio.startsWith('+')) {
        if (telefonoLimpio.startsWith('57')) {
          telefonoLimpio = '+$telefonoLimpio';
        } else {
          telefonoLimpio = '+57$telefonoLimpio';
        }
      }
      
      // Lista de URLs a intentar
      final List<String> urlsIntento = [
        'https://wa.me/$telefonoLimpio?text=${Uri.encodeComponent(mensaje)}',
        'https://api.whatsapp.com/send?phone=$telefonoLimpio&text=${Uri.encodeComponent(mensaje)}',
        'whatsapp://send?phone=$telefonoLimpio&text=${Uri.encodeComponent(mensaje)}',
      ];
      
      bool exitoso = false;
      
      for (String urlIntento in urlsIntento) {
        try {
          final Uri uri = Uri.parse(urlIntento);
          
          await launchUrl(
            uri, 
            mode: LaunchMode.externalApplication,
          );
          
          exitoso = true;
          break; // Si llegamos aquí, fue exitoso
        } catch (e) {
          debugPrint('Fallo al intentar URL: $urlIntento - Error: $e');
          continue; // Intentar la siguiente URL
        }
      }
      
      if (exitoso && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp abierto correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'No se pudo abrir WhatsApp. Verifica que esté instalado.';
      }
      
    } catch (e) {
      debugPrint('Error al enviar WhatsApp: $e');
      // Mostrar error al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para enviar confirmación por correo
  Future<void> _enviarCorreo(BuildContext context, Map<String, dynamic> data) async {
    try {
      final String correo = data['correo'] ?? '';
      
      if (correo.isEmpty) {
        throw 'No hay correo electrónico registrado para este cliente';
      }
      
      final String nombre = data['nombre'] ?? 'Cliente';
      final String servicio = data['servicio'] ?? data['tipoMasaje'] ?? 'Servicio';
      final String fecha = _formatearFecha(data['fecha']);
      final String hora = data['hora'] ?? '';
      final String nombreSucursal = data['sucursal'] ?? 'nuestra sede';
      final int? duracion = data['duracionMinutos'];
      final String duracionTexto = duracion != null ? ' por ${_formatearDuracion(duracion)}' : '';

      // Obtener la dirección de la sucursal
      final String direccionSucursal = await _obtenerDireccionSucursal(nombreSucursal);

      // Obtener mensaje personalizado de Firebase
      String mensajeTemplate = await _obtenerMensajeCorreoPersonalizado();
      
      // Reemplazar variables en el mensaje
      final String cuerpo = mensajeTemplate
          .replaceAll('{nombre}', nombre)
          .replaceAll('{fecha}', fecha)
          .replaceAll('{hora}', hora)
          .replaceAll('{duracion}', duracionTexto)
          .replaceAll('{servicio}', servicio)
          .replaceAll('{sucursal}', direccionSucursal);

      final String asunto = 'Confirmación de Cita - WA Estudio';

      // Lista de URLs a intentar
      final List<String> urlsIntento = [
        'mailto:$correo?subject=${Uri.encodeComponent(asunto)}&body=${Uri.encodeComponent(cuerpo)}',
        'mailto:$correo?subject=$asunto&body=$cuerpo',
      ];
      
      bool exitoso = false;
      
      for (String urlIntento in urlsIntento) {
        try {
          final Uri uri = Uri.parse(urlIntento);
          
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          exitoso = true;
          break; // Si llegamos aquí, fue exitoso
        } catch (e) {
          debugPrint('Fallo al intentar URL de correo: $urlIntento - Error: $e');
          continue; // Intentar la siguiente URL
        }
      }
      
      if (exitoso && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplicación de correo abierta correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'No se pudo abrir la aplicación de correo. Verifica que tengas una app de correo instalada.';
      }
      
    } catch (e) {
      debugPrint('Error al enviar correo: $e');
      // Mostrar error al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir correo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para mostrar diálogo de confirmación antes de enviar
  void _mostrarDialogoConfirmacion(BuildContext context, Map<String, dynamic> data, String tipo) {
    final String nombre = data['nombre'] ?? 'Cliente';
    final String contacto = tipo == 'whatsapp' ? (data['telefono'] ?? '') : (data['correo'] ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                tipo == 'whatsapp' ? Icons.phone : Icons.email,
                color: tipo == 'whatsapp' ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text('Confirmar ${tipo == 'whatsapp' ? 'WhatsApp' : 'Correo'}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Enviar confirmación de cita a $nombre?'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    tipo == 'whatsapp' ? Icons.phone : Icons.email,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      contacto,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipo == 'whatsapp' 
                            ? 'Se abrirá WhatsApp con el mensaje pre-escrito'
                            : 'Se abrirá tu app de correo con el mensaje pre-escrito',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                if (tipo == 'whatsapp') {
                  _enviarWhatsApp(context, data);
                } else {
                  _enviarCorreo(context, data);
                }
              },
              icon: Icon(tipo == 'whatsapp' ? Icons.send : Icons.email_outlined),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tipo == 'whatsapp' ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCitaCard(BuildContext context, QueryDocumentSnapshot cita, bool atendida) {
    final data = cita.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: atendida ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y estado
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: atendida ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nombre'] ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['servicio'] ?? data['tipoMasaje'] ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: atendida ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    atendida ? 'ATENDIDA' : 'PENDIENTE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Información de la cita
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.calendar_today, 'Fecha', _formatearFecha(data['fecha'])),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, 'Hora', _formatearHoraConDuracion(data['hora'], data['duracionMinutos'])),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.phone, 'Teléfono', data['telefono'] ?? '-'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email, 'Correo', data['correo'] ?? '-'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botones de confirmación (primera fila)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón WhatsApp
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoConfirmacion(context, data, 'whatsapp'),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón Correo
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoConfirmacion(context, data, 'correo'),
                    icon: const Icon(Icons.email, size: 16),
                    label: const Text('Correo', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Botones de acción (segunda fila)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cambiarEstadoCita(context, cita.id, !atendida),
                    icon: Icon(
                      atendida ? Icons.undo : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(
                      atendida ? 'Pendiente' : 'Atendida',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: atendida ? Colors.orange : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaEditarCita(
                            id: cita.id,
                            datos: data,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text(
                      'Editar',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // === NUEVO: BOTÓN DE PAGO MERCADOPAGO ===
            const SizedBox(height: 8),
            _buildBotonPago(context, cita.id, data),
          ],
        ),
      ),
    );
  }

  // === FUNCIONES PARA SISTEMA DE PAGOS MERCADOPAGO ===

  /// Construir botón de pago si aplica
  Widget _buildBotonPago(BuildContext context, String citaId, Map<String, dynamic> data) {
    // Solo mostrar si la cita NO está atendida y tiene datos básicos
    final atendida = data['atendido'] ?? false;
    final pagada = data['pagada'] ?? false;
    
    if (atendida || pagada) {
      return Container(); // No mostrar botón si ya está atendida o pagada
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _generarLinkPago(context, citaId, data),
        icon: const Icon(Icons.payment, size: 16),
        label: const Text(
          'Generar Link de Pago',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF009688), // Teal
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Generar link de pago para la cita
  Future<void> _generarLinkPago(BuildContext context, String citaId, Map<String, dynamic> data) async {
    try {
      // Verificar que el terapeuta tenga cuenta MP vinculada
      final cuentaVinculada = await MercadoPagoService.tieneCuentaVinculada();
      
      if (!cuentaVinculada) {
        if (context.mounted) {
          _mostrarDialogoSinCuentaMP(context);
        }
        return;
      }

      if (context.mounted) {
        _mostrarDialogoConfigurarPago(context, citaId, data);
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Diálogo cuando no hay cuenta MP vinculada
  void _mostrarDialogoSinCuentaMP(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cuenta no vinculada'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para generar links de pago, primero debes vincular tu cuenta de Mercado Pago.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('¿Cómo vincular tu cuenta?'),
            Text('1. Ve a Configuración del Negocio'),
            Text('2. Busca la sección Mercado Pago'),
            Text('3. Presiona "Vincular Cuenta"'),
            Text('4. Autoriza la aplicación'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar al home y que el usuario vaya a configuración
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/menu-terapeuta',
                (route) => false,
              );
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para configurar el pago
  void _mostrarDialogoConfigurarPago(BuildContext context, String citaId, Map<String, dynamic> data) {
    final TextEditingController montoController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Pre-llenar email si existe
    emailController.text = data['correo'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.green),
            SizedBox(width: 8),
            Text('Configurar Pago'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de la cita
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📋 Datos de la cita:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Cliente: ${data['nombre'] ?? 'N/A'}'),
                      Text('Servicio: ${data['servicio'] ?? 'N/A'}'),
                      Text('Fecha: ${_formatearFecha(data['fecha'])} ${data['hora'] ?? ''}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo de monto
                TextFormField(
                  controller: montoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto (ARS)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    helperText: 'Ingresa el precio del servicio',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el monto';
                    }
                    final monto = double.tryParse(value);
                    if (monto == null) {
                      return 'Monto inválido';
                    }
                    if (!MercadoPagoService.validarMonto(monto)) {
                      return 'Monto debe estar entre \$1 y \$250,000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Campo de email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email del cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText: 'Para enviar recibo de pago',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _crearPreferenciaPago(context, citaId, data, montoController.text, emailController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generar Link'),
          ),
        ],
      ),
    );
  }

  /// Crear preferencia de pago en MP
  Future<void> _crearPreferenciaPago(
    BuildContext context,
    String citaId,
    Map<String, dynamic> data, 
    String monto, 
    String email,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(
              child: Text('Generando link de pago...\nEsto puede tomar unos segundos.'),
            ),
          ],
        ),
      ),
    );

    try {
      final initPoint = await MercadoPagoService.crearPreferenciaPago(
        citaId: citaId,
        clienteNombre: data['nombre'] ?? 'Cliente',
        clienteEmail: email.isNotEmpty ? email : 'cliente@ejemplo.com',
        servicio: data['servicio'] ?? 'Servicio de Spa',
        monto: double.parse(monto),
        descripcion: 'Pago por ${data['servicio'] ?? 'servicio'} - ${_formatearFecha(data['fecha'])} ${data['hora'] ?? ''}',
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de loading
      }

      if (initPoint != null) {
        if (context.mounted) {
          _mostrarLinkPagoGenerado(context, initPoint, data['nombre'] ?? 'Cliente');
        }
      } else {
        throw 'No se pudo generar el link de pago';
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generando link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostrar link de pago generado
  void _mostrarLinkPagoGenerado(BuildContext context, String initPoint, String clienteNombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Link de Pago Generado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ Link generado exitosamente para: $clienteNombre',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Link de pago:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                initPoint,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ℹ️ Importante:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• El link expira en 24 horas'),
                  Text('• El cliente puede pagar con tarjeta, transferencia, etc.'),
                  Text('• Una vez pagado, recibirás notificación'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _enviarLinkPorWhatsApp(context, initPoint, clienteNombre);
            },
            icon: const Icon(Icons.share),
            label: const Text('Enviar por WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Enviar link de pago por WhatsApp
  Future<void> _enviarLinkPorWhatsApp(BuildContext context, String linkPago, String clienteNombre) async {
    try {
      final mensaje = '¡Hola $clienteNombre! 👋\n\n'
          '💳 Tu link de pago está listo:\n'
          '$linkPago\n\n'
          '✅ Pago 100% seguro con Mercado Pago\n'
          '💳 Acepta tarjetas, transferencias y más\n'
          '⏰ Válido por 24 horas\n\n'
          'Una vez realizado el pago, tu cita quedará confirmada.\n\n'
          '¡Gracias por confiar en nosotros! 😊';

      final url = 'https://wa.me/?text=${Uri.encodeComponent(mensaje)}';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp abierto con el link de pago'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'No se puede abrir WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error abriendo WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
