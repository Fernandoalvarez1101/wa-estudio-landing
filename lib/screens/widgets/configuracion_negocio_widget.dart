import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pantalla_gestionar_servicios.dart';
import '../pantalla_gestionar_terapeutas.dart';
import '../pantalla_gestionar_locales.dart';
import '../pantalla_editar_mensaje_whatsapp.dart';
import '../pantalla_editar_mensaje_correo.dart';
import '../pantalla_login_terapeuta.dart';
import 'mercadopago_widget.dart';

class ConfiguracionNegocioWidget extends StatelessWidget {
  const ConfiguracionNegocioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Configuración del Negocio',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Acciones principales (más grandes)
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryActionCard(
                    context,
                    icon: Icons.people,
                    title: 'Empleados',
                    subtitle: 'Gestionar equipo',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionarTerapeutas(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrimaryActionCard(
                    context,
                    icon: Icons.business_center,
                    title: 'Servicios',
                    subtitle: 'Configurar servicios',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionarServicios(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Acciones secundarias (más pequeñas)
            Text(
              'Configuración Adicional',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryActionButton(
                    context,
                    icon: Icons.location_on,
                    label: 'Locales',
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionarLocales(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSecondaryActionButton(
                    context,
                    icon: Icons.message,
                    label: 'WhatsApp',
                    color: Colors.green.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaEditarMensajeWhatsApp(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSecondaryActionButton(
                    context,
                    icon: Icons.email,
                    label: 'Correo',
                    color: Colors.blue.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaEditarMensajeCorreo(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // === NUEVO: WIDGET DE MERCADOPAGO ===
            const MercadoPagoWidget(),
            
            const SizedBox(height: 20),

            // Sección de configuración avanzada
            Text(
              'Configuración Avanzada',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón de eliminar cuenta
            _buildDangerActionButton(
              context,
              icon: Icons.delete_forever,
              title: 'Eliminar Cuenta',
              subtitle: 'Eliminar permanentemente todos los datos',
              onTap: () => _mostrarDialogoEliminarCuenta(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.red,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminarCuenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                '⚠️ Eliminar Cuenta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta acción es IRREVERSIBLE y eliminará permanentemente:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text('• Todos tus clientes y sus datos'),
              const Text('• Todas las citas programadas'),
              const Text('• Empleados y servicios configurados'),
              const Text('• Locales y configuraciones'),
              const Text('• Mensajes personalizados'),
              const Text('• Tu cuenta de usuario'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Text(
                  '⚠️ NO PODRÁS RECUPERAR ESTA INFORMACIÓN',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarDialogoConfirmacionFinal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoConfirmacionFinal(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '🔒 Confirmación Final',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para confirmar la eliminación de tu cuenta, escribe:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ELIMINAR MI CUENTA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  labelText: 'Escribe el texto exacto',
                  border: OutlineInputBorder(),
                  hintText: 'ELIMINAR MI CUENTA',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                confirmController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (confirmController.text.trim() == 'ELIMINAR MI CUENTA') {
                  Navigator.of(context).pop();
                  await _eliminarCuentaCompleta(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El texto no coincide. Verifica que sea exacto.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                confirmController.dispose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'ELIMINAR CUENTA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarCuentaCompleta(BuildContext context) async {
    // Mostrar diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Eliminando cuenta...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor espera, esto puede tomar unos momentos.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No hay usuario autenticado';
      }

      final String uid = user.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Eliminar datos en orden específico
      final List<String> colecciones = [
        'citas',
        'clientes',
        'terapeutas',
        'servicios', 
        'locales',
        'configuracion_mensajes',
        'papelera_clientes',
      ];

      // Eliminar documentos de cada colección
      for (String coleccion in colecciones) {
        final QuerySnapshot snapshot = await firestore
            .collection(coleccion)
            .where('terapeutaUid', isEqualTo: uid)
            .get();

        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Eliminar cuenta de Firebase Auth
      await user.delete();

      // Cerrar diálogo de progreso
      Navigator.of(context).pop();

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a pantalla de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const PantallaLoginTerapeuta(),
        ),
        (route) => false,
      );

    } catch (e) {
      // Cerrar diálogo de progreso
      Navigator.of(context).pop();

      // Mostrar error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error al eliminar cuenta',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'No se pudo eliminar la cuenta: ${e.toString()}\n\n'
              'Por favor, inténtalo de nuevo o contacta al soporte técnico.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          );
        },
      );
    }
  }
}
