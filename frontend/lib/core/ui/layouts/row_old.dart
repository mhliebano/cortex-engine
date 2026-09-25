// ignore_for_file: type=lint
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/layouts/column_old.dart';
import 'package:frontend/core/ui/style.dart';
import 'package:frontend/core/ui/scroll_controller.dart';

/// Contenedor de Disposición Horizontal (`Row`).
/// Pura estructura de alineación (100% invisible).
/// Soporta desplazamiento horizontal reactivo (`isScrollable`), arrastre por puntero y recorte de área.
class Row extends Element {
  final ScrollController? controller;
  int spacing;
  int padding;
  bool isScrollable;
  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;
  MainAxisSize mainAxisSize;

  double scrollOffset = 0.0;
  int _contentWidth = 0;

  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartX = 0.0;
  double _dragStartOffset = 0.0;

  final List<Element> children;
  final bool _isWidthFixed;
  final bool _isHeightFixed;

  Row({
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
       _isWidthFixed =
           width != 0 ||
           (className != null && Style.merge(className).width != null),
       _isHeightFixed =
           height != 0 ||
           (className != null && Style.merge(className).height != null) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 0);
    this.height = height != 0 ? height : (style?.height ?? 0);

    if (isScrollable && !_isWidthFixed && expand == Expand.none && !fillWidth) {
      fillWidth = true;
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
    final availableHeight = height > (padding * 2) ? height - (padding * 2) : 0;

    // 1. Pase 1: Calcular ancho total consumido por los hijos NO-flex
    int nonFillChildrenWidth = 0;
    int fillWidthCount = 0;
    int maxChildHeight = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child.isFlexWidth) {
        fillWidthCount++;
      } else {
        nonFillChildrenWidth += child.width;
      }
      if (child.height > maxChildHeight) {
        maxChildHeight = child.height;
      }
      if (i > 0) nonFillChildrenWidth += spacing;
    }

    // 2. Si hay hijos flexibles, asignarles el ancho sobrante proporcionalmente
    final netAvailableWidth = width > (padding * 2) ? width - (padding * 2) : 0;
    int totalChildrenWidth = nonFillChildrenWidth;

