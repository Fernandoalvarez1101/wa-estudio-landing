import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Script para migrar las citas existentes y agregar el campo de duración
/// Agrega duracionMinutos: 60 a todas las citas que no tengan este campo
Future<void> migrarDuracionCitas() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Error: No hay usuario autenticado');
      debugPrint('   Asegúrate de estar logueado antes de ejecutar el script');
      return;
    }
    
    debugPrint('👤 Usuario actual: ${currentUser.email}');
    debugPrint('🔑 UID del usuario: ${currentUser.uid}');
    debugPrint('🔄 Iniciando migración de duración en citas...\n');
    
    // Obtener todas las citas del usuario actual
    final QuerySnapshot citasSnapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('terapeutaId', isEqualTo: currentUser.uid)
        .get();
    
    debugPrint('📊 Total de citas encontradas: ${citasSnapshot.docs.length}');
    
    int citasYaCorrectas = 0;
    int citasActualizadas = 0;
    
    for (var doc in citasSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String citaId = doc.id;
      final String nombreCliente = data['nombre'] ?? 'Sin nombre';
      final String fecha = data['fecha'] ?? 'Sin fecha';
      final String hora = data['hora'] ?? 'Sin hora';
      
      debugPrint('🔍 Procesando cita: $nombreCliente - $fecha $hora (ID: $citaId)');
      
      // Verificar si ya tiene el campo duracionMinutos
      if (data.containsKey('duracionMinutos')) {
        final int duracionActual = data['duracionMinutos'] ?? 60;
        debugPrint('   ✅ Ya tiene duración: $duracionActual minutos');
        citasYaCorrectas++;
      } else {
        // Agregar el campo duracionMinutos con valor por defecto de 60 minutos
        await FirebaseFirestore.instance
            .collection('citas')
            .doc(citaId)
            .update({
          'duracionMinutos': 60,
          'fechaMigracionDuracion': FieldValue.serverTimestamp(),
        });
        
        debugPrint('   🔄 Actualizada con duración: 60 minutos (1 hora)');
        citasActualizadas++;
      }
    }
    
    debugPrint('\n📋 RESUMEN DE MIGRACIÓN:');
    debugPrint('✅ Citas ya correctas: $citasYaCorrectas');
    debugPrint('🔄 Citas actualizadas: $citasActualizadas');
    debugPrint('📊 Total procesadas: ${citasSnapshot.docs.length}');
    debugPrint('\n🎉 ¡Migración de duración completada exitosamente!');
    
    if (citasActualizadas > 0) {
      debugPrint('\n💡 INFORMACIÓN IMPORTANTE:');
      debugPrint('   • Todas las citas existentes ahora tienen duración de 60 minutos (1 hora)');
      debugPrint('   • Puedes editar cada cita para ajustar la duración según sea necesario');
      debugPrint('   • Las nuevas citas permitirán seleccionar duración al crearlas');
      debugPrint('   • El sistema ahora previene conflictos de horarios considerando la duración');
    }
    
  } catch (e) {
    debugPrint('❌ Error ejecutando la migración: $e');
    debugPrint('   Verifica tu conexión a internet y que tengas permisos adecuados');
  }
}

/// Función para verificar el estado de las citas después de la migración
Future<void> verificarEstadoCitas() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Error: No hay usuario autenticado');
      return;
    }
    
    debugPrint('🔍 Verificando estado de citas después de la migración...\n');
    
    final QuerySnapshot citasSnapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('terapeutaId', isEqualTo: currentUser.uid)
        .get();
    
    debugPrint('📊 Verificación de ${citasSnapshot.docs.length} citas:');
    
    int conDuracion = 0;
    int sinDuracion = 0;
    
    for (var doc in citasSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String nombreCliente = data['nombre'] ?? 'Sin nombre';
      final String fecha = data['fecha'] ?? 'Sin fecha';
      
      if (data.containsKey('duracionMinutos')) {
        final int duracion = data['duracionMinutos'] ?? 0;
        debugPrint('   ✅ $nombreCliente ($fecha): ${duracion} minutos');
        conDuracion++;
      } else {
        debugPrint('   ❌ $nombreCliente ($fecha): SIN DURACIÓN');
        sinDuracion++;
      }
    }
    
    debugPrint('\n📈 ESTADÍSTICAS:');
    debugPrint('✅ Citas con duración: $conDuracion');
    debugPrint('❌ Citas sin duración: $sinDuracion');
    
    if (sinDuracion == 0) {
      debugPrint('🎉 ¡Todas las citas tienen duración configurada!');
    } else {
      debugPrint('⚠️  Hay citas que requieren migración. Ejecuta migrarDuracionCitas()');
    }
    
  } catch (e) {
    debugPrint('❌ Error verificando estado: $e');
  }
}
