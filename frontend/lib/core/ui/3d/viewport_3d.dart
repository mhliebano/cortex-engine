import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';

typedef Render3DCallback = void Function(Context3D ctx3d);
typedef Render2DCallback = void Function(Context2D ctx2d);
typedef Update3DCallback = void Function(double dt, InputEngine input);

class Viewport3D extends Element {
  bool showAxes;
  final Render3DCallback? _onRender3DCallback;
  final Render2DCallback? _onRender2DCallback;
  final Update3DCallback? _onUpdate3DCallback;

  final bool _isWidthFixed;
  final bool _isHeightFixed;

  Viewport3D({
    int width = 0,
    int height = 0,
    this.showAxes = false,
    Render3DCallback? onRender3D,
    Render2DCallback? onRender2D,
    Update3DCallback? onUpdate3D,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : _isWidthFixed = width != 0,
       _isHeightFixed = height != 0,
       _onRender3DCallback = onRender3D,
       _onRender2DCallback = onRender2D,
       _onUpdate3DCallback = onUpdate3D {
    this.width = width;
    this.height = height;
  }

  @override
  bool get isFlexWidth => !_isWidthFixed || fillWidth;

  @override
  bool get isFlexHeight => !_isHeightFixed || fillHeight;

  /// Hook virtual para inicialización en subclases.
  void onInit() {}

  /// Hook virtual de actualización 3D para ser sobreescrito en subclases.
  void onUpdate3D(double dt, InputEngine input) {
    _onUpdate3DCallback?.call(dt, input);
  }

  /// Hook virtual de renderizado 3D para ser sobreescrito en subclases.
  void onRender3D(Context3D ctx3d) {
    _onRender3DCallback?.call(ctx3d);
  }

  /// Hook virtual de renderizado 2D superpuesto (HUD/UI) para ser sobreescrito en subclases.
  void onRender2D(Context2D ctx2d) {
    _onRender2DCallback?.call(ctx2d);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    onUpdate3D(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    // Renderizar espacio 3D
    ctx3d.beginMode();
    if (showAxes) {
      ctx3d.drawAxes();
    }
    onRender3D(ctx3d);
    ctx3d.endMode();

    // Renderizado 2D superpuesto opcional (HUD/UI)
    onRender2D(ctx2d);
  }
}
