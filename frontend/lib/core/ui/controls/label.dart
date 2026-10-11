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
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    required this.text,
  }) {
    _updateDimensions();
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    final fs = currentStyle.fontSize ?? 14;
    final minW = (text.length * (fs * 0.55)).round();
    final minH = (fs * 1.2).round();

    final layout = currentLayout;
    int requestedWidth;
    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        requestedWidth = maxWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        requestedWidth = (maxWidth * wRule).round();
      } else if (wRule.isFinite) {
        requestedWidth = wRule.round();
      } else {
        requestedWidth = minW;
      }
    } else {
      requestedWidth = minW;
    }

    int requestedHeight;
    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        requestedHeight = maxHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        requestedHeight = (maxHeight * hRule).round();
      } else if (hRule.isFinite) {
        requestedHeight = hRule.round();
      } else {
        requestedHeight = minH;
      }
    } else {
      requestedHeight = minH;
    }

    width = (maxWidth > 0 && requestedWidth > maxWidth) ? maxWidth : requestedWidth;
    height = (maxHeight > 0 && requestedHeight > maxHeight) ? maxHeight : requestedHeight;
  }

  void _updateDimensions() {
    final fs = currentStyle.fontSize ?? 14;
    final minW = text.length * (fs ~/ 2);
    final minH = fs + 6;

    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth) {
      width = minW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight) {
      height = minH;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    final fontSize = currentStyle.fontSize ?? 14;
    final color = currentStyle.textColor ?? ColorRGBA.white;
    ctx2d.drawText(text, x, y, fontSize, color);
  }
}
