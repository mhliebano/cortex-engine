import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/scroll_controller.dart';

/// Contenedor de Disposición Horizontal (`Row`).
///
/// Opera exclusivamente dentro del espacio provisto por un [Panel], usando
/// coordenadas locales. Organiza widgets finales (botones, textos, entradas)
/// en un eje horizontal.
///
/// El scroll horizontal se activa **automáticamente** cuando el contenido supera
/// el ancho disponible — no requiere ningún flag explícito.
///
/// Regla de dimensionamiento:
/// - Si el eje transversal (alto) no es provisto por el Panel padre, debe
///   especificarse explícitamente mediante [height].
class Row extends Element {
  final ScrollController? controller;

  int spacing;
  int padding;

  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentWidth = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartX = 0.0;
  double _dragStartOffset = 0.0;

  final List<Element> children;

  Row({
    super.key,
    this.controller,
    int width = 0,
    int height = 0,
    this.spacing = 8,
    this.padding = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
    required this.children,
  }) {
    this.width = width;
    this.height = height;

    if (controller != null) {
      scrollOffset = controller!.offset;
      controller!.addListener((newOffset) {
        scrollOffset = newOffset;
        _performLayout();
      });
    }

    _performLayout();
  }

  @override
  List<Element> get childrenElements => children;

