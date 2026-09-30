import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/style.dart';
import 'package:frontend/wrappers/graphics2d.dart';
/// Componente interactivo de Botón (`Button`) bajo la arquitectura `ControlNode`.
class Button extends ControlNode {
  String text;
  VoidCallback? onClick;
  bool isPressed;

  Button({
    super.key,
    super.isVisible,
    super.className,
    super.isEnabled,
    required this.text,
    this.onClick,
    this.isPressed = false,
  }) {
    _updateDimensions();
  }

  @override
  Style get currentStyle {
    if (className == null || className!.trim().isEmpty) {
      return const Style();
    }

    final classes = className!.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered) buffer.add('$cls:hover');
      if (isPressed) buffer.add('$cls:active');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return Style.merge(buffer.join(' '));
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);

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
        onClick?.call();
      } else if (input.isMouseButtonDown(MouseButtons.left)) {
        isPressed = true;
      } else {
        isPressed = false;
      }
    } else {
      isPressed = false;
    }
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
    final fontSize = style.fontSize ?? 14;
    final padding =
        style.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    final textWidth = _measureTextWidth(text, fontSize);
    final minW = style.width ?? (textWidth + padding.left + padding.right).round();
    final minH = style.height ?? (fontSize + padding.top + padding.bottom).round();

    if (width < minW) {
      width = minW;
    }

    if (height < minH) {
      height = minH;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;

    // 1. Resolver colores visuales (Estilo asignado o Fallback por defecto)
    ColorRGBA bgColor;
    ColorRGBA textColor;
    ColorRGBA? borderColor;

    if (!isEnabled) {
      bgColor = style.bgColor ?? const ColorRGBA(60, 64, 72, 180);
      textColor = style.textColor ?? const ColorRGBA(140, 145, 155, 180);
      borderColor = style.borderColor;
    } else if (isPressed) {
      bgColor = style.activeColor ??
          style.hoverColor ??
          (style.bgColor != null
              ? ColorRGBA(
                  (style.bgColor!.r * 0.75).round(),
                  (style.bgColor!.g * 0.75).round(),
                  (style.bgColor!.b * 0.75).round(),
                  style.bgColor!.a,
                )
              : const ColorRGBA(31, 105, 155));
      textColor = style.textColor ?? ColorRGBA.white;
      borderColor = style.borderColor ?? const ColorRGBA(255, 255, 255, 140);
    } else if (isHovered) {
      bgColor = style.hoverColor ??
          (style.bgColor != null
              ? ColorRGBA(
                  (style.bgColor!.r * 1.2).clamp(0, 255).round(),
                  (style.bgColor!.g * 1.2).clamp(0, 255).round(),
                  (style.bgColor!.b * 1.2).clamp(0, 255).round(),
                  style.bgColor!.a,
                )
              : const ColorRGBA(52, 152, 219));
      textColor = style.textColor ?? ColorRGBA.white;
      borderColor = style.borderColor ?? const ColorRGBA(255, 255, 255, 180);
    } else {
      bgColor = style.bgColor ?? const ColorRGBA(41, 128, 185);
      textColor = style.textColor ?? ColorRGBA.white;
      borderColor = style.borderColor ?? const ColorRGBA(255, 255, 255, 60);
    }

    final borderRadius = style.borderRadius ?? 6.0;
    final roundness = (borderRadius > 1.0
            ? borderRadius / (height > 0 ? height : 1)
            : borderRadius)
        .clamp(0.0, 1.0);

    // 2. Fondo del Botón (idéntico al modelo de Chip con drawRoundRect)
    if (bgColor.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRect(x, y, width, height, roundness, color: bgColor);
      } else {
        ctx2d.drawRect(x, y, width, height, bgColor);
      }
    }

    // 3. Borde del Botón (idéntico al modelo de Chip con drawRoundRectLines)
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

    // 4. Texto centrado horizontal y verticalmente
    final textWidth = ctx2d.measureText(text, fontSize);
    final textX = (x + (width - textWidth) / 2).round();
    final textY = (y + (height - fontSize) / 2).round();

    ctx2d.drawText(text, textX, textY, fontSize, textColor);
  }
}
