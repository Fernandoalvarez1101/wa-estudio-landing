import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/mercadopago_service.dart';

/// Pantalla para mostrar el historial de pagos de MercadoPago
class PantallaHistorialPagos extends StatefulWidget {
  const PantallaHistorialPagos({super.key});

  @override
  State<PantallaHistorialPagos> createState() => _PantallaHistorialPagosState();
}

class _PantallaHistorialPagosState extends State<PantallaHistorialPagos> {
  Map<String, dynamic>? _estadisticas;
  bool _cargandoEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _cargandoEstadisticas = true);
    
    final estadisticas = await MercadoPagoService.obtenerEstadisticasPagos();
    
    setState(() {
      _estadisticas = estadisticas;
      _cargandoEstadisticas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarEstadisticas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarjeta de estadísticas
          _buildEstadisticas(),
          
          // Lista de pagos
          Expanded(
            child: _buildListaPagos(),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    if (_cargandoEstadisticas) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cargando estadísticas...'),
            ],
          ),
        ),
      );
    }

    if (_estadisticas == null) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Error cargando estadísticas'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas - ${_estadisticas!['periodo'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid de estadísticas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildEstadisticaItem(
                  'Total Pagos',
                  '${_estadisticas!['total_pagos'] ?? 0}',
                  Icons.receipt,
                  Colors.blue,
                ),
                _buildEstadisticaItem(
                  'Aprobados',
                  '${_estadisticas!['pagos_aprobados'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildEstadisticaItem(
                  'Monto Total',
                  MercadoPagoService.formatearMonto(_estadisticas!['monto_total'] ?? 0.0),
                  Icons.attach_money,
                  Colors.orange,
                ),
                _buildEstadisticaItem(
                  'Promedio',
                  MercadoPagoService.formatearMonto(_estadisticas!['promedio_pago'] ?? 0.0),
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaPagos() {
    return StreamBuilder<QuerySnapshot>(
      stream: MercadoPagoService.obtenerHistorialPagos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando historial de pagos...'),
              ],
            ),
          );
        }

        final pagos = snapshot.data?.docs ?? [];

        if (pagos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay pagos registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los pagos aparecerán aquí una vez que se realicen',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pagos.length,
          itemBuilder: (context, index) {
            final pago = pagos[index];
            final data = pago.data() as Map<String, dynamic>;
            
            return _buildTarjetaPago(pago.id, data);
          },
        );
      },
    );
  }

  Widget _buildTarjetaPago(String pagoId, Map<String, dynamic> data) {
    final estado = data['estado'] ?? 'unknown';
    final monto = (data['monto'] ?? 0).toDouble();
    final clienteNombre = data['cliente_nombre'] ?? 'Cliente';
    final servicio = data['servicio'] ?? 'Servicio';
    final fechaPago = data['fecha_pago'] as Timestamp?;
    final metodoPago = data['metodo_pago'] ?? 'N/A';
    final mpPaymentId = data['mp_payment_id'] ?? 'N/A';

    final colorEstado = MercadoPagoService.obtenerColorEstado(estado);
    final iconoEstado = MercadoPagoService.obtenerIconoEstado(estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del pago
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconoEstado, color: colorEstado),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clienteNombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        servicio,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MercadoPagoService.formatearMonto(monto),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _obtenerTextoEstado(estado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Detalles del pago
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetalleFila('Fecha:', _formatearFechaPago(fechaPago)),
                  _buildDetalleFila('Método:', metodoPago),
                  _buildDetalleFila('ID MP:', mpPaymentId),
                  _buildDetalleFila('ID Interno:', pagoId.substring(0, 8) + '...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerTextoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'approved':
        return 'APROBADO';
      case 'pending':
        return 'PENDIENTE';
      case 'rejected':
        return 'RECHAZADO';
      default:
        return 'DESCONOCIDO';
    }
  }

  String _formatearFechaPago(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      final fecha = timestamp.toDate();
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
