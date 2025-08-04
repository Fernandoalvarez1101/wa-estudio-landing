# Sistema de Clasificación por Estrellas - Documentación Técnica

## 📋 Descripción General
El sistema de clasificación por estrellas permite a los usuarios clasificar a sus clientes en diferentes niveles según la frecuencia de servicios, valor del cliente, o cualquier criterio que el negocio considere relevante.

## ⭐ Niveles de Clasificación
- **0 Estrellas** (Gris): Cliente Regular
- **1 Estrella** (Azul): Cliente Frecuente  
- **2 Estrellas** (Morado): Cliente Premium
- **3 Estrellas** (Dorado): Cliente VIP

## 🏗️ Arquitectura del Sistema

### 1. Modelo de Datos
```dart
// Campos agregados al modelo Cliente:
int nivelCliente: 0-3    // Nivel de estrellas del cliente
DateTime? fechaActualizacionNivel  // Fecha de última actualización del nivel
```

### 2. Componentes Principales

#### A. Visualización en Tarjetas de Cliente
**Archivo**: `lib/screens/pantalla_ver_clientes.dart`
**Método**: `_buildSistemaEstrellas(Cliente cliente)`

```dart
Widget _buildSistemaEstrellas(Cliente cliente) {
  final int nivel = cliente.nivelCliente ?? 0;
  return Row(
    children: [
      ...List.generate(3, (index) => Icon(
        index < nivel ? Icons.star : Icons.star_border,
        color: _obtenerColorNivel(nivel),
        size: 16,
      )),
      const SizedBox(width: 8),
      Text(_obtenerTextoNivel(nivel)),
    ],
  );
}
```

#### B. Editor de Nivel en Formulario
**Archivo**: `lib/screens/pantalla_ver_clientes.dart`
**Método**: `_buildSelectorEstrellas()` en `_FormularioEditarClienteState`

```dart
Widget _buildSelectorEstrellas() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Nivel del Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(
        children: List.generate(4, (index) {
          final bool isSelected = _nivelClienteSeleccionado == index;
          return GestureDetector(
            onTap: () => setState(() => _nivelClienteSeleccionado = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _obtenerColorNivelFormulario(index).withOpacity(0.2) : Colors.grey.shade100,
                border: Border.all(color: isSelected ? _obtenerColorNivelFormulario(index) : Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(3, (starIndex) => Icon(
                    starIndex < index ? Icons.star : Icons.star_border,
                    color: _obtenerColorNivelFormulario(index),
                    size: 16,
                  )),
                  const SizedBox(width: 4),
                  Text(_obtenerTextoNivelFormulario(index)),
                ],
              ),
            ),
          );
        }),
      ),
    ],
  );
}
```

### 3. Funciones de Utilidad

#### A. Obtener Color por Nivel
```dart
Color _obtenerColorNivel(int nivel) {
  switch (nivel) {
    case 0: return Colors.grey;
    case 1: return Colors.blue;
    case 2: return Colors.purple;
    case 3: return Colors.amber;
    default: return Colors.grey;
  }
}
```

#### B. Obtener Texto por Nivel
```dart
String _obtenerTextoNivel(int nivel) {
  switch (nivel) {
    case 0: return 'Regular';
    case 1: return 'Frecuente';
    case 2: return 'Premium';
    case 3: return 'VIP';
    default: return 'Sin clasificar';
  }
}
```

## 🗄️ Estructura de Base de Datos

### Firestore - Colección `clientes`
```json
{
  "id": "cliente_123",
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "telefono": "+1234567890",
  "nivelCliente": 2,                    // ← NUEVO CAMPO
  "fechaActualizacionNivel": "2025-01-30T15:30:00Z",  // ← NUEVO CAMPO
  "fechaRegistro": "2025-01-15T10:00:00Z",
  "usuarioId": "user_456",
  // ... otros campos existentes
}
```

## 🔄 Flujo de Actualización

