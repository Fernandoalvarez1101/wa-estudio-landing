import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserType = 'user_type';
  static const String _keyUserEmail = 'user_email';

  // Guardar estado de autenticación
  static Future<void> saveAuthState(String userType, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserType, userType);
    await prefs.setString(_keyUserEmail, email);
  }

  // Verificar si hay una sesión guardada
  static Future<Map<String, dynamic>?> getAuthState() async {
    debugPrint('🔍 AuthService: Verificando estado de auth...');
    try {
      // Crear la función async que devuelve el resultado
      final result = await (() async {
        final prefs = await SharedPreferences.getInstance();
        debugPrint('✅ SharedPreferences obtenido');
        
        final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
        debugPrint('📱 isLoggedIn: $isLoggedIn');
        
        if (!isLoggedIn) {
          debugPrint('❌ No está logueado en SharedPreferences');
          return null;
        }

        // Verificar que Firebase Auth también tenga la sesión activa
        final currentUser = FirebaseAuth.instance.currentUser;
        debugPrint('🔥 Firebase currentUser: ${currentUser?.email}');
        
        if (currentUser == null) {
          debugPrint('❌ No hay usuario en Firebase Auth, limpiando SharedPreferences');
          // Si Firebase no tiene sesión, limpiar SharedPreferences
          await clearAuthState();
          return null;
        }

        final userType = prefs.getString(_keyUserType);
        final email = prefs.getString(_keyUserEmail);
        debugPrint('📧 Email guardado: $email, Tipo: $userType');

        if (userType != null && email != null) {
          debugPrint('✅ Estado de auth válido encontrado');
          return {
            'userType': userType,
            'email': email,
            'isLoggedIn': true,
          };
        }

        debugPrint('⚠️ Datos incompletos en SharedPreferences');
        return null;
      })().timeout(const Duration(seconds: 5));
      
      return result;
    } catch (e) {
      debugPrint('💥 Error en getAuthState: $e');
      return null;
    }
  }

  // Limpiar estado de autenticación
  static Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyUserEmail);
  }

  // Cerrar sesión completamente
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await clearAuthState();
  }
}
