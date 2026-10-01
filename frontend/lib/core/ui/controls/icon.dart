import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente gráfico para renderizar un ícono (`Icon`) bajo la arquitectura `ControlNode`.
class Icon extends ControlNode {
  final IconData icon;
  final int size;
  final ColorRGBA? color;

  Icon(
    this.icon, {
    super.key,
    super.isVisible,
    super.className,
    super.isEnabled,
    this.size = 16,
    this.color,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final style = currentStyle;
    final iconSize = style.fontSize ?? size;
    width = style.width ?? iconSize;
    height = style.height ?? iconSize;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final iconSize = style.fontSize ?? size;
    final iconColor = color ??
        style.textColor ??
        (isEnabled ? ColorRGBA.white : const ColorRGBA(140, 145, 155, 180));

    ctx2d.drawText(icon.glyph, x, y, iconSize, iconColor);
  }
}
