# 🗑️ Sistema de Papelera de Clientes - Documentación Técnica

## 📋 Descripción General

El sistema de papelera implementa una funcionalidad de **"soft delete"** (eliminación suave) que permite a los usuarios eliminar clientes de forma segura, con la posibilidad de restaurarlos posteriormente o eliminarlos de forma permanente.

## 🏗️ Arquitectura del Sistema

### Estructura de Datos

#### Colección Principal: `clientes`
- Contiene todos los clientes activos
- Estructura normal sin campos de eliminación

#### Colección de Papelera: `papelera_clientes`
- Contiene clientes eliminados temporalmente
- Incluye campos adicionales:
  - `eliminado: true` - Marca de eliminación
  - `fechaEliminacion: Timestamp` - Cuándo fue eliminado
  - `idOriginal: String` - ID original del documento
  - `terapeutaUid: String` - Mantiene la seguridad multi-usuario

## 🔧 Componentes del Sistema

### 1. PapeleraService (`lib/services/papelera_service.dart`)

#### Métodos Principales:

**`moverClienteAPapelera(String clienteId)`**
- Mueve un cliente de la colección principal a la papelera
- Añade metadatos de eliminación
- Mantiene la seguridad por usuario

**`getClientesEnPapelera()`**
- Obtiene todos los clientes eliminados del usuario actual
- Ordenados por fecha de eliminación (más recientes primero)

**`restaurarCliente(String clienteId)`**
- Restaura un cliente desde la papelera a la colección principal
- Elimina metadatos de eliminación
- Operación atómica

**`eliminarClientePermanentemente(String clienteId)`**
- Elimina definitivamente un cliente de la papelera
- Acción irreversible

**`vaciarPapelera()`**
- Elimina todos los clientes del usuario de la papelera
- Utiliza batch operations para eficiencia

**`limpiarPapeleraAutomatica(int diasLimite)`**
- Limpieza automática de elementos antiguos
- Por defecto elimina elementos después de 30 días

**`getEstadisticasPapelera()`**
- Estadísticas: total, esta semana, este mes

### 2. PantallaPapeleraClientes (`lib/screens/pantalla_papelera_clientes.dart`)

#### Características de la UI:

**Pantalla Principal:**
- Lista de clientes eliminados con información completa
- Estadísticas visuales en la parte superior
- Indicadores de tiempo relativo (ayer, hace X días)

**Acciones por Cliente:**
- 🔄 **Restaurar**: Vuelve el cliente a la lista principal
- 🗑️ **Eliminar permanentemente**: Eliminación definitiva

**Selección Múltiple:**
- Checkbox para seleccionar múltiples clientes
- Acciones masivas (restaurar/eliminar múltiples)
- Contador de elementos seleccionados

**Menú de Opciones:**
- Vaciar papelera completa
- Alternar modo selección múltiple

**Confirmaciones de Seguridad:**
- Diálogos de confirmación para acciones irreversibles
- Diferente color/texto según la gravedad de la acción

### 3. Integración con Pantalla de Clientes

#### Modificaciones en `pantalla_ver_clientes.dart`:

**Función de Eliminación Actualizada:**
```dart
void _eliminarCliente(BuildContext context, String id) async {
  // Confirmación con diálogo personalizado
  // Uso de PapeleraService.moverClienteAPapelera()
  // SnackBar con acción para ver papelera
}
```

**AppBar Mejorado:**
- Icono de papelera en la barra superior
- Acceso directo a la pantalla de papelera

### 4. Menú Principal Ampliado

#### Nuevo botón en `pantalla_menu_terapeuta.dart`:
- **"Papelera de Clientes"** con icono distintivo
- Color naranja para diferenciarse de otras acciones
- Acceso directo desde el menú principal

## 🔒 Seguridad y Permisos

### Multi-Usuario:
- Cada usuario solo puede ver/gestionar sus propios clientes eliminados
- Filtrado por `terapeutaUid` en todas las operaciones
- Verificación de permisos antes de cada acción

