import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/ui/control_node.dart';

/// Primitivo visual puro para la proyección de texto ("tinta sobre pantalla").
///
/// Hereda de [ControlNode] resolviendo dinámicamente sus estilos (`textColor` y `fontSize`)
/// sin implementar modelo de caja, padding ni decoraciones de fondo/borde.
class Label extends ControlNode {
  String text;

  Label({
    super.key,
    super.isVisible,
    super.className,
    super.isEnabled,
    required this.text,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final fs = currentStyle.fontSize ?? 14;
    width = text.length * (fs ~/ 2);
    height = fs + 6;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    final fontSize = currentStyle.fontSize ?? 14;
    final color = currentStyle.textColor ?? ColorRGBA.white;
    ctx2d.drawText(text, x, y, fontSize, color);
  }
}