    if (fillWidthCount > 0) {
      final remainingWidth = netAvailableWidth > nonFillChildrenWidth
          ? netAvailableWidth - nonFillChildrenWidth
          : 0;
      final allocatedPerFill = remainingWidth ~/ fillWidthCount;

      totalChildrenWidth = 0;
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        if (child.isFlexWidth) {
          child.width = allocatedPerFill;
        }
        totalChildrenWidth += child.width;
        if (i > 0) totalChildrenWidth += spacing;
      }
    }

    _contentWidth = totalChildrenWidth + (padding * 2);
    final int contentHeight = maxChildHeight > 0
        ? maxChildHeight + (padding * 2)
        : 0;

    // Ajustar el ancho del Row según mainAxisSize
    if (mainAxisSize == MainAxisSize.min) {
      width = _contentWidth;
    } else if (!_isWidthFixed && !fillWidth && !isScrollable && width == 0) {
      width = _contentWidth;
    }

    // Ajustar el alto del Row al alto máximo de sus hijos si no tiene alto fijo
    if (!_isHeightFixed && !fillHeight && contentHeight > 0 && height == 0) {
      height = contentHeight;
    }

    final calcAvailableWidth = width > (padding * 2)
        ? width - (padding * 2)
        : 0;
    final extraSpace = calcAvailableWidth > totalChildrenWidth
        ? calcAvailableWidth - totalChildrenWidth
        : 0;

    // 3. Determinar posición inicial X e incremento de espaciado entre hijos según mainAxisAlignment
    double startX = (x + padding - scrollOffset).toDouble();
    double dynamicSpacing = spacing.toDouble();

    if (extraSpace > 0 && !isScrollable) {
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
            dynamicSpacing = spacing + (extraSpace / (children.length - 1));
          }
          break;
        case MainAxisAlignment.spaceAround:
          if (children.isNotEmpty) {
            final gap = extraSpace / children.length;
            startX = (x + padding + (gap / 2) - scrollOffset).toDouble();
            dynamicSpacing = spacing + gap;
          }
          break;
        case MainAxisAlignment.spaceEvenly:
          if (children.isNotEmpty) {
            final gap = extraSpace / (children.length + 1);
            startX = (x + padding + gap - scrollOffset).toDouble();
            dynamicSpacing = spacing + gap;
          }
          break;
      }
    }

    // 4. Posicionar y redimensionar cada hijo
    double currentX = startX;

    for (final child in children) {
      child.x = currentX.toInt();

      final shouldFillH =
          child.fillHeight ||
          (child is Column && child.mainAxisSize == MainAxisSize.max);

      switch (crossAxisAlignment) {
        case CrossAxisAlignment.stretch:
          child.y = y + padding;
          if (availableHeight > 0) {
            child.height = availableHeight;
          }
          break;
        case CrossAxisAlignment.start:
          child.y = y + padding;
          if (shouldFillH && availableHeight > 0) {
            child.height = availableHeight;
          }
          break;
        case CrossAxisAlignment.center:
          if (shouldFillH && availableHeight > 0) {
            child.y = y + padding;
            child.height = availableHeight;
          } else {
            final childH = child.height;
            final spaceY = availableHeight > childH
                ? availableHeight - childH
                : 0;
            child.y = y + padding + (spaceY ~/ 2);
          }
          break;
        case CrossAxisAlignment.end:
          if (shouldFillH && availableHeight > 0) {
            child.y = y + padding;
            child.height = availableHeight;
          } else {
            final childH = child.height;
            final spaceY = availableHeight > childH
                ? availableHeight - childH
                : 0;
            child.y = y + padding + spaceY;
          }
          break;
      }

      child.onResize(child.width, child.height);

      currentX += child.width + dynamicSpacing;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _performLayout();

    if (isScrollable && width > 0) {
      final maxScroll = _contentWidth > width
          ? (_contentWidth - width).toDouble()
          : 0.0;

      if (maxScroll > 0) {
        final scrollbarWidth = ((width / _contentWidth) * width).toInt().clamp(
          20,
          width,
        );
        final scrollbarX =
            x + ((scrollOffset / maxScroll) * (width - scrollbarWidth)).toInt();
        final scrollbarHitY = y + height - 14;
        final trackSpace = (width - scrollbarWidth).toDouble();

        _isHoveringScrollbar = input.isHovering(x, scrollbarHitY, width, 14);

        // 1. Iniciar arrastre si se presiona clic izquierdo sobre la barra de scroll
        if (input.isMouseButtonPressed(MouseButtons.left)) {
          if (input.isHovering(scrollbarX, scrollbarHitY, scrollbarWidth, 14) ||
              _isHoveringScrollbar) {
            _isDraggingScrollbar = true;
            _dragStartX = input.mouseX;
            _dragStartOffset = scrollOffset;
          }
        }

        // 2. Procesar arrastre continuo mientras el mouse permanezca presionado
        if (_isDraggingScrollbar) {
          if (input.isMouseButtonDown(MouseButtons.left)) {
            final deltaX = input.mouseX - _dragStartX;
            if (trackSpace > 0) {
              final offsetDelta = (deltaX / trackSpace) * maxScroll;
              scrollOffset = (_dragStartOffset + offsetDelta).clamp(
                0.0,
                maxScroll,
              );
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
            _isWidthFixed ||
            fillWidth ||
            expand == Expand.all ||
            expand == Expand.width) &&
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
      final maxScroll = _contentWidth > width
          ? (_contentWidth - width).toDouble()
          : 0.0;
      if (maxScroll > 0) {
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
    if (mainAxisSize == MainAxisSize.max && !_isWidthFixed && !isScrollable) {
      width = allocatedWidth > marginRight ? allocatedWidth - marginRight : 0;
    }
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
