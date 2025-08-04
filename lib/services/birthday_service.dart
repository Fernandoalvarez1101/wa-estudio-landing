import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BirthdayService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene los clientes que cumplen años hoy
  static Future<List<Map<String, dynamic>>> getClientesConCumpleanosHoy() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Obtener la fecha de hoy en formato dd/mm
      final DateTime hoy = DateTime.now();
      final String diaHoy = hoy.day.toString().padLeft(2, '0');
      final String mesHoy = hoy.month.toString().padLeft(2, '0');
      final String fechaHoy = '$diaHoy/$mesHoy';

      print('🎂 Buscando clientes con cumpleaños para el día: $fechaHoy');

      // Consultar todos los clientes del terapeuta actual
      final QuerySnapshot querySnapshot = await _firestore
          .collection('clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      List<Map<String, dynamic>> clientesConCumpleanos = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String? fechaCumpleanos = data['fechaCumpleanos'];

        if (fechaCumpleanos != null && fechaCumpleanos.isNotEmpty) {
          // Extraer día y mes de la fecha de cumpleaños
          final List<String> partesFecha = fechaCumpleanos.split('/');
          if (partesFecha.length >= 2) {
            final String diaMes = '${partesFecha[0]}/${partesFecha[1]}';
            
            if (diaMes == fechaHoy) {
              // Calcular la edad si es posible
              int? edad;
              if (partesFecha.length >= 3) {
                try {
                  final int anoNacimiento = int.parse(partesFecha[2]);
                  edad = hoy.year - anoNacimiento;
                  // Ajustar si aún no ha pasado el cumpleaños este año
                  final DateTime cumpleanosEsteAno = DateTime(hoy.year, hoy.month, hoy.day);
                  final DateTime fechaNacimiento = DateTime(anoNacimiento, hoy.month, hoy.day);
                  if (cumpleanosEsteAno.isBefore(fechaNacimiento)) {
                    edad = edad - 1;
                  }
                } catch (e) {
                  print('⚠️ No se pudo calcular la edad para ${data['nombre']}');
                }
              }

              clientesConCumpleanos.add({
                'id': doc.id,
                'nombre': data['nombre'] ?? 'Cliente sin nombre',
                'fechaCumpleanos': fechaCumpleanos,
                'telefono': data['telefono'] ?? '',
                'correo': data['correo'] ?? '',
                'edad': edad,
              });
            }
          }
        }
      }

      print('🎉 Encontrados ${clientesConCumpleanos.length} clientes con cumpleaños hoy');
      
      // Ordenar por nombre para presentación consistente
      clientesConCumpleanos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
      
      return clientesConCumpleanos;

    } catch (e) {
      print('❌ Error al buscar cumpleaños: $e');
      return [];
    }
  }

  /// Muestra una notificación de cumpleaños usando SnackBar
  static void mostrarNotificacionCumpleanos(
    BuildContext context, 
    List<Map<String, dynamic>> clientesConCumpleanos
  ) {
    if (clientesConCumpleanos.isEmpty) return;

    String mensaje;
    if (clientesConCumpleanos.length == 1) {
      final cliente = clientesConCumpleanos.first;
      mensaje = '🎂 ¡Hoy es el cumpleaños de ${cliente['nombre']}!';
    } else {
      mensaje = '🎉 ¡Hoy ${clientesConCumpleanos.length} clientes están de cumpleaños!';
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.cake, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje)),
          TextButton(
            onPressed: () {
              _mostrarDetallesCumpleanos(context, clientesConCumpleanos);
            },
            child: const Text(
              'Ver detalles',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.pink.shade400,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Muestra un diálogo con los detalles de los cumpleaños
  static void _mostrarDetallesCumpleanos(
    BuildContext context, 
    List<Map<String, dynamic>> clientesConCumpleanos
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cake, color: Colors.pink),
            SizedBox(width: 8),
            Text('¡Cumpleaños de hoy!'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: clientesConCumpleanos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final cliente = clientesConCumpleanos[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink.shade100,
                  child: Text(
                    cliente['nombre'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  cliente['nombre'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 ${cliente['fechaCumpleanos']}'),
                    if (cliente['edad'] != null)
                      Text('🎂 ${cliente['edad']} años', 
                           style: TextStyle(color: Colors.pink.shade600, fontWeight: FontWeight.w500)),
                    if (cliente['telefono'].isNotEmpty) 
                      Text('📞 ${cliente['telefono']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cliente['telefono'].isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          // TODO: Implementar llamada telefónica
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Llamar a ${cliente['nombre']}: ${cliente['telefono']}'),
                            ),
                          );
                        },
                        tooltip: 'Llamar',
                      ),
                    if (cliente['correo'].isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () {
                          // TODO: Implementar envío de email
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Enviar email a ${cliente['nombre']}: ${cliente['correo']}'),
                            ),
                          );
                        },
                        tooltip: 'Enviar email',
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Verifica y muestra automáticamente las notificaciones de cumpleaños
  static Future<void> verificarYMostrarCumpleanos(BuildContext context) async {
    // Pequeña pausa para asegurar que el contexto esté listo
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!context.mounted) return;

    final clientesConCumpleanos = await getClientesConCumpleanosHoy();
    
    if (clientesConCumpleanos.isNotEmpty && context.mounted) {
      mostrarNotificacionCumpleanos(context, clientesConCumpleanos);
    }
  }
}
