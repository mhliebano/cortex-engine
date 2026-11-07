import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';

typedef Render3DCallback = void Function(Context3D ctx3d);
typedef Render2DCallback = void Function(Context2D ctx2d);
typedef Update3DCallback = void Function(double dt, InputEngine input);
typedef Pick3DCallback = void Function(Ray3D ray, RayHit? hit);

/// Componente de Ventana Gráfica 3D (`Viewport3D`) bajo la arquitectura `ControlNode`.
///
/// Proporciona un lienzo tridimensional embebido para aplicaciones CAD y visualización de modelos:
/// - Modo de cámara orbital interactivo integrado (`enableControls`).
/// - Rejilla de referencia en el suelo (`showGrid`) y ejes cartesianos coloreados (`showAxes`).
/// - Soporte para *Picking 3D* mediante proyección de rayos (`onPick` / `getMouseRay`).
/// - Doble capa de renderizado: pase 3D con aceleración GPU (`onRender3D`) y HUD 2D superpuesto (`onRender2D`).
class Viewport3D extends ControlNode {
  bool showAxes;
  bool showGrid;
  bool enableControls;
  final Render3DCallback? _onRender3DCallback;
  final Render2DCallback? _onRender2DCallback;
  final Update3DCallback? _onUpdate3DCallback;
  final Pick3DCallback? onPick;

  bool _isHovered = false;

  Viewport3D({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    this.showAxes = false,
    this.showGrid = true,
    this.enableControls = true,
    Render3DCallback? onRender3D,
    Render2DCallback? onRender2D,
    Update3DCallback? onUpdate3D,
    this.onPick,
    int? defaultWidth,
    int? defaultHeight,
  })  : _onRender3DCallback = onRender3D,
        _onRender2DCallback = onRender2D,
        _onUpdate3DCallback = onUpdate3D {
    _updateDimensions(defaultWidth ?? 0, defaultHeight ?? 0);
  }

  void _updateDimensions(int defW, int defH) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (width <= 0) {
      width = defW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (height <= 0) {
      height = defH;
    }
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else {
      width = maxWidth;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else {
      height = maxHeight;
    }
  }

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
    if (!isVisible || !isEnabled) return;

    _isHovered = input.isHovering(x, y, width, height);

    onUpdate3D(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // Actualizar cámara interactiva si el cursor está sobre el viewport
    if (enableControls && _isHovered) {
      ctx3d.updateCamera(CameraMode.orbital);
    }

    // 1. Renderizar escena en espacio 3D
    ctx3d.beginMode();

    if (showGrid) {
      ctx3d.drawGrid(20, 1.0);
    }

    if (showAxes) {
      ctx3d.drawAxes();
    }

    onRender3D(ctx3d);

    ctx3d.endMode();

    // 2. Renderizado 2D superpuesto opcional (HUD/UI/Información de selección)
    onRender2D(ctx2d);
  }
}
