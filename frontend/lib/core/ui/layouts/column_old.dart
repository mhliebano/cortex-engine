// ignore_for_file: type=lint
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/layouts/row_old.dart';
import 'package:frontend/core/ui/style.dart';
import 'package:frontend/core/ui/scroll_controller.dart';

/// Contenedor de Disposición Vertical (`Column`).
/// Pura estructura de alineación (100% invisible).
/// Soporta desplazamiento vertical reactivo (`isScrollable`), arrastre por puntero y recorte de área.
class Column extends Element {
  final ScrollController? controller;
  int spacing;
  int padding;
  bool isScrollable;
  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;
  MainAxisSize mainAxisSize;

  double scrollOffset = 0.0;
  int _contentHeight = 0;

  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  final List<Element> children;
  final bool _isHeightFixed;
  final bool _isWidthFixed;

  Column({
    super.key,
    this.controller,
    String? className,
    int width = 0,
    int height = 0,
    int? spacing,
    int? padding,
    this.isScrollable = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
    required this.children,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : spacing =
           spacing ??
           (className != null ? Style.merge(className).spacing ?? 10 : 10),
       padding =
           padding ??
           (className != null ? Style.merge(className).padding ?? 0 : 0),
       _isHeightFixed =
           height != 0 ||
           (className != null && Style.merge(className).height != null),
       _isWidthFixed =
           width != 0 ||
           (className != null && Style.merge(className).width != null) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 0);
    this.height = height != 0 ? height : (style?.height ?? 0);

    if (isScrollable &&
        !_isHeightFixed &&
        expand == Expand.none &&
        !fillHeight) {
      fillHeight = true;
    }

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
    if (!isScrollable && scrollOffset == 0.0) return null;
    return {'scrollOffset': scrollOffset};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('scrollOffset')) {
      scrollOffset = (state['scrollOffset'] as num).toDouble();
      if (controller != null) {
        controller!.offset = scrollOffset;
      }
      _performLayout();
    }
  }

  @override
  bool get isFlexWidth => !_isWidthFixed || fillWidth;

  @override
  bool get isFlexHeight => fillHeight || _isHeightFixed;

  void _performLayout() {
    final availableWidth = width > (padding * 2) ? width - (padding * 2) : 0;

    // 1. Pase 1: Calcular alto total consumido por los hijos NO-flex
    int nonFillChildrenHeight = 0;
    int fillHeightCount = 0;
    int maxChildWidth = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child.isFlexHeight) {
        fillHeightCount++;
      } else {
        nonFillChildrenHeight += child.height;
      }
      if (!child.isFlexWidth && child.width > maxChildWidth) {
        maxChildWidth = child.width;
      }
      if (i > 0) nonFillChildrenHeight += spacing;
    }

    // 2. Si hay hijos con isFlexHeight, asignarles el alto sobrante proporcionalmente
    final netAvailableHeight = height > (padding * 2)
        ? height - (padding * 2)
        : 0;
    int totalChildrenHeight = nonFillChildrenHeight;

    if (fillHeightCount > 0) {
      final remainingHeight = netAvailableHeight > nonFillChildrenHeight
          ? netAvailableHeight - nonFillChildrenHeight
          : 0;
      final allocatedPerFill = remainingHeight ~/ fillHeightCount;

      totalChildrenHeight = 0;
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        if (child.isFlexHeight) {
          child.height = allocatedPerFill;
        }
        totalChildrenHeight += child.height;
        if (i > 0) totalChildrenHeight += spacing;
      }
    }

    _contentHeight = totalChildrenHeight + (padding * 2);
    final int contentWidth = maxChildWidth > 0
        ? maxChildWidth + (padding * 2)
        : 0;

    // Ajustar el alto de Column si no especifica alto fijo/expand/isScrollable o mainAxisSize == min
    if (mainAxisSize == MainAxisSize.min ||
        (!_isHeightFixed && !fillHeight && !isScrollable && height == 0)) {
      height = _contentHeight;
    }

    // Ajustar el ancho de Column al ancho máximo de sus hijos si no tiene ancho fijo
    if (!_isWidthFixed && !fillWidth && contentWidth > 0 && width == 0) {
      width = contentWidth;
    }

    final calcAvailableHeight = height > (padding * 2)
        ? height - (padding * 2)
        : 0;
    final extraSpace = calcAvailableHeight > totalChildrenHeight
        ? calcAvailableHeight - totalChildrenHeight
        : 0;

    // 3. Determinar posición inicial Y e incremento de espaciado entre hijos según mainAxisAlignment
    double startY = (y + padding - scrollOffset).toDouble();
    double dynamicSpacing = spacing.toDouble();

    if (extraSpace > 0 && !isScrollable) {
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
            dynamicSpacing = spacing + (extraSpace / (children.length - 1));
          }
          break;
        case MainAxisAlignment.spaceAround:
          if (children.isNotEmpty) {
            final gap = extraSpace / children.length;
            startY = (y + padding + (gap / 2) - scrollOffset).toDouble();
            dynamicSpacing = spacing + gap;
          }
          break;
        case MainAxisAlignment.spaceEvenly:
          if (children.isNotEmpty) {
            final gap = extraSpace / (children.length + 1);
            startY = (y + padding + gap - scrollOffset).toDouble();
            dynamicSpacing = spacing + gap;
          }
          break;
      }
    }

    // 4. Posicionar y redimensionar cada hijo
    double currentY = startY;

    for (final child in children) {
      child.y = currentY.toInt();

      final shouldFillW =
          child.isFlexWidth ||
          (child is Row && child.mainAxisSize == MainAxisSize.max);

      switch (crossAxisAlignment) {
        case CrossAxisAlignment.stretch:
          child.x = x + padding;
          if (availableWidth > 0) {
            child.width = availableWidth;
          }
          break;
        case CrossAxisAlignment.start:
          child.x = x + padding;
          if (shouldFillW && availableWidth > 0) {
            child.width = availableWidth;
          }
          break;
        case CrossAxisAlignment.center:
          if (shouldFillW && availableWidth > 0) {
            child.x = x + padding;
            child.width = availableWidth;
          } else {
            final childW = child.width;
            final spaceX = availableWidth > childW
                ? availableWidth - childW
                : 0;
            child.x = x + padding + (spaceX ~/ 2);
          }
          break;
        case CrossAxisAlignment.end:
          if (shouldFillW && availableWidth > 0) {
            child.x = x + padding;
            child.width = availableWidth;
          } else {
            final childW = child.width;
            final spaceX = availableWidth > childW
                ? availableWidth - childW
                : 0;
            child.x = x + padding + spaceX;
          }
          break;
      }

      child.onResize(child.width, child.height);

      currentY += child.height + dynamicSpacing;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _performLayout();

    if (isScrollable && height > 0) {
      final maxScroll = _contentHeight > height
          ? (_contentHeight - height).toDouble()
          : 0.0;

      if (maxScroll > 0) {
        final scrollbarHeight = ((height / _contentHeight) * height)
            .toInt()
            .clamp(20, height);
        final scrollbarY =
            y +
            ((scrollOffset / maxScroll) * (height - scrollbarHeight)).toInt();
        final scrollbarHitX = x + width - 14;
        final trackSpace = (height - scrollbarHeight).toDouble();

        _isHoveringScrollbar = input.isHovering(scrollbarHitX, y, 14, height);

        // 1. Iniciar arrastre si se presiona clic izquierdo sobre la barra de scroll
        if (input.isMouseButtonPressed(MouseButtons.left)) {
          if (input.isHovering(
                scrollbarHitX,
                scrollbarY,
                14,
                scrollbarHeight,
              ) ||
              _isHoveringScrollbar) {
            _isDraggingScrollbar = true;
            _dragStartY = input.mouseY;
            _dragStartOffset = scrollOffset;
          }
        }

        // 2. Procesar arrastre continuo mientras el mouse permanezca presionado
        if (_isDraggingScrollbar) {
          if (input.isMouseButtonDown(MouseButtons.left)) {
            final deltaY = input.mouseY - _dragStartY;
            if (trackSpace > 0) {
              final offsetDelta = (deltaY / trackSpace) * maxScroll;
              scrollOffset = (_dragStartOffset + offsetDelta).clamp(
                0.0,
                maxScroll,
              );
              if (controller != null) controller!.offset = scrollOffset;
              _performLayout();
            }
          } else {
            _isDraggingScrollbar = false;
          }
        }

        // 3. Scroll mediante la rueda del mouse
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
    }

    for (final child in children) {
      if (child.isVisible) {
        child.onUpdate(dt, input);
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    _performLayout();

    final useClip =
        (isScrollable ||
            _isHeightFixed ||
            fillHeight ||
            expand == Expand.all ||
            expand == Expand.height) &&
        width > 0 &&
        height > 0;
    if (useClip) {
      ctx2d.beginScissor(x, y, width, height);
    }

    for (final child in children) {
      if (child.isVisible) {
        child.onRender(ctx2d, ctx3d);
      }
    }

    if (useClip) {
      final maxScroll = _contentHeight > height
          ? (_contentHeight - height).toDouble()
          : 0.0;
      if (maxScroll > 0) {
        final scrollbarHeight = ((height / _contentHeight) * height)
            .toInt()
            .clamp(20, height);
        final scrollbarY =
            y +
            ((scrollOffset / maxScroll) * (height - scrollbarHeight)).toInt();
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
      ctx2d.endScissor();
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final child in children) {
      if (child.isVisible) {
        child.onRenderOverlay(ctx2d, ctx3d);
      }
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    if (mainAxisSize == MainAxisSize.max && !_isHeightFixed && !isScrollable) {
      height = allocatedHeight > marginBottom
          ? allocatedHeight - marginBottom
          : 0;
    }
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
