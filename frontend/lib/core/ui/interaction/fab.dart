import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/icons.dart';

import 'package:cortex/core/ui/style.dart';

/// Componente Botón de Acción Flotante (`Fab` / Floating Action Button).
///
/// Soporta formato estándar (FAB circular/cuadrado redondeado) y formato extendido (Extended FAB con ícono + etiqueta).
class Fab extends Element {
  final IconData icon;
  final String? label;
  final void Function()? onPressed;
  late ColorRGBA bgColor;
  late ColorRGBA fgColor;
  final bool isExtended;

  bool _isHovered = false;
  bool _isPressed = false;

  Fab({String? className, required this.icon, this.onPressed, int size = 56})
    : label = null,
      isExtended = false,
      super(width: size, height: size) {
    final style = className != null ? Style.merge(className) : null;
    bgColor = style?.bgColor ?? const ColorRGBA(41, 128, 185);
    fgColor = style?.textColor ?? ColorRGBA.white;
  }

  Fab.extended({
    String? className,
    required this.icon,
    required this.label,
    this.onPressed,
    int height = 56,
  }) : isExtended = true,
       super(
         width: ((label?.length ?? 0) * 8 + 64).clamp(120, 300),
         height: height,
       ) {
    final style = className != null ? Style.merge(className) : null;
    bgColor = style?.bgColor ?? const ColorRGBA(41, 128, 185);
    fgColor = style?.textColor ?? ColorRGBA.white;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
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

    final ColorRGBA bg = _isPressed
        ? const ColorRGBA(30, 100, 150)
        : _isHovered
        ? const ColorRGBA(52, 152, 219)
        : bgColor;

    // 1. Sombra sutil de elevación
    ctx2d.drawRoundRect(
      x + 2,
      y + 4,
      width,
      height,
      0.4,
      color: const ColorRGBA(0, 0, 0, 80),
    );

    // 2. Contenedor FAB principal
    ctx2d.drawRoundRect(x, y, width, height, 0.4, color: bg);

    if (!isExtended || label == null || label!.isEmpty) {
      // FAB Estándar (Ícono centrado)
      final int iconSize = (height * 0.45).toInt();
      final int ix = x + (width - iconSize) ~/ 2;
      final int iy = y + (height - iconSize) ~/ 2;

      ctx2d.drawText(icon.glyph, ix, iy, iconSize, fgColor);
    } else {
      // Extended FAB (Ícono + Texto)
      final int iconSize = 22;
      final int textWidth = label!.length * 7;
      final int totalW = iconSize + 10 + textWidth;

      int cx = x + (width - totalW) ~/ 2;
      final int cy = y + (height - 14) ~/ 2;

      ctx2d.drawText(icon.glyph, cx, cy - 2, iconSize, fgColor);
      cx += iconSize + 10;
      ctx2d.drawText(label!, cx, cy, 14, fgColor);
    }
  }
}
