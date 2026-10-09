import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';

/// Orientación del divisor (`DividerAxis`).
enum DividerAxis { horizontal, vertical }

/// Componente Divisor / Separador (`Divider`) bajo la arquitectura Cortex.
///
/// Dibuja una línea fina separatoria horizontal o vertical con soporte para sangrías ([indent], [endIndent])
/// y expansión geométrica automática en el eje correspondiente.
class Divider extends ControlNode {
  final DividerAxis axis;
  final int indent;
  final int endIndent;

  Divider({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.axis = DividerAxis.horizontal,
    this.indent = 0,
    this.endIndent = 0,
  }) {
    _updateDimensions();
  }

  @override
  bool get isFlexWidth =>
      axis == DividerAxis.horizontal ? true : super.isFlexWidth;

  @override
  bool get isFlexHeight =>
      axis == DividerAxis.vertical ? true : super.isFlexHeight;

  void _updateDimensions() {
    final layout = currentLayout;
    const thickness = 1;

    if (axis == DividerAxis.horizontal) {
      const minH = thickness + 8;
      final hRule = layout.height;
      if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
        height = hRule.round();
      } else if (!isFlexHeight) {
        if (height < minH) height = minH;
      }

      final wRule = layout.width;
      if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
        width = wRule.round();
      }
    } else {
      const minW = thickness + 8;
      final wRule = layout.width;
      if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
        width = wRule.round();
      } else if (!isFlexWidth) {
        if (width < minW) width = minW;
      }

      final hRule = layout.height;
      if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
        height = hRule.round();
      }
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final layout = currentLayout;
    const thickness = 1;

    if (axis == DividerAxis.horizontal) {
      const minH = thickness + 8;
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
        width = allocatedWidth > 0 ? allocatedWidth : 10;
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
        height = allocatedHeight > 0 ? allocatedHeight : minH;
      }
    } else {
      const minW = thickness + 8;
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
        height = allocatedHeight > 0 ? allocatedHeight : 10;
      }

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
        width = allocatedWidth > 0 ? allocatedWidth : minW;
      }
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _updateDimensions();
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0 || height <= 0) return;
    _updateDimensions();

    final style = currentStyle;
    final ColorRGBA color = style.borderColor ??
        style.bgColor ??
        const ColorRGBA(50, 60, 75, 180);

    const thickness = 1;

    if (axis == DividerAxis.horizontal) {
      final lineY = y + (height ~/ 2) - (thickness ~/ 2);
      final lineX = x + indent;
      final lineW = width > (indent + endIndent)
          ? width - (indent + endIndent)
          : 0;
      if (lineW > 0) {
        ctx2d.drawRect(lineX, lineY, lineW, thickness, color);
      }
    } else {
      final lineX = x + (width ~/ 2) - (thickness ~/ 2);
      final lineY = y + indent;
      final lineH = height > (indent + endIndent)
          ? height - (indent + endIndent)
          : 0;
      if (lineH > 0) {
        ctx2d.drawRect(lineX, lineY, thickness, lineH, color);
      }
    }
  }
}
