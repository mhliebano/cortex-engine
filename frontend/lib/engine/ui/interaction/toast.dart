import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';

/// Tipo / Estado del mensaje Toast (`ToastType`).
enum ToastType {
  info,
  success,
  warning,
  error,
}

/// Componente de Notificación Flotante Tipo Toast (`Toast`).
///
/// Muestra un mensaje emergente temporal en la capa superior (`onRenderOverlay`)
/// con un temporizador de autodestrucción y estética visual distintiva por tipo.
class Toast extends Element {
  static final List<Toast> _activeToasts = [];

  final String message;
  final ToastType type;
  final double durationSec;
  final IconData? icon;

  double _timer = 0.0;
  bool _dismissed = false;

  Toast({
    required this.message,
    this.type = ToastType.info,
    this.durationSec = 3.5,
    this.icon,
  }) : super(width: 320, height: 42);

  /// Método estático conveniente para mostrar un Toast en pantalla desde cualquier handler.
  static void show(
    String message, {
    ToastType type = ToastType.info,
    double durationSec = 3.5,
    IconData? icon,
  }) {
    final toast = Toast(
      message: message,
      type: type,
      durationSec: durationSec,
      icon: icon,
    );
    _activeToasts.add(toast);
  }

  /// Actualiza la lógica de los Toast activos.
  static void updateActiveToasts(double dt, InputEngine input) {
    for (int i = _activeToasts.length - 1; i >= 0; i--) {
      final toast = _activeToasts[i];
      toast.onUpdate(dt, input);
      if (toast._dismissed) {
        _activeToasts.removeAt(i);
      }
    }
  }

  /// Renderiza todos los Toast activos registrados globalmente en la capa overlay.
  static void renderActiveToasts(Context2D ctx2d, Context3D ctx3d, int windowW, int windowH) {
    if (_activeToasts.isEmpty) return;

    int currentY = 25;

    for (int i = _activeToasts.length - 1; i >= 0; i--) {
      final toast = _activeToasts[i];
      toast.x = (windowW ~/ 2) - (toast.width ~/ 2);
      toast.y = currentY;

      toast.onRenderOverlay(ctx2d, ctx3d);

      currentY += toast.height + 10;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (_dismissed) return;
    _timer += dt;
    if (_timer >= durationSec) {
      _dismissed = true;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (_dismissed) return;

    ColorRGBA accentColor;
    IconData defaultIcon;

    switch (type) {
      case ToastType.success:
        accentColor = const ColorRGBA(46, 204, 113);
        defaultIcon = Icons.check_circle;
        break;
      case ToastType.error:
        accentColor = const ColorRGBA(231, 76, 60);
        defaultIcon = Icons.error;
        break;
      case ToastType.warning:
        accentColor = const ColorRGBA(241, 196, 15);
        defaultIcon = Icons.warning;
        break;
      case ToastType.info:
        accentColor = const ColorRGBA(41, 128, 185);
        defaultIcon = Icons.info;
        break;
    }

    final activeIcon = icon ?? defaultIcon;
    final bgCol = const ColorRGBA(24, 30, 42, 245);

    // 1. Contenedor de cápsula flotante con sombra
    ctx2d.drawRoundRect(x + 2, y + 2, width, height, 0.5, color: const ColorRGBA(0, 0, 0, 120));
    ctx2d.drawRoundRect(x, y, width, height, 0.5, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.5, color: accentColor);

    // 2. Ícono de estado
    final iconY = y + (height ~/ 2) - 9;
    ctx2d.drawText(activeIcon.glyph, x + 14, iconY, 18, accentColor);

    // 3. Texto del mensaje
    final textY = y + (height ~/ 2) - 7;
    ctx2d.drawText(message, x + 40, textY, 13, ColorRGBA.white);
  }
}
