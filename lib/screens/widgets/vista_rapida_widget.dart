import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/birthday_service.dart';
import '../pantalla_ver_clientes.dart';
import '../pantalla_ver_citas.dart';

class VistaRapidaWidget extends StatefulWidget {
  const VistaRapidaWidget({super.key});

  @override
  State<VistaRapidaWidget> createState() => _VistaRapidaWidgetState();
}

class _VistaRapidaWidgetState extends State<VistaRapidaWidget> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int totalClientes = 0;
  int citasHoy = 0;
  List<Map<String, dynamic>> clientesCumpleanos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarEstadisticas();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar datos cuando la app vuelve a estar activa
      _cargarEstadisticas();
    }
  }

  @override
  void didUpdateWidget(VistaRapidaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar datos cuando el widget se actualiza
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
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
      final String fechaHoyISO = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
      
      debugPrint('VistaRapida: Buscando citas para fecha ISO: $fechaHoyISO');
      debugPrint('VistaRapida: Terapeuta ID: ${currentUser.uid}');
      
      // Debug: Ver todas las citas del terapeuta para verificar formato de fecha
      final todasLasCitas = await _firestore
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .get();
      
      debugPrint('VistaRapida: Total de citas del terapeuta: ${todasLasCitas.docs.length}');
      for (var doc in todasLasCitas.docs) {
        final data = doc.data();
        debugPrint('VistaRapida: Cita - fecha: ${data['fecha']}, id: ${doc.id}');
      }
      
      final citasSnapshot = await _firestore
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('fecha', isEqualTo: fechaHoyISO)
          .get();
      
      debugPrint('VistaRapida: Citas encontradas para hoy: ${citasSnapshot.docs.length}');

      // Obtener clientes con cumpleaños
      final clientesConCumpleanos = await BirthdayService.getClientesConCumpleanosHoy();

      setState(() {
        totalClientes = clientesSnapshot.docs.length;
        citasHoy = citasSnapshot.docs.length;
        clientesCumpleanos = clientesConCumpleanos;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método público para actualizar los datos desde fuera del widget
  void actualizarDatos() {
    _cargarEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
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
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
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
                    Icons.analytics,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Vista Rápida',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _cargarEstadisticas,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      tooltip: 'Actualizar datos',
                    ),
                ],
              ),
              const SizedBox(height: 20),

              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else ...[
                // Estadísticas principales
                Row(
                  children: [
                    Expanded(
                      child: _buildNavigableStatCard(
                        icon: Icons.people,
                        title: 'Clientes',
                        value: totalClientes.toString(),
                        subtitle: 'Total registrados',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaVerClientes(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildNavigableStatCard(
                        icon: Icons.calendar_today,
                        title: 'Citas Hoy',
                        value: citasHoy.toString(),
                        subtitle: 'Programadas',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaVerCitas(fechaFiltro: DateTime.now()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Sección de cumpleaños
                if (clientesCumpleanos.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
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
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${clientesCumpleanos.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...clientesCumpleanos.take(3).map((cliente) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${cliente['nombre']}${cliente['edad'] != null ? ' (${cliente['edad']} años)' : ''}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        if (clientesCumpleanos.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '... y ${clientesCumpleanos.length - 3} más',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mensaje cuando no hay cumpleaños
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'No hay cumpleaños hoy',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigableStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
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
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              Icons.touch_app,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
