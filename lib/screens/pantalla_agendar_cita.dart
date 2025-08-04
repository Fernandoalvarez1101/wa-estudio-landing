import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'pantalla_ver_citas.dart';

class PantallaAgendarCita extends StatefulWidget {
  final String? nombrePrellenado;
  final String? correoPrellenado;
  final String? telefonoPrellenado;

  const PantallaAgendarCita({
    super.key,
    this.nombrePrellenado,
    this.correoPrellenado,
    this.telefonoPrellenado,
  });

  @override
  State<PantallaAgendarCita> createState() => _PantallaAgendarCitaState();
}

class _PantallaAgendarCitaState extends State<PantallaAgendarCita> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  int duracionSeleccionada = 60; // Duración por defecto en minutos

  String? servicioSeleccionado;
  String? terapeutaSeleccionado;
  String? sucursalSeleccionada; // Nueva variable para sucursal

  // Variables para mostrar estado de validación
  bool _validandoCorreo = false;
  bool _validandoTelefono = false;
  String? _mensajeCorreo;
  String? _mensajeTelefono;

  // Opciones predefinidas de duración (en minutos)
  final List<int> opcionesDuracion = [15, 30, 45, 60, 90, 120, 150, 180, 240];
  
  // Nueva variable para permitir múltiples citas en el mismo horario
  bool permitirMultiplesCitas = false;

  @override
  void initState() {
    super.initState();
    // Prellenar campos si se proporcionan datos
    if (widget.nombrePrellenado != null) {
      nombreController.text = widget.nombrePrellenado!;
    }
    if (widget.correoPrellenado != null) {
      correoController.text = widget.correoPrellenado!;
    }
    if (widget.telefonoPrellenado != null) {
      telefonoController.text = widget.telefonoPrellenado!;
    }
  }

  // Función para verificar si un cliente está bloqueado por correo
  Future<bool> _verificarClienteBloqueadoPorCorreo(String correo) async {
    if (correo.trim().isEmpty) return false;
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .where('correo', isEqualTo: correo.trim())
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final cliente = querySnapshot.docs.first;
        final bool estaBloquado = cliente.data().containsKey('bloqueado') ? 
            cliente['bloqueado'] : false;
        return estaBloquado;
      }
      return false;
    } catch (e) {
      debugPrint('Error verificando cliente por correo: $e');
      return false;
    }
  }

  // Función para verificar si un cliente está bloqueado por teléfono
  Future<bool> _verificarClienteBloqueadoPorTelefono(String telefono) async {
    if (telefono.trim().isEmpty) return false;
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .where('telefono', isEqualTo: telefono.trim())
          .where('terapeutaUid', isEqualTo: currentUser.uid)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final cliente = querySnapshot.docs.first;
        final bool estaBloquado = cliente.data().containsKey('bloqueado') ? 
            cliente['bloqueado'] : false;
        return estaBloquado;
      }
      return false;
    } catch (e) {
      debugPrint('Error verificando cliente por teléfono: $e');
      return false;
    }
  }

  // Función para mostrar advertencia de cliente bloqueado
  void _mostrarAdvertenciaClienteBloqueado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Cliente Bloqueado'),
            ],
          ),
          content: const Text(
            'Este cliente está bloqueado y no puede agendar citas. '
            'Debe desbloquearlo primero desde la lista de clientes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar advertencia de conflicto de horario
  void _mostrarAdvertenciaConflictoHorario() {
    // Calcular hora de finalización
    final totalMinutosInicio = (horaSeleccionada!.hour * 60) + horaSeleccionada!.minute;
    final totalMinutosFin = totalMinutosInicio + duracionSeleccionada;
    final horaFin = totalMinutosFin ~/ 60;
    final minutoFin = totalMinutosFin % 60;
    final horaFinString = '${horaFin.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.schedule_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Conflicto de Horario'),
            ],
          ),
          content: Text(
            'Ya existe una cita que se solapa con el horario seleccionado para el terapeuta "$terapeutaSeleccionado" '
            'el día ${fechaSeleccionada != null ? "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}" : ""} '
            'de ${horaSeleccionada?.format(context) ?? ""} a $horaFinString '
            '(${_formatearDuracion(duracionSeleccionada)}).\n\n'
            'Por favor, selecciona un horario diferente o ajusta la duración.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Validar correo en tiempo real
  void _validarCorreoEnTiempoReal(String correo) async {
    if (correo.trim().isEmpty) {
      setState(() {
        _mensajeCorreo = null;
        _validandoCorreo = false;
      });
      return;
    }

    setState(() {
      _validandoCorreo = true;
      _mensajeCorreo = null;
    });

    final bool estaBloquado = await _verificarClienteBloqueadoPorCorreo(correo);
    
    setState(() {
      _validandoCorreo = false;
      if (estaBloquado) {
        _mensajeCorreo = 'Cliente bloqueado';
      } else {
        _mensajeCorreo = null;
      }
    });
  }

  // Validar teléfono en tiempo real
  void _validarTelefonoEnTiempoReal(String telefono) async {
    if (telefono.trim().isEmpty) {
      setState(() {
        _mensajeTelefono = null;
        _validandoTelefono = false;
      });
      return;
    }

    setState(() {
      _validandoTelefono = true;
      _mensajeTelefono = null;
    });

    final bool estaBloquedo = await _verificarClienteBloqueadoPorTelefono(telefono);
    
    setState(() {
      _validandoTelefono = false;
      if (estaBloquedo) {
        _mensajeTelefono = 'Cliente bloqueado';
      } else {
        _mensajeTelefono = null;
      }
    });
  }

  void _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  void _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  // Función para formatear la duración de manera legible
  String _formatearDuracion(int minutos) {
    if (minutos < 60) {
      return '$minutos min';
    } else {
      final horas = minutos ~/ 60;
      final minutosRestantes = minutos % 60;
      if (minutosRestantes == 0) {
        return '${horas}h';
      } else {
        return '${horas}h ${minutosRestantes}min';
      }
    }
  }

  // Función para seleccionar duración
  void _seleccionarDuracion() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar duración'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: opcionesDuracion.length,
              itemBuilder: (context, index) {
                final duracion = opcionesDuracion[index];
                return ListTile(
                  title: Text('${duracion} minutos'),
                  subtitle: Text(_formatearDuracion(duracion)),
                  leading: Radio<int>(
                    value: duracion,
                    groupValue: duracionSeleccionada,
                    onChanged: (value) {
                      setState(() {
                        duracionSeleccionada = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      duracionSeleccionada = duracion;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Función para verificar conflictos de horarios considerando la duración
  Future<bool> _verificarConflictoHorario() async {
    // Si está activado el interruptor de múltiples citas, no verificar conflictos
    if (permitirMultiplesCitas) {
      return false;
    }
    
    if (fechaSeleccionada == null || horaSeleccionada == null || terapeutaSeleccionado == null) {
      return false;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      // Convertir la fecha y hora seleccionada a formato string
      String fechaString = fechaSeleccionada!.toIso8601String().split('T')[0]; // Solo la fecha (YYYY-MM-DD)

      // Calcular rangos de tiempo para la nueva cita
      final totalMinutosInicio = (horaSeleccionada!.hour * 60) + horaSeleccionada!.minute;
      final totalMinutosFin = totalMinutosInicio + duracionSeleccionada;

      // Buscar citas en la misma fecha y terapeuta
      final querySnapshot = await FirebaseFirestore.instance
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('terapeuta', isEqualTo: terapeutaSeleccionado)
          .get();

      // Verificar solapamiento con citas existentes
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final String? citaFecha = data['fecha'] as String?;
        final String? citaHora = data['hora'] as String?;
        final int citaDuracion = data['duracionMinutos'] ?? 60; // Duración por defecto si no existe

        if (citaFecha != null && citaHora != null) {
          String citaFechaString = citaFecha.split('T')[0]; // Solo la fecha
          
          // Solo verificar si es la misma fecha
          if (citaFechaString == fechaString) {
            // Calcular rangos de tiempo
            final partesHoraCita = citaHora.split(':');
            final horaInicioCita = int.parse(partesHoraCita[0]);
            final minutoInicioCita = int.parse(partesHoraCita[1]);
            final totalMinutosInicioCita = (horaInicioCita * 60) + minutoInicioCita;
            final totalMinutosFinCita = totalMinutosInicioCita + citaDuracion;

            // Verificar solapamiento
            // Hay conflicto si:
            // 1. La nueva cita empieza antes de que termine la existente Y después de que empiece
            // 2. La nueva cita termina después de que empiece la existente Y antes de que termine
            // 3. La nueva cita envuelve completamente a la existente
            if ((totalMinutosInicio < totalMinutosFinCita && totalMinutosInicio >= totalMinutosInicioCita) ||
                (totalMinutosFin > totalMinutosInicioCita && totalMinutosFin <= totalMinutosFinCita) ||
                (totalMinutosInicio <= totalMinutosInicioCita && totalMinutosFin >= totalMinutosFinCita)) {
              return true; // Conflicto encontrado
            }
          }
        }
      }

      return false; // No hay conflictos
    } catch (e) {
      debugPrint('Error verificando conflicto de horario: $e');
      return false;
    }
  }

  Future<void> _guardarCitaEnFirebase() async {
    // Obtener el ID del usuario autenticado (terapeuta que crea la cita)
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    await FirebaseFirestore.instance.collection('citas').add({
      'nombre': nombreController.text,
      'correo': correoController.text,
      'telefono': telefonoController.text,
      'fecha': fechaSeleccionada?.toIso8601String() ?? '',
      'hora': horaSeleccionada?.format(context) ?? '',
      'duracionMinutos': duracionSeleccionada, // Nueva propiedad de duración
      'servicio': servicioSeleccionado ?? '',
      'terapeuta': terapeutaSeleccionado ?? '',
      'sucursal': sucursalSeleccionada ?? '', // Nueva propiedad de sucursal
      'permitiMultiplesCitas': permitirMultiplesCitas, // Indicador si se permitieron múltiples citas
      'terapeutaId': currentUser?.uid ?? '', // ID del terapeuta que creó la cita
      'timestamp': FieldValue.serverTimestamp(),
      'atendido': false, // Estado inicial
    });
  }

  void _confirmarCita() async {
    if (_formKey.currentState!.validate() &&
        fechaSeleccionada != null &&
        horaSeleccionada != null &&
        terapeutaSeleccionado != null &&
        servicioSeleccionado != null &&
        sucursalSeleccionada != null) {
      
      // Verificar si el cliente está bloqueado por correo o teléfono
      final bool bloqueadoPorCorreo = await _verificarClienteBloqueadoPorCorreo(correoController.text);
      final bool bloqueadoPorTelefono = await _verificarClienteBloqueadoPorTelefono(telefonoController.text);
      
      if (bloqueadoPorCorreo || bloqueadoPorTelefono) {
        _mostrarAdvertenciaClienteBloqueado();
        return; // No continuar con el guardado
      }

      // Verificar conflictos de horario
      final bool hayConflicto = await _verificarConflictoHorario();
      if (hayConflicto) {
        _mostrarAdvertenciaConflictoHorario();
        return; // No continuar con el guardado
      }
      
      try {
        await _guardarCitaEnFirebase();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
        await Future.delayed(const Duration(seconds: 1)); // Espera 1 segundo
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaVerCitas()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar la cita: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar nueva cita')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del cliente',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  suffixIcon: _validandoCorreo 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : _mensajeCorreo != null
                          ? const Icon(Icons.warning, color: Colors.red)
                          : null,
                  helperText: _mensajeCorreo,
                  helperStyle: TextStyle(
                    color: _mensajeCorreo != null ? Colors.red : null,
                  ),
                ),
                onChanged: _validarCorreoEnTiempoReal,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  suffixIcon: _validandoTelefono 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : _mensajeTelefono != null
                          ? const Icon(Icons.warning, color: Colors.red)
                          : null,
                  helperText: _mensajeTelefono,
                  helperStyle: TextStyle(
                    color: _mensajeTelefono != null ? Colors.red : null,
                  ),
                ),
                onChanged: _validarTelefonoEnTiempoReal,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  fechaSeleccionada != null
                      ? 'Fecha: ${fechaSeleccionada!.toLocal()}'.split(' ')[0]
                      : 'Selecciona la fecha',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              ListTile(
                title: Text(
                  horaSeleccionada != null
                      ? 'Hora: ${horaSeleccionada!.format(context)}'
                      : 'Selecciona la hora',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _seleccionarHora,
              ),
              // Selector de duración
              ListTile(
                title: Text('Duración: ${duracionSeleccionada} minutos'),
                subtitle: Text(_formatearDuracion(duracionSeleccionada)),
                trailing: const Icon(Icons.timer),
                onTap: _seleccionarDuracion,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('servicios')
                    .where('estudioUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('activo', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error al cargar servicios');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }

                  final servicios = snapshot.data!.docs;
                  
                  if (servicios.isEmpty) {
                    return Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text(
                              'No hay servicios disponibles',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ve al botón "Servicios" en el menú principal para agregar servicios disponibles',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Volver al menú
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Volver al menú'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Si el servicio seleccionado ya no existe en la lista, limpiarlo
                  if (servicioSeleccionado != null) {
                    bool existeEnLista = servicios.any((doc) => 
                        doc['nombre'] == servicioSeleccionado);
                    if (!existeEnLista) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          servicioSeleccionado = null;
                        });
                      });
                    }
                  }

                  return DropdownButtonFormField<String>(
                    value: servicioSeleccionado,
                    items: servicios.map((DocumentSnapshot doc) {
                      final nombre = doc['nombre'] as String;
                      final precio = doc['precio'] as String? ?? '';
                      final displayText = precio.isNotEmpty ? '$nombre - $precio' : nombre;
                      
                      return DropdownMenuItem<String>(
                        value: nombre,
                        child: Text(displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        servicioSeleccionado = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un servicio' : null,
                    decoration: const InputDecoration(
                      labelText: 'Servicio',
                      prefixIcon: Icon(Icons.spa),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('terapeutas')
                    .where('estudioUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('activo', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error al cargar empleados');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }

                  final terapeutas = snapshot.data!.docs;
                  
                  if (terapeutas.isEmpty) {
                    return Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text(
                              'No hay empleados en el equipo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ve a "Gestionar Equipo" para agregar miembros al equipo',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Volver al menú
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Volver al menú'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Si el empleado seleccionado ya no existe en la lista, limpiarlo
                  if (terapeutaSeleccionado != null) {
                    bool existeEnLista = terapeutas.any((doc) => 
                        doc['nombre'] == terapeutaSeleccionado);
                    if (!existeEnLista) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          terapeutaSeleccionado = null;
                        });
                      });
                    }
                  }

                  return DropdownButtonFormField<String>(
                    value: terapeutaSeleccionado,
                    items: terapeutas.map((DocumentSnapshot doc) {
                      final nombre = doc['nombre'] as String;
                      return DropdownMenuItem<String>(
                        value: nombre,
                        child: Text(nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        terapeutaSeleccionado = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un empleado' : null,
                    decoration: const InputDecoration(
                      labelText: 'Empleado',
                      prefixIcon: Icon(Icons.person),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Selector de Sucursal
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('locales')
                    .where('terapeutaUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error al cargar sucursales: ${snapshot.error}'),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }

                  final sucursales = snapshot.data!.docs;
                  
                  if (sucursales.isEmpty) {
                    return Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.location_off, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text(
                              'No hay sucursales disponibles',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ve a "Configuración del Negocio" → "Gestionar Locales" para agregar sucursales',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Volver al menú
                              },
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Volver al menú'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Si la sucursal seleccionada ya no existe en la lista, limpiarla
                  if (sucursalSeleccionada != null) {
                    bool existeEnLista = sucursales.any((doc) => 
                        doc['nombre'] == sucursalSeleccionada);
                    if (!existeEnLista) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          sucursalSeleccionada = null;
                        });
                      });
                    }
                  }

                  return DropdownButtonFormField<String>(
                    value: sucursalSeleccionada,
                    isExpanded: true, // Agregar esta línea para evitar overflow
                    items: sucursales.map((DocumentSnapshot doc) {
                      final nombre = doc['nombre'] as String;
                      final direccion = doc['direccion'] as String? ?? '';
                      return DropdownMenuItem<String>(
                        value: nombre,
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nombre, 
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (direccion.isNotEmpty)
                                Text(
                                  direccion,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sucursalSeleccionada = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona una sucursal' : null,
                    decoration: const InputDecoration(
                      labelText: 'Sucursal',
                      prefixIcon: Icon(Icons.business),
                      helperText: 'Selecciona dónde se realizará el servicio',
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Interruptor para permitir múltiples citas
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Configuración de Horarios',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Permitir múltiples citas en el mismo horario'),
                        subtitle: Text(
                          permitirMultiplesCitas
                              ? 'Activado: Se pueden agendar varias citas a la misma hora'
                              : 'Desactivado: Solo una cita por horario',
                          style: TextStyle(
                            color: permitirMultiplesCitas ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        value: permitirMultiplesCitas,
                        onChanged: (bool value) {
                          setState(() {
                            permitirMultiplesCitas = value;
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                        secondary: Icon(
                          permitirMultiplesCitas ? Icons.group : Icons.person,
                          color: permitirMultiplesCitas 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey,
                        ),
                      ),
                      if (permitirMultiplesCitas)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Con esta opción activada, podrás agendar múltiples clientes en el mismo horario. Útil para servicios grupales.',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmarCita,
                child: const Text('Confirmar cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
