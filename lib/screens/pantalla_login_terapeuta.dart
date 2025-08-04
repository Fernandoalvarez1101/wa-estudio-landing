import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_menu_terapeuta.dart';
import 'pantalla_registro_terapeuta.dart'; // Importa la pantalla de registro
import '../services/auth_service.dart';

class PantallaLoginTerapeuta extends StatefulWidget {
  const PantallaLoginTerapeuta({super.key});

  @override
  State<PantallaLoginTerapeuta> createState() => _PantallaLoginTerapeutaState();
}

class _PantallaLoginTerapeutaState extends State<PantallaLoginTerapeuta> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String mensajeError = '';
  bool _isLoading = false;
  bool _recordarSesion = true; // Por defecto activado
  bool _obscurePassword = true; // Para controlar visibilidad de contraseña

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      mensajeError = '';
    });

    try {
      // Limpiar la instancia de FirebaseAuth antes del login
      await FirebaseAuth.instance.signOut();
      
      // Intentar login con Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usuarioController.text.trim(),
        password: _contrasenaController.text.trim(),
      );

      // Verificar que el usuario esté realmente autenticado
      if (credential.user != null && mounted) {
        // Guardar estado de autenticación solo si el usuario eligió recordar
        if (_recordarSesion) {
          await AuthService.saveAuthState('terapeuta', _usuarioController.text.trim());
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaMenuTerapeuta()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            mensajeError = 'No existe una cuenta con este correo';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            mensajeError = 'Credenciales incorrectas';
            break;
          case 'invalid-email':
            mensajeError = 'Formato de correo no válido';
            break;
          case 'too-many-requests':
            mensajeError = 'Demasiados intentos. Intenta más tarde';
            break;
          case 'network-request-failed':
            mensajeError = 'Sin conexión a internet. Verifica tu conexión';
            break;
          default:
            mensajeError = 'Error de autenticación: ${e.code}';
        }
      });
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      String errorMsg = e.toString();
      print('Error completo: $errorMsg');
      
      // Si es el error de PigeonUserDetails pero el usuario se autenticó correctamente, continuar
      if (errorMsg.contains('PigeonUserDetails') && errorMsg.contains('type cast')) {
        // Verificar si el usuario se logueó exitosamente a pesar del error
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // El login fue exitoso, guardar estado solo si se eligió recordar
          if (_recordarSesion) {
            await AuthService.saveAuthState('terapeuta', _usuarioController.text.trim());
          }
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaMenuTerapeuta()),
            );
          }
          return; // Salir de la función sin mostrar error
        } else {
          // Si no hay usuario, mostrar error genérico
          setState(() {
            mensajeError = 'Error interno de Firebase. Intenta nuevamente';
          });
        }
      } else {
        // Otros errores específicos
        setState(() {
          if (errorMsg.contains('network')) {
            mensajeError = 'Sin conexión a internet. Verifica tu conexión';
          } else if (errorMsg.contains('weak-password')) {
            mensajeError = 'La contraseña es demasiado débil';
          } else if (errorMsg.contains('wrong-password')) {
            mensajeError = 'Contraseña incorrecta';
          } else if (errorMsg.contains('user-not-found')) {
            mensajeError = 'No se encontró una cuenta con este correo';
          } else if (errorMsg.contains('invalid-email')) {
            mensajeError = 'Formato de correo no válido';
          } else {
            mensajeError = 'Error de inicio de sesión. Verifica tus credenciales';
          }
        });
      }
      print('Error general: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recuperarContrasena() async {
    if (_usuarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Ingresa tu correo electrónico para recuperar la contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _usuarioController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Se ha enviado un correo para restablecer tu contraseña'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensajeError;
      switch (e.code) {
        case 'user-not-found':
          mensajeError = 'No se encontró una cuenta con este correo';
          break;
        case 'invalid-email':
          mensajeError = 'Formato de correo no válido';
          break;
        case 'network-request-failed':
          mensajeError = 'Sin conexión a internet. Verifica tu conexión';
          break;
        default:
          mensajeError = 'Error al enviar correo: ${e.code}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $mensajeError'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error inesperado. Intenta nuevamente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Terapeuta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Checkbox para recordar sesión
              Row(
                children: [
                  Checkbox(
                    value: _recordarSesion,
                    onChanged: (value) {
                      setState(() {
                        _recordarSesion = value ?? true;
                      });
                    },
                  ),
                  const Text('Recordar sesión'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Mostrar mensaje de error si existe
              if (mensajeError.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mensajeError,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _iniciarSesion,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 20),
              
              // Botón para ir al registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaRegistroTerapeuta(),
                    ),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              
              // Botón para recuperar contraseña
              TextButton(
                onPressed: _recuperarContrasena,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
