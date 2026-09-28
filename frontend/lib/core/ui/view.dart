part of 'ui.dart';

/// Contrato abstracto interno del marco global de la aplicación (`_View`).
///
/// Mantiene la interfaz y comportamiento interno que el motor de Cortex usa para
/// calcular dimensiones (Greedy), iterar y disparar el renderizado y ciclo de vida.
abstract class _View {
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

  _View({
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
      if (_width > 0 && _height > 0) {
        _runGreedy();
      }
    }
  }

  void _runGreedy() {
    if (_width <= 0 || _height <= 0) return;

    final savedStates = _collectStates(_panels);
    _panels.clear();
    _placePanels(_declared, savedStates);
  }

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

      final int originalWidth = panel.width;
      final int originalHeight = panel.height;

      candidates.sort((a, b) {
        if (a.y != b.y) return a.y.compareTo(b.y);
        return a.x.compareTo(b.x);
      });

      for (int i = 0; i < candidates.length; i++) {
        final c = candidates[i];

        final resolvedW = _resolveWidth(panel, c.x, originalWidth);
        final resolvedH = _resolveHeight(panel, c.y, originalHeight);

        if (resolvedW <= 0 || resolvedH <= 0) continue;

        final candidateBox = (x: c.x, y: c.y, w: resolvedW, h: resolvedH);

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

          final rightCorner = (x: panel.x + panel.width, y: panel.y);
          final bottomCorner = (x: panel.x, y: panel.y + panel.height);

          if (rightCorner.x < _width && !candidates.contains(rightCorner)) {
            candidates.add(rightCorner);
          }
          if (bottomCorner.y < _height && !candidates.contains(bottomCorner)) {
            candidates.add(bottomCorner);
          }

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
          '⚠️ WARNING [_View "$id"]: Panel "${panel.key ?? panel.runtimeType}" '
          'no pudo posicionarse. Dimensiones originales: ${originalWidth}x$originalHeight. '
          'Verifica espacio disponible y colisiones.',
        );
      }
    }

    _panels.addAll(placed);
  }

  int _resolveWidth(Panel panel, int candidateX, int originalWidth) {
    final free = _width - candidateX;
    return Panel.resolveDimension(panel.rawWidth, _width, free > 0 ? free : _width);
  }

  int _resolveHeight(Panel panel, int candidateY, int originalHeight) {
    final free = _height - candidateY;
    return Panel.resolveDimension(panel.rawHeight, _height, free > 0 ? free : _height);
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
    List<CortexNode> elements, [
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
  // HOOKS SOBREESCRIBIBLES
  // =======================================================

  List<Panel> build() => [];

  void onInit() {}
  void onUpdate(double dt, InputEngine input) {}
  void onRender(Context2D ctx2d, Context3D ctx3d) {}
  void onResize(int newWidth, int newHeight) {}
  void onDispose() {}

  // =======================================================
  // MÉTODOS DEL MOTOR
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
    if (backgroundColor != null && _width > 0 && _height > 0) {
      ctx2d.drawRect(x, y, _width, _height, backgroundColor!);
    }

    onRender(ctx2d, ctx3d);

    for (final panel in _panels) {
      if (panel.isVisible) panel.onRender(ctx2d, ctx3d);
    }

    for (final panel in _panels) {
      if (panel.isVisible) panel.onRenderOverlay(ctx2d, ctx3d);
    }

    final vw = _width > 0 ? _width : 1280;
    final vh = _height > 0 ? _height : 720;
    Toast.renderActiveToasts(ctx2d, ctx3d, vw, vh);
    SnackBar.renderActiveSnackBar(ctx2d, ctx3d, vw, vh);
    Dialog.renderActiveDialog(ctx2d, ctx3d, vw, vh);
  }

  void resize(int parentWidth, int parentHeight) {
    _width = parentWidth;
    _height = parentHeight;

    _ensureBuilt();
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
///
/// Entidad pública para instanciación directa o composición.
class FluidView extends _View {
  final List<Panel>? _panelsList;
  final List<Panel> Function()? _builder;
  final void Function()? _onInitCallback;
  final void Function(double dt, InputEngine input)? _onUpdateCallback;
  final void Function(Context2D ctx2d, Context3D ctx3d)? _onRenderCallback;
  final void Function(int width, int height)? _onResizeCallback;
  final void Function()? _onDisposeCallback;

  FluidView({
    required super.id,
    super.isVisible,
    super.useScissorClipping,
    super.backgroundColor,
    List<Panel>? panels,
    List<Panel> Function()? builder,
    void Function()? onInit,
    void Function(double dt, InputEngine input)? onUpdate,
    void Function(Context2D ctx2d, Context3D ctx3d)? onRender,
    void Function(int width, int height)? onResize,
    void Function()? onDispose,
  })  : _panelsList = panels,
        _builder = builder,
        _onInitCallback = onInit,
        _onUpdateCallback = onUpdate,
        _onRenderCallback = onRender,
        _onResizeCallback = onResize,
        _onDisposeCallback = onDispose;

  @override
  List<Panel> build() {
    final builderFunc = _builder;
    if (builderFunc != null) return builderFunc();
    final list = _panelsList;
    if (list != null) return list;
    return super.build();
  }

  @override
  void onInit() {
    super.onInit();
    _onInitCallback?.call();
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    _onUpdateCallback?.call(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    super.onRender(ctx2d, ctx3d);
    _onRenderCallback?.call(ctx2d, ctx3d);
  }

  @override
  void resize(int parentWidth, int parentHeight) {
    _width = parentWidth;
    _height = parentHeight;
    _ensureBuilt();
    _runGreedy();
    super.resize(_width, _height);
    _onResizeCallback?.call(_width, _height);
  }

  @override
  void onDispose() {
    super.onDispose();
    _onDisposeCallback?.call();
  }
}

/// Vista de contenedor/lienzo de resolución fija o lógica (Modo Fit - Escalado Fijo).
///
/// Entidad pública para instanciación directa o composición.
class ContainerView extends _View {
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

  final List<Panel>? _panelsList;
  final List<Panel> Function()? _builder;
  final void Function()? _onInitCallback;
  final void Function(double dt, InputEngine input)? _onUpdateCallback;
  final void Function(Context2D ctx2d, Context3D ctx3d)? _onRenderCallback;
  final void Function(int width, int height)? _onResizeCallback;
  final void Function()? _onDisposeCallback;

  ContainerView({
    required super.id,
    int? logicalWidth,
    int? logicalHeight,
    this.letterboxColor = ColorRGBA.black,
    super.isVisible,
    super.useScissorClipping,
    super.backgroundColor,
    List<Panel>? panels,
    List<Panel> Function()? builder,
    void Function()? onInit,
    void Function(double dt, InputEngine input)? onUpdate,
    void Function(Context2D ctx2d, Context3D ctx3d)? onRender,
    void Function(int width, int height)? onResize,
    void Function()? onDispose,
  })  : _logicalWidth = logicalWidth ?? 0,
        _logicalHeight = logicalHeight ?? 0,
        _panelsList = panels,
        _builder = builder,
        _onInitCallback = onInit,
        _onUpdateCallback = onUpdate,
        _onRenderCallback = onRender,
        _onResizeCallback = onResize,
        _onDisposeCallback = onDispose {
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
  List<Panel> build() {
    final builderFunc = _builder;
    if (builderFunc != null) return builderFunc();
    final list = _panelsList;
    if (list != null) return list;
    return super.build();
  }

  @override
  void onInit() {
    super.onInit();
    _onInitCallback?.call();
  }

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

    super.resize(targetW, targetH);
    _onResizeCallback?.call(targetW, targetH);
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

    super.onUpdate(dt, transformedInput);
    _onUpdateCallback?.call(dt, transformedInput);

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
      _onRenderCallback?.call(ctx2d, ctx3d);

      if (useClip) {
        ctx2d.endScissor();
      }

      ctx2d.resetTransform();
    } finally {
      Element.isRenderingPhase = false;
    }
  }

  @override
  void onDispose() {
    super.onDispose();
    _onDisposeCallback?.call();
  }
}
