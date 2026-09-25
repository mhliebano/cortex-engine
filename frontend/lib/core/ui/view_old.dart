import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/interaction/toast.dart';
import 'package:frontend/core/ui/interaction/snack_bar.dart';
import 'package:frontend/core/ui/interaction/dialog.dart';
export 'package:frontend/core/ui/element.dart';

/// Una `View` representa una Pantalla Completa o Modo de la aplicación.
/// Completamente desacoplada de la clase Application.
class View {
  final String id;
  int _width = 0;
  int _height = 0;
  bool isVisible;
  bool useScissorClipping;
  ColorRGBA? backgroundColor;
  bool _isBuilt = false;

  final List<Element> _children = [];

  View({
    required this.id,
    this.isVisible = true,
    this.useScissorClipping = false,
    this.backgroundColor,
    List<Element>? children,
  }) {
    if (children != null) {
      addAll(children);
    }
  }

  /// Coordenadas de posición fijas (una pantalla completa siempre inicia en 0,0)
  int get x => 0;
  int get y => 0;

  /// Dimensiones de la vista de solo lectura (gestionadas automáticamente por el motor)
  int get width => _width;
  int get height => _height;

  List<Element> get children {
    _ensureBuilt();
    return List.unmodifiable(_children);
  }

  void _ensureBuilt() {
    if (!_isBuilt) {
      _isBuilt = true;
      final builtChildren = build();
      if (builtChildren.isNotEmpty) {
        addAll(builtChildren);
      }
    }
  }

  /// Forzar la reconstrucción de la jerarquía UI declarativa de la vista (`build()`).
  /// Preserva automáticamente el estado dinámico (ej. scrollOffset) de componentes coincidentes.
  void rebuild() {
    final savedStates = _collectElementStates(_children);
    _children.clear();
    _isBuilt = false;
    _ensureBuilt();
    _restoreElementStates(_children, savedStates);
    if (_width > 0 && _height > 0) {
      resize(_width, _height);
    }
  }

  Map<String, Map<String, dynamic>> _collectElementStates(
    List<Element> elements, [
    String prefix = '',
  ]) {
    final Map<String, Map<String, dynamic>> states = {};
    final Map<String, int> typeCounts = {};

    for (final element in elements) {
      final typeName = element.runtimeType.toString();
      final count = typeCounts[typeName] ?? 0;
      typeCounts[typeName] = count + 1;

      final elementKey = element.key ?? '$prefix/$typeName#$count';
      final state = element.exportState();
      if (state != null) {
        states[elementKey] = state;
      }

      final subChildren = element.childrenElements;
      if (subChildren.isNotEmpty) {
        states.addAll(_collectElementStates(subChildren, elementKey));
      }
    }
    return states;
  }

  void _restoreElementStates(
    List<Element> elements,
    Map<String, Map<String, dynamic>> states, [
    String prefix = '',
  ]) {
    final Map<String, int> typeCounts = {};

    for (final element in elements) {
      final typeName = element.runtimeType.toString();
      final count = typeCounts[typeName] ?? 0;
      typeCounts[typeName] = count + 1;

      final elementKey = element.key ?? '$prefix/$typeName#$count';
      if (states.containsKey(elementKey)) {
        element.importState(states[elementKey]!);
      }

      final subChildren = element.childrenElements;
      if (subChildren.isNotEmpty) {
        _restoreElementStates(subChildren, states, elementKey);
      }
    }
  }

  // =======================================================
  // HOOKS SOBREESCRIBIBLES POR EL DESARROLLADOR
  // =======================================================

  /// Construye la jerarquía declarativa de componentes UI de la vista.
  List<Element> build() => [];

  /// Inicialización de lógica o estado propio de la vista.
  void onInit() {}

  /// Actualización de lógica personalizada por cuadro (ej. físicas, animación de cámara 3D).
  void onUpdate(double dt, InputEngine input) {}

  /// Dibujado nativo personalizado por cuadro (ej. mallas 3D, canvas especial).
  void onRender(Context2D ctx2d, Context3D ctx3d) {}

