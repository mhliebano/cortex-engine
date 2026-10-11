import 'dart:math';
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/layout_alignment.dart';
import 'package:frontend/core/ui/scroll_controller.dart';
import 'package:frontend/core/ui/structure_node.dart';
import 'package:frontend/core/ui/layouts/spacer.dart';

/// Contenedor de Disposición Vertical (`Col`).
class Col extends StructureNode {
  final MainAlign mainAlign;
  final CrossAlign crossAlign;
  final double gap;
  final bool? scroll;
  late final List<CortexNode> children;
  final ScrollController? controller;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentHeight = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  static const int _unconstrained = 1000000;

  // Restricciones inyectadas por el contenedor padre
  int _maxWidthConstraint = _unconstrained;
  int _maxHeightConstraint = _unconstrained;

  Col({
    super.key,
    this.scroll,
    this.mainAlign = MainAlign.start,
    this.crossAlign = CrossAlign.start,
    this.gap = 0.0,
    List<CortexNode>? children,
    this.controller,
  }) {
    this.children = children ?? build();

    if (controller != null) {
      scrollOffset = controller!.offset;
      controller!.addListener((newOffset) {
        scrollOffset = newOffset;
        _performLayout();
      });
    }

    _performLayout();
  }

  List<CortexNode> build() => [];

  @override
  List<CortexNode> get childrenElements => children;

  @override
  bool get isFlexHeight => true;

  @override
  bool get isFlexWidth => false;

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
    final hasWidthConstraint = _maxWidthConstraint != _unconstrained;
    final hasHeightConstraint = _maxHeightConstraint != _unconstrained;

    final effectiveMaxW = hasWidthConstraint
        ? max(0, _maxWidthConstraint)
        : (width > 0 ? width : _unconstrained);
    final effectiveMaxH = hasHeightConstraint
        ? max(0, _maxHeightConstraint)
        : (height > 0 ? height : _unconstrained);

    if (children.isEmpty) {
      height = hasHeightConstraint ? min(height, effectiveMaxH) : height;
      width = 0;
      _contentHeight = 0;
      return;
    }

    final double totalGaps =
        children.length > 1 ? gap * (children.length - 1) : 0.0;
    final int netAvailable = hasHeightConstraint
        ? max(0, (effectiveMaxH - totalGaps).round())
        : _unconstrained;

    int flexibleSpacerCount = 0;
    bool hasFlexChild = false;
    int sumChildHeights = 0;
    int maxChildWidth = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final int gapsBefore = i > 0 ? (i * gap).round() : 0;
      final int remainingForChild = hasHeightConstraint
          ? max(0, effectiveMaxH - sumChildHeights - gapsBefore)
          : _unconstrained;

      if (child is Spacer) {
        if (child.size != null) {
          final sz = child.size!.round();
          child.height = hasHeightConstraint ? min(sz, remainingForChild) : sz;
          sumChildHeights += child.height;
        } else {
          flexibleSpacerCount++;
        }
      } else {
        if (child.isFlexHeight) {
          hasFlexChild = true;
        }

        final hRule = child is ControlNode ? child.currentLayout.height : null;
        final bool isPercentage =
            hRule != null && hRule > 0.0 && hRule <= 1.0;

        final int childMaxH;
        if (hasHeightConstraint) {
          if (isPercentage) {
            childMaxH = netAvailable;
          } else {
            childMaxH = remainingForChild;
          }
        } else {
          childMaxH = isPercentage ? child.height : _unconstrained;
        }

        child.onResize(
          effectiveMaxW,
          childMaxH,
        );

        if (hasHeightConstraint) {
          child.height = min(child.height, remainingForChild);
        }

        sumChildHeights += child.height;
      }