### Validaciones:
- Usuario autenticado requerido
- Verificación de propiedad antes de operaciones
- Manejo de errores robusto

## 📊 Estadísticas y Métricas

### Panel de Estadísticas:
- **Total**: Número total de clientes en papelera
- **Esta semana**: Clientes eliminados en los últimos 7 días  
- **Este mes**: Clientes eliminados en el mes actual

### Indicadores Visuales:
- Códigos de color para diferentes estados
- Iconografía intuitiva (🔄 restaurar, 🗑️ eliminar)
- Fechas relativas para mejor UX

## 🔄 Flujo de Trabajo

### Eliminación de Cliente:
1. Usuario presiona "Eliminar" en la lista de clientes
2. Aparece diálogo: "Mover a Papelera" 
3. Confirmación → Cliente se mueve a papelera
4. SnackBar confirma acción con enlace a papelera

### Gestión de Papelera:
1. Acceso desde menú principal o icono en lista de clientes
2. Vista de todos los clientes eliminados
3. Opciones individuales o masivas
4. Confirmaciones diferenciadas por gravedad

### Restauración:
1. Seleccionar cliente en papelera
2. Presionar icono de restaurar
3. Confirmación simple → Cliente vuelve a lista activa

### Eliminación Permanente:
1. Seleccionar cliente en papelera  
2. Presionar icono de eliminar permanentemente
3. **Confirmación crítica** → Eliminación irreversible

## ⚡ Optimizaciones

### Rendimiento:
- Uso de `StreamBuilder` para actualizaciones en tiempo real
- Batch operations para acciones múltiples
- Índices de Firestore optimizados por `terapeutaUid`

### UX:
- Indicadores de carga
- Feedback inmediato en todas las acciones
- Navegación intuitiva entre pantallas
- Colores semánticos (verde=restaurar, rojo=eliminar)

## 🛠️ Configuración y Mantenimiento

### Limpieza Automática:
```dart
// Configurar limpieza automática cada X días
await PapeleraService.limpiarPapeleraAutomatica(diasLimite: 30);
```

### Índices de Firestore Necesarios:
```
Collection: papelera_clientes
- terapeutaUid (Ascending)
- fechaEliminacion (Descending)
```

## 🎯 Beneficios del Sistema

### Para el Usuario:
- **Seguridad**: Recuperación de eliminaciones accidentales
- **Control**: Gestión granular de datos eliminados
- **Transparencia**: Visibilidad completa de elementos eliminados

### Para el Negocio:
- **Confianza**: Los usuarios pueden eliminar sin temor
- **Cumplimiento**: Auditoría de eliminaciones
- **Eficiencia**: Gestión organizada de datos

### Técnicos:
- **Escalabilidad**: Arquitectura preparada para crecimiento
- **Mantenibilidad**: Código modular y documentado
- **Seguridad**: Permisos robustos por usuario

## 🚀 Uso del Sistema

### Para Probar:
1. Eliminar un cliente desde la lista principal
2. Verificar que aparece en la papelera
3. Restaurar o eliminar permanentemente según necesidad
4. Usar selección múltiple para operaciones en lote

### Casos de Uso Comunes:
- **Eliminación accidental**: Restaurar inmediatamente
- **Limpieza periódica**: Usar "Vaciar papelera" mensualmente
- **Auditoría**: Revisar estadísticas y fechas de eliminación
- **Gestión masiva**: Selección múltiple para lotes grandes

---

## ✅ Estado Actual

- ✅ **Servicio de papelera completo y funcional**
- ✅ **Interfaz de usuario intuitiva y completa**  
- ✅ **Integración con sistema existente de clientes**
- ✅ **Seguridad multi-usuario implementada**
- ✅ **Estadísticas y métricas operativas**
- ✅ **Documentación técnica completa**

El sistema está **100% operativo** y listo para uso en producción. 🎉
