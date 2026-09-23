import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';

import 'package:cortex/core/ui/style.dart';

/// Componente Conmutador Deslizante (`Switch`).
///
/// Permite alternar entre dos estados (ON / OFF) con una transición animada suave del actuador (thumb).
class Switch extends Element {
  bool value;
  final String? label;
  final void Function(bool value)? onChanged;
  final bool enabled;
  late ColorRGBA activeTrackColor;
  late ColorRGBA inactiveTrackColor;
  late ColorRGBA thumbColor;

  double _thumbProgress = 0.0;
  bool _isHovered = false;
  bool _isPressed = false;

  Switch({
    String? className,
    this.value = false,
    this.label,
    this.onChanged,
    this.enabled = true,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    activeTrackColor = style?.accentColor ?? const ColorRGBA(41, 128, 185);
    inactiveTrackColor = style?.bgColor ?? const ColorRGBA(45, 52, 68);
    thumbColor = style?.textColor ?? ColorRGBA.white;
    _thumbProgress = value ? 1.0 : 0.0;
    _updateDimensions();
  }

  void _updateDimensions() {
    int w = 46;
    if (label != null && label!.isNotEmpty) {
      w += (label!.length * 9) + 10;
    }
    width = w;
    height = 24;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) return;

    _isHovered = input.isHovering(x, y, width, height);

    // Transición interpolada animada del actuador (thumb)
    final target = value ? 1.0 : 0.0;
    final diff = target - _thumbProgress;
    if (diff.abs() > 0.001) {
      _thumbProgress += diff * (dt * 15.0).clamp(0.0, 1.0);
    } else {
      _thumbProgress = target;
    }

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
      }
      if (_isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = false;
        value = !value;
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

    const trackW = 46;
    const trackH = 24;
    const thumbRadius = 9.0;

    // 1. Color de la pista según estado ON/OFF
    final currentTrackBg = value
        ? (enabled ? activeTrackColor : const ColorRGBA(60, 90, 120))
        : (enabled
              ? (_isHovered ? const ColorRGBA(55, 64, 82) : inactiveTrackColor)
              : const ColorRGBA(30, 35, 46));

    final trackBorder = enabled
        ? (_isHovered
              ? const ColorRGBA(52, 152, 219)
              : const ColorRGBA(65, 75, 95))
        : const ColorRGBA(45, 50, 60);

    // 2. Dibujar pista en cápsula píldora
    ctx2d.drawRoundRect(x, y, trackW, trackH, 0.5, color: currentTrackBg);
    ctx2d.drawRoundRectLines(x, y, trackW, trackH, 0.5, color: trackBorder);

    // 3. Dibujar actuador circular (thumb) con animación
    final startThumbX = x + 12;
    final endThumbX = x + trackW - 12;
    final currentThumbX =
        (startThumbX + (_thumbProgress * (endThumbX - startThumbX))).toInt();
    final currentThumbY = y + (trackH ~/ 2);

    ctx2d.drawCircle(currentThumbX, currentThumbY, thumbRadius, thumbColor);

    // 4. Etiqueta de texto acompañante
    if (label != null && label!.isNotEmpty) {
      final labelX = x + trackW + 10;
      final labelY = y + (trackH ~/ 4);
      final textColor = enabled
          ? ColorRGBA.white
          : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label!, labelX, labelY, 14, textColor);
    }
  }
}