      if (child.width > maxChildWidth) {
        maxChildWidth = child.width;
      }
    }

    final gapTotal = totalGaps.round();
    final rigidSum = sumChildHeights + gapTotal;
    _contentHeight = rigidSum;

    final bool shouldExpandMain =
        flexibleSpacerCount > 0 || hasFlexChild || mainAlign != MainAlign.start;

    height = shouldExpandMain && hasHeightConstraint
        ? effectiveMaxH
        : (hasHeightConstraint ? min(rigidSum, effectiveMaxH) : rigidSum);
    width = hasWidthConstraint ? min(maxChildWidth, effectiveMaxW) : maxChildWidth;

    if (flexibleSpacerCount > 0) {
      final remainingSpace = height - rigidSum;
      final spacerHeight = remainingSpace > 0
          ? (remainingSpace / flexibleSpacerCount).floor()
          : 0;
      for (final child in children) {
        if (child is Spacer && child.size == null) {
          child.height = spacerHeight;
        }
      }
    }

    double currentY = y.toDouble();
    double currentGap = gap;

    if (flexibleSpacerCount == 0) {
      final freeSpace =
          (height > rigidSum) ? (height - rigidSum).toDouble() : 0.0;
      switch (mainAlign) {
        case MainAlign.start:
          currentY = y.toDouble();
          break;
        case MainAlign.center:
          currentY = y + (freeSpace / 2);
          break;
        case MainAlign.end:
          currentY = y + freeSpace;
          break;
        case MainAlign.spaceBetween:
          currentY = y.toDouble();
          if (children.length > 1) {
            currentGap = gap + (freeSpace / (children.length - 1));
          }
          break;
        case MainAlign.spaceAround:
          if (children.isNotEmpty) {
            final spacePerItem = freeSpace / children.length;
            currentY = y + (spacePerItem / 2);
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
          if (child is! StructureNode) {
            child.width = width;
          }
          break;
        case CrossAlign.start:
          child.x = x;
          break;
        case CrossAlign.center:
          final spaceX = width > child.width ? width - child.width : 0;
          child.x = x + (spaceX ~/ 2);
          break;
        case CrossAlign.end:
          final spaceX = width > child.width ? width - child.width : 0;
          child.x = x + spaceX;
          break;
      }

      currentY += child.height + currentGap;
    }
  }

  double get _maxScroll =>
      _contentHeight > height ? (_contentHeight - height).toDouble() : 0.0;

  bool get _isScrollActive => scroll != false && _contentHeight > height;

  void _handleScroll(InputEngine input) {
    if (!_isScrollActive) return;
    final maxScroll = _maxScroll;
    if (maxScroll <= 0 || height <= 0) return;

    final effectiveOffset = controller?.offset ?? scrollOffset;
    final scrollbarHeight = ((height / _contentHeight) * height).toInt().clamp(
          20,
          height,
        );
    final scrollbarY =
        y + ((effectiveOffset / maxScroll) * (height - scrollbarHeight)).toInt();
    final scrollbarHitX = x + width - 14;
    final trackSpace = (height - scrollbarHeight).toDouble();

    _isHoveringScrollbar = input.isHovering(scrollbarHitX, y, 14, height);

    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarHitX, scrollbarY, 14, scrollbarHeight) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartY = input.mouseY;
        _dragStartOffset = effectiveOffset;
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

    final effectiveOffset = controller?.offset ?? scrollOffset;
    final scrollbarHeight = ((height / _contentHeight) * height).toInt().clamp(
          20,
          height,
        );
    final scrollbarY =
        y + ((effectiveOffset / maxScroll) * (height - scrollbarHeight)).toInt();
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

    final isScrollActive = _isScrollActive;

    // 1. Guillotina: Aplica clipRect limitando exactamente al tamaño físico impuesto por el padre.
    if (isScrollActive && height > 0 && width > 0) {
      ctx2d.beginScissor(x, y, width, height);
    }

    // 2. Traslación: Extrae el offset del scroll_control (interno o expuesto) y aplica translate(0, -offset).
    final effectiveOffset = controller?.offset ?? scrollOffset;
    if (isScrollActive && effectiveOffset != 0.0) {
      ctx2d.translate(0.0, -effectiveOffset);
    }

    // 3. Contenido: Ejecuta el ciclo paint sobre los nodos hijos.
    for (final child in children) {
      if (child.isVisible) child.onRender(ctx2d, ctx3d);
    }

    // 4. Restauración: Limpia la matriz del canvas para anular el recorte y la traslación.
    if (isScrollActive && effectiveOffset != 0.0) {
      ctx2d.resetTransform();
    }
    if (isScrollActive && height > 0 && width > 0) {
      ctx2d.endScissor();
    }

    // 5. Scrollbar: Invoca la rutina de dibujado de la barra de desplazamiento estáticamente sobre el límite físico.
    if (isScrollActive) {
      _renderScrollbar(ctx2d);
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
  void onResize(int maxWidth, int maxHeight) {
    _maxWidthConstraint = maxWidth;
    _maxHeightConstraint = maxHeight;
    _performLayout();
  }
}