  /// Reacción personalizada al redimensionamiento de pantalla.
  void onResize(int newWidth, int newHeight) {}

  /// Limpieza de recursos al destruir o desregistrar la vista.
  void onDispose() {}

  // =======================================================
  // MÉTODOS DEL MOTOR (EJECUTADOS INTERNAMENTE POR VIEWMANAGER)
  // =======================================================

  void init() {
    _ensureBuilt();
    onInit();
  }

  void update(double dt, InputEngine input) {
    if (!isVisible) return;
    _ensureBuilt();

    // 1. Ejecutar hook personalizado del desarrollador
    onUpdate(dt, input);

    // 2. Garantizar SIEMPRE la actualización de componentes hijos
    for (final child in _children) {
      if (child.isVisible) {
        child.onUpdate(dt, input);
      }
    }

    // 3. Actualizar notificaciones y diálogos modales flotantes (Toast, SnackBar, Dialog)
    Toast.updateActiveToasts(dt, input);
    SnackBar.updateActiveSnackBar(dt, input);
    Dialog.updateActiveDialog(
      dt,
      input,
      width > 0 ? width : 1280,
      height > 0 ? height : 720,
    );
  }

  void render(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _ensureBuilt();

    Element.isRenderingPhase = true;
    try {
      if (useScissorClipping && width > 0 && height > 0) {
        ctx2d.beginScissor(x, y, width, height);
        _renderInternal(ctx2d, ctx3d);
        ctx2d.endScissor();
      } else {
        _renderInternal(ctx2d, ctx3d);
      }
    } finally {
      Element.isRenderingPhase = false;
    }
  }

  void _renderInternal(Context2D ctx2d, Context3D ctx3d) {
    // 0. Renderizar color de fondo opcional de la vista
    if (backgroundColor != null && width > 0 && height > 0) {
      ctx2d.drawRect(x, y, width, height, backgroundColor!);
    }

    // 1. Ejecutar dibujado personalizado del desarrollador
    onRender(ctx2d, ctx3d);

    // 2. Pase 1: Garantizar SIEMPRE el renderizado de componentes hijos
    for (final child in _children) {
      if (child.isVisible) {
        child.onRender(ctx2d, ctx3d);
      }
    }

    // 3. Pase 2: Garantizar el dibujado de capas flotantes (dropdowns, popups, tooltips) por encima de todo
    for (final child in _children) {
      if (child.isVisible) {
        child.onRenderOverlay(ctx2d, ctx3d);
      }
    }

    // 4. Pase 3: Renderizar notificaciones y diálogos modales flotantes globales
    Toast.renderActiveToasts(
      ctx2d,
      ctx3d,
      width > 0 ? width : 1280,
      height > 0 ? height : 720,
    );
    SnackBar.renderActiveSnackBar(
      ctx2d,
      ctx3d,
      width > 0 ? width : 1280,
      height > 0 ? height : 720,
    );
    Dialog.renderActiveDialog(
      ctx2d,
      ctx3d,
      width > 0 ? width : 1280,
      height > 0 ? height : 720,
    );
  }

  void resize(int parentWidth, int parentHeight) {
    _width = parentWidth;
    _height = parentHeight;
    _ensureBuilt();

    // 1. Ejecutar hook personalizado del desarrollador
    onResize(_width, _height);

    // 2. Garantizar SIEMPRE el responsive de componentes hijos
    for (final child in _children) {
      final allocatedWidth = _width > child.x ? _width - child.x : 0;
      final allocatedHeight = _height > child.y ? _height - child.y : 0;
      child.onResize(allocatedWidth, allocatedHeight);
    }
  }

  void dispose() {
    onDispose();
    _children.clear();
    _isBuilt = false;
  }

  // =======================================================
  // ADMINISTRACIÓN DE HIJOS
  // =======================================================

  T add<T extends Element>(T child) {
    _children.add(child);
    return child;
  }

  void addAll(List<Element> elements) {
    _children.addAll(elements);
  }

  void remove(Element child) {
    _children.remove(child);
  }

  void clear() {
    _children.clear();
  }
}
