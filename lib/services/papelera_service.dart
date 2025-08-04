import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PapeleraService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mueve un cliente a la papelera (soft delete)
  static Future<bool> moverClienteAPapelera(String clienteId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Usuario no autenticado para mover cliente a papelera');
        return false;
      }

      debugPrint('🗑️ Moviendo cliente a papelera: $clienteId');

      // Obtener los datos del cliente
      final DocumentSnapshot clienteDoc = await _firestore
          .collection('clientes')
          .doc(clienteId)
          .get();

      if (!clienteDoc.exists) {
        debugPrint('❌ Cliente no encontrado: $clienteId');
        return false;
      }

      final Map<String, dynamic> datosCliente = clienteDoc.data() as Map<String, dynamic>;
      
      // Verificar que el cliente pertenece al usuario actual
      if (datosCliente['terapeutaUid'] != currentUser.uid) {
        debugPrint('❌ Cliente no pertenece al usuario actual');
        return false;
      }

      // Añadir campos de eliminación
      datosCliente['eliminado'] = true;
      datosCliente['fechaEliminacion'] = Timestamp.now();
      datosCliente['idOriginal'] = clienteId;

      debugPrint('📝 Datos del cliente para papelera: $datosCliente');

      // Mover a la colección de papelera
      await _firestore.collection('papelera_clientes').doc(clienteId).set(datosCliente);
      debugPrint('✅ Cliente guardado en papelera_clientes');

      // Eliminar de la colección original
      await _firestore.collection('clientes').doc(clienteId).delete();
      debugPrint('🗑️ Cliente eliminado de colección original');

      debugPrint('✅ Cliente movido a papelera exitosamente: $clienteId');
      return true;

    } catch (e) {
      debugPrint('❌ Error al mover cliente a papelera: $e');
      return false;
    }
  }

  /// Obtiene todos los clientes en la papelera del usuario actual
  static Future<List<QueryDocumentSnapshot>> getClientesEnPapelera() async {
    debugPrint('🔍 ========== INICIANDO BÚSQUEDA EN PAPELERA ==========');
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Usuario no autenticado');
        return [];
      }

      debugPrint('🔍 Buscando clientes en papelera para usuario: ${currentUser.uid}');
      debugPrint('📧 Email del usuario: ${currentUser.email}');

      // Consulta simplificada sin orderBy para evitar problemas de índice
      debugPrint('🔍 Realizando consulta simplificada...');
      final QuerySnapshot querySnapshot = await _firestore
          .collection('papelera_clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      debugPrint('📊 Clientes encontrados en papelera: ${querySnapshot.docs.length}');
      for (var doc in querySnapshot.docs) {
        debugPrint('📄 Cliente en papelera: ${doc.id} - ${doc.data()}');
      }

      return querySnapshot.docs;

    } catch (e) {
      debugPrint('❌ Error al obtener clientes en papelera: $e');
      return [];
    }
  }

  /// Restaura un cliente desde la papelera
  static Future<bool> restaurarCliente(String clienteId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Obtener los datos del cliente de la papelera
      final DocumentSnapshot clienteDoc = await _firestore
          .collection('papelera_clientes')
          .doc(clienteId)
          .get();

      if (!clienteDoc.exists) return false;

      final Map<String, dynamic> datosCliente = clienteDoc.data() as Map<String, dynamic>;
      
      // Verificar que el cliente pertenece al usuario actual
      if (datosCliente['terapeutaUid'] != currentUser.uid) return false;

      // Remover campos de eliminación
      datosCliente.remove('eliminado');
      datosCliente.remove('fechaEliminacion');
      datosCliente.remove('idOriginal');

      // Restaurar a la colección original
      await _firestore.collection('clientes').doc(clienteId).set(datosCliente);

      // Eliminar de la papelera
      await _firestore.collection('papelera_clientes').doc(clienteId).delete();

      debugPrint('✅ Cliente restaurado: $clienteId');
      return true;

    } catch (e) {
      debugPrint('❌ Error al restaurar cliente: $e');
      return false;
    }
  }

  /// Elimina permanentemente un cliente de la papelera
  static Future<bool> eliminarClientePermanentemente(String clienteId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Verificar que el cliente pertenece al usuario actual
      final DocumentSnapshot clienteDoc = await _firestore
          .collection('papelera_clientes')
          .doc(clienteId)
          .get();

      if (!clienteDoc.exists) return false;

      final Map<String, dynamic> datosCliente = clienteDoc.data() as Map<String, dynamic>;
      
      if (datosCliente['terapeutaUid'] != currentUser.uid) return false;

      // Eliminar permanentemente
      await _firestore.collection('papelera_clientes').doc(clienteId).delete();

      debugPrint('🗑️ Cliente eliminado permanentemente: $clienteId');
      return true;

    } catch (e) {
      debugPrint('❌ Error al eliminar cliente permanentemente: $e');
      return false;
    }
  }

  /// Vacía completamente la papelera del usuario actual
  static Future<int> vaciarPapelera() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final QuerySnapshot querySnapshot = await _firestore
          .collection('papelera_clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      final WriteBatch batch = _firestore.batch();
      int contador = 0;

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        contador++;
      }

      await batch.commit();

      debugPrint('🗑️ Papelera vaciada: $contador clientes eliminados permanentemente');
      return contador;

    } catch (e) {
      debugPrint('❌ Error al vaciar papelera: $e');
      return 0;
    }
  }

  /// Limpia automáticamente elementos de la papelera después de X días
  static Future<int> limpiarPapeleraAutomatica({int diasLimite = 30}) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final DateTime fechaLimite = DateTime.now().subtract(Duration(days: diasLimite));
      final Timestamp timestampLimite = Timestamp.fromDate(fechaLimite);

      final QuerySnapshot querySnapshot = await _firestore
          .collection('papelera_clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .where('fechaEliminacion', isLessThan: timestampLimite)
          .get();

      final WriteBatch batch = _firestore.batch();
      int contador = 0;

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        contador++;
      }

      await batch.commit();

      debugPrint('🧹 Limpieza automática completada: $contador clientes eliminados después de $diasLimite días');
      return contador;

    } catch (e) {
      debugPrint('❌ Error en limpieza automática: $e');
      return 0;
    }
  }

  /// Obtiene estadísticas de la papelera
  static Future<Map<String, int>> getEstadisticasPapelera() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return {'total': 0, 'estaSemanana': 0, 'esteMes': 0};

      // Solo obtener el total para evitar problemas de índices
      final QuerySnapshot totalQuery = await _firestore
          .collection('papelera_clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      // Calcular estadísticas en el cliente para evitar consultas con índices
      final DateTime ahora = DateTime.now();
      final DateTime inicioSemana = ahora.subtract(Duration(days: 7));
      final DateTime inicioMes = DateTime(ahora.year, ahora.month, 1);

      int estaSemana = 0;
      int esteMes = 0;

      for (var doc in totalQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final fechaEliminacion = data['fechaEliminacion'] as Timestamp?;
        if (fechaEliminacion != null) {
          final fecha = fechaEliminacion.toDate();
          if (fecha.isAfter(inicioSemana)) estaSemana++;
          if (fecha.isAfter(inicioMes)) esteMes++;
        }
      }

      return {
        'total': totalQuery.docs.length,
        'estaSemana': estaSemana,
        'esteMes': esteMes,
      };

    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas: $e');
      return {'total': 0, 'estaSemana': 0, 'esteMes': 0};
    }
  }

  /// Método de diagnóstico para verificar el estado de la papelera
  static Future<void> diagnosticarPapelera() async {
    debugPrint('🔍 ========== DIAGNÓSTICO DE PAPELERA ==========');
    
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Usuario no autenticado');
        return;
      }

      debugPrint('👤 Usuario actual: ${currentUser.uid}');
      debugPrint('📧 Email: ${currentUser.email}');

      // Verificar colección papelera_clientes
      debugPrint('🔍 Verificando colección papelera_clientes...');
      final QuerySnapshot papeleraQuery = await _firestore
          .collection('papelera_clientes')
          .get();
      
      debugPrint('📊 Total documentos en papelera_clientes: ${papeleraQuery.docs.length}');
      
      // Verificar documentos del usuario actual
      final QuerySnapshot userPapeleraQuery = await _firestore
          .collection('papelera_clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();
      
      debugPrint('📊 Documentos del usuario en papelera: ${userPapeleraQuery.docs.length}');
      
      for (var doc in userPapeleraQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('📄 Doc ID: ${doc.id}');
        debugPrint('   - Nombre: ${data['nombre'] ?? 'N/A'}');
        debugPrint('   - Eliminado: ${data['eliminado'] ?? 'N/A'}');
        debugPrint('   - Fecha eliminación: ${data['fechaEliminacion'] ?? 'N/A'}');
        debugPrint('   - Terapeuta UID: ${data['terapeutaUid'] ?? 'N/A'}');
      }

      // Verificar colección clientes (para comparar)
      debugPrint('🔍 Verificando colección clientes...');
      final QuerySnapshot clientesQuery = await _firestore
          .collection('clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();
      
      debugPrint('📊 Clientes activos del usuario: ${clientesQuery.docs.length}');

    } catch (e) {
      debugPrint('❌ Error en diagnóstico: $e');
    }
    
    debugPrint('🔍 ========== FIN DIAGNÓSTICO ==========');
  }
}
