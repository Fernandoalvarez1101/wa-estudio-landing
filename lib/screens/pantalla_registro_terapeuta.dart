import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_menu_terapeuta.dart';
import '../services/auth_service.dart';

class PantallaRegistroTerapeuta extends StatefulWidget {
  const PantallaRegistroTerapeuta({super.key});

  @override
  State<PantallaRegistroTerapeuta> createState() =>
      _PantallaRegistroTerapeutaState();
}

class _PantallaRegistroTerapeutaState extends State<PantallaRegistroTerapeuta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // Para controlar visibilidad de contraseña

  Future<void> _registrarTerapeuta() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Limpiar la instancia de FirebaseAuth antes del registro
        await FirebaseAuth.instance.signOut();
        
        // Crear usuario con Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correoController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Actualizar el perfil del usuario con el nombre
        if (userCredential.user != null) {
          await userCredential.user?.updateDisplayName(usuarioController.text.trim());
          await userCredential.user?.reload(); // Recargar para asegurar que se actualice
          
          // Guardar estado de autenticación automáticamente después del registro exitoso
          await AuthService.saveAuthState('terapeuta', correoController.text.trim());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Registro exitoso. Bienvenido!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navegar directamente al menú de terapeuta ya que está autenticado
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaMenuTerapeuta()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String mensajeError;
        switch (e.code) {
          case 'weak-password':
            mensajeError = 'La contraseña es demasiado débil';
            break;
          case 'email-already-in-use':
            mensajeError = 'Ya existe una cuenta con este correo';
            break;
          case 'invalid-email':
            mensajeError = 'Formato de correo no válido';
            break;
          case 'network-request-failed':
            mensajeError = 'Sin conexión a internet. Verifica tu conexión';
            break;
          default:
            mensajeError = 'Error al registrar: ${e.code}';
        }
        
        print('FirebaseAuthException en registro: ${e.code} - ${e.message}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $mensajeError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        String errorMsg = e.toString();
        print('Error general en registro: $e');
        
        // Si es el error de PigeonUserDetails pero el usuario se registró correctamente, continuar
        if (errorMsg.contains('PigeonUserDetails') && errorMsg.contains('type cast')) {
          // Verificar si el usuario se registró exitosamente a pesar del error
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            // El registro fue exitoso, guardar estado y continuar
            await AuthService.saveAuthState('terapeuta', correoController.text.trim());
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Registro exitoso. Bienvenido!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PantallaMenuTerapeuta()),
              );
            }
            return; // Salir de la función sin mostrar error
          } else {
            // Si no hay usuario, mostrar error genérico
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Error de configuración. Intenta nuevamente'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Otros errores
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error inesperado. Verifica tu conexión'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Terapeuta')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu nombre';
                  }
                  if (value.length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  helperText: 'Mínimo 6 caracteres',
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
                    return 'Ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _registrarTerapeuta,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}