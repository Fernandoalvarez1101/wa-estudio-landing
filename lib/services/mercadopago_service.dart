import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Servicio para integración con MercadoPago Marketplace
/// Maneja OAuth2, creación de preferencias y gestión de pagos
class MercadoPagoService {
  // URLs de Firebase Functions
  static const String _baseUrl = 'https://us-central1-agendawa-5d8a1.cloudfunctions.net';
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // === CONFIGURACIÓN Y ESTADO ===

  /// Verificar si el terapeuta actual tiene cuenta MP vinculada
  static Future<bool> tieneCuentaVinculada() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ MercadoPagoService: Usuario no autenticado');
        return false;
      }

      debugPrint('🔍 MercadoPagoService: Verificando cuenta para ${user.uid}');

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('mercadopago_config')
          .doc('oauth')
          .get();

      if (!doc.exists) {
        debugPrint('📋 MercadoPagoService: No existe configuración MP');
        return false;
      }

      final data = doc.data()!;
      final vinculado = data['vinculado'] == true;
      final tieneToken = data['access_token'] != null;
      
      debugPrint('🔗 MercadoPagoService: Vinculado=$vinculado, Token=$tieneToken');
      
      return vinculado && tieneToken;
      
    } catch (e) {
      debugPrint('❌ Error verificando cuenta MP: $e');
      return false;
    }
  }

  /// Obtener información completa de la cuenta MP vinculada
  static Future<Map<String, dynamic>?> obtenerInfoCuentaMP() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('mercadopago_config')
          .doc('oauth')
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'vinculado': data['vinculado'] ?? false,
        'user_id': data['user_id'],
        'public_key': data['public_key'],
        'fecha_vinculacion': data['fecha_vinculacion'],
        'expires_at': data['expires_at'],
      };
    } catch (e) {
      debugPrint('❌ Error obteniendo info cuenta MP: $e');
      return null;
    }
  }

  // === PROCESO OAUTH2 ===

  /// Generar URL de autorización OAuth2 para vincular cuenta MP
  static Future<String?> generarUrlAutorizacion() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      debugPrint('🔗 MercadoPagoService: Generando URL OAuth2 para ${user.uid}');

      final response = await http.post(
        Uri.parse('$_baseUrl/generarUrlAutorizacion'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'terapeutaId': user.uid,
        }),
      );

      debugPrint('📡 Respuesta servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['auth_url'];
        
        debugPrint('✅ URL autorización generada: ${authUrl.substring(0, 50)}...');
        return authUrl;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ Error generando URL de autorización: $e');
      return null;
    }
  }

  /// Intercambiar código OAuth2 por access_token
  static Future<bool> intercambiarCodigoPorToken(String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      debugPrint('🔄 MercadoPagoService: Intercambiando código por token');
      debugPrint('📝 Code: ${code.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse('$_baseUrl/intercambiarToken'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          'state': user.uid,
        }),
      );

      debugPrint('📡 Respuesta intercambio: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] == true;
        
        debugPrint('✅ Token intercambiado exitosamente: $success');
        return success;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ Error intercambiando token: $e');
      return false;
    }
  }

  // === GESTIÓN DE PAGOS ===

  /// Crear preferencia de pago para una cita específica
  static Future<String?> crearPreferenciaPago({
    required String citaId,
    required String clienteNombre,
    required String clienteEmail,
    required String servicio,
    required double monto,
    String? descripcion,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      debugPrint('💳 MercadoPagoService: Creando preferencia de pago');
      debugPrint('   Cliente: $clienteNombre');
      debugPrint('   Servicio: $servicio');
      debugPrint('   Monto: \$${monto.toStringAsFixed(2)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/crearPreferenciaPago'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'terapeutaId': user.uid,
          'citaId': citaId,
          'clienteNombre': clienteNombre,
          'clienteEmail': clienteEmail,
          'servicio': servicio,
          'monto': monto,
          'descripcion': descripcion ?? 'Pago por servicio de spa - $servicio',
        }),
      );

      debugPrint('📡 Respuesta preferencia: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final initPoint = data['init_point'];
        
        debugPrint('✅ Preferencia creada: ${initPoint?.substring(0, 50)}...');
        return initPoint;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ Error creando preferencia: $e');
      return null;
    }
  }

  // === ADMINISTRACIÓN DE CUENTA ===

  /// Desvincular cuenta MP del terapeuta
  static Future<bool> desvincularCuenta() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ Usuario no autenticado para desvincular');
        return false;
      }

      debugPrint('🔓 MercadoPagoService: Desvinculando cuenta MP');

      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('mercadopago_config')
          .doc('oauth')
          .update({
        'vinculado': false,
        'access_token': FieldValue.delete(),
        'refresh_token': FieldValue.delete(),
        'fecha_desvinculacion': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Cuenta MP desvinculada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error desvinculando cuenta: $e');
      return false;
    }
  }

  /// Eliminar completamente la configuración MP (para eliminar cuenta)
  static Future<bool> eliminarConfiguracionCompleta() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      debugPrint('🗑️ MercadoPagoService: Eliminando configuración MP completa');

      // Eliminar documento oauth
      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('mercadopago_config')
          .doc('oauth')
          .delete();

      // Eliminar colección de pagos
      final pagosSnapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('pagos')
          .get();

      for (final doc in pagosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar colección de preferencias
      final preferenciasSnapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('preferencias_pago')
          .get();

      for (final doc in preferenciasSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('✅ Configuración MP eliminada completamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando configuración MP: $e');
      return false;
    }
  }

  // === HISTORIAL Y CONSULTAS ===

  /// Stream del historial de pagos del terapeuta
  static Stream<QuerySnapshot> obtenerHistorialPagos() {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'Usuario no autenticado';
    }

    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('pagos')
        .orderBy('fecha_pago', descending: true)
        .limit(50) // Limitar a 50 pagos más recientes
        .snapshots();
  }

  /// Obtener estadísticas de pagos
  static Future<Map<String, dynamic>> obtenerEstadisticasPagos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      debugPrint('📊 MercadoPagoService: Calculando estadísticas de pagos');

      // Obtener todos los pagos del último mes
      final fechaLimite = DateTime.now().subtract(const Duration(days: 30));
      final timestamp = Timestamp.fromDate(fechaLimite);

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('pagos')
          .where('fecha_pago', isGreaterThan: timestamp)
          .get();

      double totalMonto = 0;
      int totalPagos = 0;
      int pagosAprobados = 0;
      int pagosPendientes = 0;
      int pagosRechazados = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final estado = data['estado'] ?? '';
        final monto = (data['monto'] ?? 0).toDouble();

        totalPagos++;
        
        switch (estado) {
          case 'approved':
            pagosAprobados++;
            totalMonto += monto;
            break;
          case 'pending':
            pagosPendientes++;
            break;
          case 'rejected':
            pagosRechazados++;
            break;
        }
      }

      final estadisticas = {
        'total_pagos': totalPagos,
        'pagos_aprobados': pagosAprobados,
        'pagos_pendientes': pagosPendientes,
        'pagos_rechazados': pagosRechazados,
        'monto_total': totalMonto,
        'promedio_pago': totalPagos > 0 ? totalMonto / pagosAprobados : 0,
        'periodo': 'Últimos 30 días',
      };

      debugPrint('📈 Estadísticas calculadas: $estadisticas');
      return estadisticas;

    } catch (e) {
      debugPrint('❌ Error calculando estadísticas: $e');
      return {
        'total_pagos': 0,
        'pagos_aprobados': 0,
        'pagos_pendientes': 0,
        'pagos_rechazados': 0,
        'monto_total': 0.0,
        'promedio_pago': 0.0,
        'error': e.toString(),
      };
    }
  }

  // === UTILIDADES ===

  /// Formatear monto para mostrar en UI
  static String formatearMonto(double monto, {String moneda = 'ARS'}) {
    return '\$${monto.toStringAsFixed(2)} $moneda';
  }

  /// Validar que el monto sea válido para MP
  static bool validarMonto(double monto) {
    // MP tiene mínimos y máximos según el país
    // Para Argentina: mínimo $1, máximo $250,000
    return monto >= 1 && monto <= 250000;
  }

  /// Obtener color según estado del pago
  static Color obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Obtener icono según estado del pago
  static IconData obtenerIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
