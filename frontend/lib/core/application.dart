import 'dart:io' show Directory, File, Platform;
import 'package:path/path.dart' as path;

import 'package:cortex/wrappers/window.dart';
import 'package:cortex/core/audio.dart';
import 'package:cortex/core/app_window.dart';

import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/navigator.dart';
import 'package:cortex/core/ui/view.dart';
import 'package:cortex/core/ui/view_manager.dart';

/// La clase `Application` encapsula la ventana, contextos 2D/3D, ruteo, fuentes TTF y ciclo de vida de la app.
class Application {
  final String title;
  final int width;
  final int height;
  final int flags;
  final ColorRGBA clearColor;

  late final AppWindow _window;
  late final Context2D _ctx2d;
  late final Context3D _ctx3d;
  late final ViewManager _viewManager;

  Application({
    required this.title,
    this.width = 1152,
    this.height = 680,
    this.flags = WindowFlags.windowResizable | WindowFlags.vsyncHint,
    this.clearColor = const ColorRGBA(20, 22, 28, 255),
  }) {
    _window = AppWindow();
    _ctx2d = Context2D();
    _ctx3d = Context3D();
    _viewManager = ViewManager();

    // Conectar el sistema de navegación por rutas global Navigator.to('ruta')
    Navigator.setHandler(switchView);
    Navigator.setRegisterHandler((route, builder) {
      _viewManager.registerLazyView(route, builder);
    });
  }

  AppWindow get window => _window;
  Context2D get ctx2d => _ctx2d;
  Context3D get ctx3d => _ctx3d;
  ViewManager get viewManager => _viewManager;
  InputEngine get input => _window.input;

  /// Registra una vista pre-instanciada en la aplicación.
  void registerView(View view) {
    _viewManager.registerView(view);
  }

  /// Registra una fábrica de vista con Carga Diferida (Lazy Loading).
  /// La vista NO consumirá memoria hasta que el usuario la abra.
  void registerLazyView(
    String id,
    ViewBuilder builder, {
    bool autoDispose = false,
  }) {
    _viewManager.registerLazyView(id, builder, autoDispose: autoDispose);
  }

  /// Cambia la vista activa actual por su ID o Ruta.
  void switchView(String viewId) {
    _viewManager.switchView(viewId);
  }

  /// Hook opcional para inicialización de la aplicación.
  void onInit() {}

  /// Hook opcional para lógica personalizada por cuadro.
  void onUpdate(double dt) {}

  String? _findAssetPath(String relativeAsset) {
    final candidatePaths = <String>[];
    final currentDir = Directory.current.path;

    // 1. Proyecto local (si el usuario sobrescribe los assets localmente)
    candidatePaths.add(path.join(currentDir, relativeAsset));

    // 2. Variable de entorno CORTEX_HOME
    final envHome = Platform.environment['CORTEX_HOME'];
    if (envHome != null && envHome.trim().isNotEmpty) {
      final envDir = envHome.trim();
      candidatePaths.add(path.join(envDir, relativeAsset));
      candidatePaths.add(path.join(envDir, '..', relativeAsset));
    }

    // 3. Variable de entorno CORTEX_SDK
    final envSdk = Platform.environment['CORTEX_SDK'];
    if (envSdk != null && envSdk.trim().isNotEmpty) {
      final sdkDir = envSdk.trim();
      candidatePaths.add(path.join(sdkDir, relativeAsset));
    }

    // 4. Ubicación por defecto del SDK (~/Desarrollo/cortex/sdk)
    final homeDir =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    if (homeDir.isNotEmpty) {
      final defaultSdk = path.join(homeDir, 'Desarrollo', 'cortex', 'sdk');
      candidatePaths.add(path.join(defaultSdk, relativeAsset));
    }

    // 5. Script / Ejecutable / Desarrollo
    try {
      final scriptDir = path.dirname(Platform.script.toFilePath());
      candidatePaths.addAll([
        path.join(scriptDir, relativeAsset),
        path.join(scriptDir, '..', relativeAsset),
        path.join(currentDir, 'frontend', relativeAsset),
      ]);
    } catch (_) {}

    for (final candidate in candidatePaths) {
      final normalized = path.normalize(candidate);
      if (File(normalized).existsSync()) {
        return normalized;
      }
    }
    return null;
  }

