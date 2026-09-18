/// Controlador de estado reactivo para campos de texto (`TextField`).
/// Permite lectura/escritura bidireccional de texto y notificación de cambios mediante listeners.
class TextEditingController {
  String _text;
  final List<void Function(String text)> _listeners = [];

  // ignore: prefer_initializing_formals
  TextEditingController({String text = ''}) : _text = text;

  /// Obtiene el texto actual almacenado.
  String get text => _text;

  /// Establece un nuevo valor de texto y notifica a los suscriptores si el valor cambia.
  set text(String value) {
    if (_text != value) {
      _text = value;
      notifyListeners();
    }
  }

  /// Suscribe una función callback que se ejecutará cada vez que el texto cambie.
  void addListener(void Function(String text) listener) {
    _listeners.add(listener);
  }

  /// Desuscribe una función callback previamente registrada.
  void removeListener(void Function(String text) listener) {
    _listeners.remove(listener);
  }

  /// Notifica manualmente a todos los suscriptores registrados.
  void notifyListeners() {
    for (final listener in List.from(_listeners)) {
      listener(_text);
    }
  }

  /// Limpia el contenido del campo de texto.
  void clear() {
    text = '';
  }
}
