import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/layouts/panel.dart';
import 'package:frontend/core/ui/interaction/toast.dart';
import 'package:frontend/core/ui/interaction/snack_bar.dart';
import 'package:frontend/core/ui/interaction/dialog.dart';
export 'package:frontend/core/ui/element.dart';

/// Marco Global de la Aplicación (`View`).
///
/// Actúa como el contenedor raíz anclado a las dimensiones de la ventana.
/// Sus hijos directos son **exclusivamente** instancias de [Panel].
///
/// ## Posicionamiento: Algoritmo Greedy de Esquinas Candidatas
///
/// La View orquesta la posición `(x, y)` de sus Panels usando un algoritmo
/// determinista basado en esquinas libres:
///
/// 1. La lista de offsets candidatos inicia en `[(0, 0)]`.
/// 2. Por cada Panel declarado en [build], se prueban los offsets en orden.
/// 3. Para cada candidato se resuelven las dimensiones del Panel:
///    - Dimensión fija → se usa directamente.
///    - `isFlexWidth`/`isFlexHeight` → se expande al espacio libre desde ese candidato.
/// 4. Si el Panel cabe (sin colisión y sin desbordamiento), se coloca ahí y
///    se generan dos nuevas esquinas candidatas.
/// 5. Si ningún offset lo admite, el Panel **no se coloca** y se emite un warning.
///
/// El Greedy se re-ejecuta en cada llamada a [resize], garantizando que los
/// Panels siempre reflejan las dimensiones actuales de la ventana.
class View {
  final String id;
  int _width = 0;
  int _height = 0;
  bool isVisible;
  bool useScissorClipping;
  ColorRGBA? backgroundColor;

  bool _isBuilt = false;

  /// Panels declarados por [build] (los "moldes", sin posición ni tamaño resuelto).
  final List<Panel> _declared = [];

  /// Panels ya posicionados y dimensionados por el Greedy (los reales).
  final List<Panel> _panels = [];

  View({
    required this.id,
    this.isVisible = true,
    this.useScissorClipping = true,
    this.backgroundColor,
  });

  int get x => 0;
  int get y => 0;
  int get width => _width;
  int get height => _height;

  /// Lista de Panels posicionados (solo lectura).
  List<Panel> get panels {
    _ensureBuilt();
    return List.unmodifiable(_panels);
  }

  // ─────────────────────────────────────────────
  // Build / Rebuild
  // ─────────────────────────────────────────────

  void _ensureBuilt() {
    if (!_isBuilt) {
      _isBuilt = true;
      _declared.clear();
      _declared.addAll(build());
      // Si ya tenemos dimensiones, ejecutar Greedy ahora mismo.
      // Si no, el Greedy se ejecutará en la primera llamada a resize().
      if (_width > 0 && _height > 0) {
        _runGreedy();
      }
    }
  }

  /// Ejecuta el Greedy desde cero con los panels declarados actuales.
  /// Solo opera si las dimensiones de la ventana son conocidas.
  void _runGreedy() {
    if (_width <= 0 || _height <= 0) return;

    final savedStates = _collectStates(_panels);
    _panels.clear();
    _placePanels(_declared, savedStates);
  }

  /// Forzar la reconstrucción de la jerarquía de Panels.
  /// Preserva automáticamente el estado dinámico entre reconstrucciones.
  void rebuild() {
    _isBuilt = false;
    _declared.clear();
    _panels.clear();
    _ensureBuilt();
  }

  // ─────────────────────────────────────────────
  // Algoritmo Greedy de Esquinas Candidatas
  // ─────────────────────────────────────────────

