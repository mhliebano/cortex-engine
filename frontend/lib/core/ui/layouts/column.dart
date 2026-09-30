import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/layout_alignment.dart';
import 'package:frontend/core/ui/scroll_controller.dart';
import 'package:frontend/core/ui/structure_node.dart';
import 'package:frontend/core/ui/layouts/spacer.dart';

/// Contenedor de Disposición Vertical (`Col`).
class Col extends StructureNode {
  final MainAlign mainAlign;
  final CrossAlign crossAlign;
  final Overflow overflow;
  final double gap;
  final List<CortexNode> children;
  final ScrollController? controller;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentHeight = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  Col({
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
  bool get isFlexWidth => children.any((c) => c.isFlexWidth);

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
    int sumChildHeights = 0;
    int flexibleSpacerCount = 0;
    int maxChildWidth = 0;

    for (final child in children) {
      if (child.width > maxChildWidth) {
        maxChildWidth = child.width;
      }

      if (child is Spacer) {
        if (child.size != null) {
          final sz = child.size!.round();
          sumChildHeights += sz;
          child.height = sz;
        } else {
          flexibleSpacerCount++;
        }
      } else if (child.isFlexHeight) {
        flexibleSpacerCount++;
      } else {
        sumChildHeights += child.height;
      }
    }

    final gapTotal =
        children.length > 1 ? ((children.length - 1) * gap).round() : 0;
    int rigidSum = sumChildHeights + gapTotal;

    _contentHeight = rigidSum;

    // Eje Transversal (Width): shrink-wrap al ancho del hijo más ancho si no se asignó previamente
    if (width == 0) {
      width = maxChildWidth;
    }

    // Eje Principal (Height): si height no ha sido asignado por el padre, shrink-wrap a rigidSum
    if (height == 0) {
      height = rigidSum;
    }

    final availableWidth = width;

    // Paso 2 (Los Resortes) & Paso 3 (Repartición de Espacio en Eje Principal)
    double currentY = (y - scrollOffset).toDouble();
    double currentGap = gap;

    if (flexibleSpacerCount > 0) {
      final remainingSpace = height - rigidSum;
      final spacerHeight = remainingSpace > 0
          ? (remainingSpace / flexibleSpacerCount).floor()
          : 0;
      for (final child in children) {
        if ((child is Spacer && child.size == null) || child.isFlexHeight) {
          child.height = spacerHeight;
        }
      }
    } else {
      final freeSpace =
          (height > rigidSum) ? (height - rigidSum).toDouble() : 0.0;
      switch (mainAlign) {
        case MainAlign.start:
          currentY = (y - scrollOffset).toDouble();
          break;
        case MainAlign.center:
          currentY = (y - scrollOffset) + (freeSpace / 2);
          break;
        case MainAlign.end:
          currentY = (y - scrollOffset) + freeSpace;
          break;
        case MainAlign.spaceBetween:
          currentY = (y - scrollOffset).toDouble();
          if (children.length > 1) {
            currentGap = gap + (freeSpace / (children.length - 1));
          }
          break;
        case MainAlign.spaceAround:
          if (children.isNotEmpty) {
            final spacePerItem = freeSpace / children.length;
            currentY = (y - scrollOffset) + (spacePerItem / 2);
            currentGap = gap + spacePerItem;
          }
          break;
      }
    }

    for (final child in children) {
      child.y = currentY.round();

      switch (crossAlign) {
        case CrossAlign.stretch:
          child.x = x;
          if (availableWidth > 0) child.width = availableWidth;
          break;
        case CrossAlign.start:
          child.x = x;
          break;
        case CrossAlign.center:
          final spaceX = availableWidth > child.width
              ? availableWidth - child.width
              : 0;
          child.x = x + (spaceX ~/ 2);
          break;
        case CrossAlign.end:
          final spaceX = availableWidth > child.width
              ? availableWidth - child.width
              : 0;
          child.x = x + spaceX;
          break;
      }

      child.onResize(child.width, child.height);
      currentY += child.height + currentGap;
    }
  }

  double get _maxScroll =>
      _contentHeight > height ? (_contentHeight - height).toDouble() : 0.0;

  void _handleScroll(InputEngine input) {
    if (overflow != Overflow.scroll && overflow != Overflow.auto) return;
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

    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarHitX, scrollbarY, 14, scrollbarHeight) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartY = input.mouseY;
        _dragStartOffset = scrollOffset;
      }
    }

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
        (overflow == Overflow.auto && _contentHeight > height);

    if (useClip && height > 0 && width > 0) {
      ctx2d.beginScissor(x, y, width, height);
    }

    for (final child in children) {
      if (child.isVisible) child.onRender(ctx2d, ctx3d);
    }

    if (useClip && height > 0 && width > 0) {
      if (overflow == Overflow.scroll ||
          (overflow == Overflow.auto && _contentHeight > height)) {
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