  void _loadDefaultFont() {
    final fontPath = _findAssetPath('assets/fonts/default_font.ttf');
    if (fontPath != null) {
      _ctx2d.loadFont(fontPath, 36);
    }

    final iconFontPath = _findAssetPath('assets/fonts/material_icons.ttf');
    if (iconFontPath != null) {
      _ctx2d.loadIconFont(iconFontPath, 36);
    }
  }

  /// Inicia el ciclo de vida de la aplicación, el bucle principal y maneja el redimensionamiento y la limpieza automáticamente.
  Future<void> run() async {
    _window.init(width, height, title, flags: flags);

    // Inicializar dispositivo de audio
    AudioEngine.init();

    // Cargar automáticamente la fuente tipográfica TTF vectorizada de alta resolución
    _loadDefaultFont();

    // Notificar las dimensiones reales iniciales de ventana a todas las vistas
    _viewManager.handleResize(_window.width, _window.height);

    // Si Navigator especifica una ruta inicial, cargarla
    if (Navigator.initialRoute != null) {
      _viewManager.switchView(Navigator.initialRoute!);
    }

    onInit();

    // --- FPS Adaptativo ---
    // Arranca en modo activo (60 FPS). Tras [idleThreshold] frames consecutivos
    // sin ningún input ni redimensión, baja a 15 FPS para ahorrar CPU/batería.
    // Cualquier actividad lo restaura a 60 FPS de inmediato.
    const int activeFps = 60;
    const int idleFps = 15;
    const int idleThreshold = 120; // ~2 s a 60 FPS
    int idleFrames = 0;
    bool isIdle = false;
    _window.setTargetFps(activeFps);

    while (!_window.shouldClose) {
      final dt = _window.deltaTime;
      final input = _window.input;

      // Actualizar streaming de música del motor de audio
      AudioEngine.updateMusic();

      // Detectar actividad: cualquier movimiento de ratón, tecla, scroll o resize
      final bool resized =
          _window.isResized ||
          _window.width != _viewManager.lastWidth ||
          _window.height != _viewManager.lastHeight;
      final bool hasInput =
          input.isMouseButtonDown(0) ||
          input.isMouseButtonDown(1) ||
          input.isMouseButtonDown(2) ||
          input.mouseWheelMove != 0.0 ||
          input.getCharPressed() != 0 ||
          resized;

      if (hasInput) {
        idleFrames = 0;
        if (isIdle) {
          isIdle = false;
          _window.setTargetFps(activeFps);
        }
      } else {
        idleFrames++;
        if (!isIdle && idleFrames >= idleThreshold) {
          isIdle = true;
          _window.setTargetFps(idleFps);
        }
      }

      // Reacción automática al redimensionamiento/maximizado de ventana
      if (resized) {
        _viewManager.handleResize(_window.width, _window.height);
      }

      // Actualizar lógica del desarrollador y de la vista activa
      onUpdate(dt);
      _viewManager.updateCurrent(dt, input);

      // Renderizar cuadro
      _window.beginFrame(
        clearColor.r,
        clearColor.g,
        clearColor.b,
        clearColor.a,
      );
      _viewManager.renderCurrent(_ctx2d, _ctx3d);
      _window.endFrame();
      // Resetear el arena de texto: offset → 0 tras EndDrawing (Raylib ya copió todos los strings)
      _ctx2d.resetTextArena();

      // Ceder el control al Event Loop de Dart para procesar Futures, Timers y callbacks async
      await Future.delayed(Duration.zero);
    }

    _viewManager.clear();
    _window.close();
    AudioEngine.close();
  }
}
