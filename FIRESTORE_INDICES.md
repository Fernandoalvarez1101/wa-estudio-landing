# Gestión de Índices en Cloud Firestore

## Problema Común: Error de Índice Requerido

Cuando recibes el error:
```
[cloud_firestore/failed-precondition] The query requires an index.
```

Esto significa que tu consulta necesita un índice compuesto para funcionar.

## Cuándo se Requieren Índices Compuestos

Cloud Firestore requiere índices compuestos en estos casos:

1. **Consultas con múltiples filtros de igualdad** en campos diferentes
2. **Consultas con filtros de igualdad + orderBy** en campos diferentes
3. **Consultas con filtros de rango + orderBy** en campos diferentes

## Soluciones

### Opción 1: Crear Índice Manualmente (Recomendada para Producción)

1. Ve a la consola de Firebase: https://console.firebase.google.com/project/agendawa-5d8a1/firestore/indexes
2. Haz clic en "Crear índice"
3. Configura:
   - **Colección**: Nombre de tu colección (ej: `locales`)
   - **Campos**: Agrega los campos en orden:
     - Campo usado en `.where()` (ej: `terapeutaUid` - Ascending)
     - Campo usado en `.orderBy()` (ej: `fechaCreacion` - Descending)

### Opción 2: Modificar la Consulta (Solución Temporal)

Si no puedes crear el índice inmediatamente:

```dart
// EN LUGAR DE:
final snapshot = await _firestore
    .collection('locales')
    .where('terapeutaUid', isEqualTo: currentUser.uid)
    .orderBy('fechaCreacion', descending: true)
    .get();

// USA:
final snapshot = await _firestore
    .collection('locales')
    .where('terapeutaUid', isEqualTo: currentUser.uid)
    .get();

// Y luego ordena en el cliente:
final locales = snapshot.docs.map((doc) => {
  'id': doc.id,
  ...doc.data(),
}).toList();

locales.sort((a, b) {
  final fechaA = a['fechaCreacion'] as Timestamp?;
  final fechaB = b['fechaCreacion'] as Timestamp?;
  
  if (fechaA == null && fechaB == null) return 0;
  if (fechaA == null) return 1;
  if (fechaB == null) return -1;
  
  return fechaB.compareTo(fechaA); // Orden descendente
});
```

## Consideraciones de Rendimiento

- **Ordenar en cliente**: Bueno para pocos documentos (<100)
- **Índices en servidor**: Mejor para muchos documentos o consultas frecuentes
- **Límites de Firestore**: Máximo 40,000 índices por proyecto

## Índices Recomendados para Esta App

### Colección: `locales`
- `terapeutaUid` (Ascending) + `fechaCreacion` (Descending)
  - **Estado**: ✅ Solucionado (ordenado en cliente)

### Colección: `clientes`
- `terapeutaUid` (Ascending) + `nombre` (Ascending)
  - **Estado**: ⚠️ Requiere índice en Firebase Console
  - **Ubicación**: `lib/screens/pantalla_ver_clientes.dart:351`
  - **Consulta**: `.where('terapeutaUid', isEqualTo: uid).orderBy('nombre')`

### Colección: `citas`
- `terapeutaId` (Ascending) + `nombre` (Ascending) + `atendido` (Ascending) + `fecha` (Descending)
  - **Estado**: ✅ Solucionado (ordenado en cliente)
  - **Ubicación**: `lib/services/visitas_service.dart:97`
  - **Consulta**: Múltiples filtros + orderBy

### Índices Prioritarios para Crear en Firebase Console

1. **Más Urgente**: `clientes` collection
   ```
   Campo 1: terapeutaUid (Ascending)
   Campo 2: nombre (Ascending)
   ```

2. **Opcional**: Si decides usar orderBy en servidor para `locales`
   ```
   Campo 1: terapeutaUid (Ascending) 
   Campo 2: fechaCreacion (Descending)
   ```

## Comandos CLI (Opcional)

También puedes crear índices desde la línea de comandos:

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Crear archivo de índices
firebase firestore:indexes > firestore.indexes.json

# Desplegar índices
firebase deploy --only firestore:indexes
```

## Enlaces Útiles

- [Documentación de Índices](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Consola de Firebase](https://console.firebase.google.com/project/agendawa-5d8a1/firestore/indexes)
- [Límites de Firestore](https://firebase.google.com/docs/firestore/quotas)
