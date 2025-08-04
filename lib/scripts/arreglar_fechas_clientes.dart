import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Script para arreglar los campos de fecha en todos los clientes
/// Convierte fechaNacimiento a fechaCumpleanos para compatibilidad
Future<void> arreglarFechasClientes() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Error: No hay usuario autenticado');
      debugPrint('   Asegúrate de estar logueado antes de ejecutar el script');
      return;
    }
    
    debugPrint('👤 Usuario actual: ${currentUser.email}');
    debugPrint('🔑 UID del usuario: ${currentUser.uid}');
    
    // Obtener todos los clientes del usuario actual
    final QuerySnapshot clientesSnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .where('terapeutaUid', isEqualTo: currentUser.uid)
        .get();
    
    debugPrint('📊 Total de clientes encontrados: ${clientesSnapshot.docs.length}');
    
    int clientesActualizados = 0;
    int clientesYaCorrectos = 0;
    
    // Procesar cada cliente
    for (DocumentSnapshot cliente in clientesSnapshot.docs) {
      final Map<String, dynamic> data = cliente.data() as Map<String, dynamic>;
      final String nombreCliente = data['nombre'] ?? 'Sin nombre';
      
      // Verificar el estado de los campos de fecha
      final bool tieneFechaCumpleanos = data.containsKey('fechaCumpleanos');
      final bool tieneFechaNacimiento = data.containsKey('fechaNacimiento');
      
      debugPrint('\\n👤 Cliente: $nombreCliente');
      debugPrint('   - Tiene fechaCumpleanos: $tieneFechaCumpleanos');
      debugPrint('   - Tiene fechaNacimiento: $tieneFechaNacimiento');
      
      if (tieneFechaCumpleanos) {
        // El cliente ya tiene el campo correcto
        clientesYaCorrectos++;
        debugPrint('   ✅ Ya tiene fechaCumpleanos');
        
        // Si también tiene fechaNacimiento, lo eliminamos para limpiar
        if (tieneFechaNacimiento) {
          await FirebaseFirestore.instance
              .collection('clientes')
              .doc(cliente.id)
              .update({
                'fechaNacimiento': FieldValue.delete(),
              });
          debugPrint('   🧹 Eliminado fechaNacimiento duplicado');
        }
      } else if (tieneFechaNacimiento) {
        // Migrar fechaNacimiento a fechaCumpleanos
        final String fechaValue = data['fechaNacimiento'];
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(cliente.id)
            .update({
              'fechaCumpleanos': fechaValue,
              'fechaNacimiento': FieldValue.delete(), // Eliminar el campo viejo
            });
        
        clientesActualizados++;
        debugPrint('   🔄 Migrado fechaNacimiento -> fechaCumpleanos: $fechaValue');
      } else {
        // No tiene ninguno de los dos campos
        debugPrint('   ⚠️  No tiene ningún campo de fecha');
      }
    }
    
    debugPrint('\\n📋 RESUMEN:');
    debugPrint('✅ Clientes ya correctos: $clientesYaCorrectos');
    debugPrint('🔄 Clientes actualizados: $clientesActualizados');
    debugPrint('📊 Total procesados: ${clientesSnapshot.docs.length}');
    debugPrint('\\n🎉 ¡Script completado exitosamente!');
    
  } catch (e) {
    debugPrint('❌ Error ejecutando el script: $e');
  }
}
