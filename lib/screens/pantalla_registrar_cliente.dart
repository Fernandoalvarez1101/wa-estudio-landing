import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'pantalla_ver_clientes.dart';
import 'pantalla_agendar_cita.dart';

class PantallaRegistrarCliente extends StatefulWidget {
  const PantallaRegistrarCliente({super.key});

  @override
  State<PantallaRegistrarCliente> createState() =>
      _PantallaRegistrarClienteState();
}

class _PantallaRegistrarClienteState extends State<PantallaRegistrarCliente> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaCumpleanosController =
      TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _anotacionesController = TextEditingController();

  bool _clienteRegistrado = false; // Para mostrar opciones después del registro
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  
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
    {'codigo': '+505', 'pais': 'Nicaragua', 'bandera': '��'},
    {'codigo': '+506', 'pais': 'Costa Rica', 'bandera': '🇨🇷'},
    {'codigo': '+507', 'pais': 'Panamá', 'bandera': '🇵🇦'},
    
    // América del Sur
    {'codigo': '+57', 'pais': 'Colombia', 'bandera': '��'},
    {'codigo': '+58', 'pais': 'Venezuela', 'bandera': '🇻🇪'},
    {'codigo': '+595', 'pais': 'Paraguay', 'bandera': '🇵🇾'},
    {'codigo': '+598', 'pais': 'Uruguay', 'bandera': '��'},
    {'codigo': '+54', 'pais': 'Argentina', 'bandera': '🇦🇷'},
    {'codigo': '+55', 'pais': 'Brasil', 'bandera': '🇧🇷'},
    {'codigo': '+56', 'pais': 'Chile', 'bandera': '🇨🇱'},
    {'codigo': '+51', 'pais': 'Perú', 'bandera': '🇵🇪'},
    {'codigo': '+593', 'pais': 'Ecuador', 'bandera': '🇪🇨'},
    {'codigo': '+591', 'pais': 'Bolivia', 'bandera': '��'},
    {'codigo': '+594', 'pais': 'Guyana Francesa', 'bandera': '🇬🇫'},
    {'codigo': '+597', 'pais': 'Surinam', 'bandera': '��'},
    {'codigo': '+592', 'pais': 'Guyana', 'bandera': '��'},
    
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

  Future<void> _seleccionarFechaCumpleanos(BuildContext context) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2024, 1, 1), // Año ficticio
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 12, 31),
      helpText: 'Selecciona la fecha de cumpleaños (día y mes)',
    );

    if (fechaSeleccionada != null) {
      // Solo guardar día y mes
      String fechaFormateada = DateFormat(
        'dd/MM',
      ).format(fechaSeleccionada);
      setState(() {
        _fechaCumpleanosController.text = fechaFormateada;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<void> _tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<Map<String, String?>> _subirImagen(String clienteId) async {
    if (_imagenSeleccionada == null) {
      debugPrint('❌ No hay imagen seleccionada para subir');
      return {'fotoUrl': null, 'rutaImagenLocal': null};
    }
    
    try {
      debugPrint('🔄 Guardando imagen localmente para cliente: $clienteId');
      
      // Por ahora, vamos a usar una URL temporal como workaround
      // hasta que configuremos Firebase Storage correctamente
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempUrl = 'local://cliente_${clienteId}_$timestamp.jpg';
      final rutaLocal = _imagenSeleccionada!.path;
      
      debugPrint('✅ Imagen "guardada" temporalmente: $tempUrl');
      debugPrint('📁 Ruta local de la imagen: $rutaLocal');
      
      // TODO: Implementar Firebase Storage cuando esté configurado
      // Para testing, devolvemos una URL temporal y la ruta local
      return {
        'fotoUrl': tempUrl,
        'rutaImagenLocal': rutaLocal,
      };
      
    } catch (e) {
      debugPrint('❌ Error: $e');
      return {'fotoUrl': null, 'rutaImagenLocal': null};
    }
  }

  Future<void> guardarClienteEnFirestore() async {
    try {
      // Obtener el usuario actual
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Preparar datos básicos del cliente
      final String telefonoCompleto = _codigoPaisSeleccionado + _telefonoController.text.trim();
      
      Map<String, dynamic> datosCliente = {
        'nombre': _nombreController.text.trim(),
        'telefono': telefonoCompleto,
        'fechaCumpleanos': _fechaCumpleanosController.text.trim(),
        'correo': _correoController.text.trim(),
        'anotaciones': _anotacionesController.text.trim(),
        'fechaRegistro': Timestamp.now(),
        'terapeutaUid': currentUser.uid, // Agregar UID del terapeuta
        'nivelCliente': 0, // Inicializar con nivel 0 (sin estrellas)
        'fechaActualizacionNivel': Timestamp.now(),
      };

      // Si hay imagen, primero crear el documento sin fotoUrl
      final clienteRef = await FirebaseFirestore.instance.collection('clientes').add(datosCliente);
      debugPrint('📝 Cliente creado con ID: ${clienteRef.id}');

      // Si hay imagen seleccionada, subirla y actualizar el documento
      if (_imagenSeleccionada != null) {
        debugPrint('📸 Imagen seleccionada, procediendo a subirla...');
        Map<String, String?> resultadoImagen = await _subirImagen(clienteRef.id);
        String? fotoUrl = resultadoImagen['fotoUrl'];
        String? rutaImagenLocal = resultadoImagen['rutaImagenLocal'];
        
        if (fotoUrl != null && fotoUrl.isNotEmpty) {
          debugPrint('💾 Actualizando documento con URL: $fotoUrl');
          Map<String, dynamic> datosActualizacion = {'fotoUrl': fotoUrl};
          if (rutaImagenLocal != null) {
            datosActualizacion['rutaImagenLocal'] = rutaImagenLocal;
          }
          await clienteRef.update(datosActualizacion);
          debugPrint('✅ Documento actualizado con foto y ruta local');
        } else {
          debugPrint('❌ No se pudo obtener la URL de la foto');
          // No agregamos el campo fotoUrl si falló la subida
        }
      } else {
        debugPrint('📷 No hay imagen seleccionada');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente registrado exitosamente')),
      );

      // Mostrar opciones en lugar de navegar inmediatamente
      setState(() {
        _clienteRegistrado = true;
      });

    } catch (e) {
      debugPrint('❌ Error completo al guardar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
    }
  }

  void _crearCitaConDatos() {
    // Navegar a la pantalla de agendar cita con los datos pre-llenados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaAgendarCita(
          nombrePrellenado: _nombreController.text.trim(),
          correoPrellenado: _correoController.text.trim(),
          telefonoPrellenado: _codigoPaisSeleccionado + _telefonoController.text.trim(),
        ),
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _telefonoController.clear();
    _fechaCumpleanosController.clear();
    _correoController.clear();
    _anotacionesController.clear();
    setState(() {
      _clienteRegistrado = false;
      _imagenSeleccionada = null;
    });
  }

  String? _validarCampoObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar nuevo cliente')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _validarCampoObligatorio,
              ),
              
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
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Número de teléfono',
                        hintText: 'Ej: 3001234567',
                        prefixText: _codigoPaisSeleccionado + ' ',
                        prefixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el número de teléfono';
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
              TextFormField(
                controller: _fechaCumpleanosController,
                readOnly: true,
                onTap: () => _seleccionarFechaCumpleanos(context),
                decoration: const InputDecoration(
                  labelText: 'Fecha de Cumpleaños (día/mes)',
                  hintText: 'dd/mm',
                  suffixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la fecha de cumpleaños';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) return 'Correo no válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _anotacionesController,
                decoration: const InputDecoration(labelText: 'Anotaciones'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Sección de fotografía
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fotografía (opcional)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_imagenSeleccionada != null) ...[
                        Center(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imagenSeleccionada!,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imagenSeleccionada = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _seleccionarImagen,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _tomarFoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Mostrar botones según el estado
              if (!_clienteRegistrado) ...[
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      guardarClienteEnFirestore();
                    }
                  },
                  child: const Text('Confirmar registro'),
                ),
              ] else ...[
                // Opciones después del registro exitoso
                const Text(
                  '¿Qué deseas hacer ahora?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: _crearCitaConDatos,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Crear cita con estos datos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: _limpiarFormulario,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Registrar otro cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaVerClientes()),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Ver todos los clientes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
