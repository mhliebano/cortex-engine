import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente de Insignia / Indicador (`Badge`) bajo la arquitectura Cortex.
///
/// Soporta dos estilos visuales:
/// 1. **Dot Indicator**: Cuando [label] es nulo o vacío. Muestra un punto circular discreto.
/// 2. **Numeric/Label Badge**: Cuando contiene texto (ej. `"5"`, `"99+"`, `"NUEVO"`). Muestra una cápsula pill redondeada.
///
/// Puede usarse de forma independiente o envolviendo un componente ancla ([child]),
/// superponiéndose automáticamente en la esquina superior derecha del ancla.
class Badge extends ControlNode {
  final CortexNode? child;
  final String? label;

  Badge({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.child,
    this.label,
  }) {
    _updateDimensions();
  }

  @override
  List<CortexNode> get childrenElements => child == null ? const [] : [child!];

  int _measureTextWidth(String text, int fontSize) {
    if (text.isEmpty) return 0;
    try {
      final w = Graphics2D().measureText(text, fontSize);
      if (w > 0) return w;
    } catch (_) {}
    double totalWidth = 0.0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune).toLowerCase();
      if ('iljft1!| .,:;-/\\()[]\'`"'.contains(char)) {
        totalWidth += fontSize * 0.30;
      } else if ('mw0@#%&'.contains(char)) {
        totalWidth += fontSize * 0.65;
      } else {
        totalWidth += fontSize * 0.48;
      }
    }
    return totalWidth.round();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final style = currentStyle;
    final fontSize = style.fontSize ?? 10;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 1);

    if (child != null) {
      width = child!.width;
      height = child!.height;
    } else {
      final isDot = label == null || label!.isEmpty;
      final int minW;
      final int minH;

      if (isDot) {
        minW = 8;
        minH = 8;
      } else {
        final textW = _measureTextWidth(label!, fontSize);
        minH = (fontSize + pad.top + pad.bottom).round().clamp(14, 50);
        final calculatedW = (textW + pad.left + pad.right).round();
        minW = calculatedW < minH ? minH : calculatedW;
      }

      final wRule = layout.width;
      if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
        width = wRule.round();
      } else if (!isFlexWidth) {
        if (width < minW) width = minW;
      }

      final hRule = layout.height;
      if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
        height = hRule.round();
      } else if (!isFlexHeight) {
        if (height < minH) height = minH;
      }
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    if (child != null) {
      child!.onResize(allocatedWidth, allocatedHeight);
      width = child!.width;
      height = child!.height;
    } else {
      final style = currentStyle;
      final layout = currentLayout;
      final fontSize = style.fontSize ?? 10;
      final pad =
          layout.padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 1);
      final isDot = label == null || label!.isEmpty;

      final int minW;
      final int minH;

      if (isDot) {
        minW = 8;
        minH = 8;
      } else {
        final textW = _measureTextWidth(label!, fontSize);
        minH = (fontSize + pad.top + pad.bottom).round().clamp(14, 50);
        final calculatedW = (textW + pad.left + pad.right).round();
        minW = calculatedW < minH ? minH : calculatedW;
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
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _updateDimensions();

    if (child != null && child!.isVisible) {
      child!.x = x;
      child!.y = y;
      child!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // 1. Renderizar el componente ancla hijo si existe
    if (child != null && child!.isVisible) {
      child!.x = x;
      child!.y = y;
      child!.onRender(ctx2d, ctx3d);
    }

    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 10;
    final bgColor = style.bgColor ?? const ColorRGBA(228, 77, 61);
    final textColor = style.textColor ?? ColorRGBA.white;
    final borderColor = style.borderColor;
    final isDot = label == null || label!.isEmpty;

    if (isDot) {
      final double radius = (style.borderRadius ?? 4.0).clamp(2.0, 20.0);
      final int cx = child != null ? (x + width - 2) : (x + width ~/ 2);
      final int cy = child != null ? (y + 2) : (y + height ~/ 2);

      ctx2d.drawCircle(cx, cy, radius, bgColor);
      if (borderColor != null && borderColor.a > 0) {
        ctx2d.drawCircleLines(cx, cy, radius, borderColor);
      }
    } else {
      final text = label!;
      final textWidth = _measureTextWidth(text, fontSize);
      final pad =
          layout.padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 1);
      final badgeHeight = (fontSize + pad.top + pad.bottom).round().clamp(14, 50);
      final calculatedWidth = (textWidth + pad.left + pad.right).round();
      final badgeWidth =
          calculatedWidth < badgeHeight ? badgeHeight : calculatedWidth;

      final int bx =
          child != null ? (x + width - (badgeWidth ~/ 2)) : x;
      final int by =
          child != null ? (y - (badgeHeight ~/ 3)) : y;

      final double roundness = (style.borderRadius != null
              ? style.borderRadius! / badgeHeight
              : 0.5)
          .clamp(0.0, 1.0);

      // Fondo de la píldora
      ctx2d.drawRoundRect(bx, by, badgeWidth, badgeHeight, roundness,
          color: bgColor);

      // Borde si aplica
      if (borderColor != null && borderColor.a > 0) {
        ctx2d.drawRoundRectLines(bx, by, badgeWidth, badgeHeight, roundness,
            color: borderColor);
      }

      // Texto centrado en la píldora
      final textX = (bx + (badgeWidth - textWidth) / 2).round();
      final textY = (by + (badgeHeight - fontSize) / 2).round();
      ctx2d.drawText(text, textX, textY, fontSize, textColor);
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    if (child != null && child!.isVisible) {
      child!.onRenderOverlay(ctx2d, ctx3d);
    }
    super.onRenderOverlay(ctx2d, ctx3d);
  }
}
