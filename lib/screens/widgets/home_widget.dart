import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/birthday_service.dart';
import '../pantalla_registrar_cliente.dart';
import '../pantalla_agendar_cita.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int totalClientes = 0;
  int citasHoy = 0;
  List<Map<String, dynamic>> clientesCumpleanos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosWidget();
  }

  Future<void> _cargarDatosWidget() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Obtener total de clientes
      final clientesSnapshot = await _firestore
          .collection('clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();
      
      // Obtener citas de hoy
      final DateTime hoy = DateTime.now();
      final String fechaHoy = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
      
      final citasSnapshot = await _firestore
          .collection('citas')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .where('fecha', isEqualTo: fechaHoy)
          .get();

      // Obtener clientes con cumpleaños
      final clientesConCumpleanos = await BirthdayService.getClientesConCumpleanosHoy();

      setState(() {
        totalClientes = clientesSnapshot.docs.length;
        citasHoy = citasSnapshot.docs.length;
        clientesCumpleanos = clientesConCumpleanos;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos del widget: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del widget
              Row(
                children: [
                  Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Resumen de Hoy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _cargarDatosWidget,
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Estadísticas en fila
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      title: 'Clientes',
                      value: totalClientes.toString(),
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.calendar_today,
                      title: 'Citas Hoy',
                      value: citasHoy.toString(),
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // Sección de cumpleaños
              if (clientesCumpleanos.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cake,
                            color: Colors.orange[300],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🎂 Cumpleaños de Hoy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...clientesCumpleanos.map((cliente) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '• ${cliente['nombre']}${cliente['edad'] != null ? ' (${cliente['edad']} años)' : ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Botones de acceso rápido
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.person_add,
                      label: 'Nuevo Cliente',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaRegistrarCliente(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.event_note,
                      label: 'Nueva Cita',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaAgendarCita(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
