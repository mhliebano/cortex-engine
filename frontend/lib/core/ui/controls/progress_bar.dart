import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';

/// Componente Barra de Progreso Lineal (`ProgressBar`) bajo la arquitectura `ControlNode`.
///
/// Soporta dos modos de operación:
/// - **Determinado** (`value` de `0.0` a `1.0`): Representa avance cuantitativo concreto.
/// - **Indeterminado** (`value == null`): Animación pulsante continua de lado a lado.
///
/// Incluye bordes redondeados tipo píldora, etiqueta descriptiva opcional y porcentaje textual (`showPercentage`).
/// Se estiliza reactivamente mediante `StyleRules` y `LayoutRules`.
class ProgressBar extends ControlNode {
  double? value;
  final int minHeight;
  final double roundness;
  final bool showPercentage;
  final String? label;

  double _animTime = 0.0;

  ProgressBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    this.value,
    this.minHeight = 8,
    this.roundness = 0.5,
    this.showPercentage = false,
    this.label,
  }) {
    _updateDimensions();
  }

  @override
  bool get isFlexWidth {
    final wRule = currentLayout.width;
    if (wRule == null || wRule == double.infinity) return true;
    return wRule > 0.0 && wRule <= 1.0;
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth && width <= 0) {
      width = 200;
    }

    final headerH = (label != null || showPercentage) ? 20 : 0;
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight && height <= 0) {
      height = headerH + minHeight + 4;
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;
    final wRule = layout.width;
    int requestedWidth;

    if (wRule != null) {
      if (wRule == double.infinity) {
        requestedWidth = maxWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        requestedWidth = (maxWidth * wRule).round();
      } else if (wRule.isFinite) {
        requestedWidth = wRule.round();
      } else {
        requestedWidth = 200;
      }
    } else {
      requestedWidth = maxWidth > 0 ? maxWidth : 200;
    }

    final headerH = (label != null || showPercentage) ? 20 : 0;
    final defaultHeight = headerH + minHeight + 4;
    int requestedHeight;
    final hRule = layout.height;

    if (hRule != null) {
      if (hRule == double.infinity) {
        requestedHeight = maxHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        requestedHeight = (maxHeight * hRule).round();
      } else if (hRule.isFinite) {
        requestedHeight = hRule.round();
      } else {
        requestedHeight = defaultHeight;
      }
    } else {
      requestedHeight = defaultHeight;
    }

    width = (maxWidth > 0 && requestedWidth > maxWidth) ? maxWidth : requestedWidth;
    height = (maxHeight > 0 && requestedHeight > maxHeight) ? maxHeight : requestedHeight;
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible) return;
    _updateDimensions();

    if (value == null) {
      _animTime += dt * 2.5;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0) return;
    _updateDimensions();

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(32, 38, 50);
    final valueColor = style.activeColor ?? style.accentColor ?? ColorRGBA.accentBlue;
    final textColor = style.textColor ?? ColorRGBA.white;
    final borderColor = style.borderColor ?? const ColorRGBA(55, 65, 82);
    final fontSize = style.fontSize ?? 12;

    final resolvedRoundness = (style.borderRadius != null && style.borderRadius! > 0)
        ? (style.borderRadius! > 1.0 ? 0.5 : style.borderRadius!)
        : roundness;

    int barY = y;

    // 1. Renderizar encabezado con etiqueta y porcentaje si están presentes
    if (label != null || showPercentage) {
      if (label != null) {
        ctx2d.drawText(label!, x, y, fontSize, const ColorRGBA(180, 195, 215));
      }
      if (showPercentage && value != null) {
        final pctText = "${(value!.clamp(0.0, 1.0) * 100).toInt()}%";
        final pctW = (pctText.length * fontSize * 0.6).round();
        final pctX = x + width - pctW;
        ctx2d.drawText(pctText, pctX, y, fontSize, textColor);
      }
      barY += fontSize + 6;
    }

    final barH = minHeight;

    // 2. Fondo de la barra de progreso
    ctx2d.drawRoundRect(x, barY, width, barH, resolvedRoundness, color: bgColor);
    ctx2d.drawRoundRectLines(
      x,
      barY,
      width,
      barH,
      resolvedRoundness,
      color: borderColor,
    );

    // 3. Relleno activo de progreso
    if (value != null) {
      final clampedVal = value!.clamp(0.0, 1.0);
      final fillW = (width * clampedVal).toInt();
      if (fillW >= 2) {
        ctx2d.drawRoundRect(
          x,
          barY,
          fillW,
          barH,
          resolvedRoundness,
          color: valueColor,
        );
      }
    } else {
      // Modo Indeterminado: Bloque pulsante animado deslizante
      final pulseW = (width * 0.35).clamp(20.0, 150.0);
      final sinePos = (math.sin(_animTime) * 0.5 + 0.5);
      final pulseX = (x + sinePos * (width - pulseW)).toInt();

      ctx2d.beginScissor(x + 1, barY, width - 2, barH);
      ctx2d.drawRoundRect(
        pulseX,
        barY,
        pulseW.toInt(),
        barH,
        resolvedRoundness,
        color: valueColor,
      );
      ctx2d.endScissor();
    }
  }

  @override
  Map<String, dynamic>? exportState() {
    return {'value': value};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('value')) {
      value = (state['value'] as num?)?.toDouble();
    }
  }
}
