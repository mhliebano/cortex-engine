import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Opción de menú para un `SplitButton`.
class SplitMenuItem {
  final String label;
  final IconData? icon;
  final void Function()? onTap;

  const SplitMenuItem({required this.label, this.icon, this.onTap});
}

/// Componente de Botón Dividido (`SplitButton`) bajo la arquitectura `ControlNode`.
///
/// Combina una acción principal izquierda con una flecha desplegable derecha que
/// despliega un menú flotante en `onRenderOverlay()`.
class SplitButton extends ControlNode {
  final String label;
  final IconData? icon;
  final List<SplitMenuItem> options;
  final void Function()? onMainPressed;

  bool _isMainHovered = false;
  bool _isArrowHovered = false;
  bool _isDropdownOpen = false;
  int _hoveredOptionIndex = -1;

  SplitButton({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.label,
    required this.options,
    this.icon,
    this.onMainPressed,
    int? defaultWidth,
    int? defaultHeight,
  }) {
    _updateDimensions(defaultWidth ?? 160, defaultHeight ?? 38);
  }

  void _updateDimensions([int defW = 160, int defH = 38]) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (width <= 0) {
      width = defW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (height <= 0) {
      height = defH;
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (isFlexWidth) {
      width = maxWidth;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled) return;

    const int arrowW = 32;
    final int mainW = width - arrowW;

    _isMainHovered = input.isHovering(x, y, mainW, height);
    _isArrowHovered = input.isHovering(x + mainW, y, arrowW, height);

    if (_isMainHovered && input.isMouseButtonPressed(MouseButtons.left)) {
      _isDropdownOpen = false;
      onMainPressed?.call();
    }

    if (_isArrowHovered && input.isMouseButtonPressed(MouseButtons.left)) {
      _isDropdownOpen = !_isDropdownOpen;
    }

    // Actualizar interacción con el menú desplegable en Overlay
    if (_isDropdownOpen) {
      final int menuWidth = width < 180 ? 180 : width;
      final int menuHeight = options.length * 36 + 10;
      final int menuX = x;
      final int menuY = y + height + 4;

      _hoveredOptionIndex = -1;

      if (input.isHovering(menuX, menuY, menuWidth, menuHeight)) {
        for (int i = 0; i < options.length; i++) {
          final int itemY = menuY + 5 + (i * 36);
          if (input.isHovering(menuX, itemY, menuWidth, 36)) {
            _hoveredOptionIndex = i;
            if (input.isMouseButtonPressed(MouseButtons.left)) {
              _isDropdownOpen = false;
              options[i].onTap?.call();
            }
            break;
          }
        }
      } else if (input.isMouseButtonPressed(MouseButtons.left) && !_isArrowHovered) {
        _isDropdownOpen = false;
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final ColorRGBA bg = style.bgColor ?? const ColorRGBA(41, 128, 185, 255);
    final ColorRGBA fg = style.textColor ?? ColorRGBA.white;

    const int arrowW = 32;
    final int mainW = width - arrowW;

    // 1. Fondo contenedor
    ctx2d.drawRoundRect(x, y, width, height, 0.4, color: bg);

    // Resaltado de la zona principal al pasar el cursor
    if (_isMainHovered) {
      ctx2d.drawRoundRect(
        x,
        y,
        mainW,
        height,
        0.4,
        color: const ColorRGBA(255, 255, 255, 25),
      );
    }

    // Resaltado de la zona de flecha desplegable
    if (_isArrowHovered || _isDropdownOpen) {
      ctx2d.drawRoundRect(
        x + mainW,
        y,
        arrowW,
        height,
        0.4,
        color: const ColorRGBA(255, 255, 255, 40),
      );
    }

    // Línea divisora
    ctx2d.drawRect(
      x + mainW,
      y + 6,
      1,
      height - 12,
      const ColorRGBA(255, 255, 255, 80),
    );

    // 2. Renderizar Acción Principal (Izquierda)
    final int iconW = icon != null ? 18 : 0;
    final int textW = label.length * 8;
    final int totalW = iconW + (icon != null ? 6 : 0) + textW;

    int cx = x + (mainW - totalW) ~/ 2;
    final int cy = y + (height - 14) ~/ 2;

    if (icon != null) {
      ctx2d.drawIcon(icon!, cx, cy - 1, 16, fg);
      cx += iconW + 6;
    }
    ctx2d.drawText(label, cx, cy, 13, fg);

    // 3. Renderizar Flecha Desplegable (Derecha)
    final int arrowX = x + mainW + (arrowW - 16) ~/ 2;
    ctx2d.drawIcon(Icons.arrow_drop_down, arrowX, cy - 2, 18, fg);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || !_isDropdownOpen || options.isEmpty) return;

    final int menuWidth = width < 180 ? 180 : width;
    final int menuHeight = options.length * 36 + 10;
    final int menuX = x;
    final int menuY = y + height + 4;

    // Fondo del menú flotante
    ctx2d.drawRoundRect(
      menuX,
      menuY,
      menuWidth,
      menuHeight,
      0.2,
      color: const ColorRGBA(32, 38, 48, 255),
    );
    ctx2d.drawRoundRectLines(
      menuX,
      menuY,
      menuWidth,
      menuHeight,
      0.2,
      lineThick: 1.0,
      color: const ColorRGBA(75, 85, 100, 255),
    );

    for (int i = 0; i < options.length; i++) {
      final item = options[i];
      final int itemY = menuY + 5 + (i * 36);
      final bool isHovered = _hoveredOptionIndex == i;

      if (isHovered) {
        ctx2d.drawRect(
          menuX + 4,
          itemY,
          menuWidth - 8,
          34,
          const ColorRGBA(41, 128, 185, 255),
        );
      }

      int ix = menuX + 12;
      if (item.icon != null) {
        ctx2d.drawIcon(item.icon!, ix, itemY + 8, 16, ColorRGBA.white);
        ix += 24;
      }

      ctx2d.drawText(item.label, ix, itemY + 9, 13, ColorRGBA.white);
    }
  }
}

