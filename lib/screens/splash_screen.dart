import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'pantalla_inicio.dart';
import 'pantalla_menu_terapeuta.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  
  // Animaciones para "Wä"
  late Animation<double> _waFadeAnimation;
  late Animation<double> _dieresisDropAnimation;
  
  // Animaciones para la línea y "Estudio"
  late Animation<double> _lineExpandAnimation;
  late Animation<double> _estudioRevealAnimation;
  late Animation<double> _lineContractAnimation;

  @override
  void initState() {
    super.initState();
    
    debugPrint('🚀 SplashScreen iniciado');
    
    // Controlador maestro para toda la secuencia de 3 segundos
    _masterController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 1. Aparición de "Wä" (0.5s - 1.5s)
    _waFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.17, 0.5, curve: Curves.easeIn), // 0.5s - 1.5s
    ));

    // Caída de los puntos de la diéresis (inmediatamente después de "Wä")
    _dieresisDropAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.5, 0.67, curve: Curves.bounceOut), // 1.5s - 2.0s
    ));

    // 2. Revelación de "Estudio" (1.5s - 2.5s)
    _lineExpandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.5, 0.67, curve: Curves.easeOut), // 1.5s - 2.0s
    ));

    _estudioRevealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.6, 0.77, curve: Curves.easeIn), // 1.8s - 2.3s
    ));

    _lineContractAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.77, 0.83, curve: Curves.easeIn), // 2.3s - 2.5s
    ));

    // Iniciar la animación maestra
    _masterController.forward();

    // Navegación después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      debugPrint('⏰ Timer completado, verificando estado de auth...');
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    try {
      debugPrint('🔍 Verificando estado de autenticación...');
      final authState = await AuthService.getAuthState();
      
      if (authState != null && authState['isLoggedIn'] == true) {
        debugPrint('✅ Sesión encontrada, navegando al menú principal');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PantallaMenuTerapeuta()),
          );
        }
      } else {
        debugPrint('❌ No hay sesión guardada, navegando a pantalla de inicio');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PantallaInicio()),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error verificando auth: $e');
      // En caso de error, navegar a pantalla de inicio por seguridad
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
        );
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Fondo blanco
      body: Center(
        child: AnimatedBuilder(
          animation: _masterController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contenedor principal del logo
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // "Wä" con animación de fade in
                      FadeTransition(
                        opacity: _waFadeAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Texto base "Wa"
                            const Text(
                              'Wa',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF008080),
                                letterSpacing: 2,
                              ),
                            ),
                            // Puntos de la diéresis que caen
                            AnimatedBuilder(
                              animation: _dieresisDropAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(14, _dieresisDropAnimation.value - 15),
                                  child: const Text(
                                    '¨',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF008080),
                                      height: 0.1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Línea horizontal que se expande y revela "Estudio"
                SizedBox(
                  height: 60,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Texto "Estudio" que se revela
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _estudioRevealAnimation.value,
                          child: const Text(
                            'Estudio',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF008080),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      
                      // Línea horizontal animada
                      Positioned(
                        bottom: 10,
                        child: AnimatedBuilder(
                          animation: _masterController,
                          builder: (context, child) {
                            double lineWidth;
                            if (_lineContractAnimation.value < 1.0) {
                              // Fase de contracción
                              lineWidth = 200 * _lineContractAnimation.value;
                            } else {
                              // Fase de expansión
                              lineWidth = 200 * _lineExpandAnimation.value;
                            }
                            
                            return Container(
                              width: lineWidth,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF008080),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Subtítulo que aparece al final
                AnimatedOpacity(
                  opacity: _masterController.value > 0.8 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'Tu agenda de citas profesional',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