  @override
  Map<String, dynamic>? exportState() {
    if (scrollOffset == 0.0) return null;
    return {'scrollOffset': scrollOffset};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('scrollOffset')) {
      scrollOffset = (state['scrollOffset'] as num).toDouble();
      if (controller != null) controller!.offset = scrollOffset;
      _performLayout();
    }
  }

  // ─────────────────────────────────────────────
  // Layout
  // ─────────────────────────────────────────────

  void _performLayout() {
    if (children.isEmpty) return;

    final availableHeight = height > (padding * 2) ? height - (padding * 2) : 0;
    final netAvailableWidth = width > (padding * 2) ? width - (padding * 2) : 0;

    // Pase 1: contabilizar hijos flex y no-flex
    int nonFlexWidth = 0;
    int flexCount = 0;
    int maxChildHeight = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child.isFlexWidth) {
        flexCount++;
      } else {
        nonFlexWidth += child.width;
      }
      if (child.height > maxChildHeight) maxChildHeight = child.height;
      if (i > 0) nonFlexWidth += spacing;
    }

    // Pase 2: distribuir espacio entre hijos flex
    int totalChildrenWidth = nonFlexWidth;

    if (flexCount > 0 && netAvailableWidth > nonFlexWidth) {
      final remaining = netAvailableWidth - nonFlexWidth;
      final perFlex = remaining ~/ flexCount;

      totalChildrenWidth = 0;
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        if (child.isFlexWidth) child.width = perFlex;
        totalChildrenWidth += child.width;
        if (i > 0) totalChildrenWidth += spacing;
      }
    }

    _contentWidth = totalChildrenWidth + (padding * 2);

    // Auto-ajuste de ancho si el Row no tiene ancho fijo propio
    if (width == 0 && _contentWidth > 0) {
      width = _contentWidth;
    }

    final calcAvailableWidth = width > (padding * 2)
        ? width - (padding * 2)
        : 0;
    final extraSpace = calcAvailableWidth > totalChildrenWidth
        ? calcAvailableWidth - totalChildrenWidth
        : 0;

    // Pase 3: posición inicial X según mainAxisAlignment
    final isScrollActive = _contentWidth > width;
    double startX = (x + padding - scrollOffset).toDouble();
    double dynSpacing = spacing.toDouble();

    if (extraSpace > 0 && !isScrollActive) {
      switch (mainAxisAlignment) {
        case MainAxisAlignment.start:
          startX = (x + padding - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.end:
          startX = (x + padding + extraSpace - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.center:
          startX = (x + padding + (extraSpace / 2) - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.spaceBetween:
          startX = (x + padding - scrollOffset).toDouble();
          if (children.length > 1) {
            dynSpacing = spacing + (extraSpace / (children.length - 1));
          }
          break;
        case MainAxisAlignment.spaceAround:
          if (children.isNotEmpty) {
            final gap = extraSpace / children.length;
            startX = (x + padding + (gap / 2) - scrollOffset).toDouble();
            dynSpacing = spacing + gap;
          }
          break;
        case MainAxisAlignment.spaceEvenly:
          if (children.isNotEmpty) {
            final gap = extraSpace / (children.length + 1);
            startX = (x + padding + gap - scrollOffset).toDouble();
            dynSpacing = spacing + gap;
          }
          break;
      }
    }

    // Pase 4: posicionar cada hijo
    double currentX = startX;
    for (final child in children) {
      child.x = currentX.toInt();

      switch (crossAxisAlignment) {
        case CrossAxisAlignment.stretch:
          child.y = y + padding;
          if (availableHeight > 0) child.height = availableHeight;
          break;
        case CrossAxisAlignment.start:
          child.y = y + padding;
          if (child.isFlexHeight && availableHeight > 0) {
            child.height = availableHeight;
          }
          break;
        case CrossAxisAlignment.center:
          if (child.isFlexHeight && availableHeight > 0) {
            child.y = y + padding;
            child.height = availableHeight;
          } else {
            final spaceY = availableHeight > child.height
                ? availableHeight - child.height
                : 0;
            child.y = y + padding + (spaceY ~/ 2);
          }
          break;
        case CrossAxisAlignment.end:
          if (child.isFlexHeight && availableHeight > 0) {
            child.y = y + padding;
            child.height = availableHeight;
          } else {
            final spaceY = availableHeight > child.height
                ? availableHeight - child.height
                : 0;
            child.y = y + padding + spaceY;
          }
          break;
      }

      child.onResize(child.width, child.height);
      currentX += child.width + dynSpacing;
    }
  }

  // ─────────────────────────────────────────────
  // Scroll interno
  // ─────────────────────────────────────────────

  double get _maxScroll =>
      _contentWidth > width ? (_contentWidth - width).toDouble() : 0.0;

  void _handleScroll(InputEngine input) {
    final maxScroll = _maxScroll;
    if (maxScroll <= 0 || width <= 0) return;

    final scrollbarWidth = ((width / _contentWidth) * width).toInt().clamp(
      20,
      width,
    );
    final scrollbarX =
        x + ((scrollOffset / maxScroll) * (width - scrollbarWidth)).toInt();
    final scrollbarHitY = y + height - 14;
    final trackSpace = (width - scrollbarWidth).toDouble();

    _isHoveringScrollbar = input.isHovering(x, scrollbarHitY, width, 14);

    // Iniciar arrastre
    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarX, scrollbarHitY, scrollbarWidth, 14) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartX = input.mouseX;
        _dragStartOffset = scrollOffset;
      }
    }

    // Arrastre continuo
    if (_isDraggingScrollbar) {
      if (input.isMouseButtonDown(MouseButtons.left)) {
        final deltaX = input.mouseX - _dragStartX;
        if (trackSpace > 0) {
          final delta = (deltaX / trackSpace) * maxScroll;
          scrollOffset = (_dragStartOffset + delta).clamp(0.0, maxScroll);
          if (controller != null) controller!.offset = scrollOffset;
          _performLayout();
        }
      } else {
        _isDraggingScrollbar = false;
      }
    }

    // Rueda del mouse
    if (input.isHovering(x, y, width, height)) {
      final wheel = input.mouseWheelMove;
      if (wheel != 0) {
        scrollOffset -= wheel * 30.0;
        scrollOffset = scrollOffset.clamp(0.0, maxScroll);
        if (controller != null) controller!.offset = scrollOffset;
        _performLayout();
      }
    }
  }

  void _renderScrollbar(Context2D ctx2d) {
    final maxScroll = _maxScroll;
    if (maxScroll <= 0) return;

    final scrollbarWidth = ((width / _contentWidth) * width).toInt().clamp(
      20,
      width,
    );
    final scrollbarX =
        x + ((scrollOffset / maxScroll) * (width - scrollbarWidth)).toInt();
    final isHighlighted = _isDraggingScrollbar || _isHoveringScrollbar;
    final barHeight = isHighlighted ? 6 : 4;
    final color = isHighlighted
        ? const ColorRGBA(255, 255, 255, 220)
        : const ColorRGBA(255, 255, 255, 120);

    ctx2d.drawRect(
      scrollbarX,
      y + height - (barHeight + 2),
      scrollbarWidth,
      barHeight,
      color,
    );
  }

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    _performLayout();
    _handleScroll(input);
    for (final child in children) {
      if (child.isVisible) child.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _performLayout();

    final useClip = width > 0 && height > 0;
    if (useClip) ctx2d.beginScissor(x, y, width, height);

    for (final child in children) {
      if (child.isVisible) child.onRender(ctx2d, ctx3d);
    }

    if (useClip) {
      _renderScrollbar(ctx2d);
      ctx2d.endScissor();
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final child in children) {
      if (child.isVisible) child.onRenderOverlay(ctx2d, ctx3d);
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
