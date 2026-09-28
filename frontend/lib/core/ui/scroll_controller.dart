import 'dart:math' as math;

/// Controlador reactivo para contenedores desplazables (`ListView`, `Column`, `Row`).
/// Permite leer/modificar el offset de desplazamiento dinámicamente e interactuar mediante suscriptores.
class ScrollController {
  double _offset;
  final List<void Function(double offset)> _listeners = [];

  ScrollController({double initialOffset = 0.0}) : _offset = math.max(0.0, initialOffset);

  /// Obtiene la posición actual de desplazamiento en píxeles.
  double get offset => _offset;

  /// Modifica la posición de desplazamiento y notifica a los componentes vinculados.
  set offset(double value) {
    final clamped = math.max(0.0, value);
    if ((_offset - clamped).abs() > 0.001) {
      _offset = clamped;
      notifyListeners();
    }
  }

  /// Desplaza la vista a la posición especificada.
  void jumpTo(double value) {
    offset = value;
  }

  /// Registra una función callback que escucha cambios en el desplazamiento.
  void addListener(void Function(double offset) listener) {
    _listeners.add(listener);
  }

  /// Remueve una función callback suscripta.
  void removeListener(void Function(double offset) listener) {
    _listeners.remove(listener);
  }

  /// Notifica a todos los suscriptores.
  void notifyListeners() {
    for (final listener in List.from(_listeners)) {
      listener(_offset);
    }
  }
}
