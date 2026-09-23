import 'dart:math' as math;
import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/style.dart';

/// Variante de estilo del indicador de carga (`LoadingVariant`).
enum LoadingVariant {
  /// Anillo de progreso rotatorio fluido de grosor adaptable con estela en degradado.
  circular,

  /// Indicador de actividad radial con 12 barras giratorias estilo macOS / Material 3.
  spinner,

  /// Trío de puntos flotantes pulsantes con desfase senoidal y brillo.
  dots,

  /// Pulso concéntrico expansivo con núcleo brillante.
  pulse,
}

/// Componente Indicador de Carga Animado de Alta Fidelidad (`LoadingIndicator`).
class LoadingIndicator extends Element {
  final LoadingVariant variant;
  final int size;
  final double speed;
  final double strokeWidth;
  final String? label;
  late int labelFontSize;
  late ColorRGBA color;
  late ColorRGBA labelColor;

  double _animTime = 0.0;

  LoadingIndicator({
    super.key,
    String? className,
    this.variant = LoadingVariant.circular,
    this.size = 32,
    this.speed = 1.0,
    double? strokeWidth,
    this.label,
    int width = 0,
    int height = 0,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : strokeWidth = strokeWidth ?? (size / 8.0).clamp(2.5, 6.0) {
    final style = className != null ? Style.merge(className) : null;
    color = style?.accentColor ?? style?.borderColor ?? ColorRGBA.accentBlue;
    labelColor = style?.textColor ?? ColorRGBA.white;
    labelFontSize = style?.fontSize ?? 13;

    final labelW = label != null ? (label!.length * 8 + 14) : 0;
    final baseW = variant == LoadingVariant.dots ? (size * 2) : size;
    this.width = width != 0 ? width : (baseW + labelW);
    this.height = height != 0
        ? height
        : (size > labelFontSize ? size : labelFontSize + 6);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _animTime += dt * speed;
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final centerY = y + (height ~/ 2);

    switch (variant) {
      case LoadingVariant.circular:
        _renderCircular(ctx2d, centerY);
        break;
      case LoadingVariant.spinner:
        _renderSpinner(ctx2d, centerY);
        break;
      case LoadingVariant.dots:
        _renderDots(ctx2d, centerY);
        break;
      case LoadingVariant.pulse:
        _renderPulse(ctx2d, centerY);
        break;
    }

    if (label != null) {
      final labelX = (variant == LoadingVariant.dots
          ? (x + size * 2 + 10)
          : (x + size + 12));
      final labelY = centerY - (labelFontSize ~/ 2);
      ctx2d.drawText(label!, labelX, labelY, labelFontSize, labelColor);
    }
  }

  /// Renderizado de anillo rotatorio fluido con estela y cabezal brillante
  void _renderCircular(Context2D ctx2d, int centerY) {
    final radius = (size / 2.0 - strokeWidth).clamp(4.0, 80.0);
    final centerX = x + (size ~/ 2);

    // 1. Pista base de fondo semi-transparente
    final trackColor = ColorRGBA(color.r, color.g, color.b, 35);
    _drawThickArc(
      ctx2d,
      centerX,
      centerY,
      radius,
      0,
      360,
      strokeWidth,
      trackColor,
    );

    // 2. Cálculo de barrido y rotación fluida (onda senoidal expansiva)
    final rotationAngle = (_animTime * 240.0) % 360.0;
    final sweepSpan = 40.0 + (math.sin(_animTime * 3.0) * 0.5 + 0.5) * 160.0;
    final startAngle = rotationAngle;
    final endAngle = startAngle + sweepSpan;

    // 3. Estela degradada en capas con opacidad progresiva
    const steps = 6;
    for (int i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 = (i + 1) / steps;
      final segStart = startAngle + (sweepSpan * t1);
      final segEnd = startAngle + (sweepSpan * t2);

      final alpha = (math.pow(t2, 1.8) * (color.a - 20) + 20).toInt().clamp(
        20,
        255,
      );
      final stepColor = ColorRGBA(color.r, color.g, color.b, alpha);

      _drawThickArc(
        ctx2d,
        centerX,
        centerY,
        radius,
        segStart,
        segEnd,
        strokeWidth,
        stepColor,
      );
    }

    // 4. Cabezal de cierre (Round Cap) en la punta principal
    final headRad = endAngle * math.pi / 180.0;
    final headX = centerX + math.cos(headRad) * radius;
    final headY = centerY + math.sin(headRad) * radius;

    final capRadius = strokeWidth / 1.6;
    ctx2d.drawCircle(headX.toInt(), headY.toInt(), capRadius, color);
    ctx2d.drawCircle(
      headX.toInt(),
      headY.toInt(),
      capRadius * 0.5,
      ColorRGBA.white,
    );
  }

  /// Renderizado de indicador radial de 12 barras (macOS / iOS activity indicator)
  void _renderSpinner(Context2D ctx2d, int centerY) {
    final centerX = x + (size ~/ 2);
    final innerR = size * 0.22;
    final outerR = size * 0.42;

    const totalDashes = 12;
    for (int i = 0; i < totalDashes; i++) {
      final angle = (i * 30.0) * math.pi / 180.0;
      final phase = ((_animTime * 1.6 - (i / totalDashes)) % 1.0);
      final alpha = (math.pow(phase, 2.5) * 215 + 40).toInt().clamp(40, 255);
      final dashColor = ColorRGBA(color.r, color.g, color.b, alpha);

      final x1 = centerX + math.cos(angle) * innerR;
      final y1 = centerY + math.sin(angle) * innerR;
      final x2 = centerX + math.cos(angle) * outerR;
      final y2 = centerY + math.sin(angle) * outerR;

      _drawLineThick(
        ctx2d,
        x1,
        y1,
        x2,
        y2,
        (strokeWidth * 0.9).clamp(2.0, 5.0),
        dashColor,
      );
    }
  }

  /// Renderizado de 3 puntos flotantes pulsantes
  void _renderDots(Context2D ctx2d, int centerY) {
    final dotRadius = (size / 5.5).clamp(3.0, 12.0);
    final spacing = (dotRadius * 2.8).toInt();
    final startX = x + dotRadius.toInt() + 4;

    for (int i = 0; i < 3; i++) {
      final phaseOffset = i * 0.6;
      final sineVal = math.sin((_animTime * 5.0) - phaseOffset);
      final offsetY = (sineVal * (dotRadius * 0.9)).toInt();

      final alpha = ((sineVal * 0.5 + 0.5) * 185 + 70).toInt().clamp(50, 255);
      final dotColor = ColorRGBA(color.r, color.g, color.b, alpha);

      // Sombra inferior sutil
      ctx2d.drawCircle(
        startX + (i * spacing),
        centerY + (dotRadius * 0.8).toInt(),
        dotRadius * 0.7,
        const ColorRGBA(0, 0, 0, 40),
      );
      // Punto principal
      ctx2d.drawCircle(
        startX + (i * spacing),
        centerY - offsetY,
        dotRadius,
        dotColor,
      );
      // Brillo en el centro
      ctx2d.drawCircle(
        startX + (i * spacing),
        centerY - offsetY,
        dotRadius * 0.4,
        ColorRGBA(255, 255, 255, alpha ~/ 2),
      );
    }
  }

  /// Renderizado de onda de pulso concéntrica
  void _renderPulse(Context2D ctx2d, int centerY) {
    final centerX = x + (size ~/ 2);
    final maxR = size / 2.0;

    final phase = (_animTime * 1.5) % 1.0;
    final pulseR = maxR * phase;
    final alpha = ((1.0 - phase) * 220).toInt().clamp(0, 255);

    // Anillo concéntrico en expansión
    ctx2d.drawCircleLines(
      centerX,
      centerY,
      pulseR,
      ColorRGBA(color.r, color.g, color.b, alpha),
    );
    // Núcleo brillante sólido
    ctx2d.drawCircle(centerX, centerY, maxR * 0.3, color);
    ctx2d.drawCircle(centerX, centerY, maxR * 0.15, ColorRGBA.white);
  }

  /// Utilidad para dibujar arcos con grosor utilizando múltiples capas concéntricas
  void _drawThickArc(
    Context2D ctx2d,
    int cx,
    int cy,
    double radius,
    double startAngle,
    double endAngle,
    double thickness,
    ColorRGBA col,
  ) {
    final half = thickness / 2.0;
    final steps = thickness <= 3 ? 2 : 4;
    for (int i = 0; i < steps; i++) {
      final r = radius - half + (thickness * (i / (steps - 1)));
      ctx2d.drawArcLines(
        cx,
        cy,
        r,
        startAngle,
        endAngle,
        segments: 40,
        color: col,
      );
    }
  }

  /// Utilidad para dibujar líneas con grosor mediante polígonos rellenos / tiras
  void _drawLineThick(
    Context2D ctx2d,
    double x1,
    double y1,
    double x2,
    double y2,
    double thickness,
    ColorRGBA col,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final px = -dy / len * (thickness / 2.0);
    final py = dx / len * (thickness / 2.0);

    ctx2d.drawCircle(x1.toInt(), y1.toInt(), thickness / 2.0, col);
    ctx2d.drawCircle(x2.toInt(), y2.toInt(), thickness / 2.0, col);
    ctx2d.drawRect(
      (x1 + px).toInt(),
      (y1 + py).toInt(),
      (len).toInt(),
      thickness.toInt(),
      col,
    );
  }
}
