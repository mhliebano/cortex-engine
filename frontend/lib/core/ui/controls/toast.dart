import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Tipo / Estado del mensaje Toast (`ToastType`).
enum ToastType { info, success, warning, error }

/// Componente de Notificación Flotante Tipo Toast (`Toast`) bajo la arquitectura `ControlNode`.
///
/// Muestra un mensaje emergente temporal en la capa superior (`onRenderOverlay`)
/// con un temporizador de autodestrucción y estética visual distintiva por tipo.
class Toast extends ControlNode {
  static final List<Toast> _activeToasts = [];

  final String message;
  final ToastType type;
  final double durationSec;
  final IconData? icon;

  double _timer = 0.0;
  bool _dismissed = false;

  Toast({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.message,
    this.type = ToastType.info,
    this.durationSec = 3.5,
    this.icon,
  }) {
    width = 40 + (message.length * 8) + 24;
    if (width < 260) width = 260;
    if (width > 500) width = 500;
    height = 42;
  }

  /// Método estático conveniente para mostrar un Toast en pantalla desde cualquier handler.
  static void show(
    String message, {
    ToastType type = ToastType.info,
    double durationSec = 3.5,
    IconData? icon,
    String? styleClass,
    String? layoutClass,
  }) {
    final toast = Toast(
      message: message,
      type: type,
      durationSec: durationSec,
      icon: icon,
      styleClass: styleClass,
      layoutClass: layoutClass,
    );
    _activeToasts.add(toast);
  }

  /// Limpia todos los Toasts activos.
  static void clearAll() {
    _activeToasts.clear();
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
  static void renderActiveToasts(
    Context2D ctx2d,
    Context3D ctx3d,
    int windowW,
    int windowH,
  ) {
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
    final style = currentStyle;
    final bgCol = style.bgColor ?? const ColorRGBA(24, 30, 42, 245);
    final borderCol = style.borderColor ?? accentColor;
    final textCol = style.textColor ?? ColorRGBA.white;
    final fontSize = style.fontSize ?? 13;
    final roundness = style.borderRadius != null && style.borderRadius! > 0
        ? (style.borderRadius! > 1.0 ? 0.5 : style.borderRadius!)
        : 0.5;

    // 1. Contenedor de cápsula flotante con sombra
    ctx2d.drawRoundRect(
      x + 2,
      y + 2,
      width,
      height,
      roundness,
      color: const ColorRGBA(0, 0, 0, 120),
    );
    ctx2d.drawRoundRect(x, y, width, height, roundness, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, roundness, color: borderCol);

    // 2. Ícono de estado
    final iconY = y + (height ~/ 2) - 9;
    ctx2d.drawText(activeIcon.glyph, x + 14, iconY, 18, accentColor);

    // 3. Texto del mensaje
    final textY = y + (height ~/ 2) - (fontSize ~/ 2);
    ctx2d.drawText(message, x + 40, textY, fontSize, textCol);
  }
}

