import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/layout_alignment.dart';
import 'package:frontend/core/ui/scroll_controller.dart';
import 'package:frontend/core/ui/structure_node.dart';
import 'package:frontend/core/ui/layouts/spacer.dart';

/// Contenedor de Disposición Horizontal (`Row`).
class Row extends StructureNode {
  final MainAlign mainAlign;
  final CrossAlign crossAlign;
  final Overflow overflow;
  final double gap;
  final List<CortexNode> children;
  final ScrollController? controller;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentWidth = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartX = 0.0;
  double _dragStartOffset = 0.0;

  Row({
    super.key,
    this.mainAlign = MainAlign.start,
    this.crossAlign = CrossAlign.start,
    this.overflow = Overflow.visible,
    this.gap = 0.0,
    this.children = const [],
    this.controller,
  }) {
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
  List<CortexNode> get childrenElements => children;

  @override
  bool get isFlexHeight =>
      children.any((c) => (c is Spacer && c.size == null) || c.isFlexHeight);

  @override
  bool get isFlexWidth =>
      children.isEmpty ||
      mainAlign != MainAlign.start ||
      children.any((c) => (c is Spacer && c.size == null) || c.isFlexWidth);

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

  void _performLayout() {
    if (children.isEmpty) return;

    // Paso 1 (Medición Rígida y Eje Transversal)
    int sumChildWidths = 0;
    int flexibleSpacerCount = 0;
    int maxChildHeight = 0;

    for (final child in children) {
      if (child.height > maxChildHeight) {
        maxChildHeight = child.height;
      }

      if (child is Spacer) {
        if (child.size != null) {
          final sz = child.size!.round();
          sumChildWidths += sz;
          child.width = sz;
        } else {
          flexibleSpacerCount++;
        }
      } else if (child.isFlexWidth) {
        flexibleSpacerCount++;
      } else {
        sumChildWidths += child.width;
      }
    }

    final gapTotal =
        children.length > 1 ? ((children.length - 1) * gap).round() : 0;
    int rigidSum = sumChildWidths + gapTotal;

    _contentWidth = rigidSum;

    // Eje Transversal (Height): shrink-wrap a la altura del hijo más alto si no se asignó previamente
    if (height == 0) {
      height = maxChildHeight;
    }

    // Eje Principal (Width): si width no ha sido asignado por el padre, shrink-wrap a rigidSum
    if (width == 0) {
      width = rigidSum;
    }

    final availableHeight = height;

    // Paso 2 (Los Resortes) & Paso 3 (Repartición de Espacio en Eje Principal)
    double currentX = (x - scrollOffset).toDouble();
    double currentGap = gap;

    if (flexibleSpacerCount > 0) {
      final remainingSpace = width - rigidSum;
      final spacerWidth = remainingSpace > 0
          ? (remainingSpace / flexibleSpacerCount).floor()
          : 0;
      for (final child in children) {
        if ((child is Spacer && child.size == null) || child.isFlexWidth) {
          child.width = spacerWidth;
        }
      }
    } else {
      final freeSpace =
          (width > rigidSum) ? (width - rigidSum).toDouble() : 0.0;
      switch (mainAlign) {
        case MainAlign.start:
          currentX = (x - scrollOffset).toDouble();
          break;
        case MainAlign.center:
          currentX = (x - scrollOffset) + (freeSpace / 2);
          break;
        case MainAlign.end:
          currentX = (x - scrollOffset) + freeSpace;
          break;
        case MainAlign.spaceBetween:
          currentX = (x - scrollOffset).toDouble();
          if (children.length > 1) {
            currentGap = gap + (freeSpace / (children.length - 1));
          }
          break;
        case MainAlign.spaceAround:
          if (children.isNotEmpty) {
            final spacePerItem = freeSpace / children.length;
            currentX = (x - scrollOffset) + (spacePerItem / 2);
            currentGap = gap + spacePerItem;
          }
          break;
      }
    }

    for (final child in children) {
      child.x = currentX.round();

      if (child is StructureNode) {
        child.y = y;
        if (availableHeight > 0) child.height = availableHeight;
      } else {
        switch (crossAlign) {
          case CrossAlign.stretch:
            child.y = y;
            if (availableHeight > 0) child.height = availableHeight;
            break;
          case CrossAlign.start:
            child.y = y;
            break;
          case CrossAlign.center:
            final spaceY = availableHeight > child.height
                ? availableHeight - child.height
                : 0;
            child.y = y + (spaceY ~/ 2);
            break;
          case CrossAlign.end:
            final spaceY = availableHeight > child.height
                ? availableHeight - child.height
                : 0;
            child.y = y + spaceY;
            break;
        }
      }

      child.onResize(child.width, child.height);
      currentX += child.width + currentGap;
    }
  }

  double get _maxScroll =>
      _contentWidth > width ? (_contentWidth - width).toDouble() : 0.0;

  void _handleScroll(InputEngine input) {
    if (overflow != Overflow.scroll && overflow != Overflow.auto) return;
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

    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarX, scrollbarHitY, scrollbarWidth, 14) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartX = input.mouseX;
        _dragStartOffset = scrollOffset;
      }
    }

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

    final useClip = overflow == Overflow.hidden ||
        overflow == Overflow.scroll ||
        (overflow == Overflow.auto && _contentWidth > width);

    if (useClip && width > 0 && height > 0) {
      ctx2d.beginScissor(x, y, width, height);
    }

    for (final child in children) {
      if (child.isVisible) child.onRender(ctx2d, ctx3d);
    }

    if (useClip && width > 0 && height > 0) {
      if (overflow == Overflow.scroll ||
          (overflow == Overflow.auto && _contentWidth > width)) {
        _renderScrollbar(ctx2d);
      }
      ctx2d.endScissor();
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final child in children) {
      if (child.isVisible) child.onRenderOverlay(ctx2d, ctx3d);
    }
    super.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
