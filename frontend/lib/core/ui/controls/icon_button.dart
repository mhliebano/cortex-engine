import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente interactivo de Botón de Ícono (`IconButton`) bajo la arquitectura `ControlNode`.
class IconButton extends ControlNode {
  final IconData icon;
  final IconData? selectedIcon;
  final bool isToggle;
  bool isSelected;
  bool isPressed;
  final void Function(bool selected)? onToggle;
  final VoidCallback? onClick;
  final int iconSize;

  IconButton({
    required this.icon,
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.selectedIcon,
    this.isToggle = false,
    this.isSelected = false,
    this.isPressed = false,
    this.onToggle,
    this.onClick,
    this.iconSize = 20,
  }) {
    _updateDimensions();
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final size = style.fontSize ?? iconSize;
    final minSize = size + 16;

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
      width = allocatedWidth > 0 ? allocatedWidth : minSize;
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
      height = allocatedHeight > 0 ? allocatedHeight : minSize;
    }
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
        if (isToggle) {
          isSelected = !isSelected;
          onToggle?.call(isSelected);
        }
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

  void _updateDimensions() {
    final style = currentStyle;
    final layout = currentLayout;
    final size = style.fontSize ?? iconSize;
    final minSize = size + 16;

    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth) {
      if (width < minSize) width = minSize;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight) {
      if (height < minSize) height = minSize;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final size = style.fontSize ?? iconSize;
    final IconData activeIcon = (isToggle && isSelected && selectedIcon != null)
        ? selectedIcon!
        : icon;

    // 1. Resolver colores visuales
    ColorRGBA bg;
    ColorRGBA fg;
    ColorRGBA? borderColor;

    if (!isEnabled) {
      bg = style.bgColor ?? const ColorRGBA(60, 64, 72, 80);
      fg = style.textColor ?? const ColorRGBA(140, 145, 155, 150);
      borderColor = style.borderColor;
    } else if (isPressed) {
      bg =
          style.activeColor ??
          style.hoverColor ??
          (style.bgColor != null
              ? ColorRGBA(
                  (style.bgColor!.r * 0.75).round(),
                  (style.bgColor!.g * 0.75).round(),
                  (style.bgColor!.b * 0.75).round(),
                  style.bgColor!.a,
                )
              : const ColorRGBA(255, 255, 255, 35));
      fg = style.textColor ?? ColorRGBA.white;
      borderColor = style.borderColor ?? const ColorRGBA(255, 255, 255, 120);
    } else if (isHovered) {
      bg =
          style.hoverColor ??
          (style.bgColor != null
              ? ColorRGBA(
                  (style.bgColor!.r * 1.2).clamp(0, 255).round(),
                  (style.bgColor!.g * 1.2).clamp(0, 255).round(),
                  (style.bgColor!.b * 1.2).clamp(0, 255).round(),
                  style.bgColor!.a,
                )
              : const ColorRGBA(255, 255, 255, 18));
      fg = style.textColor ?? ColorRGBA.white;
      borderColor = style.borderColor ?? const ColorRGBA(255, 255, 255, 180);
    } else {
      bg = style.bgColor ?? ColorRGBA.transparent;
      fg =
          style.textColor ??
          (isSelected
              ? const ColorRGBA(52, 152, 219)
              : const ColorRGBA(220, 225, 235));
      borderColor = style.borderColor;
    }

    final borderRadius = style.borderRadius ?? (height / 2.0);
    final roundness =
        (borderRadius > 1.0
                ? borderRadius / (height > 0 ? height : 1)
                : borderRadius)
            .clamp(0.0, 1.0);

    // 2. Fondo del Botón
    if (bg.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRect(x, y, width, height, roundness, color: bg);
      } else {
        ctx2d.drawRect(x, y, width, height, bg);
      }
    }

    // 3. Borde del Botón
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

    // 4. Ícono centrado
    final iconX = x + (width - size) ~/ 2;
    final iconY = y + (height - size) ~/ 2;

    ctx2d.drawText(activeIcon.glyph, iconX, iconY, size, fg);
  }
}
