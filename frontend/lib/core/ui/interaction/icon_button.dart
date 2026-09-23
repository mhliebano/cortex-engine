import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/icons.dart';

import 'package:cortex/core/ui/style.dart';

enum IconButtonVariant { standard, filled, tonal, outlined }

/// Componente de Botón de Ícono (`IconButton`).
///
/// Soporta íconos independientes, botones de alternancia (*Toggle Icon Button*),
/// variantes visuales y estados de interacción (hover, pressed, selected, disabled).
class IconButton extends Element {
  final IconData icon;
  final IconData? selectedIcon;
  final IconButtonVariant variant;
  final bool isToggle;
  bool isSelected;
  bool enabled;
  final void Function(bool selected)? onToggle;
  final void Function()? onPressed;

  final int iconSize;
  late ColorRGBA? customColor;

  bool _isHovered = false;
  bool _isPressed = false;

  IconButton({
    String? className,
    required this.icon,
    this.selectedIcon,
    this.variant = IconButtonVariant.standard,
    this.isToggle = false,
    this.isSelected = false,
    this.enabled = true,
    this.onToggle,
    this.onPressed,
    int size = 40,
    this.iconSize = 20,
  }) : super(width: size, height: size) {
    final style = className != null ? Style.merge(className) : null;
    customColor = style?.textColor;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) {
      _isHovered = false;
      _isPressed = false;
      return;
    }

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
        if (isToggle) {
          isSelected = !isSelected;
          onToggle?.call(isSelected);
        }
        onPressed?.call();
      } else if (input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = true;
      } else {
        _isPressed = false;
      }
    } else {
      _isPressed = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final IconData activeIcon = (isToggle && isSelected && selectedIcon != null)
        ? selectedIcon!
        : icon;

    ColorRGBA bg;
    ColorRGBA fg;
    ColorRGBA border = ColorRGBA.transparent;
    const double roundness = 0.5; // Forma circular / cápsula

    if (!enabled) {
      bg = variant == IconButtonVariant.standard
          ? ColorRGBA.transparent
          : const ColorRGBA(60, 64, 72, 80);
      fg = const ColorRGBA(140, 145, 155, 150);
    } else {
      switch (variant) {
        case IconButtonVariant.standard:
          bg = _isPressed
              ? const ColorRGBA(255, 255, 255, 35)
              : _isHovered
              ? const ColorRGBA(255, 255, 255, 18)
              : ColorRGBA.transparent;
          fg = isSelected
              ? const ColorRGBA(52, 152, 219)
              : (customColor ?? const ColorRGBA(220, 225, 235));
          break;

        case IconButtonVariant.filled:
          final bool active = isToggle ? isSelected : true;
          bg = _isPressed
              ? const ColorRGBA(31, 105, 155)
              : _isHovered
              ? const ColorRGBA(52, 152, 219)
              : (active
                    ? const ColorRGBA(41, 128, 185)
                    : const ColorRGBA(45, 50, 60));
          fg = active ? ColorRGBA.white : const ColorRGBA(180, 190, 205);
          break;

        case IconButtonVariant.tonal:
          bg = _isPressed
              ? const ColorRGBA(45, 75, 100)
              : _isHovered
              ? const ColorRGBA(55, 95, 125)
              : (isSelected
                    ? const ColorRGBA(40, 80, 110)
                    : const ColorRGBA(35, 42, 54));
          fg = isSelected
              ? const ColorRGBA(130, 200, 255)
              : const ColorRGBA(190, 200, 215);
          break;

        case IconButtonVariant.outlined:
          bg = _isPressed
              ? const ColorRGBA(52, 152, 219, 40)
              : _isHovered
              ? const ColorRGBA(52, 152, 219, 20)
              : (isSelected
                    ? const ColorRGBA(41, 128, 185, 30)
                    : ColorRGBA.transparent);
          fg = isSelected
              ? const ColorRGBA(100, 180, 240)
              : const ColorRGBA(200, 210, 225);
          border = _isHovered || isSelected
              ? const ColorRGBA(52, 152, 219)
              : const ColorRGBA(75, 85, 100);
          break;
      }
    }

    // 1. Dibujar contenedor de fondo
    if (bg.a > 0) {
      ctx2d.drawRoundRect(x, y, width, height, roundness, color: bg);
    }

    // 2. Dibujar contorno si aplica
    if (border.a > 0) {
      ctx2d.drawRoundRectLines(
        x,
        y,
        width,
        height,
        roundness,
        lineThick: 1.2,
        color: border,
      );
    }

    // 3. Renderizar ícono centrado
    final int iconX = x + (width - iconSize) ~/ 2;
    final int iconY = y + (height - iconSize) ~/ 2;

    ctx2d.drawText(activeIcon.glyph, iconX, iconY, iconSize, fg);
  }
}
