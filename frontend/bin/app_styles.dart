import 'package:frontend/core/ui/style.dart';
import 'package:frontend/cortex.dart';

/// Registra todas las Clases CSS de la Aplicación en el registro global de estilos.
void initAppStyles() {
  // Encabezados y Etiquetas
  Style.register(
    'text-h1',
    const Style(fontSize: 52, textColor: ColorRGBA.accentBlue),
  );
  Style.register(
    'text',
    const Style(fontSize: 16, textColor: ColorRGBA(255, 0, 0, 255)),
  );
  Style.register(
    'chip-class',
    const Style(
      fontSize: 12,
      textColor: ColorRGBA.accentBlue,
      bgColor: ColorRGBA.white,
      borderRadius: 25,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderColor: ColorRGBA(255, 0, 0),
    ),
  );
}
