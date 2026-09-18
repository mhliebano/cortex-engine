import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';

import 'package:cortex/engine/ui/style.dart';

/// Componente gráfico para renderizar un ícono (`Icon`).
class Icon extends Element {
  final IconData icon;
  final int size;
  late ColorRGBA color;

  Icon(
    this.icon, {
    String? className,
    this.size = 16,
    ColorRGBA? color,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.color = color ?? style?.textColor ?? ColorRGBA.white;
    width = size;
    height = size;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    ctx2d.drawText(icon.glyph, x, y, size, color);
  }
}
