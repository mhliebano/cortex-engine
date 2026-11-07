import 'dart:math';
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/structure_node.dart';

/// Orientación del divisor en un `Splitter`.
enum SplitterAxis {
  /// Disposición lado a lado (panel izquierdo | divisor | panel derecho).
  horizontal,

  /// Disposición apilada (panel superior / divisor / panel inferior).
  vertical,
}

/// Contenedor Divisor Redimensionable (`Splitter` / `SplitPanel`) bajo la arquitectura Cortex.
///
/// Divide el área disponible entre dos paneles hijos ([first], [second]) mediante una barra divisoria
/// interactiva que puede ser arrastrada con el ratón para redistribuir el espacio en tiempo real.
///
/// Soporta:
/// - Orientación horizontal y vertical ([axis]).
/// - Proporción inicial y dinámica de división ([split] de `0.0` a `1.0`, por defecto `0.5`).
/// - Restricciones de tamaño mínimo por píxeles o porcentaje ([minFirst], [minSecond]).
/// - Detección de arrastre y hover interactivo con cambio de color y tirador visual (grip handle).
/// - Preservación y restauración de estado ([exportState] e [importState]).
class Splitter extends StructureNode {
  final SplitterAxis axis;
  double split;
  final double minFirst;
  final double minSecond;
  final int dividerSize;
  final CortexNode first;
  final CortexNode second;
  final void Function(double split)? onSplitChanged;

  ColorRGBA? dividerColor;
  ColorRGBA? hoverDividerColor;
  ColorRGBA? gripColor;

  bool _isHoveredDivider = false;
  bool _isDragging = false;
  double _dragStartMouse = 0.0;
  double _dragStartSplit = 0.5;

  static const int _unconstrained = 1000000;
  int _maxWidthConstraint = _unconstrained;
  int _maxHeightConstraint = _unconstrained;

  Splitter({
    super.key,
    this.axis = SplitterAxis.horizontal,
    this.split = 0.5,
    this.minFirst = 50.0,
    this.minSecond = 50.0,
    this.dividerSize = 8,
    required this.first,
    required this.second,
    this.onSplitChanged,
    this.dividerColor,
    this.hoverDividerColor,
    this.gripColor,
  }) {
    split = split.clamp(0.05, 0.95);
    _performLayout();
  }

  @override
  List<CortexNode> get childrenElements => [first, second];

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  Map<String, dynamic>? exportState() {
    return {'split': split};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('split')) {
      split = (state['split'] as num).toDouble().clamp(0.05, 0.95);
      _performLayout();
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    _maxWidthConstraint = maxWidth > 0 ? maxWidth : _unconstrained;
    _maxHeightConstraint = maxHeight > 0 ? maxHeight : _unconstrained;
    _performLayout();
  }

