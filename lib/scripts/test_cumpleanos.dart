import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Script de prueba para crear un cliente con cumpleaños de hoy
/// para verificar que funciona la notificación de cumpleaños
Future<void> crearClientePruebaCumpleanos() async {
  try {
    // Obtener el usuario actual
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ No hay usuario autenticado');
      return;
    }

    // Obtener la fecha de hoy en formato dd/mm/yyyy
    final DateTime hoy = DateTime.now();
    final String fechaHoy = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';

    debugPrint('🎂 Creando cliente de prueba con cumpleaños: $fechaHoy');

    // Crear cliente de prueba
    Map<String, dynamic> datosCliente = {
      'nombre': 'Cliente Cumpleañero',
      'telefono': '+1234567890',
      'fechaCumpleanos': fechaHoy,
      'correo': 'cumpleanos@ejemplo.com',
      'anotaciones': 'Cliente de prueba para verificar notificaciones de cumpleaños',
      'fechaRegistro': Timestamp.now(),
      'terapeutaUid': currentUser.uid,
    };

    // Guardar en Firestore
    final clienteRef = await FirebaseFirestore.instance.collection('clientes').add(datosCliente);
    
    debugPrint('✅ Cliente de prueba creado con ID: ${clienteRef.id}');
    debugPrint('📅 Cumpleaños: $fechaHoy');
    debugPrint('👤 Nombre: Cliente Cumpleañero');
    debugPrint('🎉 ¡Ahora debería aparecer la notificación al iniciar sesión!');

  } catch (e) {
    debugPrint('❌ Error al crear cliente de prueba: $e');
  }
}

/// Script de limpieza para eliminar clientes de prueba
Future<void> eliminarClientesPrueba() async {
  try {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ No hay usuario autenticado');
      return;
    }

    debugPrint('🧹 Buscando clientes de prueba...');

    // Buscar clientes de prueba
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .where('terapeutaUid', isEqualTo: currentUser.uid)
        .where('nombre', isEqualTo: 'Cliente Cumpleañero')
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint('ℹ️ No se encontraron clientes de prueba para eliminar');
      return;
    }

    debugPrint('🗑️ Eliminando ${querySnapshot.docs.length} clientes de prueba...');

    // Eliminar cada cliente de prueba
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
      debugPrint('✅ Cliente eliminado: ${doc.id}');
    }

    debugPrint('🎯 Limpieza completada');

  } catch (e) {
    debugPrint('❌ Error al eliminar clientes de prueba: $e');
  }
}
