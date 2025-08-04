import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaGestionarServicios extends StatefulWidget {
  const PantallaGestionarServicios({super.key});

  @override
  State<PantallaGestionarServicios> createState() => _PantallaGestionarServiciosState();
}

class _PantallaGestionarServiciosState extends State<PantallaGestionarServicios> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _agregarServicio() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('servicios').add({
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'precio': _precioController.text.trim(),
          'estudioUid': currentUser.uid, // Asociar al estudio del usuario actual
          'fechaCreacion': FieldValue.serverTimestamp(),
          'activo': true,
        });

        _nombreController.clear();
        _descripcionController.clear();
        _precioController.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio agregado exitosamente')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: $e')),
        );
      }
    }
  }

  Future<void> _eliminarServicio(String id, String nombre) async {
    // Mostrar confirmación
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de eliminar el servicio "$nombre"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance.collection('servicios').doc(id).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Servicio "$nombre" eliminado')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  Future<void> _editarServicio(String id, Map<String, dynamic> servicioData) async {
    final TextEditingController editNombreController = TextEditingController(text: servicioData['nombre']);
    final TextEditingController editDescripcionController = TextEditingController(text: servicioData['descripcion'] ?? '');
    final TextEditingController editPrecioController = TextEditingController(text: servicioData['precio'] ?? '');
    final formKey = GlobalKey<FormState>();
    
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Servicio'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editNombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del servicio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.spa),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre del servicio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: editDescripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: editPrecioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: 'Ej: \$500, \$800, etc.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance.collection('servicios').doc(id).update({
          'nombre': editNombreController.text.trim(),
          'descripcion': editDescripcionController.text.trim(),
          'precio': editPrecioController.text.trim(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio actualizado exitosamente')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
    
    editNombreController.dispose();
    editDescripcionController.dispose();
    editPrecioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulario para agregar servicio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agregar Nuevo Servicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del servicio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.spa),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre del servicio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: 'Ej: \$500, \$800, etc.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _agregarServicio,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Servicio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lista de servicios
            const Text(
              'Servicios Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('servicios')
                    .where('estudioUid', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final servicios = snapshot.data!.docs
                      .where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['activo'] == true;
                      })
                      .toList();

                  // Ordenar por fecha de creación (más recientes primero)
                  servicios.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aFecha = aData['fechaCreacion'] as Timestamp?;
                    final bFecha = bData['fechaCreacion'] as Timestamp?;
                    if (aFecha == null && bFecha == null) return 0;
                    if (aFecha == null) return 1;
                    if (bFecha == null) return -1;
                    return aFecha.compareTo(bFecha);
                  });

                  if (servicios.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay servicios disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Agrega el primer servicio usando el formulario arriba',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: servicios.length,
                    itemBuilder: (context, index) {
                      final servicio = servicios[index];
                      final nombre = servicio['nombre'];
                      final descripcion = servicio['descripcion'] ?? '';
                      final precio = servicio['precio'] ?? '';
                      
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.spa,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            nombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (descripcion.isNotEmpty)
                                Text(descripcion),
                              if (precio.isNotEmpty)
                                Text(
                                  'Precio: $precio',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarServicio(servicio.id, servicio.data() as Map<String, dynamic>),
                                tooltip: 'Editar servicio',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarServicio(servicio.id, nombre),
                                tooltip: 'Eliminar servicio',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }
}
