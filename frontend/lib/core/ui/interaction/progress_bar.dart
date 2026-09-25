import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/style.dart';

/// Componente Barra de Progreso Lineal (`ProgressBar`).
///
/// Soporta dos modos de operación:
/// - **Determinado** (`value` de `0.0` a `1.0`): Representa avance cuantitativo concreto.
/// - **Indeterminado** (`value == null`): Animación pulsante continua de lado a lado.
///
/// Incluye bordes redondeados tipo píldora, etiqueta descriptiva opcional y porcentaje textual (`showPercentage`).
class ProgressBar extends Element {
  final double? value;
  final int minHeight;
  final double roundness;
  final bool showPercentage;
  final String? label;
  late ColorRGBA bgColor;
  late ColorRGBA valueColor;
  late ColorRGBA textColor;

  double _animTime = 0.0;

  ProgressBar({
    String? className,
    this.value,
    this.minHeight = 10,
    this.roundness = 0.5,
    this.showPercentage = false,
    this.label,
    int width = 0,
    int height = 0,
    bool fillWidth = true,
    super.expand,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : super(fillWidth: fillWidth) {
    final style = className != null ? Style.merge(className) : null;
    bgColor = style?.bgColor ?? const ColorRGBA(32, 38, 50);
    valueColor =
        style?.accentColor ?? style?.borderColor ?? ColorRGBA.accentBlue;
    textColor = style?.textColor ?? ColorRGBA.white;

    final headerH = (label != null || showPercentage) ? 20 : 0;
    this.width = width != 0 ? width : (style?.width ?? 200);
    this.height = height != 0 ? height : (headerH + minHeight + 4);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    if (value == null) {
      _animTime += dt * 2.0;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || width <= 0) return;

    int barY = y;

    // 1. Renderizar encabezado con etiqueta y porcentaje si están presentes
    if (label != null || showPercentage) {
      if (label != null) {
        ctx2d.drawText(label!, x, y, 12, const ColorRGBA(180, 195, 215));
      }
      if (showPercentage && value != null) {
        final pctText = "${(value!.clamp(0.0, 1.0) * 100).toInt()}%";
        final pctW = pctText.length * 7;
        final pctX = x + width - pctW;
        ctx2d.drawText(pctText, pctX, y, 12, textColor);
      }
      barY += 18;
    }

    final barH = minHeight;

    // 2. Fondo de la barra de progreso
    ctx2d.drawRoundRect(x, barY, width, barH, roundness, color: bgColor);
    ctx2d.drawRoundRectLines(
      x,
      barY,
      width,
      barH,
      roundness,
      color: const ColorRGBA(55, 65, 82),
    );

    // 3. Relleno activo de progreso
    if (value != null) {
      final clampedVal = value!.clamp(0.0, 1.0);
      final fillW = (width * clampedVal).toInt();
      if (fillW >= 2) {
        ctx2d.drawRoundRect(x, barY, fillW, barH, roundness, color: valueColor);
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
        roundness,
        color: valueColor,
      );
      ctx2d.endScissor();
    }
  }
}
