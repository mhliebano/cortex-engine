import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/style_rules.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente de Casilla de Verificación (`Checkbox`) bajo la arquitectura Cortex.
///
/// Soporta 3 estados de selección:
/// 1. **`true`** (Marcado - Checkmark `✓`)
/// 2. **`false`** (Desmarcado - Vacío)
/// 3. **`null`** (Indeterminado - Guión `-`)
class Checkbox extends ControlNode {
  bool? value;
  final String? label;
  final void Function(bool? value)? onChanged;
  bool isPressed;

  Checkbox({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.value = false,
    this.label,
    this.onChanged,
    this.isPressed = false,
  }) {
    _updateDimensions();
  }

  @override
  StyleRules get currentStyle {
    final raw = styleClass;
    if (raw == null || raw.trim().isEmpty) {
      return const StyleRules();
    }

    final classes = raw.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered) buffer.add('$cls:hover');
      if (isPressed) buffer.add('$cls:active');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return StyleRules.merge(buffer.join(' '));
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

  void _updateDimensions() {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    const boxSize = 20;
    int minW = boxSize + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (boxSize > fontSize ? boxSize : fontSize) +
        pad.top.round() +
        pad.bottom.round();

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

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    const boxSize = 20;
    int minW = boxSize + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (boxSize > fontSize ? boxSize : fontSize) +
        pad.top.round() +
        pad.bottom.round();

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

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !isEnabled) {
      isHovered = false;
      isPressed = false;
      return;
    }

    _updateDimensions();

    isHovered = input.isHovering(x, y, width, height);

    if (isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        isPressed = true;
      }
      if (isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        isPressed = false;
        final nextValue = value == true ? false : true;
        value = nextValue;
        onChanged?.call(value);
      }
    } else {
      isPressed = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;
    const boxSize = 20;

    final isChecked = value == true;
    final isIndeterminate = value == null;

    final ColorRGBA activeColor = style.activeColor ??
        style.hoverColor ??
        style.bgColor ??
        const ColorRGBA(41, 128, 185);
    final ColorRGBA checkColor = style.textColor ?? ColorRGBA.white;

    // 1. Color del cuadro según estado
    final ColorRGBA currentBg;
    final ColorRGBA currentBorder;

    if (!isEnabled) {
      currentBg = isChecked || isIndeterminate
          ? const ColorRGBA(80, 90, 110)
          : const ColorRGBA(25, 30, 40);
      currentBorder = const ColorRGBA(50, 55, 65);
    } else if (isChecked || isIndeterminate) {
      currentBg = isPressed
          ? ColorRGBA((activeColor.r * 0.8).round(),
              (activeColor.g * 0.8).round(), (activeColor.b * 0.8).round())
          : (isHovered
              ? ColorRGBA(
                  (activeColor.r * 1.15).clamp(0, 255).round(),
                  (activeColor.g * 1.15).clamp(0, 255).round(),
                  (activeColor.b * 1.15).clamp(0, 255).round())
              : activeColor);
      currentBorder = style.borderColor ?? currentBg;
    } else {
      currentBg = isHovered
          ? (style.hoverColor ?? const ColorRGBA(45, 52, 68))
          : (style.bgColor ?? const ColorRGBA(32, 38, 50));
      currentBorder = isHovered
          ? (style.borderColor ?? const ColorRGBA(52, 152, 219))
          : (style.borderColor ?? const ColorRGBA(70, 80, 100));
    }

    final boxY = y + ((height - boxSize) ~/ 2);
    final borderRadius = style.borderRadius ?? 4.0;
    final roundness = (borderRadius / boxSize).clamp(0.0, 1.0);

    // 2. Dibujar casilla cuadrada redondeada
    if (roundness > 0) {
      ctx2d.drawRoundRect(x, boxY, boxSize, boxSize, roundness,
          color: currentBg);
      ctx2d.drawRoundRectLines(x, boxY, boxSize, boxSize, roundness,
          color: currentBorder);
    } else {
      ctx2d.drawRect(x, boxY, boxSize, boxSize, currentBg);
      ctx2d.drawRect(x, boxY, boxSize, 1, currentBorder);
      ctx2d.drawRect(x, boxY + boxSize - 1, boxSize, 1, currentBorder);
      ctx2d.drawRect(x, boxY, 1, boxSize, currentBorder);
      ctx2d.drawRect(x + boxSize - 1, boxY, 1, boxSize, currentBorder);
    }

    // 3. Renderizar ícono de marca o guión indeterminado
    if (isChecked) {
      ctx2d.drawText(
          Icons.check.glyph, x + 2, boxY + 2, boxSize - 4, checkColor);
    } else if (isIndeterminate) {
      ctx2d.drawRect(
          x + 4, boxY + (boxSize ~/ 2) - 2, boxSize - 8, 4, checkColor);
    }

    // 4. Renderizar etiqueta de texto acompañante
    if (label != null && label!.isNotEmpty) {
      final labelX = x + boxSize + 8;
      final labelY = y + ((height - fontSize) ~/ 2);
      final textCol = isEnabled
          ? (style.textColor ?? ColorRGBA.white)
          : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label!, labelX, labelY, fontSize, textCol);
    }
  }
}