  void _performLayout() {
    final effectiveW = _maxWidthConstraint != _unconstrained
        ? _maxWidthConstraint
        : (width > 0 ? width : 400);
    final effectiveH = _maxHeightConstraint != _unconstrained
        ? _maxHeightConstraint
        : (height > 0 ? height : 300);

    width = effectiveW;
    height = effectiveH;

    if (axis == SplitterAxis.horizontal) {
      final available = max(0, width - dividerSize);

      final minFirstPx = minFirst <= 1.0
          ? (available * minFirst).round()
          : minFirst.round();
      final minSecondPx = minSecond <= 1.0
          ? (available * minSecond).round()
          : minSecond.round();

      final maxFirstPx = max(minFirstPx, available - minSecondPx);
      final rawFirstPx = (available * split).round();
      final firstW = rawFirstPx.clamp(minFirstPx, maxFirstPx);
      final secondW = max(0, available - firstW);

      first.x = x;
      first.y = y;
      first.onResize(firstW, height);

      second.x = x + firstW + dividerSize;
      second.y = y;
      second.onResize(secondW, height);
    } else {
      final available = max(0, height - dividerSize);

      final minFirstPx = minFirst <= 1.0
          ? (available * minFirst).round()
          : minFirst.round();
      final minSecondPx = minSecond <= 1.0
          ? (available * minSecond).round()
          : minSecond.round();

      final maxFirstPx = max(minFirstPx, available - minSecondPx);
      final rawFirstPx = (available * split).round();
      final firstH = rawFirstPx.clamp(minFirstPx, maxFirstPx);
      final secondH = max(0, available - firstH);

      first.x = x;
      first.y = y;
      first.onResize(width, firstH);

      second.x = x;
      second.y = y + firstH + dividerSize;
      second.onResize(width, secondH);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    final firstW = first.width;
    final firstH = first.height;

    // 1. Detección de colisión del divisor
    if (axis == SplitterAxis.horizontal) {
      final divX = x + firstW;
      final divY = y;
      final divW = dividerSize;
      final divH = height;

      // Expandir ligeramente el margen de hover para facilidad de clic
      _isHoveredDivider = input.isHovering(divX - 2, divY, divW + 4, divH);

      if (_isHoveredDivider && input.isMouseButtonPressed(MouseButtons.left)) {
        _isDragging = true;
        _dragStartMouse = input.mouseX;
        _dragStartSplit = split;
      }

      if (_isDragging) {
        if (input.isMouseButtonDown(MouseButtons.left)) {
          final delta = input.mouseX - _dragStartMouse;
          final available = max(1, width - dividerSize);
          final deltaSplit = delta / available;
          final newSplit = (_dragStartSplit + deltaSplit).clamp(0.05, 0.95);

          if ((newSplit - split).abs() > 0.001) {
            split = newSplit;
            _performLayout();
            onSplitChanged?.call(split);
          }
        } else {
          _isDragging = false;
        }
      }
    } else {
      final divX = x;
      final divY = y + firstH;
      final divW = width;
      final divH = dividerSize;

      _isHoveredDivider = input.isHovering(divX, divY - 2, divW, divH + 4);

      if (_isHoveredDivider && input.isMouseButtonPressed(MouseButtons.left)) {
        _isDragging = true;
        _dragStartMouse = input.mouseY;
        _dragStartSplit = split;
      }

      if (_isDragging) {
        if (input.isMouseButtonDown(MouseButtons.left)) {
          final delta = input.mouseY - _dragStartMouse;
          final available = max(1, height - dividerSize);
          final deltaSplit = delta / available;
          final newSplit = (_dragStartSplit + deltaSplit).clamp(0.05, 0.95);

          if ((newSplit - split).abs() > 0.001) {
            split = newSplit;
            _performLayout();
            onSplitChanged?.call(split);
          }
        } else {
          _isDragging = false;
        }
      }
    }

    if (first.isVisible) first.onUpdate(dt, input);
    if (second.isVisible) second.onUpdate(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    if (first.isVisible) first.onRender(ctx2d, ctx3d);
    if (second.isVisible) second.onRender(ctx2d, ctx3d);

    // 2. Renderizado de la barra divisoria
    final defaultBg = dividerColor ?? const ColorRGBA(30, 36, 48);
    final activeBg = hoverDividerColor ?? ColorRGBA.accentBlue;
    final handleCol = gripColor ?? const ColorRGBA(120, 135, 160);

    final bgToUse = _isDragging
        ? activeBg
        : (_isHoveredDivider ? ColorRGBA(activeBg.r, activeBg.g, activeBg.b, 180) : defaultBg);

    if (axis == SplitterAxis.horizontal) {
      final divX = x + first.width;
      final divY = y;
      final divW = dividerSize;
      final divH = height;

      // Pista divisoria
      ctx2d.drawRect(divX, divY, divW, divH, bgToUse);

      // Tirador central (3 puntos verticales)
      final midY = divY + (divH ~/ 2);
      final midX = divX + (divW ~/ 2);
      final dotR = max(1.0, divW / 5.0);

      ctx2d.drawCircle(midX, midY - 8, dotR, handleCol);
      ctx2d.drawCircle(midX, midY, dotR, handleCol);
      ctx2d.drawCircle(midX, midY + 8, dotR, handleCol);
    } else {
      final divX = x;
      final divY = y + first.height;
      final divW = width;
      final divH = dividerSize;

      // Pista divisoria
      ctx2d.drawRect(divX, divY, divW, divH, bgToUse);

      // Tirador central (3 puntos horizontales)
      final midX = divX + (divW ~/ 2);
      final midY = divY + (divH ~/ 2);
      final dotR = max(1.0, divH / 5.0);

      ctx2d.drawCircle(midX - 8, midY, dotR, handleCol);
      ctx2d.drawCircle(midX, midY, dotR, handleCol);
      ctx2d.drawCircle(midX + 8, midY, dotR, handleCol);
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    if (first.isVisible) first.onRenderOverlay(ctx2d, ctx3d);
    if (second.isVisible) second.onRenderOverlay(ctx2d, ctx3d);
  }
}

