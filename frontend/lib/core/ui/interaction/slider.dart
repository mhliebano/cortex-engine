import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';

import 'package:cortex/core/ui/style.dart';

/// Componente Deslizador Numérico (`Slider`).
///
/// Permite seleccionar valores numéricos continuos o discretos (pasos `divisions`) arrastrando un actuador (thumb) a lo largo de una barra (track).
class Slider extends Element {
  double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double value)? valueFormatter;
  final void Function(double value)? onChanged;
  final bool enabled;
  late ColorRGBA activeTrackColor;
  late ColorRGBA inactiveTrackColor;
  late ColorRGBA thumbColor;

  bool _isDragging = false;
  bool _isHovered = false;

  Slider({
    String? className,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.valueFormatter,
    this.onChanged,
    this.enabled = true,
    int width = 0,
    int height = 0,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 220);
    this.height = height != 0 ? height : (style?.height ?? 30);
    activeTrackColor = style?.accentColor ?? const ColorRGBA(41, 128, 185);
    inactiveTrackColor = style?.bgColor ?? const ColorRGBA(45, 52, 68);
    thumbColor = style?.textColor ?? ColorRGBA.white;
    this.value = value.clamp(min, max);
  }

  double get normalizedValue =>
      (max > min) ? ((value - min) / (max - min)).clamp(0.0, 1.0) : 0.0;

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
      if (onChanged != null) {
        onChanged!(value);
      }
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) return;

    _isHovered = input.isHovering(x, y, width, height);

    if (input.isMouseButtonPressed(MouseButtons.left) && _isHovered) {
      _isDragging = true;
    }

    if (_isDragging) {
      if (input.isMouseButtonDown(MouseButtons.left)) {
        _updateValueFromMouseX(input.mouseX);
      } else {
        _isDragging = false;
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    const trackPadding = 12;
    const trackH = 6;
    final trackW = width - (trackPadding * 2);
    final trackY = y + (height ~/ 2) - (trackH ~/ 2);
    final trackX = x + trackPadding;

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
      final activeBg = enabled
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
    final thumbRadius = (_isDragging || _isHovered) ? 9.0 : 7.0;

    if (_isHovered || _isDragging) {
      ctx2d.drawCircle(
        thumbX,
        thumbY,
        thumbRadius + 3.0,
        const ColorRGBA(41, 128, 185, 80),
      );
    }
    ctx2d.drawCircle(
      thumbX,
      thumbY,
      thumbRadius,
      enabled ? thumbColor : const ColorRGBA(120, 130, 145),
    );

    // 5. Etiqueta o valor formateado en texto flotante al arrastrar o estático
    final formattedValue = valueFormatter != null
        ? valueFormatter!(value)
        : (divisions != null
              ? value.toStringAsFixed(0)
              : value.toStringAsFixed(1));

    if (label != null || _isDragging) {
      final displayTxt = label != null
          ? "$label: $formattedValue"
          : formattedValue;
      final txtY = y - 2;
      ctx2d.drawText(
        displayTxt,
        trackX,
        txtY,
        12,
        enabled ? ColorRGBA.white : const ColorRGBA(140, 150, 165),
      );
    }
  }
}
