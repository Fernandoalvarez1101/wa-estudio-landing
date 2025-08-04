import 'package:shared_preferences/shared_preferences.dart';

class AuthLocal {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';

  // Lista de usuarios registrados (simulada)
  static final Map<String, Map<String, String>> _users = {
    'admin@test.com': {'password': '123456', 'name': 'Administrador'},
    'terapeuta@test.com': {'password': '123456', 'name': 'Terapeuta Prueba'},
  };

  // Registrar nuevo usuario
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validaciones básicas
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return {
          'success': false,
          'message': 'Todos los campos son obligatorios',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'La contraseña debe tener al menos 6 caracteres',
        };
      }

      if (!email.contains('@')) {
        return {'success': false, 'message': 'Formato de correo no válido'};
      }

      // Verificar si el usuario ya existe
      if (_users.containsKey(email)) {
        return {
          'success': false,
          'message': 'Ya existe una cuenta con este correo',
        };
      }

      // Agregar usuario
      _users[email] = {'password': password, 'name': name};

      // Guardar en preferencias
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserName, name);

      return {'success': true, 'message': 'Registro exitoso'};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones básicas
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Ingresa correo y contraseña'};
      }

      // Verificar si el usuario existe
      if (!_users.containsKey(email)) {
        return {
          'success': false,
          'message': 'No existe una cuenta con este correo',
        };
      }

      // Verificar contraseña
      if (_users[email]!['password'] != password) {
        return {'success': false, 'message': 'Contraseña incorrecta'};
      }

      // Guardar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserName, _users[email]!['name']!);

      return {'success': true, 'message': 'Login exitoso'};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
  }

  // Verificar si está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Obtener información del usuario actual
  static Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyUserEmail),
      'name': prefs.getString(_keyUserName),
    };
  }
}
