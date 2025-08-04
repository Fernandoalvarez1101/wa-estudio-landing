import 'package:flutter/material.dart';
import '../scripts/arreglar_fechas_clientes.dart';

class PantallaArreglarFechas extends StatefulWidget {
  const PantallaArreglarFechas({super.key});

  @override
  State<PantallaArreglarFechas> createState() => _PantallaArreglarFechasState();
}

class _PantallaArreglarFechasState extends State<PantallaArreglarFechas> {
  bool _ejecutando = false;
  String _mensaje = 'Presiona el botón para arreglar los campos de fecha en tus clientes.\\n\\nEste proceso convertirá todos los campos "fechaNacimiento" a "fechaCumpleanos" para evitar errores.';

  Future<void> _ejecutarScript() async {
    setState(() {
      _ejecutando = true;
      _mensaje = 'Ejecutando script...\\nPor favor espera...';
    });

    try {
      await arreglarFechasClientes();
      setState(() {
        _mensaje = '✅ ¡Script ejecutado exitosamente!\\n\\nTodos los campos de fecha han sido actualizados.\\n\\nYa puedes regresar y usar la aplicación normalmente.';
      });
    } catch (e) {
      setState(() {
        _mensaje = '❌ Error ejecutando el script:\\n$e';
      });
    }

    setState(() {
      _ejecutando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arreglar Fechas de Clientes'),
        backgroundColor: const Color(0xFF008080),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle,
                          color: Colors.orange.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Script de Reparación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Este script arreglará los problemas con los campos de fecha en tus clientes:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Convierte "fechaNacimiento" → "fechaCumpleanos"\\n'
                      '• Elimina campos duplicados\\n'
                      '• Asegura compatibilidad total',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                _mensaje,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _ejecutando ? null : _ejecutarScript,
              icon: _ejecutando 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_ejecutando ? 'Ejecutando...' : 'Ejecutar Script'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (!_ejecutando)
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF008080)),
                  foregroundColor: const Color(0xFF008080),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
