import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/style.dart';

/// Lienzo Acotado / Viewport (`Panel`).
///
/// Es el hijo directo de una [View] y funciona como una hoja en blanco
/// independiente. Recibe su posición final `(x, y)` del [View], pero define
/// sus propias dimensiones bajo estas reglas estrictas:
///
/// - Si usa [expandWidth], su eje transversal debe estar definido
///   (`height > 0`).
/// - Si usa [expandHeight], su eje transversal debe estar definido
///   (`width > 0`).
///
/// Aísla completamente los cambios de interfaz de su interior: cualquier
/// modificación interna no fuerza recálculos en el resto de la pantalla.
///
/// Aplica un scissor propio sobre su contenido para evitar desbordamiento.
///
/// Opcionalmente acepta un [className] para aplicar estilos globales
/// pre-registrados mediante el sistema [Style].
class Panel extends Element {
  ColorRGBA bgColor;
  ColorRGBA borderColor;
  int padding;
  Element? child;
  bool clipContent;

  final bool expandWidth;
  final bool expandHeight;

  Panel({
    super.key,
    String? className,
    int width = 0,
    int height = 0,
    this.expandWidth = false,
    this.expandHeight = false,
    ColorRGBA? bgColor,
    ColorRGBA? borderColor,
    int? padding,
    this.child,
    this.clipContent = true,
    // Compat: fillWidth/fillHeight mapean a expandWidth/expandHeight
    bool fillWidth = false,
    bool fillHeight = false,
    super.expand,
    super.marginRight,
    super.marginBottom,
  }) : assert(
         !(expandWidth && height == 0 && !expandHeight && !fillHeight),
         'Panel: si expandWidth=true, height debe ser > 0 (o usar expandHeight=true)',
       ),
       assert(
         !(expandHeight && width == 0 && !expandWidth && !fillWidth),
         'Panel: si expandHeight=true, width debe ser > 0 (o usar expandWidth=true)',
       ),
       bgColor =
           bgColor ??
           (className != null
               ? Style.merge(className).bgColor ??
                     const ColorRGBA(40, 44, 52, 255)
               : const ColorRGBA(40, 44, 52, 255)),
       borderColor =
           borderColor ??
           (className != null
               ? Style.merge(className).borderColor ?? ColorRGBA.transparent
               : ColorRGBA.transparent),
       padding =
           padding ??
           (className != null ? Style.merge(className).padding ?? 0 : 0) {
    // Resolver dimensiones desde className si no se especificaron
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 0);
    this.height = height != 0 ? height : (style?.height ?? 0);

    // Propagar flags de expansión al sistema base de Element
    final wExpand =
        expandWidth ||
        fillWidth ||
        expand == Expand.width ||
        expand == Expand.all;
    final hExpand =
        expandHeight ||
        fillHeight ||
        expand == Expand.height ||
        expand == Expand.all;

    if (wExpand && hExpand) {
      this.expand = Expand.all;
    } else if (wExpand) {
      this.expand = Expand.width;
    } else if (hExpand) {
      this.expand = Expand.height;
    } else {
      this.expand = Expand.none;
    }

    _updateChildBounds();
  }

  bool get _isExpandingWidth => expand == Expand.width || expand == Expand.all;

  bool get _isExpandingHeight =>
      expand == Expand.height || expand == Expand.all;

  @override
  List<Element> get childrenElements => child != null ? [child!] : const [];

  @override
  bool get isFlexWidth => _isExpandingWidth;

  @override
  bool get isFlexHeight => _isExpandingHeight;

  // ─────────────────────────────────────────────
  // Layout interno
  // ─────────────────────────────────────────────

  void _updateChildBounds() {
    if (child == null) return;

    child!.x = x + padding;
    child!.y = y + padding;

    final availableWidth = width > (padding * 2) ? width - (padding * 2) : 0;
    final availableHeight = height > (padding * 2) ? height - (padding * 2) : 0;

    if (availableWidth > 0) child!.width = availableWidth;
    if (availableHeight > 0) child!.height = availableHeight;

    child!.onResize(
      availableWidth > 0 ? availableWidth : child!.width,
      availableHeight > 0 ? availableHeight : child!.height,
    );
  }

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    if (child != null) {
      child!.x = x + padding;
      child!.y = y + padding;
      if (child!.isVisible) child!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    if (child != null) {
      child!.x = x + padding;
      child!.y = y + padding;
    }

    // 1. Dibujar fondo y borde del Panel
    ctx2d.drawPanel(
      x,
      y,
      width,
      height,
      bgColor: bgColor,
      borderColor: borderColor,
    );

    // 2. Renderizar contenido hijo con scissor propio
    if (child != null && child!.isVisible) {
      final useClip = clipContent && width > 0 && height > 0;
      if (useClip) ctx2d.beginScissor(x, y, width, height);
      child!.onRender(ctx2d, ctx3d);
      if (useClip) ctx2d.endScissor();
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
    if (_isExpandingWidth) {
      width = allocatedWidth > marginRight ? allocatedWidth - marginRight : 0;
    }
    if (_isExpandingHeight) {
      height = allocatedHeight > marginBottom
          ? allocatedHeight - marginBottom
          : 0;
    }
    _updateChildBounds();
  }
}
