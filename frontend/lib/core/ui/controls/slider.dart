import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/style_rules.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente Deslizador Numérico (`Slider`) bajo la arquitectura Cortex.
///
/// Permite seleccionar valores numéricos continuos o discretos (pasos [divisions])
/// arrastrando un actuador (thumb) a lo largo de una barra horizontal (track).
class Slider extends ControlNode {
  double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double value)? valueFormatter;
  final void Function(double value)? onChanged;

  bool _isDragging = false;
  bool isPressed;

  Slider({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.valueFormatter,
    this.onChanged,
    this.isPressed = false,
  }) {
    value = value.clamp(min, max);
    _updateDimensions();
  }

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
      if (isHovered || _isDragging) buffer.add('$cls:hover');
      if (isPressed || _isDragging) buffer.add('$cls:active');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return StyleRules.merge(buffer.join(' '));
  }

  double get normalizedValue =>
      (max > min) ? ((value - min) / (max - min)).clamp(0.0, 1.0) : 0.0;

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
    final fontSize = style.fontSize ?? 12;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    int minW = 180;
    if (label != null && label!.isNotEmpty) {
      final sampleTxt = valueFormatter != null
          ? valueFormatter!(max)
          : '$label: ${max.toStringAsFixed(1)}';
      final textW = _measureTextWidth(sampleTxt, fontSize);
      minW = (textW + 24 + pad.left + pad.right).round().clamp(180, 9999);
    }

    final int minH = (label != null ? fontSize + 18 : 24) +
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
  void onResize(int maxWidth, int maxHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 12;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0);

    int minW = 180;
    if (label != null && label!.isNotEmpty) {
      final sampleTxt = valueFormatter != null
          ? valueFormatter!(max)
          : '$label: ${max.toStringAsFixed(1)}';
      final textW = _measureTextWidth(sampleTxt, fontSize);
      minW = (textW + 24 + pad.left + pad.right).round().clamp(180, 9999);
    }

    final int minH = (label != null ? fontSize + 18 : 24) +
        pad.top.round() +
        pad.bottom.round();

    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        width = maxWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        width = (maxWidth * wRule).round();
      } else if (wRule.isFinite) {
        width = wRule.round();
      }
    } else {
      width = minW;
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        height = maxHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        height = (maxHeight * hRule).round();
      } else if (hRule.isFinite) {
        height = hRule.round();
      }
    } else {
      height = minH;
    }
  }

  void _updateValueFromMouseX(double mouseX) {
    if (max <= min) return;
    const trackPadding = 12;
    final trackW = width - (trackPadding * 2);
    if (trackW <= 0) return;

    final relativeX = (mouseX - (x + trackPadding)).clamp(
      0.0,
      trackW.toDouble(),
    );
    double norm = relativeX / trackW;

    if (divisions != null && divisions! > 0) {
      norm = (norm * divisions!).round() / divisions!;
    }

    final newValue = (min + (norm * (max - min))).clamp(min, max);
    if (newValue != value) {
      value = newValue;
      onChanged?.call(value);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !isEnabled) {
      isHovered = false;
      _isDragging = false;
      isPressed = false;
      return;
    }

    _updateDimensions();

    isHovered = input.isHovering(x, y, width, height);

    if (input.isMouseButtonPressed(MouseButtons.left) && isHovered) {
      _isDragging = true;
      isPressed = true;
      _updateValueFromMouseX(input.mouseX);
    }

    if (_isDragging) {
      if (input.isMouseButtonDown(MouseButtons.left)) {
        _updateValueFromMouseX(input.mouseX);
      } else {
        _isDragging = false;
        isPressed = false;
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0 || height <= 0) return;
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 12;

    const trackPadding = 12;
    const trackH = 6;
    final trackW = width - (trackPadding * 2);
    final hasLabel = label != null && label!.isNotEmpty;

    final trackY = hasLabel
        ? y + fontSize + 6 + ((height - (fontSize + 6) - trackH) ~/ 2)
        : y + ((height - trackH) ~/ 2);
    final trackX = x + trackPadding;

    final ColorRGBA activeTrackColor = style.activeColor ??
        style.hoverColor ??
        const ColorRGBA(41, 128, 185);
    final ColorRGBA inactiveTrackColor =
        style.bgColor ?? const ColorRGBA(45, 52, 68);
    final ColorRGBA thumbColor = style.textColor ?? ColorRGBA.white;

    // 1. Dibujar pista inactiva de fondo
    ctx2d.drawRoundRect(
      trackX,
      trackY,
      trackW,
      trackH,
      0.5,
      color: inactiveTrackColor,
    );

    // 2. Dibujar pista activa rellena a la izquierda del actuador
    final activeW = (normalizedValue * trackW).toInt();
    if (activeW > 0) {
      final activeBg = isEnabled
          ? activeTrackColor
          : const ColorRGBA(60, 90, 120);
      ctx2d.drawRoundRect(
        trackX,
        trackY,
        activeW,
        trackH,
        0.5,
        color: activeBg,
      );
    }

    // 3. Dibujar marcas de división si es discreto
    if (divisions != null && divisions! > 0) {
      final stepW = trackW / divisions!;
      for (int i = 0; i <= divisions!; i++) {
        final markX = (trackX + (i * stepW)).toInt();
        ctx2d.drawCircle(
          markX,
          trackY + (trackH ~/ 2),
          1.5,
          const ColorRGBA(100, 110, 130),
        );
      }
    }

    // 4. Dibujar actuador circular (thumb)
    final thumbX = trackX + activeW;
    final thumbY = trackY + (trackH ~/ 2);
    final thumbRadius = (_isDragging || isHovered) ? 9.0 : 7.0;

    if (isHovered || _isDragging) {
      final haloColor = ColorRGBA(
        activeTrackColor.r,
        activeTrackColor.g,
        activeTrackColor.b,
        80,
      );
      ctx2d.drawCircle(
        thumbX,
        thumbY,
        thumbRadius + 3.0,
        haloColor,
      );
    }

    ctx2d.drawCircle(
      thumbX,
      thumbY,
      thumbRadius,
      isEnabled ? thumbColor : const ColorRGBA(120, 130, 145),
    );

    // 5. Etiqueta o valor formateado en texto flotante
    final formattedValue = valueFormatter != null
        ? valueFormatter!(value)
        : (divisions != null
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(1));

    if (hasLabel || _isDragging) {
      final displayTxt = hasLabel ? "$label: $formattedValue" : formattedValue;
      final txtY = y;
      final textCol = isEnabled
          ? (style.textColor ?? ColorRGBA.white)
          : const ColorRGBA(140, 150, 165);
      ctx2d.drawText(displayTxt, trackX, txtY, fontSize, textCol);
    }
  }
}
