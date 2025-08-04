import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mercadopago_service.dart';

/// Widget simplificado para gestionar MercadoPago
/// Versión sin Firebase Functions
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
      
      final url = await MercadoPagoService.generarUrlAutorizacion();
      
      if (url == null) {
        throw 'Error generando URL de autorización';
      }

      // Abrir URL en navegador
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir el navegador';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Abriendo autorización MercadoPago...'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Desvincular cuenta MP
  Future<void> _desvincularCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desvincular MercadoPago'),
        content: const Text('¿Estás seguro? No podrás recibir pagos hasta vincular otra cuenta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      setState(() => _isLoading = true);
      
      final exito = await MercadoPagoService.desvincularCuenta();
      
      if (exito) {
        await _verificarEstadoCuenta();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cuenta desvinculada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'Error desvinculando cuenta';
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A1E4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MercadoPago',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gestiona tus pagos online',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Loading
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            
            // Estado de cuenta
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cuentaVinculada 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cuentaVinculada 
                        ? Colors.green
                        : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cuentaVinculada 
                          ? Icons.check_circle
                          : Icons.warning,
                      color: _cuentaVinculada 
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cuentaVinculada 
                                ? 'Cuenta Vinculada'
                                : 'Cuenta No Vinculada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _cuentaVinculada 
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                          Text(
                            _cuentaVinculada 
                                ? 'Puedes recibir pagos'
                                : 'Vincula tu cuenta para recibir pagos',
                            style: TextStyle(
                              fontSize: 12,
                              color: _cuentaVinculada 
                                  ? Colors.green[600]
                                  : Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Info cuenta (si está vinculada)
              if (_cuentaVinculada && _infoCuenta != null) ...[
                const Text(
                  'Información de la cuenta:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_infoCuenta!['user_id'] != null)
                        Text('ID Usuario: ${_infoCuenta!['user_id']}'),
                      if (_infoCuenta!['fecha_vinculacion'] != null)
                        Text('Vinculada: ${_infoCuenta!['fecha_vinculacion']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Botones de acción
              Row(
                children: [
                  if (!_cuentaVinculada)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _vincularCuenta,
                        icon: const Icon(Icons.link),
                        label: const Text('Vincular Cuenta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A1E4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _desvincularCuenta,
                        icon: const Icon(Icons.link_off),
                        label: const Text('Desvincular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  
                  const SizedBox(width: 12),
                  
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _verificarEstadoCuenta,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NOTA: Esta es una versión simplificada. Para completar la vinculación necesitarás copiar el código de autorización manualmente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
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
