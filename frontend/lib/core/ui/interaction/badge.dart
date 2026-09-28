import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/style.dart';

/// Componente de Insignia / Indicador (`Badge`).
///
/// Soporta dos estilos visuales:
/// 1. **Dot Indicator (Insignia Pequeña)**: Cuando `label` es nulo o vacío. Muestra un punto circular discreto.
/// 2. **Numeric/Label Badge (Insignia Grande)**: Cuando contiene texto (ej. `"5"`, `"99+"`, `"NUEVO"`). Muestra una cápsula pill redondeada.
///
/// Puede ser usado de forma independiente o envolviendo un componente ancla (`child`),
/// superponiéndose automáticamente en la esquina superior derecha del ancla.
class Badge extends Element {
  final Element? child;
  final String? label;
  late ColorRGBA bgColor;
  late ColorRGBA textColor;
  final int offsetX;
  final int offsetY;
  Badge({
    String? className,
    this.child,
    this.label,
    ColorRGBA? bgColor,
    ColorRGBA? textColor,
    this.offsetX = 0,
    this.offsetY = 0,
    super.isVisible = true,
    super.width,
    super.height,
  }) : super() {
    final style = className != null ? Style.merge(className) : null;
    this.bgColor = bgColor ?? style?.bgColor ?? const ColorRGBA(228, 77, 61);
    this.textColor = textColor ?? style?.textColor ?? ColorRGBA.white;
    if (child != null) {
      width = child!.width;
      height = child!.height;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (child != null) {
      child!.x = x;
      child!.y = y;
      child!.onUpdate(dt, input);
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    if (child != null) {
      child!.onResize(allocatedWidth, allocatedHeight);
      width = child!.width;
      height = child!.height;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    // 1. Renderizar el componente hijo ancla primero (si existe)
    if (child != null) {
      child!.x = x;
      child!.y = y;
      child!.onRender(ctx2d, ctx3d);
    }

    if (!isVisible) return;

    final isDot = label == null || label!.isEmpty;

    if (isDot) {
      // Small Dot Badge (8px diameter)
      const double radius = 4.0;
      final int cx = child != null ? (x + child!.width - 2 + offsetX) : (x + 4);
      final int cy = child != null ? (y + 2 + offsetY) : (y + 4);

      ctx2d.drawCircle(cx, cy, radius, bgColor);
    } else {
      // Large Badge (Pill shape with label/number)
      final String text = label!;
      const int badgeHeight = 16;
      final int textWidth = text.length * 7;
      final int badgeWidth = (textWidth + 8) < 16 ? 16 : (textWidth + 8);

      final int bx = child != null
          ? (x + child!.width - (badgeWidth ~/ 2) + offsetX)
          : x;
      final int by = child != null ? (y - (badgeHeight ~/ 3) + offsetY) : y;

      // Render Pill (Rounded Rect with roundness 0.5)
      ctx2d.drawRoundRect(bx, by, badgeWidth, badgeHeight, 0.5, color: bgColor);

      // Centrar texto del Badge
      final int textX = bx + ((badgeWidth - textWidth) ~/ 2);
      final int textY = by + 2;

      ctx2d.drawText(text, textX, textY, 11, textColor);
    }
  }
}
