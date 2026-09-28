import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/style.dart';

/// Opción de menú para un `SplitButton`.
class SplitMenuItem {
  final String label;
  final IconData? icon;
  final void Function()? onTap;

  const SplitMenuItem({required this.label, this.icon, this.onTap});
}

/// Componente de Botón Dividido (`SplitButton`).
///
/// Combina una acción principal izquierda con una flecha desplegable derecha que
/// despliega un menú flotante en `onRenderOverlay()`.
class SplitButton extends Element {
  final String label;
  final IconData? icon;
  final List<SplitMenuItem> options;
  final void Function()? onMainPressed;
  late ColorRGBA bgColor;
  late ColorRGBA fgColor;

  bool _isMainHovered = false;
  bool _isArrowHovered = false;
  bool _isDropdownOpen = false;
  int _hoveredOptionIndex = -1;

  SplitButton({
    String? className,
    required this.label,
    required this.options,
    this.icon,
    this.onMainPressed,
    int width = 0,
    int height = 0,
  }) : super(
         width: width != 0 ? width : 160,
         height: height != 0 ? height : 40,
       ) {
    final style = className != null ? Style.merge(className) : null;
    if (style?.width != null) this.width = style!.width!;
    if (style?.height != null) this.height = style!.height!;
    bgColor = style?.bgColor ?? const ColorRGBA(41, 128, 185);
    fgColor = style?.textColor ?? ColorRGBA.white;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    final int arrowW = 32;
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
      } else if (input.isMouseButtonPressed(MouseButtons.left) &&
          !_isArrowHovered) {
        _isDropdownOpen = false;
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final int arrowW = 32;
    final int mainW = width - arrowW;

    // 1. Fondo contenedor
    ctx2d.drawRoundRect(x, y, width, height, 0.4, color: bgColor);

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
    final int textW = label.length * 7;
    final int totalW = iconW + (icon != null ? 6 : 0) + textW;

    int cx = x + (mainW - totalW) ~/ 2;
    final int cy = y + (height - 14) ~/ 2;

    if (icon != null) {
      ctx2d.drawText(icon!.glyph, cx, cy - 1, 16, fgColor);
      cx += iconW + 6;
    }
    ctx2d.drawText(label, cx, cy, 13, fgColor);

    // 3. Renderizar Flecha Desplegable (Derecha)
    final int arrowX = x + mainW + (arrowW - 16) ~/ 2;
    ctx2d.drawText(Icons.arrow_drop_down.glyph, arrowX, cy - 2, 18, fgColor);
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
      color: const ColorRGBA(32, 38, 48),
    );
    ctx2d.drawRoundRectLines(
      menuX,
      menuY,
      menuWidth,
      menuHeight,
      0.2,
      lineThick: 1.0,
      color: const ColorRGBA(75, 85, 100),
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
          const ColorRGBA(41, 128, 185),
        );
      }

      int ix = menuX + 12;
      if (item.icon != null) {
        ctx2d.drawText(item.icon!.glyph, ix, itemY + 8, 16, ColorRGBA.white);
        ix += 24;
      }

      ctx2d.drawText(item.label, ix, itemY + 9, 13, ColorRGBA.white);
    }
  }
}
