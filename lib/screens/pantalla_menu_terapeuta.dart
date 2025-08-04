import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/birthday_service.dart';
import 'widgets/vista_rapida_widget.dart';
import 'widgets/acceso_rapido_widget.dart';
import 'widgets/configuracion_negocio_widget.dart';

class PantallaMenuTerapeuta extends StatefulWidget {
  const PantallaMenuTerapeuta({super.key});

  @override
  State<PantallaMenuTerapeuta> createState() => _PantallaMenuTerapeutaState();
}

class _PantallaMenuTerapeutaState extends State<PantallaMenuTerapeuta> {

  @override
  void initState() {
    super.initState();
    // Verificar cumpleaños al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BirthdayService.verificarYMostrarCumpleanos(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del Terapeuta')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget de Vista Rápida (Estadísticas)
            const VistaRapidaWidget(),
            
            // Widget de Acceso Rápido (Botones de Acción)
            const AccesoRapidoWidget(),
            
            // Widget de Configuración del Negocio
            const ConfiguracionNegocioWidget(),
            
            // Botón de cerrar sesión al final manteniéndolo visible
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Cerrar sesión completamente
                      await AuthService.signOut();
                      
                      if (context.mounted) {
                        // Navegar a la pantalla de inicio y limpiar el stack de navegación
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
