import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/mercadopago_service.dart';

/// Widget para gestionar la configuración de MercadoPago
/// Permite vincular/desvincular cuenta y ver estado
class MercadoPagoWidget extends StatefulWidget {
  const MercadoPagoWidget({super.key});

  @override
  State<MercadoPagoWidget> createState() => _MercadoPagoWidgetState();
}

class _MercadoPagoWidgetState extends State<MercadoPagoWidget> {
  bool _isLoading = true;
  bool _cuentaVinculada = false;
  Map<String, dynamic>? _infoCuenta;

  @override
  void initState() {
    super.initState();
    _verificarEstadoCuenta();
  }

  /// Verificar estado actual de la cuenta MP
  Future<void> _verificarEstadoCuenta() async {
    setState(() => _isLoading = true);
    
    try {
      final vinculada = await MercadoPagoService.tieneCuentaVinculada();
      final info = await MercadoPagoService.obtenerInfoCuentaMP();
      
      setState(() {
        _cuentaVinculada = vinculada;
        _infoCuenta = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verificando cuenta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Iniciar proceso de vinculación OAuth2
  Future<void> _vincularCuenta() async {
    try {
      setState(() => _isLoading = true);

      final authUrl = await MercadoPagoService.generarUrlAutorizacion();
      
      if (authUrl == null) {
        throw 'No se pudo generar URL de autorización';
      }

      // Abrir navegador para OAuth2
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // Mostrar diálogo informativo
        if (mounted) {
          _mostrarDialogoEsperaAutorizacion();
        }
      } else {
        throw 'No se puede abrir el navegador';
      }

    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Diálogo de espera durante autorización OAuth2
  void _mostrarDialogoEsperaAutorizacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.link, color: Colors.blue),
            SizedBox(width: 8),
            Text('Vinculando cuenta'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌐 Se ha abierto Mercado Pago en tu navegador.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Autoriza la aplicación en Mercado Pago'),
            Text('2. Regresa a esta pantalla'),
            Text('3. Presiona "Ya autoricé"'),
            SizedBox(height: 16),
            Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Esperando autorización...'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _verificarEstadoCuenta(); // Recargar estado
            },
            child: const Text('Ya autoricé'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isLoading = false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Confirmar y desvincular cuenta MP
  Future<void> _desvincularCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Desvincular cuenta'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Esta acción desactivará los pagos para tus servicios.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Los clientes no podrán:'),
            Text('• Realizar pagos online'),
            Text('• Recibir links de pago'),
            Text('• Confirmar citas con pago'),
            SizedBox(height: 12),
            Text(
              '¿Estás seguro de que quieres desvincular tu cuenta de Mercado Pago?',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);
      
      final exito = await MercadoPagoService.desvincularCuenta();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito 
                ? '✅ Cuenta desvinculada exitosamente'
                : '❌ Error al desvincular cuenta'
            ),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
      
      _verificarEstadoCuenta();
    }
  }

  /// Navegar al historial de pagos
  void _verHistorialPagos() {
    Navigator.pushNamed(context, '/historial-pagos');
  }

  /// Mostrar información detallada de la cuenta
  void _mostrarInfoDetallada() {
    if (_infoCuenta == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Información de la cuenta'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Estado:', _cuentaVinculada ? 'Vinculada' : 'No vinculada'),
            if (_infoCuenta!['user_id'] != null)
              _buildInfoRow('ID Usuario MP:', _infoCuenta!['user_id']),
            if (_infoCuenta!['public_key'] != null)
              _buildInfoRow('Public Key:', '${_infoCuenta!['public_key']}'.substring(0, 20) + '...'),
            if (_infoCuenta!['fecha_vinculacion'] != null)
              _buildInfoRow('Vinculada el:', _formatearFecha(_infoCuenta!['fecha_vinculacion'])),
            if (_infoCuenta!['expires_at'] != null)
              _buildInfoRow('Token expira:', _formatearFecha(_infoCuenta!['expires_at'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verificando estado de Mercado Pago...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cuentaVinculada ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _cuentaVinculada ? Icons.account_balance_wallet : Icons.payment,
                    color: _cuentaVinculada ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mercado Pago',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _cuentaVinculada ? 'Pagos online activados' : 'Pagos online desactivados',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _cuentaVinculada ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cuentaVinculada ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _cuentaVinculada ? 'VINCULADA' : 'NO VINCULADA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información básica
            if (_cuentaVinculada && _infoCuenta != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Tu cuenta está vinculada y funcionando'),
                        const Spacer(),
                        IconButton(
                          onPressed: _mostrarInfoDetallada,
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Ver detalles',
                        ),
                      ],
                    ),
                    if (_infoCuenta!['user_id'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${_infoCuenta!['user_id']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botones de acción para cuenta vinculada
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _verHistorialPagos,
                      icon: const Icon(Icons.history),
                      label: const Text('Historial'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _desvincularCuenta,
                      icon: const Icon(Icons.link_off),
                      label: const Text('Desvincular'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Información para cuenta no vinculada
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vincula tu cuenta para activar pagos online',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Recibe pagos directamente en tu cuenta MP'),
                    Text('• Genera links de pago para tus clientes'),
                    Text('• Acepta tarjetas, transferencias y más'),
                    Text('• Confirmación automática de pagos'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botón de vinculación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _vincularCuenta,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Vincular Cuenta de Mercado Pago'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Formatear timestamp de Firestore a string legible
  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return 'No disponible';
    
    try {
      final fecha = (timestamp as Timestamp).toDate();
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
