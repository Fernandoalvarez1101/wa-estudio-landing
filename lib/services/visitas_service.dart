import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VisitasService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cuenta las visitas de un cliente en los últimos 6 meses
  /// basándose en las citas que están marcadas como "atendido: true"
  static Future<int> contarVisitasUltimos6Meses(String clienteNombre) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ VisitasService: Usuario no autenticado');
        return 0;
      }

      debugPrint('🔍 VisitasService: Contando visitas para cliente: $clienteNombre');
      debugPrint('👤 VisitasService: Terapeuta ID: ${currentUser.uid}');

      // Primero, buscar TODAS las citas del cliente para debug
      final QuerySnapshot todasLasCitas = await _firestore
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('nombre', isEqualTo: clienteNombre)
          .get();

      debugPrint('� VisitasService: Total de citas encontradas para $clienteNombre: ${todasLasCitas.docs.length}');
      
      // Debug: mostrar detalles de cada cita
      for (var doc in todasLasCitas.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('   📝 Cita: fecha=${data['fecha']}, atendido=${data['atendido']}');
      }

      // Ahora contar solo las atendidas
      final QuerySnapshot citasAtendidas = await _firestore
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('nombre', isEqualTo: clienteNombre)
          .where('atendido', isEqualTo: true)
          .get();

      final int visitasAtendidas = citasAtendidas.docs.length;
      
      debugPrint('✅ VisitasService: Cliente $clienteNombre tiene $visitasAtendidas citas atendidas (sin filtro de fecha)');
      
      return visitasAtendidas;
    } catch (e) {
      debugPrint('❌ VisitasService: Error contando visitas: $e');
      return 0;
    }
  }

  /// Obtiene un resumen de visitas por cliente para el terapeuta actual
  static Future<Map<String, int>> obtenerResumenVisitas() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ VisitasService: Usuario no autenticado');
        return {};
      }

      // Obtener todos los clientes del terapeuta
      final QuerySnapshot clientesSnapshot = await _firestore
          .collection('clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      Map<String, int> resumenVisitas = {};

      // Para cada cliente, contar sus visitas
      for (var clienteDoc in clientesSnapshot.docs) {
        final clienteData = clienteDoc.data() as Map<String, dynamic>;
        final String nombreCliente = clienteData['nombre'] ?? '';
        
        if (nombreCliente.isNotEmpty) {
          final int visitas = await contarVisitasUltimos6Meses(nombreCliente);
          resumenVisitas[nombreCliente] = visitas;
        }
      }

      debugPrint('📊 VisitasService: Resumen de visitas generado para ${resumenVisitas.length} clientes');
      return resumenVisitas;
    } catch (e) {
      debugPrint('❌ VisitasService: Error obteniendo resumen: $e');
      return {};
    }
  }

  /// Obtiene las fechas de las últimas visitas de un cliente
  static Future<List<DateTime>> obtenerFechasUltimasVisitas(String clienteNombre, {int limite = 5}) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final QuerySnapshot citasSnapshot = await _firestore
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('nombre', isEqualTo: clienteNombre)
          .where('atendido', isEqualTo: true)
          .get();

      List<DateTime> fechas = [];
      for (var doc in citasSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String fechaStr = data['fecha'] ?? '';
        if (fechaStr.isNotEmpty) {
          try {
            fechas.add(DateTime.parse(fechaStr));
          } catch (e) {
            debugPrint('⚠️ VisitasService: Error parseando fecha: $fechaStr');
          }
        }
      }

      // Ordenar por fecha (más recientes primero) y limitar
      fechas.sort((a, b) => b.compareTo(a));
      return fechas.take(limite).toList();
    } catch (e) {
      debugPrint('❌ VisitasService: Error obteniendo fechas de visitas: $e');
      return [];
    }
  }
}
