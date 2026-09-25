import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/scroll_controller.dart';

/// Contenedor de Disposición Vertical (`Col`).
///
/// Opera exclusivamente dentro del espacio provisto por un [Panel], usando
/// coordenadas locales. Organiza widgets finales (botones, textos, entradas)
/// en un eje vertical.
///
/// El scroll vertical se activa **automáticamente** cuando el contenido supera
/// el alto disponible — no requiere ningún flag explícito.
///
/// Regla de dimensionamiento:
/// - Si el eje transversal (ancho) no es provisto por el Panel padre, debe
///   especificarse explícitamente mediante [width].
class Col extends Element {
  final ScrollController? controller;

  int spacing;
  int padding;

  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentHeight = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  final List<Element> children;

  Col({
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

    final availableWidth = width > (padding * 2) ? width - (padding * 2) : 0;
    final netAvailableHeight = height > (padding * 2)
        ? height - (padding * 2)
        : 0;

    // Pase 1: contabilizar hijos flex y no-flex
    int nonFlexHeight = 0;
    int flexCount = 0;
    int maxChildWidth = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child.isFlexHeight) {
        flexCount++;
      } else {
        nonFlexHeight += child.height;
      }
      if (!child.isFlexWidth && child.width > maxChildWidth) {
        maxChildWidth = child.width;
      }
      if (i > 0) nonFlexHeight += spacing;
    }

    // Pase 2: distribuir espacio entre hijos flex
    int totalChildrenHeight = nonFlexHeight;

    if (flexCount > 0 && netAvailableHeight > nonFlexHeight) {
      final remaining = netAvailableHeight - nonFlexHeight;
      final perFlex = remaining ~/ flexCount;

      totalChildrenHeight = 0;
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        if (child.isFlexHeight) child.height = perFlex;
        totalChildrenHeight += child.height;
        if (i > 0) totalChildrenHeight += spacing;
      }
    }

    _contentHeight = totalChildrenHeight + (padding * 2);

    // Auto-ajuste de alto si el Col no tiene alto fijo propio
    if (height == 0 && _contentHeight > 0) {
      height = _contentHeight;
    }

    final calcAvailableHeight = height > (padding * 2)
        ? height - (padding * 2)
        : 0;
    final extraSpace = calcAvailableHeight > totalChildrenHeight
        ? calcAvailableHeight - totalChildrenHeight
        : 0;

    // Pase 3: posición inicial Y según mainAxisAlignment
    double startY = (y + padding - scrollOffset).toDouble();
    double dynSpacing = spacing.toDouble();

    final isScrollActive = _contentHeight > height;

    if (extraSpace > 0 && !isScrollActive) {
      switch (mainAxisAlignment) {
        case MainAxisAlignment.start:
          startY = (y + padding - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.end:
          startY = (y + padding + extraSpace - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.center:
          startY = (y + padding + (extraSpace / 2) - scrollOffset).toDouble();
          break;
        case MainAxisAlignment.spaceBetween:
          startY = (y + padding - scrollOffset).toDouble();
          if (children.length > 1) {
            dynSpacing = spacing + (extraSpace / (children.length - 1));
          }
          break;
        case MainAxisAlignment.spaceAround:
          if (children.isNotEmpty) {
            final gap = extraSpace / children.length;
            startY = (y + padding + (gap / 2) - scrollOffset).toDouble();
            dynSpacing = spacing + gap;
          }
          break;
        case MainAxisAlignment.spaceEvenly:
          if (children.isNotEmpty) {
            final gap = extraSpace / (children.length + 1);
            startY = (y + padding + gap - scrollOffset).toDouble();
            dynSpacing = spacing + gap;
          }
          break;
      }
    }

    // Pase 4: posicionar cada hijo
    double currentY = startY;
    for (final child in children) {
      child.y = currentY.toInt();

      switch (crossAxisAlignment) {
        case CrossAxisAlignment.stretch:
          child.x = x + padding;
          if (availableWidth > 0) child.width = availableWidth;
          break;
        case CrossAxisAlignment.start:
          child.x = x + padding;
          if (child.isFlexWidth && availableWidth > 0) {
            child.width = availableWidth;
          }
          break;
        case CrossAxisAlignment.center:
          if (child.isFlexWidth && availableWidth > 0) {
            child.x = x + padding;
            child.width = availableWidth;
          } else {
            final spaceX = availableWidth > child.width
                ? availableWidth - child.width
                : 0;
            child.x = x + padding + (spaceX ~/ 2);
          }
          break;
        case CrossAxisAlignment.end:
          if (child.isFlexWidth && availableWidth > 0) {
            child.x = x + padding;
            child.width = availableWidth;
          } else {
            final spaceX = availableWidth > child.width
                ? availableWidth - child.width
                : 0;
            child.x = x + padding + spaceX;
          }
          break;
      }

      child.onResize(child.width, child.height);
      currentY += child.height + dynSpacing;
    }
  }

  // ─────────────────────────────────────────────
  // Scroll interno
  // ─────────────────────────────────────────────

  double get _maxScroll =>
      _contentHeight > height ? (_contentHeight - height).toDouble() : 0.0;

  void _handleScroll(InputEngine input) {
    final maxScroll = _maxScroll;
    if (maxScroll <= 0 || height <= 0) return;

    final scrollbarHeight = ((height / _contentHeight) * height).toInt().clamp(
      20,
      height,
    );
    final scrollbarY =
        y + ((scrollOffset / maxScroll) * (height - scrollbarHeight)).toInt();
    final scrollbarHitX = x + width - 14;
    final trackSpace = (height - scrollbarHeight).toDouble();

    _isHoveringScrollbar = input.isHovering(scrollbarHitX, y, 14, height);

    // Iniciar arrastre
    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarHitX, scrollbarY, 14, scrollbarHeight) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartY = input.mouseY;
        _dragStartOffset = scrollOffset;
      }
    }

    // Arrastre continuo
    if (_isDraggingScrollbar) {
      if (input.isMouseButtonDown(MouseButtons.left)) {
        final deltaY = input.mouseY - _dragStartY;
        if (trackSpace > 0) {
          final delta = (deltaY / trackSpace) * maxScroll;
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

    final scrollbarHeight = ((height / _contentHeight) * height).toInt().clamp(
      20,
      height,
    );
    final scrollbarY =
        y + ((scrollOffset / maxScroll) * (height - scrollbarHeight)).toInt();
    final isHighlighted = _isDraggingScrollbar || _isHoveringScrollbar;
    final barWidth = isHighlighted ? 6 : 4;
    final color = isHighlighted
        ? const ColorRGBA(255, 255, 255, 220)
        : const ColorRGBA(255, 255, 255, 120);

    ctx2d.drawRect(
      x + width - (barWidth + 2),
      scrollbarY,
      barWidth,
      scrollbarHeight,
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
