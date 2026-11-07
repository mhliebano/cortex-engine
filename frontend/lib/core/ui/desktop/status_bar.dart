import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';

/// Barra de Estado Inferior (`StatusBar`) para métricas, coordenadas e información del motor.
/// Soporta cadenas de texto, íconos, componentes hijos y separadores explícitos (`Divider`).
class StatusBar extends ControlNode {
  final List<dynamic> items;

  StatusBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.items,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight && height <= 0) {
      height = 24;
    }
  }

  @override
  bool get isFlexWidth => true;

  @override
  List<CortexNode> get childrenElements =>
      items.whereType<CortexNode>().toList();

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    final hRule = currentLayout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else {
      height = 24;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(16, 18, 24);
    final textColor = style.textColor ?? ColorRGBA.lightGray;
    final fontSize = style.fontSize ?? 12;

    // 1. Dibujar barra de fondo
    ctx2d.drawRect(x, y, width, height, bgColor);

    // 2. Línea separadora superior
    final borderColor = style.borderColor ?? const ColorRGBA(36, 40, 52);
    ctx2d.drawRect(x, y, width, 1, borderColor);

    // 3. Renderizado de ítems de estado
    int currentX = x + 12;
    final textY = y + ((height - fontSize) ~/ 2);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item is CortexNode) {
        item.x = currentX;
        item.y = y + 2;
        item.height = height - 4;
        item.onRender(ctx2d, ctx3d);
        currentX += (item.width > 0 ? item.width : 12) + 8;
      } else {
        final text = item.toString();
        ctx2d.drawText(text, currentX, textY, fontSize, textColor);

        final textWidth = text.length * (fontSize ~/ 2) + 8;
        currentX += textWidth + 12;
      }
    }
  }
}
