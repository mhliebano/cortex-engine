import 'package:cortex/core/ui/desktop/desktop_layout.dart';
import 'package:cortex/core/ui/layouts/column.dart';
import 'package:cortex/core/ui/view.dart';

typedef ViewBuilder = View Function();

/// Sistema de Navegación por Rutas Genérico para el Motor UI.
/// Permite registrar la tabla de rutas con carga diferida (Lazy Loading) y navegar con `Navigator.to('ruta')`.
class Navigator {
  static final Map<String, ViewBuilder> _routes = {};
  static String? initialRoute;
  static void Function(String route)? _navigationHandler;
  static void Function(String route, ViewBuilder builder)?
  _routeRegistrationHandler;

  /// Inicializado automáticamente por la clase `Application`.
  static void setHandler(void Function(String route) handler) {
    _navigationHandler = handler;
  }

  /// Conecta el gestor de registro diferido de Application / ViewManager.
  static void setRegisterHandler(
    void Function(String route, ViewBuilder builder) handler,
  ) {
    _routeRegistrationHandler = handler;
    _routes.forEach((route, builder) {
      _routeRegistrationHandler?.call(route, builder);
    });
  }

  /// Registra una tabla completa de rutas con carga diferida (Lazy Loading).
  /// Ejemplo:
  /// ```dart
  /// Navigator.registerRoutes({
  ///   'test_view': () => TestView(),
  ///   'editor3d': () => Editor3DView(),
  /// });
  /// ```
  static void registerRoutes(Map<String, ViewBuilder> routes) {
    routes.forEach((route, builder) {
      registerRoute(route, builder);
    });
  }

  /// Registra una ruta individual con carga diferida.
  static void registerRoute(String route, ViewBuilder builder) {
    _routes[route] = builder;
    if (_routeRegistrationHandler != null) {
      _routeRegistrationHandler!(route, builder);
    }
  }

  /// Navega a la vista/pantalla especificada por su nombre de ruta.
  /// Si un `DesktopLayout` MDI está activo en pantalla y `fullscreen` es false,
  /// la navegación reemplaza de forma fluida el contenido de la zona central `body`.
  static void to(String route, {bool fullscreen = false}) {
    final layout = DesktopLayout.activeLayout;

    if (!fullscreen && layout != null && _routes.containsKey(route)) {
      final view = _routes[route]!();
      view.init();
      final children = view.children;
      if (children.isNotEmpty) {
        if (children.length == 1) {
          layout.body = children.first;
        } else {
          layout.body = Column(
            expand: Expand.all,
            spacing: 0,
            children: children,
          );
        }
      }
      return;
    }

    if (_navigationHandler != null) {
      _navigationHandler!(route);
    }
  }

  /// Alias intuitivos estilo Flutter.
  static void pushNamed(String route, {bool fullscreen = false}) =>
      to(route, fullscreen: fullscreen);
  static void push(String route, {bool fullscreen = false}) =>
      to(route, fullscreen: fullscreen);
}
