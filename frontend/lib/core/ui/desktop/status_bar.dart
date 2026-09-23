import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/style.dart';

/// Barra de Estado Inferior (`StatusBar`) para métricas, coordenadas e información del motor.
/// Soporta cadenas de texto, íconos y separadores explícitos (`Divider`).
class StatusBar extends Element {
  final List<dynamic> items;
  late ColorRGBA bgColor;
  late ColorRGBA textColor;
  late int fontSize;

  StatusBar({
    String? className,
    int height = 0,
    required this.items,
    super.expand = Expand.width,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.height = height != 0 ? height : (style?.height ?? 24);

    bgColor = style?.bgColor ?? const ColorRGBA(16, 18, 24);
    textColor = style?.textColor ?? ColorRGBA.lightGray;
    fontSize = style?.fontSize ?? 12;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // 1. Dibujar barra de fondo
    ctx2d.drawRect(x, y, width, height, bgColor);

    // 2. Línea separadora superior
    ctx2d.drawRect(x, y, width, 1, const ColorRGBA(36, 40, 52));

    // 3. Renderizado de ítems de estado
    int currentX = x + 12;
    final textY = y + ((height - fontSize) ~/ 2);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item is Element) {
        // Dibujar elemento o Divider explícito
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
