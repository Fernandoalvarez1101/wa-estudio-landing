import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaGestionarLocales extends StatefulWidget {
  const PantallaGestionarLocales({super.key});

  @override
  State<PantallaGestionarLocales> createState() => _PantallaGestionarLocalesState();
}

class _PantallaGestionarLocalesState extends State<PantallaGestionarLocales> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _locales = [];

  @override
  void initState() {
    super.initState();
    _cargarLocales();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarLocales() async {
    try {
      setState(() => _isLoading = true);
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final snapshot = await _firestore
          .collection('locales')
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();

      // Ordenar en el cliente para evitar necesidad de índice compuesto
      final locales = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      // Ordenar por fecha de creación (más recientes primero)
      locales.sort((a, b) {
        final fechaA = a['fechaCreacion'] as Timestamp?;
        final fechaB = b['fechaCreacion'] as Timestamp?;
        
        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;
        
        return fechaB.compareTo(fechaA); // Orden descendente
      });

      setState(() {
        _locales = locales;
      });
    } catch (e) {
      _mostrarError('Error al cargar los locales: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _agregarLocal() async {
    if (_nombreController.text.trim().isEmpty || _direccionController.text.trim().isEmpty) {
      _mostrarError('Por favor completa al menos el nombre y la dirección');
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('locales').add({
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'horario': _horarioController.text.trim(),
        'terapeutaUid': currentUser.uid,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      _limpiarCampos();
      await _cargarLocales();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local agregado exitosamente')),
        );
      }
    } catch (e) {
      _mostrarError('Error al agregar el local: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarLocal(String localId) async {
    try {
      await _firestore.collection('locales').doc(localId).delete();
      await _cargarLocales();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local eliminado exitosamente')),
        );
      }
    } catch (e) {
      _mostrarError('Error al eliminar el local: $e');
    }
  }

  void _mostrarDialogoEliminar(String localId, String nombreLocal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el local "$nombreLocal"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarLocal(localId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditar(Map<String, dynamic> local) {
    // Crear controladores temporales para la edición
    final nombreEditController = TextEditingController(text: local['nombre'] ?? '');
    final direccionEditController = TextEditingController(text: local['direccion'] ?? '');
    final telefonoEditController = TextEditingController(text: local['telefono'] ?? '');
    final horarioEditController = TextEditingController(text: local['horario'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Editar Local'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreEditController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del local *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: direccionEditController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefonoEditController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: horarioEditController,
                    decoration: const InputDecoration(
                      labelText: 'Horario de atención',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      hintText: 'Ej: Lun-Vie 9:00-18:00',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nombreEditController.dispose();
                direccionEditController.dispose();
                telefonoEditController.dispose();
                horarioEditController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _editarLocal(
                  local['id'],
                  nombreEditController.text.trim(),
                  direccionEditController.text.trim(),
                  telefonoEditController.text.trim(),
                  horarioEditController.text.trim(),
                );
                nombreEditController.dispose();
                direccionEditController.dispose();
                telefonoEditController.dispose();
                horarioEditController.dispose();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarLocal(
    String localId,
    String nombre,
    String direccion,
    String telefono,
    String horario,
  ) async {
    if (nombre.isEmpty || direccion.isEmpty) {
      _mostrarError('Por favor completa al menos el nombre y la dirección');
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      await _firestore.collection('locales').doc(localId).update({
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono,
        'horario': horario,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      await _cargarLocales();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _mostrarError('Error al actualizar el local: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    _horarioController.clear();
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Locales'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Formulario para agregar nuevo local
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_business,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Agregar Nuevo Local',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Local *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _horarioController,
                      decoration: const InputDecoration(
                        labelText: 'Horario de Atención (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                        hintText: 'Ej: Lun-Vie 9:00-18:00',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _agregarLocal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Agregar Local'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lista de locales existentes
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Locales Registrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_locales.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay locales registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega tu primer local usando el formulario de arriba',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _locales.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final local = _locales[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.business,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              local['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (local['direccion'] != null && local['direccion'].isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(local['direccion']),
                                      ),
                                    ],
                                  ),
                                if (local['telefono'] != null && local['telefono'].isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(local['telefono']),
                                    ],
                                  ),
                                ],
                                if (local['horario'] != null && local['horario'].isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(local['horario']),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _mostrarDialogoEditar(local),
                                  tooltip: 'Editar local',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _mostrarDialogoEliminar(
                                    local['id'],
                                    local['nombre'] ?? 'Local sin nombre',
                                  ),
                                  tooltip: 'Eliminar local',
                                ),
                              ],
                            ),
                          );
                        },
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
