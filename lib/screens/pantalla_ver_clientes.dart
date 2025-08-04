import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'pantalla_agendar_cita.dart';
import '../services/papelera_service.dart';
import '../services/visitas_service.dart';
import 'pantalla_papelera_clientes.dart';

class PantallaVerClientes extends StatefulWidget {
  final bool autoOpenSearch;
  
  const PantallaVerClientes({super.key, this.autoOpenSearch = false});

  @override
  State<PantallaVerClientes> createState() => _PantallaVerClientesState();
}

class _PantallaVerClientesState extends State<PantallaVerClientes> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;
  
  // Lista de códigos de país para formateo
  final List<Map<String, String>> _codigosPaisFormato = [
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

  // Función para formatear el teléfono con bandera
  String _formatearTelefono(String telefono) {
    if (telefono.isEmpty || !telefono.startsWith('+')) {
      return telefono;
    }
    
    // Buscar el código de país y su bandera
    for (var pais in _codigosPaisFormato) {
      if (telefono.startsWith(pais['codigo']!)) {
        final numero = telefono.replaceFirst(pais['codigo']!, '');
        return '${pais['bandera']} ${pais['codigo']} $numero';
      }
    }
    
    return telefono; // Si no se encuentra el código, devolver tal como está
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    
    // Si se solicita abrir automáticamente la búsqueda
    if (widget.autoOpenSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isSearching = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _agendarCitaParaCliente(BuildContext context, DocumentSnapshot cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaAgendarCita(
          nombrePrellenado: cliente['nombre'],
          correoPrellenado: cliente['correo'],
          telefonoPrellenado: cliente['telefono'],
        ),
      ),
    );
  }

  void _eliminarCliente(BuildContext context, String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      // Confirmar eliminación
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mover a Papelera'),
          content: const Text('¿Deseas mover este cliente a la papelera? Podrás restaurarlo más tarde si es necesario.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Mover a Papelera', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ?? false;

      if (!confirmado) return;
      
      // Mover a papelera usando el servicio
      final resultado = await PapeleraService.moverClienteAPapelera(id);
    
      if (!mounted) return;
      
      if (resultado) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cliente movido a la papelera'),
              action: SnackBarAction(
                label: 'Ver Papelera',
                onPressed: () {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaPapeleraClientes(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al mover cliente a la papelera')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _alternarBloqueoCliente(BuildContext context, DocumentSnapshot cliente) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      // Verificar que el cliente pertenece al usuario actual
      final clienteData = cliente.data() as Map<String, dynamic>;
      if (clienteData['terapeutaUid'] != currentUser.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes permisos para modificar este cliente')),
        );
        return;
      }

      final bool estaBloquado = clienteData.containsKey('bloqueado') ? 
          clienteData['bloqueado'] : false;
      
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(cliente.id)
          .update({
            'bloqueado': !estaBloquado,
          });
      
      if (!mounted) return;
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(estaBloquado ? 
              'Cliente desbloqueado' : 'Cliente bloqueado'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    }
  }

  void _mostrarFormularioEditar(
    BuildContext context,
    DocumentSnapshot cliente,
  ) {
    showDialog(
      context: context,
      builder: (_) => _FormularioEditarCliente(cliente: cliente),
    );
  }

  Widget _buildSistemaEstrellas(QueryDocumentSnapshot cliente) {
    final clienteData = cliente.data() as Map<String, dynamic>;
    final int nivelActual = clienteData['nivelCliente'] ?? 0; // 0-3 estrellas
    
    return Row(
      children: List.generate(3, (index) {
        final bool estaActiva = index < nivelActual;
        return GestureDetector(
          onTap: () => _cambiarNivelCliente(cliente.id, index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              estaActiva ? Icons.star : Icons.star_border,
              color: estaActiva ? Colors.amber : Colors.grey,
              size: 24,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _cambiarNivelCliente(String clienteId, int nuevoNivel) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Verificar que el cliente pertenece al usuario actual
      final clienteDoc = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .get();

      if (!clienteDoc.exists) return;

      final clienteData = clienteDoc.data() as Map<String, dynamic>;
      if (clienteData['terapeutaUid'] != currentUser.uid) return;

      final int nivelActual = clienteData['nivelCliente'] ?? 0;
      final int nuevoNivelFinal = (nivelActual == nuevoNivel) ? nuevoNivel - 1 : nuevoNivel;

      // Actualizar el nivel en Firestore
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .update({
            'nivelCliente': nuevoNivelFinal,
            'fechaActualizacionNivel': Timestamp.now(),
          });

      // Mostrar mensaje informativo
      if (!mounted) return;
      final String mensaje = _obtenerMensajeNivel(nuevoNivelFinal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: _obtenerColorNivel(nuevoNivelFinal),
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar nivel: $e')),
      );
    }
  }

  String _obtenerMensajeNivel(int nivel) {
    switch (nivel) {
      case 0:
        return '⭐ Cliente nuevo - Sin clasificación';
      case 1:
        return '⭐ Cliente bronce - Nivel básico';
      case 2:
        return '⭐⭐ Cliente plata - Nivel intermedio';
      case 3:
        return '⭐⭐⭐ Cliente oro - Nivel premium';
      default:
        return 'Nivel actualizado';
    }
  }

  Color _obtenerColorNivel(int nivel) {
    switch (nivel) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.brown;
      case 2:
        return Colors.blueGrey;
      case 3:
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar cliente por nombre...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                ),
                autofocus: true,
              )
            : const Text('Clientes registrados'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar cliente',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Ver Papelera',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaPapeleraClientes(),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clientes')
            .where('terapeutaUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('nombre')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Error en StreamBuilder: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error al cargar los datos'),
                  const SizedBox(height: 8),
                  Text(
                    'Detalles: ${snapshot.error}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clientes = snapshot.data!.docs;

          // Filtrar clientes por el texto de búsqueda
          final clientesFiltrados = clientes.where((cliente) {
            if (_searchText.isEmpty) return true;
            
            final clienteData = cliente.data() as Map<String, dynamic>;
            final nombre = clienteData['nombre']?.toString().toLowerCase() ?? '';
            final telefono = clienteData['telefono']?.toString().toLowerCase() ?? '';
            final correo = clienteData['correo']?.toString().toLowerCase() ?? '';
            
            final textoBusqueda = _searchText.toLowerCase();
            
            return nombre.contains(textoBusqueda) || 
                   telefono.contains(textoBusqueda) || 
                   correo.contains(textoBusqueda);
          }).toList();

          if (clientes.isEmpty) {
            return const Center(child: Text('No hay clientes registrados.'));
          }

          if (clientesFiltrados.isEmpty && _searchText.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.clear_all, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron clientes para "$_searchText"',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Intenta con otro término de búsqueda',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Contador de resultados si hay búsqueda activa
              if (_searchText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Encontrados ${clientesFiltrados.length} resultado${clientesFiltrados.length != 1 ? 's' : ''} para "$_searchText"',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Lista de clientes filtrados
              Expanded(
                child: ListView.builder(
                  itemCount: clientesFiltrados.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesFiltrados[index];
              final bool estaBloquado = cliente.data() != null && 
                  (cliente.data() as Map<String, dynamic>).containsKey('bloqueado') ? 
                  cliente['bloqueado'] : false;
              
              // Debug: imprimir información de la foto
              final clienteData = cliente.data() as Map<String, dynamic>?;
              final tieneUrlFoto = clienteData?.containsKey('fotoUrl') ?? false;
              final fotoUrl = tieneUrlFoto ? clienteData!['fotoUrl'] : null;
              debugPrint('👤 Cliente: ${cliente['nombre']} - TieneFoto: $tieneUrlFoto - URL: $fotoUrl');
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: estaBloquado ? Colors.red.shade50 : null,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto del cliente
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: (() {
                          final clienteData = cliente.data() as Map<String, dynamic>?;
                          final fotoUrl = clienteData?['fotoUrl'] as String?;
                          
                          if (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.startsWith('local://')) {
                            debugPrint('🖼️ Mostrando imagen para ${cliente['nombre']}: $fotoUrl');
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / 
                                            loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('❌ Error cargando imagen para ${cliente['nombre']}: $error');
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              ),
                            );
                          } else if (fotoUrl != null && fotoUrl.startsWith('local://')) {
                            // Para URLs locales temporales, mostrar la foto desde archivo local
                            debugPrint('📱 Cliente con foto local: ${cliente['nombre']}');
                            try {
                              final clienteData = cliente.data() as Map<String, dynamic>?;
                              final rutaImagen = clienteData?.containsKey('rutaImagenLocal') == true 
                                  ? clienteData!['rutaImagenLocal'] as String? 
                                  : null;
                              
                              if (rutaImagen != null && rutaImagen.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(rutaImagen),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint('❌ Error cargando imagen local para ${cliente['nombre']}: $error');
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.blue.shade100,
                                        ),
                                        child: Icon(
                                          Icons.photo_camera,
                                          size: 40,
                                          color: Colors.blue.shade600,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                debugPrint('📷 No hay ruta de imagen local para ${cliente['nombre']} (campo no existe o está vacío)');
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.shade100,
                                  ),
                                  child: Icon(
                                    Icons.photo_camera,
                                    size: 40,
                                    color: Colors.blue.shade600,
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('❌ Error accediendo al campo rutaImagenLocal: $e');
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue.shade100,
                                ),
                                child: Icon(
                                  Icons.photo_camera,
                                  size: 40,
                                  color: Colors.blue.shade600,
                                ),
                              );
                            }
                          } else {
                            debugPrint('👤 Sin imagen para ${cliente['nombre']}');
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            );
                          }
                        })(),
                      ),
                      const SizedBox(width: 16),
                      
                      // Información del cliente
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cliente['nombre'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: estaBloquado ? Colors.red.shade700 : null,
                                      decoration: estaBloquado ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                if (estaBloquado)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'BLOQUEADO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Sistema de niveles con estrellas
                            Row(
                              children: [
                                const Text('Nivel: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                _buildSistemaEstrellas(cliente),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Contador de visitas de los últimos 6 meses
                            FutureBuilder<int>(
                              future: VisitasService.contarVisitasUltimos6Meses(cliente['nombre']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Row(
                                    children: [
                                      const Text('📊 Visitas (6 meses): '),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ],
                                  );
                                }
                                
                                final visitas = snapshot.data ?? 0;
                                return Row(
                                  children: [
                                    const Text('📊 Visitas (6 meses): ', 
                                        style: TextStyle(fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: visitas > 5 ? Colors.green.shade100 : 
                                              visitas > 2 ? Colors.orange.shade100 : 
                                              Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: visitas > 5 ? Colors.green : 
                                                visitas > 2 ? Colors.orange : 
                                                Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '$visitas',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: visitas > 5 ? Colors.green.shade700 : 
                                                visitas > 2 ? Colors.orange.shade700 : 
                                                Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            
                            Text('📞 ${_formatearTelefono(cliente['telefono'] ?? '')}',
                                style: TextStyle(color: estaBloquado ? Colors.red.shade600 : null)),
                            Text('✉️ Correo: ${cliente['correo']}',
                                style: TextStyle(color: estaBloquado ? Colors.red.shade600 : null)),
                            // Mostrar fecha de cumpleaños (verificando que el campo exista)
                            (() {
                              final clienteData = cliente.data() as Map<String, dynamic>;
                              final fechaCumpleanos = clienteData.containsKey('fechaCumpleanos') ? clienteData['fechaCumpleanos'] : null;
                              final fechaNacimiento = clienteData.containsKey('fechaNacimiento') ? clienteData['fechaNacimiento'] : null;
                              
                              final fechaAMostrar = fechaCumpleanos ?? fechaNacimiento;
                              
                              if (fechaAMostrar != null && fechaAMostrar.toString().isNotEmpty) {
                                return Text('🎂 Cumpleaños: $fechaAMostrar',
                                    style: TextStyle(color: estaBloquado ? Colors.red.shade600 : null));
                              } else {
                                return const SizedBox.shrink();
                              }
                            })(),
                            const SizedBox(height: 12),
                            
                            // Botones de acción
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: estaBloquado ? null : () => _agendarCitaParaCliente(context, cliente),
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: const Text('Agendar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _mostrarFormularioEditar(context, cliente),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Editar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _alternarBloqueoCliente(context, cliente),
                                  icon: Icon(estaBloquado ? Icons.lock_open : Icons.lock, size: 16),
                                  label: Text(estaBloquado ? 'Desbloquear' : 'Bloquear'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: estaBloquado ? Colors.orange : Colors.grey.shade600,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _eliminarCliente(context, cliente.id),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text('Eliminar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormularioEditarCliente extends StatefulWidget {
  final DocumentSnapshot cliente;

  const _FormularioEditarCliente({required this.cliente});

  @override
  State<_FormularioEditarCliente> createState() => _FormularioEditarClienteState();
}

class _FormularioEditarClienteState extends State<_FormularioEditarCliente> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _fechaController;
  late TextEditingController _correoController;
  late TextEditingController _anotacionesController;
  
  late int _nivelSeleccionado; // Para el sistema de estrellas
  
  File? _nuevaImagen;
  final ImagePicker _picker = ImagePicker();
  bool _cargandoImagen = false;

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
    _nombreController = TextEditingController(text: widget.cliente['nombre']);
    
    // Separar código de país del número telefónico existente
    final telefonoCompleto = widget.cliente['telefono'] ?? '';
    if (telefonoCompleto.startsWith('+')) {
      // Buscar el código en nuestra lista
      for (var pais in _codigosPais) {
        if (telefonoCompleto.startsWith(pais['codigo']!)) {
          _codigoPaisSeleccionado = pais['codigo']!;
          _telefonoController = TextEditingController(
            text: telefonoCompleto.replaceFirst(pais['codigo']!, '')
          );
          break;
        }
      }
      // Si no se encuentra el código, usar el número completo
      if (_telefonoController.text.isEmpty) {
        _telefonoController = TextEditingController(text: telefonoCompleto);
      }
    } else {
      // Si no tiene código de país, usar el número tal como está
      _telefonoController = TextEditingController(text: telefonoCompleto);
    }
    
    // Verificar que los campos de fecha existan antes de acceder a ellos
    final clienteData = widget.cliente.data() as Map<String, dynamic>;
    final fechaCumpleanos = clienteData.containsKey('fechaCumpleanos') ? clienteData['fechaCumpleanos'] : null;
    final fechaNacimiento = clienteData.containsKey('fechaNacimiento') ? clienteData['fechaNacimiento'] : null;
    _fechaController = TextEditingController(text: fechaCumpleanos ?? fechaNacimiento ?? '');
    
    _correoController = TextEditingController(text: widget.cliente['correo']);
    _anotacionesController = TextEditingController(text: widget.cliente['anotaciones']);
    
    // Inicializar nivel del cliente
    _nivelSeleccionado = clienteData['nivelCliente'] ?? 0;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _correoController.dispose();
    _anotacionesController.dispose();
    super.dispose();
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
        _nuevaImagen = File(imagen.path);
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
        _nuevaImagen = File(imagen.path);
      });
    }
  }

  Future<Map<String, String?>> _subirImagen() async {
    if (_nuevaImagen == null) return {'fotoUrl': null, 'rutaImagenLocal': null};
    
    setState(() {
      _cargandoImagen = true;
    });
    
    try {
      debugPrint('🔄 Guardando imagen (edición) para cliente: ${widget.cliente.id}');
      
      // Sistema temporal igual que en registro
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempUrl = 'local://cliente_${widget.cliente.id}_edit_$timestamp.jpg';
      final rutaLocal = _nuevaImagen!.path;
      
      debugPrint('✅ Imagen "guardada" temporalmente (edición): $tempUrl');
      debugPrint('📁 Ruta local de la imagen (edición): $rutaLocal');
      
      // TODO: Implementar Firebase Storage cuando esté configurado
      return {
        'fotoUrl': tempUrl,
        'rutaImagenLocal': rutaLocal,
      };
      
    } catch (e) {
      debugPrint('❌ Error en edición: $e');
      return {'fotoUrl': null, 'rutaImagenLocal': null};
    } finally {
      setState(() {
        _cargandoImagen = false;
      });
    }
  }

  Future<void> _eliminarFotoExistente() async {
    // Mostrar confirmación
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar foto'),
          content: const Text('¿Estás seguro de que deseas eliminar la foto de este cliente?'),
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
        // Eliminar la foto de Firestore
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.cliente.id)
            .update({
          'fotoUrl': FieldValue.delete(),
          'rutaImagenLocal': FieldValue.delete(),
        });

        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Cerrar el diálogo de edición para que se actualice la vista
          Navigator.of(context).pop();
        }
        
        debugPrint('✅ Foto eliminada del cliente: ${widget.cliente.id}');
      } catch (e) {
        debugPrint('❌ Error eliminando foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error eliminando foto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String? _obtenerFotoActual() {
    if (widget.cliente.data() != null && 
        (widget.cliente.data() as Map<String, dynamic>).containsKey('fotoUrl') &&
        widget.cliente['fotoUrl'] != null && 
        widget.cliente['fotoUrl'].toString().isNotEmpty) {
      return widget.cliente['fotoUrl'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cliente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sección de fotografía
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fotografía',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _nuevaImagen != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _nuevaImagen!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _nuevaImagen = null;
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
                              )
                            : _obtenerFotoActual() != null
                                ? (() {
                                    final fotoUrl = _obtenerFotoActual()!;
                                    if (fotoUrl.startsWith('local://')) {
                                      // Para URLs locales, mostrar ícono de cámara azul
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.blue.shade100,
                                        ),
                                        child: Icon(
                                          Icons.photo_camera,
                                          size: 60,
                                          color: Colors.blue.shade600,
                                        ),
                                      );
                                    } else {
                                      // Para URLs reales de Firebase Storage
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          fotoUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  })()
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _cargandoImagen ? null : _seleccionarImagen,
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Galería'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _cargandoImagen ? null : _tomarFoto,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Cámara'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade100,
                            foregroundColor: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    
                    // Botón para eliminar foto existente
                    if (_obtenerFotoActual() != null && _nuevaImagen == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _cargandoImagen ? null : _eliminarFotoExistente,
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Eliminar foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    
                    if (_cargandoImagen)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Subiendo imagen...'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Campos de información
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
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
                  child: TextField(
                    controller: _telefonoController,
                    decoration: InputDecoration(
                      labelText: 'Número de teléfono',
                      hintText: 'Ej: 3001234567',
                      prefixText: _codigoPaisSeleccionado + ' ',
                      prefixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Cumpleaños (día/mes)',
                hintText: 'dd/mm',
                suffixIcon: Icon(Icons.cake),
              ),
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _anotacionesController,
              decoration: const InputDecoration(labelText: 'Anotaciones'),
            ),
            const SizedBox(height: 16),
            
            // Selector de nivel de cliente
            Row(
              children: [
                const Text('Nivel del cliente: ', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(3, (index) {
                    final bool estaActiva = index < _nivelSeleccionado;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _nivelSeleccionado = (index + 1 == _nivelSeleccionado) ? index : index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          estaActiva ? Icons.star : Icons.star_border,
                          color: estaActiva ? Colors.amber : Colors.grey,
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  _obtenerTextoNivelFormulario(_nivelSeleccionado),
                  style: TextStyle(
                    color: _obtenerColorNivelFormulario(_nivelSeleccionado),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          onPressed: _cargandoImagen ? null : () async {
            try {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario no autenticado')),
                );
                return;
              }

              // Verificar que el cliente pertenece al usuario actual
              final clienteData = widget.cliente.data() as Map<String, dynamic>;
              if (clienteData['terapeutaUid'] != currentUser.uid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No tienes permisos para editar este cliente')),
                );
                return;
              }

              // Preparar datos para actualizar
              final String telefonoCompleto = _codigoPaisSeleccionado + _telefonoController.text.trim();
              
              Map<String, dynamic> datosActualizar = {
                'nombre': _nombreController.text.trim(),
                'telefono': telefonoCompleto,
                'fechaCumpleanos': _fechaController.text.trim(),
                'correo': _correoController.text.trim(),
                'anotaciones': _anotacionesController.text.trim(),
              };

              // Si hay nueva imagen, subirla
              if (_nuevaImagen != null) {
                Map<String, String?> resultadoImagen = await _subirImagen();
                String? nuevaFotoUrl = resultadoImagen['fotoUrl'];
                String? rutaImagenLocal = resultadoImagen['rutaImagenLocal'];
                
                if (nuevaFotoUrl != null) {
                  datosActualizar['fotoUrl'] = nuevaFotoUrl;
                  if (rutaImagenLocal != null) {
                    datosActualizar['rutaImagenLocal'] = rutaImagenLocal;
                  }
                }
              }

              // Actualizar documento
              await FirebaseFirestore.instance
                  .collection('clientes')
                  .doc(widget.cliente.id)
                  .update(datosActualizar);

              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente actualizado exitosamente')),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e')),
                );
              }
            }
          },
          child: _cargandoImagen 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar cambios'),
        ),
      ],
    );
  }

  // Métodos para el sistema de estrellas en el formulario de edición
  String _obtenerTextoNivelFormulario(int nivel) {
    switch (nivel) {
      case 0:
        return 'Cliente Regular';
      case 1:
        return 'Cliente Frecuente';
      case 2:
        return 'Cliente Premium';
      case 3:
        return 'Cliente VIP';
      default:
        return 'Sin clasificar';
    }
  }

  Color _obtenerColorNivelFormulario(int nivel) {
    switch (nivel) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
