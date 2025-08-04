import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/papelera_service.dart';

class PantallaPapeleraClientes extends StatefulWidget {
  const PantallaPapeleraClientes({super.key});

  @override
  State<PantallaPapeleraClientes> createState() =>
      _PantallaPapeleraClientesState();
}

class _PantallaPapeleraClientesState extends State<PantallaPapeleraClientes> {
  List<QueryDocumentSnapshot> _clientesEliminados = [];
  Map<String, int> _estadisticas = {};
  bool _cargando = true;
  bool _seleccionMultiple = false;
  final Set<String> _clientesSeleccionados = {};

  @override
  void initState() {
    super.initState();
    print('🚀 Pantalla Papelera - initState ejecutado');
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    try {
      print('🔄 Cargando datos de papelera...');

      // Ejecutar diagnóstico primero
      await PapeleraService.diagnosticarPapelera();

      final clientes = await PapeleraService.getClientesEnPapelera();
      final stats = await PapeleraService.getEstadisticasPapelera();

      print('📊 Clientes en papelera obtenidos: ${clientes.length}');
      print('📈 Estadísticas: $stats');

      setState(() {
        _clientesEliminados = clientes;
        _estadisticas = stats;
        _cargando = false;
      });
    } catch (e) {
      print('❌ Error en _cargarDatos: $e');
      setState(() => _cargando = false);
      _mostrarError('Error al cargar datos: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  Future<void> _restaurarCliente(String clienteId, String nombre) async {
    final confirmado = await _mostrarDialogoConfirmacion(
      'Restaurar Cliente',
      '¿Deseas restaurar a "$nombre"? El cliente volverá a aparecer en la lista principal.',
      'Restaurar',
      Colors.green,
    );

    if (confirmado) {
      final resultado = await PapeleraService.restaurarCliente(clienteId);
      if (resultado) {
        _mostrarExito('Cliente "$nombre" restaurado correctamente');
        _cargarDatos();
      } else {
        _mostrarError('Error al restaurar el cliente');
      }
    }
  }

  Future<void> _eliminarPermanentemente(String clienteId, String nombre) async {
    final confirmado = await _mostrarDialogoConfirmacion(
      'Eliminar Permanentemente',
      '⚠️ ¿Estás seguro de eliminar permanentemente a "$nombre"?\n\nEsta acción NO se puede deshacer.',
      'Eliminar',
      Colors.red,
    );

    if (confirmado) {
      final resultado = await PapeleraService.eliminarClientePermanentemente(
        clienteId,
      );
      if (resultado) {
        _mostrarExito('Cliente "$nombre" eliminado permanentemente');
        _cargarDatos();
      } else {
        _mostrarError('Error al eliminar el cliente');
      }
    }
  }

  Future<void> _vaciarPapelera() async {
    if (_clientesEliminados.isEmpty) {
      _mostrarError('La papelera ya está vacía');
      return;
    }

    final confirmado = await _mostrarDialogoConfirmacion(
      'Vaciar Papelera',
      '⚠️ ¿Deseas eliminar PERMANENTEMENTE todos los ${_clientesEliminados.length} clientes de la papelera?\n\nEsta acción NO se puede deshacer.',
      'Vaciar Papelera',
      Colors.red,
    );

    if (confirmado) {
      final eliminados = await PapeleraService.vaciarPapelera();
      if (eliminados > 0) {
        _mostrarExito('$eliminados clientes eliminados permanentemente');
        _cargarDatos();
      } else {
        _mostrarError('Error al vaciar la papelera');
      }
    }
  }

  Future<bool> _mostrarDialogoConfirmacion(
    String titulo,
    String mensaje,
    String textoBoton,
    Color colorBoton,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: colorBoton),
                child: Text(
                  textoBoton,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _alternarSeleccionMultiple() {
    setState(() {
      _seleccionMultiple = !_seleccionMultiple;
      _clientesSeleccionados.clear();
    });
  }

  Future<void> _accionMasiva(bool restaurar) async {
    if (_clientesSeleccionados.isEmpty) {
      _mostrarError('No hay clientes seleccionados');
      return;
    }

    final accion = restaurar ? 'restaurar' : 'eliminar permanentemente';
    final confirmado = await _mostrarDialogoConfirmacion(
      restaurar ? 'Restaurar Seleccionados' : 'Eliminar Seleccionados',
      '¿Deseas $accion ${_clientesSeleccionados.length} clientes?',
      restaurar ? 'Restaurar' : 'Eliminar',
      restaurar ? Colors.green : Colors.red,
    );

    if (confirmado) {
      int exitosos = 0;
      for (String clienteId in _clientesSeleccionados) {
        final resultado = restaurar
            ? await PapeleraService.restaurarCliente(clienteId)
            : await PapeleraService.eliminarClientePermanentemente(clienteId);
        if (resultado) exitosos++;
      }

      _mostrarExito('$exitosos clientes procesados correctamente');
      setState(() {
        _seleccionMultiple = false;
        _clientesSeleccionados.clear();
      });
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papelera de Clientes'),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        actions: [
          if (_clientesEliminados.isNotEmpty) ...[
            IconButton(
              icon: Icon(_seleccionMultiple ? Icons.close : Icons.checklist),
              tooltip: _seleccionMultiple
                  ? 'Cancelar selección'
                  : 'Selección múltiple',
              onPressed: _alternarSeleccionMultiple,
            ),
            if (_seleccionMultiple && _clientesSeleccionados.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.green),
                tooltip: 'Restaurar seleccionados',
                onPressed: () => _accionMasiva(true),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Eliminar seleccionados',
                onPressed: () => _accionMasiva(false),
              ),
            ],
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'vaciar') _vaciarPapelera();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'vaciar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Vaciar papelera'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estadísticas
                if (_estadisticas.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estadísticas de la Papelera',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildEstadistica(
                              'Total',
                              _estadisticas['total'] ?? 0,
                            ),
                            _buildEstadistica(
                              'Esta semana',
                              _estadisticas['estaSemana'] ?? 0,
                            ),
                            _buildEstadistica(
                              'Este mes',
                              _estadisticas['esteMes'] ?? 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Lista de clientes eliminados
                Expanded(
                  child: _clientesEliminados.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'La papelera está vacía',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Los clientes eliminados aparecerán aquí',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _clientesEliminados.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientesEliminados[index];
                            final data = cliente.data() as Map<String, dynamic>;
                            final clienteId = cliente.id;
                            final nombre = data['nombre'] ?? 'Sin nombre';
                            final telefono = data['telefono'] ?? '';
                            final fechaEliminacion =
                                (data['fechaEliminacion'] as Timestamp?)
                                    ?.toDate();

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: _seleccionMultiple
                                    ? Checkbox(
                                        value: _clientesSeleccionados.contains(
                                          clienteId,
                                        ),
                                        onChanged: (selected) {
                                          setState(() {
                                            if (selected == true) {
                                              _clientesSeleccionados.add(
                                                clienteId,
                                              );
                                            } else {
                                              _clientesSeleccionados.remove(
                                                clienteId,
                                              );
                                            }
                                          });
                                        },
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Text(
                                          nombre[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                title: Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (telefono.isNotEmpty)
                                      Text('📞 $telefono'),
                                    if (fechaEliminacion != null)
                                      Text(
                                        '🗑️ Eliminado: ${_formatearFecha(fechaEliminacion)}',
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: _seleccionMultiple
                                    ? null
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.restore,
                                              color: Colors.green,
                                            ),
                                            tooltip: 'Restaurar',
                                            onPressed: () => _restaurarCliente(
                                              clienteId,
                                              nombre,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Eliminar permanentemente',
                                            onPressed: () =>
                                                _eliminarPermanentemente(
                                                  clienteId,
                                                  nombre,
                                                ),
                                          ),
                                        ],
                                      ),
                                onTap: _seleccionMultiple
                                    ? () {
                                        setState(() {
                                          if (_clientesSeleccionados.contains(
                                            clienteId,
                                          )) {
                                            _clientesSeleccionados.remove(
                                              clienteId,
                                            );
                                          } else {
                                            _clientesSeleccionados.add(
                                              clienteId,
                                            );
                                          }
                                        });
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEstadistica(String label, int valor) {
    return Column(
      children: [
        Text(
          valor.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
