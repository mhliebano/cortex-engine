// ignore_for_file: type=lint
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/style.dart';

/// Contenedor Gráfico (`Panel`).
/// Actúa como un Container/Card visual que dibuja fondo, borde, aplica padding y contiene a un elemento hijo (`child`).
class Panel extends Element {
  late ColorRGBA bgColor;
  late ColorRGBA borderColor;
  int padding;
  Element? child;
  bool clipContent;

  final bool _isWidthFixed;
  final bool _isHeightFixed;

  Panel({
    super.key,
    String? className,
    int width = 0,
    int height = 0,
    int? padding,
    this.child,
    this.clipContent = true,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : padding =
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

    bgColor = style?.bgColor ?? ColorRGBA.darkGray;
    borderColor = style?.borderColor ?? ColorRGBA.transparent;

    _updateChildBounds();
  }

  @override
  List<Element> get childrenElements => child != null ? [child!] : const [];

  @override
  bool get isFlexWidth => !_isWidthFixed || fillWidth;

  @override
  bool get isFlexHeight => fillHeight || _isHeightFixed;

  void _updateChildBounds() {
    if (child == null) return;

    child!.x = x + padding;
    child!.y = y + padding;

    final isWidthConstrained =
        _isWidthFixed ||
        fillWidth ||
        expand == Expand.all ||
        expand == Expand.width;
    final isHeightConstrained =
        _isHeightFixed ||
        fillHeight ||
        expand == Expand.all ||
        expand == Expand.height;

    final availableWidth = width > (padding * 2) ? width - (padding * 2) : 0;
    final availableHeight = height > (padding * 2) ? height - (padding * 2) : 0;

    if (child!.isFlexWidth || child!.width == 0 || isWidthConstrained) {
      if (availableWidth > 0) child!.width = availableWidth;
    }
    if ((child!.isFlexHeight || child!.height == 0 || isHeightConstrained) &&
        availableHeight > 0) {
      child!.height = availableHeight;
    }

    child!.onResize(
      isWidthConstrained && availableWidth > 0
          ? availableWidth
          : (child!.width > 0 ? child!.width : availableWidth),
      isHeightConstrained && availableHeight > 0
          ? availableHeight
          : (child!.height > 0 ? child!.height : availableHeight),
    );

    // Auto-dimensionamiento del Panel si width/height no están especificados manualmente
    if (!isWidthConstrained && child!.width > 0) {
      width = child!.width + (padding * 2);
    }
    if (!isHeightConstrained && child!.height > 0) {
      height = child!.height + (padding * 2);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    if (child != null && child!.isVisible) {
      child!.x = x + padding;
      child!.y = y + padding;
      child!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    if (child != null) {
      child!.x = x + padding;
      child!.y = y + padding;
    }

    // 1. Dibujar caja de fondo y borde del Panel
    ctx2d.drawPanel(
      x,
      y,
      width,
      height,
      bgColor: bgColor,
      borderColor: borderColor,
    );

    // 2. Renderizar contenido hijo (con opción de recortar si clipContent es true y height/width son fijos)
    if (child != null && child!.isVisible) {
      final useClip = clipContent && width > 0 && height > 0;
      if (useClip) {
        ctx2d.beginScissor(x, y, width, height);
      }
      child!.onRender(ctx2d, ctx3d);
      if (useClip) {
        ctx2d.endScissor();
      }
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    if (child != null && child!.isVisible) {
      child!.onRenderOverlay(ctx2d, ctx3d);
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _updateChildBounds();
  }
}