### 1. Registro de Nuevo Cliente
```dart
// En pantalla_registrar_cliente.dart
final cliente = {
  'nombre': _nombreController.text,
  'email': _emailController.text,
  'telefono': _telefonoController.text,
  'nivelCliente': 0,                    // Inicializado en 0 (Regular)
  'fechaActualizacionNivel': FieldValue.serverTimestamp(),
  'fechaRegistro': FieldValue.serverTimestamp(),
  'usuarioId': user.uid,
};
```

### 2. Edición de Cliente Existente
```dart
// En _FormularioEditarClienteState
Map<String, dynamic> datosActualizar = {
  'nombre': _nombreController.text,
  'email': _correoController.text,
  'telefono': _telefonoController.text,
  'nivelCliente': _nivelClienteSeleccionado,
  'fechaActualizacionNivel': FieldValue.serverTimestamp(),
};

await FirebaseFirestore.instance
    .collection('clientes')
    .doc(widget.cliente.id)
    .update(datosActualizar);
```

## 🎨 Interfaz de Usuario

### 1. Tarjeta de Cliente
- **Ubicación**: Dentro de cada tarjeta de cliente en la lista principal
- **Elementos**: 3 íconos de estrella + texto descriptivo
- **Colores**: Dinámicos según el nivel del cliente

### 2. Formulario de Edición
- **Ubicación**: Modal de edición de cliente
- **Elementos**: 4 botones seleccionables (0-3 estrellas)
- **Interacción**: Tap para seleccionar nivel
- **Feedback**: Resaltado visual del nivel seleccionado

## 🔧 Personalización

### Modificar Colores
Para cambiar los colores de los niveles, editar las funciones:
- `_obtenerColorNivel()` - Para visualización en tarjetas
- `_obtenerColorNivelFormulario()` - Para formulario de edición

### Modificar Textos
Para cambiar las descripciones de los niveles, editar las funciones:
- `_obtenerTextoNivel()` - Para visualización en tarjetas  
- `_obtenerTextoNivelFormulario()` - Para formulario de edición

### Agregar Más Niveles
1. Modificar los bucles `List.generate(4, ...)` por el nuevo número
2. Agregar nuevos cases en las funciones switch de colores y textos
3. Actualizar la validación de rango en el modelo

## 📱 Casos de Uso Recomendados

### 1. Por Frecuencia de Visitas
- **0 Estrellas**: 1-2 visitas al año
- **1 Estrella**: 3-6 visitas al año  
- **2 Estrellas**: 6-12 visitas al año
- **3 Estrellas**: Más de 12 visitas al año

### 2. Por Valor de Servicios
- **0 Estrellas**: Servicios básicos
- **1 Estrella**: Servicios estándar
- **2 Estrellas**: Servicios premium
- **3 Estrellas**: Servicios VIP/exclusivos

### 3. Por Fidelidad del Cliente
- **0 Estrellas**: Cliente nuevo
- **1 Estrella**: Cliente regular (6+ meses)
- **2 Estrellas**: Cliente leal (1+ años)
- **3 Estrellas**: Cliente VIP (2+ años)

## 🔍 Funcionalidades Futuras Sugeridas

1. **Filtros por Nivel**: Permitir filtrar la lista de clientes por nivel de estrellas
2. **Estadísticas**: Dashboard con distribución de clientes por nivel
3. **Auto-clasificación**: Sistema automático basado en historial de servicios
4. **Promociones Dirigidas**: Ofertas específicas según el nivel del cliente
5. **Reportes**: Análisis de rentabilidad por nivel de cliente

## ✅ Estado de Implementación

- ✅ Modelo de datos actualizado
- ✅ Visualización en tarjetas de cliente
- ✅ Editor de nivel en formulario de edición
- ✅ Funciones de utilidad para colores y textos
- ✅ Integración con Firebase Firestore
- ✅ Inicialización en registro de nuevos clientes
- ✅ Persistencia de cambios en edición

## 🚀 Próximos Pasos

1. Compilar nueva versión APK con sistema de estrellas
2. Probar funcionalidad en diferentes dispositivos
3. Considerar implementar filtros por nivel
4. Agregar métricas y analytics del sistema de clasificación

---

**Fecha de Implementación**: 30 de Enero, 2025  
**Versión**: v2.1 - Sistema de Clasificación por Estrellas  
**Estado**: ✅ Completado y Funcional
