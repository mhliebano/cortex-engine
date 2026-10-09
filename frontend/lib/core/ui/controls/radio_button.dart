import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/style_rules.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente de Botón de Opción Única (`RadioButton<T>`) bajo la arquitectura Cortex.
class RadioButton<T> extends ControlNode {
  final T value;
  T? groupValue;
  final String? label;
  void Function(T value)? onChanged;
  bool isPressed;

  RadioButton({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    required this.value,
    this.groupValue,
    this.label,
    this.onChanged,
    this.isPressed = false,
  }) {
    _updateDimensions();
  }

  bool get isSelected => value == groupValue;

  @override
  StyleRules get currentStyle {
    final raw = styleClass;
    if (raw == null || raw.trim().isEmpty) {
      return const StyleRules();
    }

    final classes = raw.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered) buffer.add('$cls:hover');
      if (isPressed) buffer.add('$cls:active');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return StyleRules.merge(buffer.join(' '));
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
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    const radioSize = 20;
    int minW = radioSize + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (radioSize > fontSize ? radioSize : fontSize) +
        pad.top.round() +
        pad.bottom.round();

    final wRule = layout.width;
    if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
      width = wRule.round();
    } else if (!isFlexWidth) {
      if (width < minW) width = minW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
      height = hRule.round();
    } else if (!isFlexHeight) {
      if (height < minH) height = minH;
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    const radioSize = 20;
    int minW = radioSize + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (radioSize > fontSize ? radioSize : fontSize) +
        pad.top.round() +
        pad.bottom.round();

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
      width = allocatedWidth > 0 ? allocatedWidth : minW;
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
      height = allocatedHeight > 0 ? allocatedHeight : minH;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
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
      }
      if (isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        isPressed = false;
        groupValue = value;
        onChanged?.call(value);
      }
    } else {
      isPressed = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;
    const radioSize = 20;
    const radius = radioSize / 2.0;

    final centerX = x + (radioSize ~/ 2);
    final centerY = y + ((height - radioSize) ~/ 2) + (radioSize ~/ 2);

    final ColorRGBA activeColor = style.activeColor ??
        style.hoverColor ??
        style.bgColor ??
        const ColorRGBA(41, 128, 185);

    final ColorRGBA currentBg;
    final ColorRGBA currentBorder;

    if (!isEnabled) {
      currentBg =
          isSelected ? const ColorRGBA(70, 80, 100) : const ColorRGBA(25, 30, 40);
      currentBorder = const ColorRGBA(50, 55, 65);
    } else if (isSelected) {
      currentBg = isPressed
          ? ColorRGBA((activeColor.r * 0.8).round(),
              (activeColor.g * 0.8).round(), (activeColor.b * 0.8).round())
          : (isHovered
              ? ColorRGBA(
                  (activeColor.r * 1.15).clamp(0, 255).round(),
                  (activeColor.g * 1.15).clamp(0, 255).round(),
                  (activeColor.b * 1.15).clamp(0, 255).round())
              : activeColor);
      currentBorder = style.borderColor ?? currentBg;
    } else {
      currentBg = isHovered
          ? (style.hoverColor ?? const ColorRGBA(45, 52, 68))
          : (style.bgColor ?? const ColorRGBA(32, 38, 50));
      currentBorder = isHovered
          ? (style.borderColor ?? const ColorRGBA(52, 152, 219))
          : (style.borderColor ?? const ColorRGBA(70, 80, 100));
    }

    // 1. Círculo exterior
    ctx2d.drawCircle(centerX, centerY, radius, currentBg);
    ctx2d.drawCircleLines(centerX, centerY, radius, currentBorder);

    // 2. Punto interior si está seleccionado
    if (isSelected) {
      final dotColor = style.textColor ?? ColorRGBA.white;
      ctx2d.drawCircle(centerX, centerY, radius * 0.45, dotColor);
    }

    // 3. Etiqueta de texto
    if (label != null && label!.isNotEmpty) {
      final labelX = x + radioSize + 8;
      final labelY = y + ((height - fontSize) ~/ 2);
      final textCol = isEnabled
          ? (style.textColor ?? ColorRGBA.white)
          : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label!, labelX, labelY, fontSize, textCol);
    }
  }
}

/// Contenedor Administrador de Opciones Únicas (`RadioGroup<T>`) bajo la arquitectura Cortex.
class RadioGroup<T> extends ControlNode {
  T selectedValue;
  final List<RadioButton<T>> options;
  final bool isRow;
  final double gap;
  final void Function(T value)? onChanged;

  final Map<RadioButton<T>, void Function(T value)?> _optionCallbacks = {};

  RadioGroup({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    required this.selectedValue,
    required this.options,
    this.isRow = true,
    this.gap = 15.0,
    this.onChanged,
  }) {
    _bindOptions();
  }

  @override
  List<CortexNode> get childrenElements => options;

  void _bindOptions() {
    int currentX = x;
    int currentY = y;
    int maxW = 0;
    int maxH = 0;
    final int gapInt = gap.round();

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
        currentX += option.width + gapInt;
        if (option.height > maxH) maxH = option.height;
      } else {
        option.x = x;
        option.y = currentY;
        currentY += option.height + gapInt;
        if (option.width > maxW) maxW = option.width;
      }
    }

    if (isRow) {
      width = currentX > x ? currentX - x - gapInt : 0;
      height = maxH > 0 ? maxH : 20;
    } else {
      width = maxW > 0 ? maxW : 100;
      height = currentY > y ? currentY - y - gapInt : 0;
    }
  }

  void selectValue(T newValue) {
    selectedValue = newValue;
    for (final option in options) {
      option.groupValue = selectedValue;
    }
    onChanged?.call(selectedValue);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !isEnabled) return;
    _bindOptions();
    for (final option in options) {
      if (option.isVisible) option.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final option in options) {
      if (option.isVisible) option.onRender(ctx2d, ctx3d);
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final option in options) {
      if (option.isVisible) option.onRenderOverlay(ctx2d, ctx3d);
    }
    super.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _bindOptions();
  }
}
