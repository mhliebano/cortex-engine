import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/ui/style.dart';

/// Registra todas las Clases CSS de la Aplicación en el registro global de estilos.
void initAppStyles() {
  // Encabezados y Etiquetas
  Style.register('panel-1', const Style(bgColor: ColorRGBA(255, 255, 255)));
  Style.register('panel-2', const Style(bgColor: ColorRGBA(255, 0, 255)));
  Style.register('panel-3', const Style(bgColor: ColorRGBA(0, 255, 255)));
  Style.register('panel-4', const Style(bgColor: ColorRGBA(255, 255, 0)));
}
