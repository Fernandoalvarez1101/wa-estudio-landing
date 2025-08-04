import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_ver_citas.dart';

class PantallaEditarCita extends StatefulWidget {
  final String id;
  final Map<String, dynamic> datos;

  const PantallaEditarCita({
    super.key,
    required this.id,
    required this.datos,
  });

  @override
  State<PantallaEditarCita> createState() => _PantallaEditarCitaState();
}

class _PantallaEditarCitaState extends State<PantallaEditarCita> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController nombreController;
  late TextEditingController correoController;
  late TextEditingController telefonoController;
  late DateTime fechaSeleccionada;
  late TimeOfDay horaSeleccionada;
  late int duracionSeleccionada; // Nueva propiedad para duración
  String tipoMasaje = 'Relajante';
  String? terapeutaSeleccionado;

  List<String> listaTerapeutas = ['Raúl', 'Fernando', 'Otro'];
  List<String> tiposMasajeValidos = ['Relajante', 'Descontracturante', 'Deportivo'];
  
  // Opciones predefinidas de duración (en minutos)
  final List<int> opcionesDuracion = [15, 30, 45, 60, 90, 120, 150, 180, 240];

  // Variables para código de país
  String _codigoPaisSeleccionado = '+57'; // Colombia por defecto
  
  // Lista extendida de códigos de país
  final List<Map<String, String>> _codigosPais = [
    // América del Norte
    {'codigo': '+1', 'pais': 'Estados Unidos', 'bandera': '🇺🇸'},
    {'codigo': '+1', 'pais': 'Canadá', 'bandera': '🇨🇦'},
    
    // América Central
    {'codigo': '+52', 'pais': 'México', 'bandera': '🇲🇽'},
    {'codigo': '+502', 'pais': 'Guatemala', 'bandera': '🇬🇹'},
    {'codigo': '+503', 'pais': 'El Salvador', 'bandera': '🇸🇻'},
    {'codigo': '+504', 'pais': 'Honduras', 'bandera': '🇭🇳'},
    {'codigo': '+505', 'pais': 'Nicaragua', 'bandera': '🇳🇮'},
    {'codigo': '+506', 'pais': 'Costa Rica', 'bandera': '🇨🇷'},
    {'codigo': '+507', 'pais': 'Panamá', 'bandera': '🇵🇦'},
    
    // América del Sur
    {'codigo': '+57', 'pais': 'Colombia', 'bandera': '🇨🇴'},
    {'codigo': '+58', 'pais': 'Venezuela', 'bandera': '🇻🇪'},
    {'codigo': '+595', 'pais': 'Paraguay', 'bandera': '🇵🇾'},
    {'codigo': '+598', 'pais': 'Uruguay', 'bandera': '🇺🇾'},
    {'codigo': '+54', 'pais': 'Argentina', 'bandera': '🇦🇷'},
    {'codigo': '+55', 'pais': 'Brasil', 'bandera': '🇧🇷'},
    {'codigo': '+56', 'pais': 'Chile', 'bandera': '🇨🇱'},
    {'codigo': '+51', 'pais': 'Perú', 'bandera': '🇵🇪'},
    {'codigo': '+593', 'pais': 'Ecuador', 'bandera': '🇪🇨'},
    {'codigo': '+591', 'pais': 'Bolivia', 'bandera': '🇧🇴'},
    {'codigo': '+594', 'pais': 'Guyana Francesa', 'bandera': '🇬🇫'},
    {'codigo': '+597', 'pais': 'Surinam', 'bandera': '🇸🇷'},
    {'codigo': '+592', 'pais': 'Guyana', 'bandera': '🇬🇾'},
    
    // Europa
    {'codigo': '+34', 'pais': 'España', 'bandera': '🇪🇸'},
    {'codigo': '+33', 'pais': 'Francia', 'bandera': '🇫🇷'},
    {'codigo': '+49', 'pais': 'Alemania', 'bandera': '🇩🇪'},
    {'codigo': '+44', 'pais': 'Reino Unido', 'bandera': '🇬🇧'},
    {'codigo': '+39', 'pais': 'Italia', 'bandera': '🇮🇹'},
    {'codigo': '+351', 'pais': 'Portugal', 'bandera': '🇵🇹'},
    {'codigo': '+31', 'pais': 'Países Bajos', 'bandera': '🇳🇱'},
    {'codigo': '+32', 'pais': 'Bélgica', 'bandera': '🇧🇪'},
    {'codigo': '+41', 'pais': 'Suiza', 'bandera': '🇨🇭'},
    {'codigo': '+43', 'pais': 'Austria', 'bandera': '🇦🇹'},
    {'codigo': '+45', 'pais': 'Dinamarca', 'bandera': '🇩🇰'},
    {'codigo': '+46', 'pais': 'Suecia', 'bandera': '🇸🇪'},
    {'codigo': '+47', 'pais': 'Noruega', 'bandera': '🇳🇴'},
    {'codigo': '+358', 'pais': 'Finlandia', 'bandera': '🇫🇮'},
    {'codigo': '+48', 'pais': 'Polonia', 'bandera': '🇵🇱'},
    {'codigo': '+420', 'pais': 'República Checa', 'bandera': '🇨🇿'},
    {'codigo': '+421', 'pais': 'Eslovaquia', 'bandera': '🇸🇰'},
    {'codigo': '+36', 'pais': 'Hungría', 'bandera': '🇭🇺'},
    {'codigo': '+40', 'pais': 'Rumania', 'bandera': '🇷🇴'},
    {'codigo': '+359', 'pais': 'Bulgaria', 'bandera': '🇧🇬'},
    {'codigo': '+30', 'pais': 'Grecia', 'bandera': '🇬🇷'},
    {'codigo': '+7', 'pais': 'Rusia', 'bandera': '🇷🇺'},
    
    // Asia
    {'codigo': '+86', 'pais': 'China', 'bandera': '🇨🇳'},
    {'codigo': '+81', 'pais': 'Japón', 'bandera': '🇯🇵'},
    {'codigo': '+82', 'pais': 'Corea del Sur', 'bandera': '🇰🇷'},
    {'codigo': '+91', 'pais': 'India', 'bandera': '🇮🇳'},
    {'codigo': '+62', 'pais': 'Indonesia', 'bandera': '🇮🇩'},
    {'codigo': '+66', 'pais': 'Tailandia', 'bandera': '🇹🇭'},
    {'codigo': '+60', 'pais': 'Malasia', 'bandera': '🇲🇾'},
    {'codigo': '+65', 'pais': 'Singapur', 'bandera': '🇸🇬'},
    {'codigo': '+63', 'pais': 'Filipinas', 'bandera': '🇵🇭'},
    {'codigo': '+84', 'pais': 'Vietnam', 'bandera': '🇻🇳'},
    {'codigo': '+886', 'pais': 'Taiwán', 'bandera': '🇹🇼'},
    {'codigo': '+852', 'pais': 'Hong Kong', 'bandera': '🇭🇰'},
    
    // Oceanía
    {'codigo': '+61', 'pais': 'Australia', 'bandera': '🇦🇺'},
    {'codigo': '+64', 'pais': 'Nueva Zelanda', 'bandera': '🇳🇿'},
    
    // África
    {'codigo': '+27', 'pais': 'Sudáfrica', 'bandera': '🇿🇦'},
    {'codigo': '+20', 'pais': 'Egipto', 'bandera': '🇪🇬'},
    {'codigo': '+234', 'pais': 'Nigeria', 'bandera': '🇳🇬'},
    {'codigo': '+254', 'pais': 'Kenia', 'bandera': '🇰🇪'},
    
    // Medio Oriente
    {'codigo': '+971', 'pais': 'Emiratos Árabes Unidos', 'bandera': '🇦🇪'},
    {'codigo': '+966', 'pais': 'Arabia Saudí', 'bandera': '🇸🇦'},
    {'codigo': '+972', 'pais': 'Israel', 'bandera': '🇮🇱'},
    {'codigo': '+90', 'pais': 'Turquía', 'bandera': '🇹🇷'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Verificar que el usuario autenticado sea el dueño de la cita
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.uid != widget.datos['terapeutaId']) {
      // Si no es el dueño, volver a la pantalla anterior
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes permisos para editar esta cita')),
        );
      });
      return;
    }
    
    nombreController = TextEditingController(text: widget.datos['nombre']);
    correoController = TextEditingController(text: widget.datos['correo']);
    
    // Separar código de país del número telefónico existente
    final telefonoCompleto = widget.datos['telefono'] ?? '';
    if (telefonoCompleto.startsWith('+')) {
      // Buscar el código en nuestra lista
      for (var pais in _codigosPais) {
        if (telefonoCompleto.startsWith(pais['codigo']!)) {
          _codigoPaisSeleccionado = pais['codigo']!;
          telefonoController = TextEditingController(
            text: telefonoCompleto.replaceFirst(pais['codigo']!, '')
          );
          break;
        }
      }
      // Si no se encuentra el código, usar el número completo
      if (telefonoController.text.isEmpty) {
        telefonoController = TextEditingController(text: telefonoCompleto);
      }
    } else {
      // Si no tiene código de país, usar el número tal como está
      telefonoController = TextEditingController(text: telefonoCompleto);
    }
    
    // Validar y asignar el tipo de masaje
    String tipoMasajeFromData = widget.datos['servicio'] ?? widget.datos['tipoMasaje'] ?? 'Relajante';
    
    debugPrint('🔍 Datos de la cita: ${widget.datos}');
    debugPrint('🎯 Tipo de masaje detectado: $tipoMasajeFromData');
    debugPrint('📋 Lista válida inicial: $tiposMasajeValidos');
    
    // Verificar si el valor existe en la lista válida
    if (tiposMasajeValidos.contains(tipoMasajeFromData)) {
      tipoMasaje = tipoMasajeFromData;
    } else {
      // Si el valor no es válido, agregarlo a la lista para evitar errores del dropdown
      // y mantener el valor original
      tiposMasajeValidos.add(tipoMasajeFromData);
      tipoMasaje = tipoMasajeFromData;
      debugPrint('➕ Agregado nuevo tipo de masaje: $tipoMasajeFromData');
    }
    
    terapeutaSeleccionado = widget.datos['terapeuta'];
    
    // Verificar si el terapeuta existe en la lista, si no, agregarlo
    if (terapeutaSeleccionado != null && !listaTerapeutas.contains(terapeutaSeleccionado!)) {
      listaTerapeutas.add(terapeutaSeleccionado!);
    }

    fechaSeleccionada = DateTime.tryParse(widget.datos['fecha'] ?? '') ?? DateTime.now();
    final horaString = widget.datos['hora'] ?? '12:00';
    final partesHora = horaString.split(':');
    horaSeleccionada = TimeOfDay(
      hour: int.tryParse(partesHora[0]) ?? 12,
      minute: int.tryParse(partesHora[1]) ?? 0,
    );
    
    // Cargar duración, por defecto 60 minutos si no existe
    duracionSeleccionada = widget.datos['duracionMinutos'] ?? 60;
  }

  void _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
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
      initialTime: horaSeleccionada,
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

  // Función para verificar conflictos de horarios al editar considerando duración
  Future<bool> _verificarConflictoHorarioEdicion() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      // Convertir la fecha y hora seleccionada a formato string antes de la operación async
      String fechaString = fechaSeleccionada.toIso8601String().split('T')[0]; // Solo la fecha (YYYY-MM-DD)
      
      // Calcular rangos de tiempo para la cita editada
      final totalMinutosInicio = (horaSeleccionada.hour * 60) + horaSeleccionada.minute;
      final totalMinutosFin = totalMinutosInicio + duracionSeleccionada;

      // Buscar citas en la misma fecha y terapeuta (excluyendo la cita actual)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('citas')
          .where('terapeutaId', isEqualTo: currentUser.uid)
          .where('terapeuta', isEqualTo: terapeutaSeleccionado)
          .get();

      // Verificar solapamiento con citas existentes
      for (var doc in querySnapshot.docs) {
        // Excluir la cita actual que se está editando
        if (doc.id == widget.id) continue;

        final data = doc.data();
        final String? citaFecha = data['fecha'] as String?;
        final String? citaHora = data['hora'] as String?;
        final int citaDuracion = data['duracionMinutos'] ?? 60; // Duración por defecto si no existe

        if (citaFecha != null && citaHora != null) {
          String citaFechaString = citaFecha.split('T')[0]; // Solo la fecha
          
          // Solo verificar si es la misma fecha
          if (citaFechaString == fechaString) {
            // Calcular rangos de tiempo de la cita existente
            final partesHoraCita = citaHora.split(':');
            final horaInicioCita = int.parse(partesHoraCita[0]);
            final minutoInicioCita = int.parse(partesHoraCita[1]);
            final totalMinutosInicioCita = (horaInicioCita * 60) + minutoInicioCita;
            final totalMinutosFinCita = totalMinutosInicioCita + citaDuracion;

            // Verificar solapamiento
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

  // Función para mostrar advertencia de conflicto de horario
  void _mostrarAdvertenciaConflictoHorario() {
    // Calcular hora de finalización
    final totalMinutosInicio = (horaSeleccionada.hour * 60) + horaSeleccionada.minute;
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
            'el día ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year} '
            'de ${horaSeleccionada.format(context)} a $horaFinString '
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

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Guardar el formato de hora antes de cualquier operación async
        String horaFormateada = horaSeleccionada.format(context);
        
        setState(() {
          _isLoading = true;
        });

        // Verificar que el usuario autenticado sea el dueño de la cita
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.uid != widget.datos['terapeutaId']) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes permisos para editar esta cita')),
          );
          return;
        }

        // Verificar conflictos de horario antes de actualizar
        bool hayConflicto = await _verificarConflictoHorarioEdicion();
        if (hayConflicto) {
          setState(() {
            _isLoading = false;
          });
          _mostrarAdvertenciaConflictoHorario();
          return;
        }

        await FirebaseFirestore.instance.collection('citas').doc(widget.id).update({
          'nombre': nombreController.text,
          'correo': correoController.text,
          'telefono': _codigoPaisSeleccionado + telefonoController.text,
          'fecha': fechaSeleccionada.toIso8601String(),
          'hora': horaFormateada,
          'duracionMinutos': duracionSeleccionada, // Agregar duración
          'servicio': tipoMasaje, // Usar 'servicio' para consistencia
          'terapeuta': terapeutaSeleccionado ?? '',
          // Mantener el terapeutaId original
          'terapeutaId': widget.datos['terapeutaId'],
          'fechaModificacion': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cita actualizada exitosamente')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaVerCitas()),
          (route) => false,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la cita: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarCita() async {
    // Mostrar diálogo de confirmación
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar Cita'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta cita?\n\n'
            'Esta acción no se puede deshacer.',
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
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        // Verificar permisos antes de eliminar
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.uid != widget.datos['terapeutaId']) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes permisos para eliminar esta cita')),
          );
          return;
        }

        // Eliminar la cita de Firestore
        await FirebaseFirestore.instance.collection('citas').doc(widget.id).delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Cita eliminada exitosamente')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaVerCitas()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al eliminar la cita: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cita')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              
              // Campo de teléfono con selector de código de país
              Row(
                children: [
                  // Dropdown para código de país
                  Container(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value: _codigoPaisSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'País',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _codigosPais.map((pais) {
                        return DropdownMenuItem<String>(
                          value: pais['codigo'],
                          child: Row(
                            children: [
                              Text(pais['bandera']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pais['codigo']!,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _codigoPaisSeleccionado = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Campo de número de teléfono
                  Expanded(
                    child: TextFormField(
                      controller: telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Número de teléfono',
                        hintText: 'Ej: 3001234567',
                        prefixText: _codigoPaisSeleccionado + ' ',
                        prefixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (value.length < 7) {
                          return 'Número muy corto';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Fecha: ${fechaSeleccionada.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              ListTile(
                title: Text('Hora: ${horaSeleccionada.format(context)}'),
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
              DropdownButtonFormField<String>(
                value: tipoMasaje,
                items: tiposMasajeValidos.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tipoMasaje = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de masaje'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: terapeutaSeleccionado,
                items: listaTerapeutas.map((String nombre) {
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
                validator: (value) => value == null ? 'Selecciona un terapeuta' : null,
                decoration: const InputDecoration(labelText: 'Terapeuta'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _eliminarCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever, size: 18),
                          SizedBox(width: 4),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
