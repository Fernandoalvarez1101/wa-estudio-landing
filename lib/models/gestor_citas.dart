import 'cita.dart';

class GestorCitas {
  static final List<Cita> _citas = [];

  static void agregarCita(Cita cita) {
    _citas.add(cita);
  }

  static List<Cita> obtenerCitas() {
    return _citas;
  }

  static void eliminarCita(int index) {
    if (index >= 0 && index < _citas.length) {
      _citas.removeAt(index);
    }
  }

  static void editarCita(int index, Cita nuevaCita) {
    if (index >= 0 && index < _citas.length) {
      _citas[index] = nuevaCita;
    }
  }
}
