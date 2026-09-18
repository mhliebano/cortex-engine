import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';

import 'package:cortex/engine/ui/style.dart';

enum ChipVariant {
  input,
  filter,
  action,
}

/// Componente de Ficha o Etiqueta Compacta (`Chip`).
///
/// Soporta 3 variantes funcionales:
/// 1. **`input`**: Etiqueta con botón de eliminación (`onDeleted`).
/// 2. **`filter`**: Etiqueta seleccionable con tilde de verificación (`isSelected`, `onSelected`).
/// 3. **`action`**: Botón compacto tipo píldora (`onTap`).
class Chip extends Element {
  final String label;
  final IconData? leadingIcon;
  final ChipVariant variant;
  bool isSelected;
  final void Function(bool selected)? onSelected;
  final void Function()? onDeleted;
  final void Function()? onTap;

  late ColorRGBA bgColor;
  late ColorRGBA selectedBgColor;
  late ColorRGBA borderColor;

  bool _isHovered = false;
  bool _isPressed = false;
  bool _isDeleteHovered = false;

  Chip({
    String? className,
    required this.label,
    this.leadingIcon,
    this.variant = ChipVariant.action,
    this.isSelected = false,
    this.onSelected,
    this.onDeleted,
    this.onTap,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    bgColor = style?.bgColor ?? const ColorRGBA(36, 42, 54);
    selectedBgColor = style?.accentColor ?? const ColorRGBA(41, 128, 185);
    borderColor = style?.borderColor ?? const ColorRGBA(60, 70, 88);

    _updateDimensions();
  }

  void _updateDimensions() {
    int w = 24; // Padding inicial y final
    if (leadingIcon != null || (variant == ChipVariant.filter && isSelected)) {
      w += 18;
    }
    w += (label.length * 8);

    if (variant == ChipVariant.input && onDeleted != null) {
      w += 20;
    }

    width = w;
    height = 28;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _isHovered = input.isHovering(x, y, width, height);

    if (variant == ChipVariant.input && onDeleted != null) {
      final deleteX = x + width - 22;
      _isDeleteHovered = input.isHovering(deleteX, y, 20, height);
    }

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
      }
      if (_isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = false;
        if (_isDeleteHovered && onDeleted != null) {
          onDeleted!();
        } else {
          if (variant == ChipVariant.filter) {
            isSelected = !isSelected;
            _updateDimensions();
            if (onSelected != null) onSelected!(isSelected);
          } else if (onTap != null) {
            onTap!();
          }
        }
      }
    } else {
      _isPressed = false;
      _isDeleteHovered = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // 1. Color de fondo según variante y selección
    final activeBg = isSelected
        ? selectedBgColor
        : (_isPressed
            ? const ColorRGBA(28, 34, 44)
            : (_isHovered ? const ColorRGBA(48, 56, 72) : bgColor));

    final activeBorder = _isHovered ? const ColorRGBA(52, 152, 219) : borderColor;

    // 2. Dibujar cápsula píldora
    ctx2d.drawRoundRect(x, y, width, height, 0.5, color: activeBg);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.5, color: activeBorder);

    int contentX = x + 10;

    // 3. Renderizar ícono inicial o tilde de filtro seleccionado
    if (variant == ChipVariant.filter && isSelected) {
      ctx2d.drawText(Icons.check.glyph, contentX, y + 6, 14, ColorRGBA.white);
      contentX += 18;
    } else if (leadingIcon != null) {
      ctx2d.drawText(leadingIcon!.glyph, contentX, y + 6, 14, ColorRGBA.white);
      contentX += 18;
    }

    // 4. Renderizar texto de la etiqueta
    ctx2d.drawText(label, contentX, y + 6, 13, ColorRGBA.white);
    contentX += (label.length * 8);

    // 5. Renderizar botón de eliminación (X) para variante input
    if (variant == ChipVariant.input && onDeleted != null) {
      final deleteIconColor = _isDeleteHovered
          ? const ColorRGBA(228, 77, 61)
          : const ColorRGBA(160, 170, 190);
      ctx2d.drawText(Icons.close.glyph, x + width - 18, y + 6, 14, deleteIconColor);
    }
  }
}
