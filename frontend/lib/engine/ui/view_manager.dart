import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/navigator.dart';
import 'package:cortex/engine/ui/view.dart';

/// El ViewManager administra el catálogo de Vistas (Pantallas/Modos del software)
/// y garantiza que SOLO UNA View esté activa y renderizada a la vez.
/// Soporta Instanciación Bajo Demanda (Lazy Loading) y Liberación Automática de Memoria.
class ViewManager {
  final Map<String, View> _views = {};
  final Map<String, ViewBuilder> _factories = {};
  final Set<String> _autoDisposeViews = {};

  View? _activeView;
  int _lastWidth = 0;
  int _lastHeight = 0;

  View? get activeView => _activeView;
  int get lastWidth => _lastWidth;
  int get lastHeight => _lastHeight;

  /// Registra una vista pre-instanciada (Instanciación inmediata).
  void registerView(View view) {
    _views[view.id] = view;
    view.init();
    if (_lastWidth > 0 && _lastHeight > 0) {
      view.resize(_lastWidth, _lastHeight);
    }
    _activeView ??= view;
  }

  /// Registra una fábrica de vista con Carga Diferida (Lazy Loading).
  /// La vista NO se instanciará ni consumirá memoria RAM/VRAM hasta que se navegue a ella.
  /// Si `autoDispose` es true, la vista se destruirá al salir de ella para liberar memoria.
  void registerLazyView(String id, ViewBuilder builder, {bool autoDispose = false}) {
    _factories[id] = builder;
    if (autoDispose) {
      _autoDisposeViews.add(id);
    }

    // Si no hay ninguna vista activa aún, cargar esta inmediatamente
    if (_activeView == null) {
      switchView(id);
    }
  }

  void switchView(String id) {
    // 1. Si la vista ya fue instanciada previamente en memoria
    if (_views.containsKey(id)) {
      _setActiveView(_views[id]!);
      return;
    }

    // 2. Si la vista está registrada como una fábrica Lazy, crearla bajo demanda
    if (_factories.containsKey(id)) {
      final view = _factories[id]!();
      _views[id] = view;
      view.init();
      if (_lastWidth > 0 && _lastHeight > 0) {
        view.resize(_lastWidth, _lastHeight);
      }
      _setActiveView(view);
    }
  }

  void _setActiveView(View newView) {
    // Si la vista anterior requiere auto-liberación de memoria (autoDispose)
    if (_activeView != null && _activeView != newView) {
      final oldId = _activeView!.id;
      if (_autoDisposeViews.contains(oldId)) {
        _activeView!.dispose();
        _views.remove(oldId);
      }
    }

    _activeView = newView;
    if (_lastWidth > 0 && _lastHeight > 0) {
      _activeView!.resize(_lastWidth, _lastHeight);
    }
  }

  void updateCurrent(double dt, InputEngine input) {
    _activeView?.update(dt, input);
  }

  void renderCurrent(Context2D ctx2d, Context3D ctx3d) {
    _activeView?.render(ctx2d, ctx3d);
  }

  void handleResize(int windowWidth, int windowHeight) {
    _lastWidth = windowWidth;
    _lastHeight = windowHeight;
    for (final view in _views.values) {
      view.resize(windowWidth, windowHeight);
    }
  }

  void clear() {
    for (final view in _views.values) {
      view.dispose();
    }
    _views.clear();
    _factories.clear();
    _autoDisposeViews.clear();
    _activeView = null;
  }
}
