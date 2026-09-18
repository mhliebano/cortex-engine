import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';

import 'package:cortex/engine/ui/style.dart';

/// Componente de Casilla de Verificación (`Checkbox`).
///
/// Soporta 3 estados de selección:
/// 1. **`true`** (Marcado - Checkmark `✓`)
/// 2. **`false`** (Desmarcado - Vacío)
/// 3. **`null`** (Indeterminado - Guión `-`)
///
/// Puede ser acompañado de una etiqueta de texto (`label`) y responder a gestos (`onChanged`).
class Checkbox extends Element {
  bool? value;
  final String? label;
  final void Function(bool? value)? onChanged;
  final bool enabled;
  late ColorRGBA activeColor;
  late ColorRGBA checkColor;

  bool _isHovered = false;
  bool _isPressed = false;

  Checkbox({
    String? className,
    this.value = false,
    this.label,
    this.onChanged,
    this.enabled = true,
    int size = 20,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    activeColor = style?.accentColor ?? const ColorRGBA(41, 128, 185);
    checkColor = style?.textColor ?? ColorRGBA.white;
    _updateDimensions(size);
  }

  void _updateDimensions(int boxSize) {
    int w = boxSize;
    if (label != null && label!.isNotEmpty) {
      w += (label!.length * 9) + 10;
    }
    width = w;
    height = boxSize;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) return;

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
      }
      if (_isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = false;
        final nextValue = value == true ? false : true;
        value = nextValue;
        if (onChanged != null) {
          onChanged!(value);
        }
      }
    } else {
      _isPressed = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final boxSize = height > 0 ? height : 20;
    final isChecked = value == true;
    final isIndeterminate = value == null;

    // 1. Color del cuadro de la casilla según estado
    final currentBg = isChecked || isIndeterminate
        ? (enabled ? activeColor : const ColorRGBA(80, 90, 110))
        : (enabled
            ? (_isHovered ? const ColorRGBA(45, 52, 68) : const ColorRGBA(32, 38, 50))
            : const ColorRGBA(25, 30, 40));

    final currentBorder = enabled
        ? (_isHovered ? const ColorRGBA(52, 152, 219) : const ColorRGBA(70, 80, 100))
        : const ColorRGBA(50, 55, 65);

    // 2. Dibujar casilla cuadrada redondeada
    ctx2d.drawRoundRect(x, y, boxSize, boxSize, 0.2, color: currentBg);
    ctx2d.drawRoundRectLines(x, y, boxSize, boxSize, 0.2, color: currentBorder);

    // 3. Renderizar ícono de marca o guión indeterminado
    if (isChecked) {
      ctx2d.drawText(Icons.check.glyph, x + 2, y + 2, boxSize - 4, checkColor);
    } else if (isIndeterminate) {
      ctx2d.drawRect(x + 4, y + (boxSize ~/ 2) - 2, boxSize - 8, 4, checkColor);
    }

    // 4. Renderizar etiqueta de texto acompañante
    if (label != null && label!.isNotEmpty) {
      final labelX = x + boxSize + 8;
      final labelY = y + (boxSize ~/ 4);
      final textColor = enabled ? ColorRGBA.white : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label!, labelX, labelY, 14, textColor);
    }
  }
}
