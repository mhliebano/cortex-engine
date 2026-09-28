import 'package:frontend/core/ui/style.dart';

/// Registra todas las Clases CSS de la Aplicación en el registro global de estilos.
void initAppStyles() {
  // Encabezados y Etiquetas
  Style.register('text-h1', const Style(fontSize: 52));
  Style.register('text', const Style(fontSize: 16));
}
