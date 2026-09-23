import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/style.dart';
import 'package:cortex/core/ui/scroll_controller.dart';

/// Contenedor Desplazable de Lista (`ListView`).
/// Organiza una secuencia vertical de ítems (`children`) con desplazamiento fluido por rueda del mouse,
/// barra de scroll arrastrable anclada al borde derecho y recorte estricto por área (`beginScissor` / `endScissor`).
class ListView extends Element {
  final List<Element> children;
  final ScrollController? controller;
  int spacing;
  int padding;
  bool isScrollable;
  bool showDividers;

  late ColorRGBA bgColor;
  late ColorRGBA borderColor;
  late ColorRGBA dividerColor;

  double scrollOffset = 0.0;
  int _contentHeight = 0;

  bool _isDraggingScrollbar = false;
  bool _isHoveringScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;
  final bool _isHeightFixed;
  final bool _isWidthFixed;

  ListView({
    super.key,
    this.controller,
    String? className,
    required this.children,
    int width = 0,
    int height = 0,
    int? spacing,
    int? padding,
    this.isScrollable = true,
    this.showDividers = false,
    bool fillWidth = true,
    super.expand,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : spacing =
           spacing ??
           (className != null ? Style.merge(className).spacing ?? 4 : 4),
       padding =
           padding ??
           (className != null ? Style.merge(className).padding ?? 6 : 6),
       _isHeightFixed =
           height != 0 ||
           (className != null && Style.merge(className).height != null),
       _isWidthFixed =
           width != 0 ||
           (className != null && Style.merge(className).width != null),
       super(fillWidth: fillWidth) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 0);
    this.height = height != 0 ? height : (style?.height ?? 240);

    bgColor = style?.bgColor ?? const ColorRGBA(20, 24, 32);
    borderColor = style?.borderColor ?? const ColorRGBA(50, 60, 75);
    dividerColor = style?.dividerColor ?? const ColorRGBA(40, 48, 60);

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

  void _performLayout() {
    final maxScrollable = _contentHeight > height
        ? (_contentHeight - height)
        : 0;
    final rightMargin = (isScrollable && maxScrollable > 0) ? 14 : 0;
    final availableChildWidth = width > (padding * 2 + rightMargin)
        ? width - (padding * 2 + rightMargin)
        : (width > (padding * 2) ? width - (padding * 2) : 0);

    int totalHeight = 0;
    int maxChildW = 0;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (availableChildWidth > 0) {
        child.width = availableChildWidth;
      }
      if (child.width > maxChildW) maxChildW = child.width;

      totalHeight += child.height;
      if (i > 0) totalHeight += spacing;
    }

    _contentHeight = totalHeight + (padding * 2);

    // Ajustar dimensión si no se especificó alto fijo o expand
    if (!_isHeightFixed && !fillHeight && height == 0) {
      height = _contentHeight.clamp(100, 400);
    }
    if (!_isWidthFixed && !fillWidth && width == 0) {
      width = (maxChildW > 0 ? maxChildW + (padding * 2 + rightMargin) : 250);
    }

    // Posicionar hijos verticalmente aplicando la compensación de scrollOffset
    double currentY = (y + padding - scrollOffset).toDouble();
    final itemX = x + padding;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      child.x = itemX;
      child.y = currentY.toInt();

      if (availableChildWidth > 0) {
        child.width = availableChildWidth;
      }

      currentY += child.height + spacing;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _performLayout();

    final maxScroll = _contentHeight > height
        ? (_contentHeight - height).toDouble()
        : 0.0;
    final isHovered = input.isHovering(x, y, width, height);

    // 1. Desplazamiento por Rueda del Mouse
    if (isHovered && isScrollable && maxScroll > 0) {
      final wheel = input.mouseWheelMove;
      if (wheel != 0) {
        scrollOffset -= wheel * 30.0;
        if (scrollOffset < 0) scrollOffset = 0;
        if (scrollOffset > maxScroll) scrollOffset = maxScroll;
        if (controller != null) controller!.offset = scrollOffset;
        _performLayout();
      }
    }

    // 2. Interacción con Barra de Scroll Vertical (Anclada al borde DERECHO)
    if (isScrollable && maxScroll > 0) {
      final scrollbarWidth = 8;
      final scrollbarX = x + width - scrollbarWidth - 4;
      final trackY = y + padding;
      final trackHeight = height - (padding * 2);

      final thumbHeight = (trackHeight * (height / _contentHeight)).clamp(
        20.0,
        trackHeight.toDouble(),
      );
      final thumbY =
          trackY + (scrollOffset / maxScroll) * (trackHeight - thumbHeight);

      _isHoveringScrollbar = input.isHovering(
        scrollbarX - 4,
        thumbY.toInt(),
        scrollbarWidth + 8,
        thumbHeight.toInt(),
      );

      if (_isHoveringScrollbar &&
          input.isMouseButtonPressed(MouseButtons.left)) {
        _isDraggingScrollbar = true;
        _dragStartY = input.mouseY;
        _dragStartOffset = scrollOffset;
      }

      if (_isDraggingScrollbar) {
        if (input.isMouseButtonDown(MouseButtons.left)) {
          final deltaY = input.mouseY - _dragStartY;
          final scrollRatio = maxScroll / (trackHeight - thumbHeight);
          scrollOffset = (_dragStartOffset + (deltaY * scrollRatio)).clamp(
            0.0,
            maxScroll,
          );
          if (controller != null) controller!.offset = scrollOffset;
          _performLayout();
        } else {
          _isDraggingScrollbar = false;
        }
      }
    } else {
      _isHoveringScrollbar = false;
      _isDraggingScrollbar = false;
    }

    // 3. Actualizar lógica de hijos estrictamente dentro del área visible de la lista
    for (final child in children) {
      final isChildVisibleInView =
          (child.y + child.height) > y && child.y < (y + height);
      if (isChildVisibleInView) {
        child.onUpdate(dt, input);
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    _performLayout();

    // 1. Dibujar panel base de fondo
    ctx2d.drawPanel(
      x,
      y,
      width,
      height,
      bgColor: bgColor,
      borderColor: borderColor,
    );

    // 2. Recorte de Área Scissor estricto para evitar desbordamientos superiores o inferiores
    final useScissor = width > 2 && height > 2;
    if (useScissor) {
      ctx2d.beginScissor(x + 1, y + 1, width - 2, height - 2);
    }

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final isChildVisibleInView =
          (child.y + child.height) > y && child.y < (y + height);
      if (isChildVisibleInView) {
        child.onRender(ctx2d, ctx3d);

        // Dibujar línea divisora si está habilitado
        if (showDividers && i < children.length - 1) {
          final divY = child.y + child.height + (spacing ~/ 2);
          ctx2d.drawRect(child.x, divY, child.width, 1, dividerColor);
        }
      }
    }

    if (useScissor) {
      ctx2d.endScissor();
    }

    // 3. Renderizar Barra de Scroll Vertical anclada estrictamente al borde DERECHO
    final maxScroll = _contentHeight > height
        ? (_contentHeight - height).toDouble()
        : 0.0;
    if (isScrollable && maxScroll > 0) {
      final scrollbarWidth = 6;
      final scrollbarX = x + width - scrollbarWidth - 4;
      final trackY = y + 4;
      final trackHeight = height - 8;

      final thumbHeight = (trackHeight * (height / _contentHeight)).clamp(
        20.0,
        trackHeight.toDouble(),
      );
      final thumbY =
          trackY + (scrollOffset / maxScroll) * (trackHeight - thumbHeight);

      final thumbColor = _isDraggingScrollbar
          ? ColorRGBA.accentBlue
          : (_isHoveringScrollbar
                ? const ColorRGBA(110, 130, 155)
                : const ColorRGBA(60, 72, 90));

      ctx2d.drawRoundRect(
        scrollbarX,
        thumbY.toInt(),
        scrollbarWidth,
        thumbHeight.toInt(),
        0.5,
        color: thumbColor,
      );
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
