import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';

import 'package:cortex/engine/ui/style.dart';

/// Componente de Botón de Opción Única (`RadioButton<T>`).
///
/// Diseñado para ser usado de forma independiente o integrado dentro de un `RadioGroup<T>`.
class RadioButton<T> extends Element {
  final T value;
  T? groupValue;
  final String label;
  void Function(T value)? onChanged;
  final bool enabled;
  late ColorRGBA activeColor;

  bool _isHovered = false;
  bool _isPressed = false;

  RadioButton({
    String? className,
    required this.value,
    this.groupValue,
    required this.label,
    this.onChanged,
    this.enabled = true,
    int size = 20,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    activeColor = style?.accentColor ?? const ColorRGBA(41, 128, 185);
    _updateDimensions(size);
  }

  void _updateDimensions(int radioSize) {
    int w = radioSize;
    if (label.isNotEmpty) {
      w += (label.length * 9) + 10;
    }
    width = w;
    height = radioSize;
  }

  bool get isSelected => value == groupValue;

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
        groupValue = value;
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

    final radioSize = height > 0 ? height : 20;
    final radius = radioSize / 2.0;
    final centerX = x + (radioSize ~/ 2);
    final centerY = y + (radioSize ~/ 2);

    final currentBg = isSelected
        ? (enabled ? activeColor : const ColorRGBA(70, 80, 100))
        : (enabled
            ? (_isHovered ? const ColorRGBA(45, 52, 68) : const ColorRGBA(32, 38, 50))
            : const ColorRGBA(25, 30, 40));

    final currentBorder = enabled
        ? (_isHovered ? const ColorRGBA(52, 152, 219) : const ColorRGBA(70, 80, 100))
        : const ColorRGBA(50, 55, 65);

    // 1. Dibujar círculo base de opción
    ctx2d.drawCircle(centerX, centerY, radius, currentBg);
    ctx2d.drawCircleLines(centerX, centerY, radius, currentBorder);

    // 2. Renderizar punto interno si está seleccionado
    if (isSelected) {
      ctx2d.drawCircle(centerX, centerY, radius * 0.45, ColorRGBA.white);
    }

    // 3. Etiqueta de texto acompañante
    if (label.isNotEmpty) {
      final labelX = x + radioSize + 8;
      final labelY = y + (radioSize ~/ 4);
      final textColor = enabled ? ColorRGBA.white : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label, labelX, labelY, 14, textColor);
    }
  }
}

/// Contenedor Administrador de Opciones Únicas (`RadioGroup<T>`).
///
/// Dispone y sincroniza automáticamente un grupo de `RadioButton<T>` en orientación horizontal o vertical.
class RadioGroup<T> extends Element {
  T selectedValue;
  final List<RadioButton<T>> options;
  final bool isRow;
  final int spacing;
  final void Function(T value)? onChanged;

  final Map<RadioButton<T>, void Function(T value)?> _optionCallbacks = {};

  RadioGroup({
    required this.selectedValue,
    required this.options,
    this.isRow = true,
    this.spacing = 25,
    this.onChanged,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) {
    _bindOptions();
  }

  void _bindOptions() {
    int currentX = x;
    int currentY = y;
    int maxW = 0;
    int maxH = 0;

    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      if (!_optionCallbacks.containsKey(option)) {
        _optionCallbacks[option] = option.onChanged;
      }
      option.groupValue = selectedValue;
      option.onChanged = (val) {
        selectValue(val);
        _optionCallbacks[option]?.call(val);
      };

      if (isRow) {
        option.x = currentX;
        option.y = y;
        currentX += option.width + spacing;
        if (option.height > maxH) maxH = option.height;
      } else {
        option.x = x;
        option.y = currentY;
        currentY += option.height + spacing;
        if (option.width > maxW) maxW = option.width;
      }
    }

    if (isRow) {
      width = currentX > x ? currentX - x - spacing : 0;
      height = maxH > 0 ? maxH : 20;
    } else {
      width = maxW > 0 ? maxW : 100;
      height = currentY > y ? currentY - y - spacing : 0;
    }
  }

  void selectValue(T newValue) {
    selectedValue = newValue;
    for (final option in options) {
      option.groupValue = selectedValue;
    }
    if (onChanged != null) {
      onChanged!(selectedValue);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _bindOptions();
    for (final option in options) {
      option.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final option in options) {
      option.onRender(ctx2d, ctx3d);
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _bindOptions();
  }
}
