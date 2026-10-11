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

/// Contenedor de Disposición Horizontal (`Row`).
class Row extends StructureNode {
  final MainAlign mainAlign;
  final CrossAlign crossAlign;
  final double gap;
  final bool? scroll;
  late final List<CortexNode> children;
  final ScrollController? controller;

  // Estado de scroll
  double scrollOffset = 0.0;
  int _contentWidth = 0;

  // Estado interno de la scrollbar
  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartX = 0.0;
  double _dragStartOffset = 0.0;

  static const int _unconstrained = 1000000;

  // Restricciones inyectadas por el contenedor padre
  int _maxWidthConstraint = _unconstrained;
  int _maxHeightConstraint = _unconstrained;

  Row({
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
  bool get isFlexHeight => false;

  @override
  bool get isFlexWidth => true;

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
      width = hasWidthConstraint ? min(width, effectiveMaxW) : width;
      height = 0;
      _contentWidth = 0;
      return;
    }

    final double totalGaps =
        children.length > 1 ? gap * (children.length - 1) : 0.0;
    final int netAvailable = hasWidthConstraint
        ? max(0, (effectiveMaxW - totalGaps).round())
        : _unconstrained;

    int flexibleSpacerCount = 0;
    bool hasFlexChild = false;
    int sumChildWidths = 0;
    int maxChildHeight = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final int gapsBefore = i > 0 ? (i * gap).round() : 0;
      final int remainingForChild = hasWidthConstraint
          ? max(0, effectiveMaxW - sumChildWidths - gapsBefore)
          : _unconstrained;

      if (child is Spacer) {
        if (child.size != null) {
          final sz = child.size!.round();
          child.width = hasWidthConstraint ? min(sz, remainingForChild) : sz;
          sumChildWidths += child.width;
        } else {
          flexibleSpacerCount++;
        }
      } else {
        if (child.isFlexWidth) {
          hasFlexChild = true;
        }

        final wRule = child is ControlNode ? child.currentLayout.width : null;
        final bool isPercentage =
            wRule != null && wRule > 0.0 && wRule <= 1.0;

        final int childMaxW;
        if (hasWidthConstraint) {
          if (isPercentage) {
            childMaxW = netAvailable;
          } else {
            childMaxW = remainingForChild;
          }
        } else {
          childMaxW = isPercentage ? child.width : _unconstrained;
        }

        child.onResize(
          childMaxW,
          effectiveMaxH,
        );

        if (hasWidthConstraint) {
          child.width = min(child.width, remainingForChild);
        }

        sumChildWidths += child.width;
      }

      if (child.height > maxChildHeight) {
        maxChildHeight = child.height;
      }
    }

    final gapTotal = totalGaps.round();
    final rigidSum = sumChildWidths + gapTotal;
    _contentWidth = rigidSum;

    final bool shouldExpandMain =
        flexibleSpacerCount > 0 || hasFlexChild || mainAlign != MainAlign.start;

    width = shouldExpandMain && hasWidthConstraint
        ? effectiveMaxW
        : (hasWidthConstraint ? min(rigidSum, effectiveMaxW) : rigidSum);
    height = hasHeightConstraint ? min(maxChildHeight, effectiveMaxH) : maxChildHeight;

    if (flexibleSpacerCount > 0) {
      final remainingSpace = width - rigidSum;
      final spacerWidth = remainingSpace > 0
          ? (remainingSpace / flexibleSpacerCount).floor()
          : 0;
      for (final child in children) {
        if (child is Spacer && child.size == null) {
          child.width = spacerWidth;
        }
      }
    }

    double currentX = x.toDouble();
    double currentGap = gap;

    if (flexibleSpacerCount == 0) {
      final freeSpace =
          (width > rigidSum) ? (width - rigidSum).toDouble() : 0.0;
      switch (mainAlign) {
        case MainAlign.start:
          currentX = x.toDouble();
          break;
        case MainAlign.center:
          currentX = x + (freeSpace / 2);
          break;
        case MainAlign.end:
          currentX = x + freeSpace;
          break;
        case MainAlign.spaceBetween:
          currentX = x.toDouble();
          if (children.length > 1) {
            currentGap = gap + (freeSpace / (children.length - 1));
          }
          break;
        case MainAlign.spaceAround:
          if (children.isNotEmpty) {
            final spacePerItem = freeSpace / children.length;
            currentX = x + (spacePerItem / 2);
            currentGap = gap + spacePerItem;
          }
          break;
      }
    }

    for (final child in children) {
      child.x = currentX.round();

      switch (crossAlign) {
        case CrossAlign.stretch:
          child.y = y;
          if (child is! StructureNode) {
            child.height = height;
          }
          break;
        case CrossAlign.start:
          child.y = y;
          break;
        case CrossAlign.center:
          final spaceY = height > child.height ? height - child.height : 0;
          child.y = y + (spaceY ~/ 2);
          break;
        case CrossAlign.end:
          final spaceY = height > child.height ? height - child.height : 0;
          child.y = y + spaceY;
          break;
      }

      currentX += child.width + currentGap;
    }
  }

  double get _maxScroll =>
      _contentWidth > width ? (_contentWidth - width).toDouble() : 0.0;

  bool get _isScrollActive => scroll != false && _contentWidth > width;

  void _handleScroll(InputEngine input) {
    if (!_isScrollActive) return;
    final maxScroll = _maxScroll;
    if (maxScroll <= 0 || width <= 0) return;

    final effectiveOffset = controller?.offset ?? scrollOffset;
    final scrollbarWidth = ((width / _contentWidth) * width).toInt().clamp(
          20,
          width,
        );
    final scrollbarX =
        x + ((effectiveOffset / maxScroll) * (width - scrollbarWidth)).toInt();
    final scrollbarHitY = y + height - 14;
    final trackSpace = (width - scrollbarWidth).toDouble();

    _isHoveringScrollbar = input.isHovering(x, scrollbarHitY, width, 14);

    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (input.isHovering(scrollbarX, scrollbarHitY, scrollbarWidth, 14) ||
          _isHoveringScrollbar) {
        _isDraggingScrollbar = true;
        _dragStartX = input.mouseX;
        _dragStartOffset = effectiveOffset;
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

    final effectiveOffset = controller?.offset ?? scrollOffset;
    final scrollbarWidth = ((width / _contentWidth) * width).toInt().clamp(
          20,
          width,
        );
    final scrollbarX =
        x + ((effectiveOffset / maxScroll) * (width - scrollbarWidth)).toInt();
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

    final isScrollActive = _isScrollActive;

    // 1. Guillotina: Aplica clipRect limitando exactamente al tamaño físico impuesto por el padre.
    if (isScrollActive && width > 0 && height > 0) {
      ctx2d.beginScissor(x, y, width, height);
    }

    // 2. Traslación: Extrae el offset del scroll_control (interno o expuesto) y aplica translate(-offset, 0).
    final effectiveOffset = controller?.offset ?? scrollOffset;
    if (isScrollActive && effectiveOffset != 0.0) {
      ctx2d.translate(-effectiveOffset, 0.0);
    }

    // 3. Contenido: Ejecuta el ciclo paint sobre los nodos hijos.
    for (final child in children) {
      if (child.isVisible) child.onRender(ctx2d, ctx3d);
    }

    // 4. Restauración: Limpia la matriz del canvas para anular el recorte y la traslación.
    if (isScrollActive && effectiveOffset != 0.0) {
      ctx2d.resetTransform();
    }
    if (isScrollActive && width > 0 && height > 0) {
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