  void _placePanels(
    List<Panel> declared,
    Map<String, Map<String, dynamic>> savedStates,
  ) {
    final List<({int x, int y})> candidates = [(x: 0, y: 0)];
    final List<Panel> placed = [];

    for (final panel in declared) {
      bool positioned = false;

      // Guardar las dimensiones originales intactas por si hay que evaluar múltiples esquinas
      final int originalWidth = panel.width;
      final int originalHeight = panel.height;

      // Ordenar candidatos por Y primero (arriba a abajo), luego por X (izquierda a derecha)
      candidates.sort((a, b) {
        if (a.y != b.y) return a.y.compareTo(b.y);
        return a.x.compareTo(b.x);
      });

      for (int i = 0; i < candidates.length; i++) {
        final c = candidates[i];

        // 1. Resolver en variables locales, NO en el panel
        final resolvedW = _resolveWidth(panel, c.x, originalWidth);
        final resolvedH = _resolveHeight(panel, c.y, originalHeight);

        if (resolvedW <= 0 || resolvedH <= 0) continue;

        // 2. Crear una caja temporal (Bounding Box) para el test
        final candidateBox = (x: c.x, y: c.y, w: resolvedW, h: resolvedH);

        // 3. Test de límites y colisiones usando la caja temporal
        bool outOfBounds =
            (candidateBox.x + candidateBox.w > _width) ||
            (candidateBox.y + candidateBox.h > _height);

        bool colisiona = placed.any(
          (p) =>
              candidateBox.x < p.x + p.width &&
              candidateBox.x + candidateBox.w > p.x &&
              candidateBox.y < p.y + p.height &&
              candidateBox.y + candidateBox.h > p.y,
        );

        if (!outOfBounds && !colisiona) {
          // ✅ El panel cabe: aplicar mutación definitiva
          panel.x = candidateBox.x;
          panel.y = candidateBox.y;
          panel.width = candidateBox.w;
          panel.height = candidateBox.h;

          placed.add(panel);

          panel.onResize(resolvedW, resolvedH);

          final key = _panelKey(panel, placed.length - 1);
          if (savedStates.containsKey(key)) {
            panel.importState(savedStates[key]!);
          }

          // 4. Generar nuevas esquinas (evitando duplicados)
          final rightCorner = (x: panel.x + panel.width, y: panel.y);
          final bottomCorner = (x: panel.x, y: panel.y + panel.height);

          if (rightCorner.x < _width && !candidates.contains(rightCorner)) {
            candidates.add(rightCorner);
          }
          if (bottomCorner.y < _height && !candidates.contains(bottomCorner)) {
            candidates.add(bottomCorner);
          }

          // 5. CULLING REAL: Eliminar esquinas sepultadas por el nuevo panel
          candidates.removeWhere(
            (corner) =>
                corner.x >= panel.x &&
                corner.x < panel.x + panel.width &&
                corner.y >= panel.y &&
                corner.y < panel.y + panel.height,
          );

          positioned = true;
          break;
        }
      }

      if (!positioned) {
        print(
          '⚠️ WARNING [View "$id"]: Panel "${panel.key ?? panel.runtimeType}" '
          'no pudo posicionarse. Dimensiones originales: ${originalWidth}x${originalHeight}. '
          'Verifica espacio disponible y colisiones.',
        );
      }
    }

    _panels.addAll(placed);
  }

  /// Resuelve el ancho definitivo de un Panel para un candidato X dado.
  int _resolveWidth(Panel panel, int candidateX, int originalWidth) {
    if (panel.isFlexWidth) {
      // Ocupa todo el ancho libre desde candidateX hasta el borde derecho
      final free = _width - candidateX;
      return free > 0 ? free : 0;
    }
    return originalWidth; // Usa el valor original intacto
  }

  /// Resuelve el alto definitivo de un Panel para un candidato Y dado.
  int _resolveHeight(Panel panel, int candidateY, int originalHeight) {
    if (panel.isFlexHeight) {
      // Ocupa todo el alto libre desde candidateY hasta el borde inferior
      final free = _height - candidateY;
      return free > 0 ? free : 0;
    }
    return originalHeight; // Usa el valor original intacto
  }

  String _panelKey(Panel panel, int index) {
    return panel.key ?? '/${panel.runtimeType}#$index';
  }

  // ─────────────────────────────────────────────
  // Preservación de estado entre rebuilds
  // ─────────────────────────────────────────────

