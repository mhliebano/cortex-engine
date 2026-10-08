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
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.size = 16,
    this.color,
  }) {
    _updateDimensions();
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final iconSize = style.fontSize ?? size;

    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        width = allocatedWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        width = (allocatedWidth * wRule).round();
      } else if (wRule.isFinite) {
        width = wRule.round();
      }
    } else {
      width = allocatedWidth > 0 ? allocatedWidth : iconSize;
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        height = allocatedHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        height = (allocatedHeight * hRule).round();
      } else if (hRule.isFinite) {
        height = hRule.round();
      }
    } else {
      height = allocatedHeight > 0 ? allocatedHeight : iconSize;
    }
  }

  void _updateDimensions() {
    final style = currentStyle;
    final layout = currentLayout;
    final iconSize = style.fontSize ?? size;

    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth) {
      width = iconSize;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight) {
      height = iconSize;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final iconSize = style.fontSize ?? size;
    final iconColor =
        color ??
        style.textColor ??
        (isEnabled ? ColorRGBA.white : const ColorRGBA(140, 145, 155, 180));

    ctx2d.drawText(icon.glyph, x, y, iconSize, iconColor);
  }
}
