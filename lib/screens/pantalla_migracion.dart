import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaMigracion extends StatefulWidget {
  const PantallaMigracion({super.key});

  @override
  State<PantallaMigracion> createState() => _PantallaMigracionState();
}

class _PantallaMigracionState extends State<PantallaMigracion> {
  bool _migrando = false;
  String _mensaje = '';
  int _totalClientes = 0;
  int _clientesMigrados = 0;
  int _clientesYaMigrados = 0;

  @override
  void initState() {
    super.initState();
    _verificarEstado();
  }

  Future<void> _verificarEstado() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _mensaje = 'Error: No hay usuario autenticado';
        });
        return;
      }

      // Obtener estadísticas
      final QuerySnapshot todosLosClientes = await FirebaseFirestore.instance
          .collection('clientes')
          .get();

      final QuerySnapshot clientesConUID = await FirebaseFirestore.instance
          .collection('clientes')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        _totalClientes = todosLosClientes.docs.length;
        _clientesYaMigrados = clientesConUID.docs.length;
        _mensaje = 'Usuario: ${currentUser.email}\n'
            'Total de clientes: $_totalClientes\n'
            'Clientes asignados a ti: $_clientesYaMigrados\n'
            'Clientes sin asignar: ${_totalClientes - _clientesYaMigrados}';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error verificando estado: $e';
      });
    }
  }

  Future<void> _ejecutarMigracion() async {
    setState(() {
      _migrando = true;
      _mensaje = 'Iniciando migración...';
      _clientesMigrados = 0;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _mensaje = 'Error: No hay usuario autenticado';
          _migrando = false;
        });
        return;
      }

      // Obtener todos los clientes
      final QuerySnapshot todosLosClientes = await FirebaseFirestore.instance
          .collection('clientes')
          .get();

      setState(() {
        _mensaje = 'Procesando ${todosLosClientes.docs.length} clientes...';
      });

      int migrados = 0;
      int yaMigrados = 0;

      for (DocumentSnapshot cliente in todosLosClientes.docs) {
        final Map<String, dynamic> data = cliente.data() as Map<String, dynamic>;
        
        // Verificar si ya tiene el campo terapeutaUid
        if (data.containsKey('terapeutaUid')) {
          yaMigrados++;
          continue;
        }
        
        // Agregar el campo terapeutaUid
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(cliente.id)
            .update({
              'terapeutaUid': currentUser.uid,
            });
        
        migrados++;
        
        setState(() {
          _clientesMigrados = migrados;
          _mensaje = 'Migrando clientes...\n'
              'Procesados: ${migrados + yaMigrados}/${todosLosClientes.docs.length}\n'
              'Migrados: $migrados\n'
              'Ya migrados: $yaMigrados';
        });
      }

      setState(() {
        _mensaje = '✅ MIGRACIÓN COMPLETADA\n\n'
            'Clientes migrados: $migrados\n'
            'Clientes ya migrados: $yaMigrados\n'
            'Total procesados: ${migrados + yaMigrados}\n\n'
            'Ahora todos tus clientes deberían aparecer correctamente.';
        _migrando = false;
      });

    } catch (e) {
      setState(() {
        _mensaje = 'Error durante la migración: $e';
        _migrando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migración de Clientes'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ MIGRACIÓN DE DATOS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Se necesita ejecutar una migración única para restaurar '
                      'tus clientes existentes. Esta operación asignará todos '
                      'los clientes sin propietario a tu cuenta.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado actual:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _mensaje,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_migrando)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _ejecutarMigracion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ejecutar Migración'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _verificarEstado,
                    child: const Text('Actualizar Estado'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (!_migrando && _clientesMigrados > 0)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Migración exitosa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Volver a la aplicación'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
