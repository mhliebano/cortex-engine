import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente Botón de Acción Flotante (`Fab` / Floating Action Button) bajo la arquitectura `ControlNode`.
///
/// Soporta formato estándar (FAB circular/cuadrado redondeado) y formato extendido (Extended FAB con ícono + etiqueta).
class Fab extends ControlNode {
  final IconData icon;
  final String? label;
  final void Function()? onPressed;
  final bool isExtended;

  bool _isHovered = false;
  bool _isPressed = false;

  Fab({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.icon,
    this.onPressed,
    int size = 56,
  })  : label = null,
        isExtended = false {
    _updateDimensions(size, size);
  }

  Fab.extended({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.icon,
    required this.label,
    this.onPressed,
    int height = 56,
  })  : isExtended = true {
    final calcW = ((label?.length ?? 0) * 8 + 64).clamp(120, 300);
    _updateDimensions(calcW, height);
  }

  void _updateDimensions(int defW, int defH) {
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

    final style = currentStyle;
    final ColorRGBA baseBg = style.bgColor ?? const ColorRGBA(41, 128, 185, 255);
    final ColorRGBA fgColor = style.textColor ?? ColorRGBA.white;

    final ColorRGBA bg = _isPressed
        ? const ColorRGBA(30, 100, 150, 255)
        : _isHovered
            ? (style.hoverColor ?? const ColorRGBA(52, 152, 219, 255))
            : baseBg;

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
      final int iconSize = math.max(16, (height * 0.45).toInt());
      final int ix = x + (width - iconSize) ~/ 2;
      final int iy = y + (height - iconSize) ~/ 2;

      ctx2d.drawIcon(icon, ix, iy, iconSize, fgColor);
    } else {
      // Extended FAB (Ícono + Texto)
      const int iconSize = 20;
      final int textWidth = label!.length * 8;
      final int totalW = iconSize + 10 + textWidth;

      int cx = x + (width - totalW) ~/ 2;
      final int cy = y + (height - 14) ~/ 2;

      ctx2d.drawIcon(icon, cx, cy - 2, iconSize, fgColor);
      cx += iconSize + 10;
      ctx2d.drawText(label!, cx, cy, 14, fgColor);
    }
  }
}

