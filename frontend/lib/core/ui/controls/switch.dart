import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/style_rules.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Componente Conmutador Deslizante (`Switch`) bajo la arquitectura Cortex.
///
/// Permite alternar entre dos estados (ON / OFF) con una transición animada suave del actuador (thumb).
class Switch extends ControlNode {
  bool value;
  final String? label;
  final void Function(bool value)? onChanged;
  bool isPressed;

  double _thumbProgress = 0.0;

  Switch({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.value = false,
    this.label,
    this.onChanged,
    this.isPressed = false,
  }) {
    _thumbProgress = value ? 1.0 : 0.0;
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

    const trackW = 44;
    const trackH = 22;

    int minW = trackW + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (trackH > fontSize ? trackH : fontSize) +
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

    const trackW = 44;
    const trackH = 22;

    int minW = trackW + pad.left.round() + pad.right.round();
    if (label != null && label!.isNotEmpty) {
      final textW = _measureTextWidth(label!, fontSize);
      minW += textW + 8;
    }
    final minH = (trackH > fontSize ? trackH : fontSize) +
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

    // Transición interpolada animada del actuador (thumb)
    final target = value ? 1.0 : 0.0;
    final diff = target - _thumbProgress;
    if (diff.abs() > 0.001) {
      _thumbProgress += diff * (dt * 15.0).clamp(0.0, 1.0);
    } else {
      _thumbProgress = target;
    }

    if (isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        isPressed = true;
      }
      if (isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        isPressed = false;
        value = !value;
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

    const trackW = 44;
    const trackH = 22;
    const thumbRadius = 8.0;

    final ColorRGBA activeColor = style.activeColor ??
        style.hoverColor ??
        style.bgColor ??
        const ColorRGBA(41, 128, 185);
    final ColorRGBA inactiveTrackColor =
        style.bgColor ?? const ColorRGBA(45, 52, 68);
    final ColorRGBA thumbColor = style.textColor ?? ColorRGBA.white;

    final trackY = y + ((height - trackH) ~/ 2);

    // 1. Color de la pista según estado ON/OFF
    final ColorRGBA currentTrackBg;
    final ColorRGBA trackBorder;

    if (!isEnabled) {
      currentTrackBg = value
          ? const ColorRGBA(60, 90, 120)
          : const ColorRGBA(30, 35, 46);
      trackBorder = const ColorRGBA(45, 50, 60);
    } else if (value) {
      currentTrackBg = isPressed
          ? ColorRGBA((activeColor.r * 0.8).round(),
              (activeColor.g * 0.8).round(), (activeColor.b * 0.8).round())
          : (isHovered
              ? ColorRGBA(
                  (activeColor.r * 1.15).clamp(0, 255).round(),
                  (activeColor.g * 1.15).clamp(0, 255).round(),
                  (activeColor.b * 1.15).clamp(0, 255).round())
              : activeColor);
      trackBorder = style.borderColor ?? currentTrackBg;
    } else {
      currentTrackBg = isHovered
          ? (style.hoverColor ?? const ColorRGBA(55, 64, 82))
          : inactiveTrackColor;
      trackBorder = isHovered
          ? (style.borderColor ?? const ColorRGBA(52, 152, 219))
          : (style.borderColor ?? const ColorRGBA(65, 75, 95));
    }

    // 2. Dibujar pista en cápsula píldora
    ctx2d.drawRoundRect(x, trackY, trackW, trackH, 0.5, color: currentTrackBg);
    ctx2d.drawRoundRectLines(x, trackY, trackW, trackH, 0.5,
        color: trackBorder);

    // 3. Dibujar actuador circular (thumb) con animación
    final startThumbX = x + 11;
    final endThumbX = x + trackW - 11;
    final currentThumbX =
        (startThumbX + (_thumbProgress * (endThumbX - startThumbX))).toInt();
    final currentThumbY = trackY + (trackH ~/ 2);

    ctx2d.drawCircle(currentThumbX, currentThumbY, thumbRadius, thumbColor);

    // 4. Etiqueta de texto acompañante
    if (label != null && label!.isNotEmpty) {
      final labelX = x + trackW + 8;
      final labelY = y + ((height - fontSize) ~/ 2);
      final textCol = isEnabled
          ? (style.textColor ?? ColorRGBA.white)
          : const ColorRGBA(120, 130, 145);
      ctx2d.drawText(label!, labelX, labelY, fontSize, textCol);
    }
  }
}