  Map<String, Map<String, dynamic>> _collectStates(List<Panel> panels) {
    final Map<String, Map<String, dynamic>> states = {};
    for (int i = 0; i < panels.length; i++) {
      final panel = panels[i];
      final key = _panelKey(panel, i);
      final state = panel.exportState();
      if (state != null) states[key] = state;
      states.addAll(_collectElementStates(panel.childrenElements, key));
    }
    return states;
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
      final key = element.key ?? '$prefix/$typeName#$count';
      final state = element.exportState();
      if (state != null) states[key] = state;
      if (element.childrenElements.isNotEmpty) {
        states.addAll(_collectElementStates(element.childrenElements, key));
      }
    }
    return states;
  }

  // =======================================================
  // HOOKS SOBREESCRIBIBLES POR EL DESARROLLADOR
  // =======================================================

  /// Construye y retorna la lista de [Panel]s que componen esta vista.
  /// El orden importa: el Greedy los posiciona en el orden declarado.
  List<Panel> build() => [];

  void onInit() {}
  void onUpdate(double dt, InputEngine input) {}
  void onRender(Context2D ctx2d, Context3D ctx3d) {}
  void onResize(int newWidth, int newHeight) {}
  void onDispose() {}

  // =======================================================
  // MÉTODOS DEL MOTOR (EJECUTADOS INTERNAMENTE POR VIEWMANAGER)
  // =======================================================

  void init() {
    print("Inicializando la vista $id init()");
    _ensureBuilt();
    onInit();
  }

  void update(double dt, InputEngine input) {
    if (!isVisible) return;
    _ensureBuilt();

    onUpdate(dt, input);

    for (final panel in _panels) {
      if (panel.isVisible) panel.onUpdate(dt, input);
    }

    Toast.updateActiveToasts(dt, input);
    SnackBar.updateActiveSnackBar(dt, input);
    Dialog.updateActiveDialog(
      dt,
      input,
      _width > 0 ? _width : 1280,
      _height > 0 ? _height : 720,
    );
  }

  void render(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _ensureBuilt();

    Element.isRenderingPhase = true;
    try {
      if (useScissorClipping && _width > 0 && _height > 0) {
        ctx2d.beginScissor(x, y, _width, _height);
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
    // 0. Fondo opcional de la vista
    if (backgroundColor != null && _width > 0 && _height > 0) {
      ctx2d.drawRect(x, y, _width, _height, backgroundColor!);
    }

    // 1. Hook de dibujado personalizado del desarrollador
    onRender(ctx2d, ctx3d);

    // 2. Pase 1: Renderizar todos los Panels posicionados
    for (final panel in _panels) {
      if (panel.isVisible) panel.onRender(ctx2d, ctx3d);
    }

    // 3. Pase 2: Capas flotantes (dropdowns, popups, tooltips) por encima de todo
    for (final panel in _panels) {
      if (panel.isVisible) panel.onRenderOverlay(ctx2d, ctx3d);
    }

    // 4. Pase 3: Notificaciones y diálogos modales flotantes globales
    final vw = _width > 0 ? _width : 1280;
    final vh = _height > 0 ? _height : 720;
    Toast.renderActiveToasts(ctx2d, ctx3d, vw, vh);
    SnackBar.renderActiveSnackBar(ctx2d, ctx3d, vw, vh);
    Dialog.renderActiveDialog(ctx2d, ctx3d, vw, vh);
  }

  /// Llamado por el ViewManager cada vez que la ventana cambia de tamaño.
  /// Re-ejecuta el Greedy para reposicionar y redimensionar todos los Panels.
  void resize(int parentWidth, int parentHeight) {
    _width = parentWidth;
    _height = parentHeight;

    _ensureBuilt();

    // Siempre re-ejecutar el Greedy con las nuevas dimensiones.
    // Esto garantiza que los Panels expand:true llenen el nuevo espacio.
    _runGreedy();

    onResize(_width, _height);
  }

  void dispose() {
    onDispose();
    _declared.clear();
    _panels.clear();
    _isBuilt = false;
  }
}

/// Vista responsiva por defecto (Modo Reflow - Hoja Elástica).
abstract class FluidView extends View {
  FluidView({
    required super.id,
    super.isVisible,
    super.useScissorClipping,
    super.backgroundColor,
  });

  @override
  void resize(int parentWidth, int parentHeight) {
    _width = parentWidth;
    _height = parentHeight;
    _ensureBuilt();
    _runGreedy();
    onResize(_width, _height);
  }
}

/// Vista de lienzo de resolución fija (Modo Fit - Escalado Fijo).
abstract class CanvasView extends View {
  int _logicalWidth;
  int _logicalHeight;
  ColorRGBA letterboxColor;

  int get logicalWidth => _logicalWidth;
  int get logicalHeight => _logicalHeight;

  int _windowWidth = 0;
  int _windowHeight = 0;
  double _scale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  bool _initializedLogicalSize = false;

  CanvasView({
    required super.id,
    int? logicalWidth,
    int? logicalHeight,
    this.letterboxColor = ColorRGBA.black,
    super.isVisible,
    super.useScissorClipping,
    super.backgroundColor,
  })  : _logicalWidth = logicalWidth ?? 0,
        _logicalHeight = logicalHeight ?? 0 {
    if (_logicalWidth > 0 && _logicalHeight > 0) {
      _initializedLogicalSize = true;
      _width = _logicalWidth;
      _height = _logicalHeight;
    }
  }

  double get scale => _scale;
  double get offsetX => _offsetX;
  double get offsetY => _offsetY;

  @override
  void resize(int parentWidth, int parentHeight) {
    _windowWidth = parentWidth;
    _windowHeight = parentHeight;

    bool isFirstLogicalInit = !_initializedLogicalSize;

    if (isFirstLogicalInit && parentWidth > 0 && parentHeight > 0) {
      _initializedLogicalSize = true;
      _logicalWidth = parentWidth;
      _logicalHeight = parentHeight;
      _width = _logicalWidth;
      _height = _logicalHeight;
    }

    final targetW = _logicalWidth > 0 ? _logicalWidth : parentWidth;
    final targetH = _logicalHeight > 0 ? _logicalHeight : parentHeight;

    final double scaleX = targetW > 0 ? parentWidth / targetW : 1.0;
    final double scaleY = targetH > 0 ? parentHeight / targetH : 1.0;
    _scale = math.min(scaleX, scaleY);

    _offsetX = (parentWidth - (targetW * _scale)) / 2.0;
    _offsetY = (parentHeight - (targetH * _scale)) / 2.0;

    _ensureBuilt();

    if (_panels.isEmpty || isFirstLogicalInit) {
      _runGreedy();
    }

    onResize(targetW, targetH);
  }

  @override
  void update(double dt, InputEngine input) {
    if (!isVisible) return;
    _ensureBuilt();

    final transformedInput = TransformedInputEngine(
      input,
      offsetX: _offsetX,
      offsetY: _offsetY,
      scale: _scale,
    );

    onUpdate(dt, transformedInput);

    for (final panel in panels) {
      if (panel.isVisible) panel.onUpdate(dt, transformedInput);
    }

    Toast.updateActiveToasts(dt, transformedInput);
    SnackBar.updateActiveSnackBar(dt, transformedInput);
    Dialog.updateActiveDialog(
      dt,
      transformedInput,
      _logicalWidth > 0 ? _logicalWidth : 1280,
      _logicalHeight > 0 ? _logicalHeight : 720,
    );
  }

  @override
  void render(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _ensureBuilt();

    final winW = _windowWidth > 0 ? _windowWidth : _logicalWidth;
    final winH = _windowHeight > 0 ? _windowHeight : _logicalHeight;

    if (winW > 0 && winH > 0 && _logicalWidth > 0 && _logicalHeight > 0) {
      final double scaleX = winW / _logicalWidth;
      final double scaleY = winH / _logicalHeight;
      _scale = math.min(scaleX, scaleY);

      _offsetX = (winW - (_logicalWidth * _scale)) / 2.0;
      _offsetY = (winH - (_logicalHeight * _scale)) / 2.0;
    }

    Element.isRenderingPhase = true;
    try {
      if (winW > 0 && winH > 0) {
        ctx2d.drawRect(0, 0, winW, winH, letterboxColor);
      }

      ctx2d.translate(_offsetX, _offsetY);
      ctx2d.scale(_scale, _scale);

      final useClip =
          useScissorClipping && _logicalWidth > 0 && _logicalHeight > 0;
      if (useClip) {
        ctx2d.beginScissor(0, 0, _logicalWidth, _logicalHeight);
      }

      _renderInternal(ctx2d, ctx3d);

      if (useClip) {
        ctx2d.endScissor();
      }

      ctx2d.resetTransform();
    } finally {
      Element.isRenderingPhase = false;
    }
  }
}
