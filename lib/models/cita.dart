class Cita {
  final String nombre;
  final String correo;
  final String telefono;
  final DateTime fecha;
  final String hora;
  final String tipoMasaje;
  final String terapeuta;
  final int duracionMinutos; // Nueva propiedad para duración en minutos

  Cita({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.fecha,
    required this.hora,
    required this.tipoMasaje,
    required this.terapeuta,
    this.duracionMinutos = 60, // Duración por defecto de 60 minutos
  });

  // Método para calcular la hora de finalización
  String get horaFinalizacion {
    try {
      final partesHora = hora.split(':');
      final horaInicio = int.parse(partesHora[0]);
      final minutoInicio = int.parse(partesHora[1]);
      
      final totalMinutos = (horaInicio * 60) + minutoInicio + duracionMinutos;
      final horaFin = totalMinutos ~/ 60;
      final minutoFin = totalMinutos % 60;
      
      return '${horaFin.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';
    } catch (e) {
      return hora; // Si hay error, devolver la hora original
    }
  }
}
