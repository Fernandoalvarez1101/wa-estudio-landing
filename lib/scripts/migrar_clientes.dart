import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Script para migrar clientes existentes agregando el campo terapeutaUid
/// Este script debe ejecutarse una sola vez para corregir los datos existentes
Future<void> migrarClientesExistentes() async {
  try {
    debugPrint('🚀 Iniciando migración de clientes...');
    
    // Inicializar Firebase si no está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Error: No hay usuario autenticado');
      debugPrint('   Asegúrate de estar logueado antes de ejecutar la migración');
      return;
    }
    
    debugPrint('👤 Usuario actual: ${currentUser.email}');
    debugPrint('🔑 UID del usuario: ${currentUser.uid}');
    
    // Obtener todos los clientes que NO tienen el campo terapeutaUid
    final QuerySnapshot clientesSinUID = await FirebaseFirestore.instance
        .collection('clientes')
        .get();
    
    debugPrint('📊 Total de documentos encontrados: ${clientesSinUID.docs.length}');
    
    int clientesMigrados = 0;
    int clientesYaMigrados = 0;
    
    // Procesar cada cliente
    for (DocumentSnapshot cliente in clientesSinUID.docs) {
      final Map<String, dynamic> data = cliente.data() as Map<String, dynamic>;
      
      // Verificar si ya tiene el campo terapeutaUid
      if (data.containsKey('terapeutaUid')) {
        clientesYaMigrados++;
        debugPrint('✅ Cliente ${data['nombre']} ya tiene terapeutaUid');
        continue;
      }
      
      // Agregar el campo terapeutaUid
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(cliente.id)
          .update({
            'terapeutaUid': currentUser.uid,
          });
      
      clientesMigrados++;
      debugPrint('🔄 Migrado: ${data['nombre']} (${cliente.id})');
    }
    
    debugPrint('\n📋 RESUMEN DE MIGRACIÓN:');
    debugPrint('   - Clientes migrados: $clientesMigrados');
    debugPrint('   - Clientes ya migrados: $clientesYaMigrados');
    debugPrint('   - Total procesados: ${clientesMigrados + clientesYaMigrados}');
    debugPrint('✅ Migración completada exitosamente');
    
  } catch (e) {
    debugPrint('❌ Error durante la migración: $e');
  }
}

/// Función para verificar el estado de la migración
Future<void> verificarMigracion() async {
  try {
    debugPrint('🔍 Verificando estado de la migración...');
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Error: No hay usuario autenticado');
      return;
    }
    
    // Clientes con terapeutaUid
    final QuerySnapshot clientesConUID = await FirebaseFirestore.instance
        .collection('clientes')
        .where('terapeutaUid', isEqualTo: currentUser.uid)
        .get();
    
    // Todos los clientes
    final QuerySnapshot todosLosClientes = await FirebaseFirestore.instance
        .collection('clientes')
        .get();
    
    debugPrint('📊 ESTADO ACTUAL:');
    debugPrint('   - Total de clientes: ${todosLosClientes.docs.length}');
    debugPrint('   - Clientes asignados a tu usuario: ${clientesConUID.docs.length}');
    debugPrint('   - Clientes sin asignar: ${todosLosClientes.docs.length - clientesConUID.docs.length}');
    
    if (clientesConUID.docs.isNotEmpty) {
      debugPrint('\n👥 TUS CLIENTES:');
      for (var cliente in clientesConUID.docs) {
        final data = cliente.data() as Map<String, dynamic>;
        debugPrint('   - ${data['nombre']} (${data['correo']})');
      }
    }
  } catch (e) {
    debugPrint('❌ Error verificando migración: $e');
  }
}
