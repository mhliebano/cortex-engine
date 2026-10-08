import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente de Ficha o Etiqueta Compacta con Modelo de Caja (`Chip`).
class Chip extends ControlNode {
  String text;

  Chip({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    required this.text,
  }) {
    _updateDimensions();
  }

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

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final padding =
        layout.padding ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final textWidth = _measureTextWidth(text, fontSize);
    final minW = (textWidth + padding.left + padding.right).round();
    final minH = (fontSize + padding.top + padding.bottom).round();

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

  void _updateDimensions() {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final padding =
        layout.padding ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final textWidth = _measureTextWidth(text, fontSize);
    final textHeight = fontSize;
    final minW = (textWidth + padding.left + padding.right).round();
    final minH = (textHeight + padding.top + padding.bottom).round();

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
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;
    final bgColor = style.bgColor;
    final borderColor = style.borderColor;
    final borderRadius = style.borderRadius ?? 0.0;
    final textColor = style.textColor ?? ColorRGBA.white;

    final roundness =
        (borderRadius > 1.0
                ? borderRadius / (height > 0 ? height : 1)
                : borderRadius)
            .clamp(0.0, 1.0);

    // 1. Fondo
    if (bgColor != null && bgColor.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRect(x, y, width, height, roundness, color: bgColor);
      } else {
        ctx2d.drawRect(x, y, width, height, bgColor);
      }
    }

    // 2. Borde
    if (borderColor != null && borderColor.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRectLines(
          x,
          y,
          width,
          height,
          roundness,
          color: borderColor,
        );
      } else {
        ctx2d.drawRect(x, y, width, 1, borderColor);
        ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
        ctx2d.drawRect(x, y, 1, height, borderColor);
        ctx2d.drawRect(x + width - 1, y, 1, height, borderColor);
      }
    }

    // 3. Texto centrado horizontal y verticalmente dentro del Chip
    final textWidth = ctx2d.measureText(text, fontSize);
    final textHeight = fontSize;

    final textX = (x + (width - textWidth) / 2).round();
    final textY = (y + (height - textHeight) / 2).round();

    ctx2d.drawText(text, textX, textY, fontSize, textColor);
  }
}
