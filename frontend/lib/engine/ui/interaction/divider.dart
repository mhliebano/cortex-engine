import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/style.dart';

/// Orientación del divisor (`DividerAxis`).
enum DividerAxis {
  horizontal,
  vertical,
}

/// Componente Divisor / Separador (`Divider`).
/// Dibuja una línea fina separatoria horizontal o vertical con soporte para sangrías (`indent`, `endIndent`)
/// y expansión automática en el eje correspondiente.
class Divider extends Element {
  final DividerAxis axis;
  final int thickness;
  final int indent;
  final int endIndent;
  late ColorRGBA color;

  Divider({
    String? className,
    this.axis = DividerAxis.horizontal,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    int width = 0,
    int height = 0,
    bool? fillWidth,
    bool? fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : super(
          fillWidth: fillWidth ?? (axis == DividerAxis.horizontal),
          fillHeight: fillHeight ?? (axis == DividerAxis.vertical),
        ) {
    final style = className != null ? Style.merge(className) : null;
    color = style?.dividerColor ?? style?.borderColor ?? const ColorRGBA(50, 60, 75);

    if (axis == DividerAxis.horizontal) {
      this.height = height != 0 ? height : (style?.height ?? (thickness + 8));
      this.width = width != 0 ? width : (style?.width ?? 0);
    } else {
      this.width = width != 0 ? width : (style?.width ?? (thickness + 8));
      this.height = height != 0 ? height : (style?.height ?? 0);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {}

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0 || height <= 0) return;

    if (axis == DividerAxis.horizontal) {
      final lineY = y + (height ~/ 2) - (thickness ~/ 2);
      final lineX = x + indent;
      final lineW = width > (indent + endIndent) ? width - (indent + endIndent) : 0;
      if (lineW > 0) {
        ctx2d.drawRect(lineX, lineY, lineW, thickness, color);
      }
    } else {
      final lineX = x + (width ~/ 2) - (thickness ~/ 2);
      final lineY = y + indent;
      final lineH = height > (indent + endIndent) ? height - (indent + endIndent) : 0;
      if (lineH > 0) {
        ctx2d.drawRect(lineX, lineY, thickness, lineH, color);
      }
    }
  }
}
