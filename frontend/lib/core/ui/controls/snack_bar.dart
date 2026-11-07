import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente Banner de Notificación con Acción (`SnackBar`) bajo la arquitectura `ControlNode`.
///
/// Muestra un banner flotante en la parte inferior de la pantalla (`onRenderOverlay`),
/// con soporte para mensaje principal, botón de acción interactivo ("DESHACER", "REINTENTAR") y temporizador.
class SnackBar extends ControlNode {
  static SnackBar? _currentSnackBar;

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double durationSec;

  double _timer = 0.0;
  bool _dismissed = false;
  bool _isActionHovered = false;
  bool _isCloseHovered = false;

  SnackBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.durationSec = 4.0,
  }) {
    width = 480;
    height = 46;
  }

  /// Muestra un SnackBar globalmente en pantalla.
  static void show(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    double durationSec = 4.0,
    String? styleClass,
    String? layoutClass,
  }) {
    _currentSnackBar = SnackBar(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      durationSec: durationSec,
      styleClass: styleClass,
      layoutClass: layoutClass,
    );
  }

  /// Oculta el SnackBar activo.
  static void dismiss() {
    _currentSnackBar?._dismissed = true;
    _currentSnackBar = null;
  }

  /// Actualiza la lógica del SnackBar activo.
  static void updateActiveSnackBar(double dt, InputEngine input) {
    if (_currentSnackBar == null) return;
    final sb = _currentSnackBar!;
    sb.onUpdate(dt, input);
    if (sb._dismissed) {
      _currentSnackBar = null;
    }
  }

  /// Renderiza el SnackBar activo globalmente en la capa overlay.
  static void renderActiveSnackBar(
    Context2D ctx2d,
    Context3D ctx3d,
    int windowW,
    int windowH,
  ) {
    if (_currentSnackBar == null) return;
    final sb = _currentSnackBar!;

    sb.x = (windowW ~/ 2) - (sb.width ~/ 2);
    sb.y = windowH - sb.height - 20;

    sb.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (_dismissed) return;

    _timer += dt;
    if (_timer >= durationSec) {
      _dismissed = true;
      return;
    }

    // Interacción con botón de acción
    if (actionLabel != null) {
      final actW = actionLabel!.length * 8 + 16;
      final actX = x + width - actW - 36;
      _isActionHovered = input.isHovering(actX, y + 8, actW, height - 16);

      if (_isActionHovered && input.isMouseButtonPressed(MouseButtons.left)) {
        _dismissed = true;
        onAction?.call();
        return;
      }
    }

    // Interacción con botón de cierre X
    final closeX = x + width - 28;
    _isCloseHovered = input.isHovering(closeX, y + 10, 20, 20);

    if (_isCloseHovered && input.isMouseButtonPressed(MouseButtons.left)) {
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

    final style = currentStyle;
    final bgCol = style.bgColor ?? const ColorRGBA(24, 28, 38, 250);
    final borderCol = style.borderColor ?? const ColorRGBA(60, 72, 92);
    final roundness = style.borderRadius != null && style.borderRadius! > 0
        ? (style.borderRadius! > 1.0 ? 0.15 : style.borderRadius!)
        : 0.15;
    final textCol = style.textColor ?? ColorRGBA.white;
    final fontSize = style.fontSize ?? 13;

    // 1. Fondo de la barra de mensajes con sombra
    ctx2d.drawRoundRect(
      x + 2,
      y + 3,
      width,
      height,
      roundness,
      color: const ColorRGBA(0, 0, 0, 140),
    );
    ctx2d.drawRoundRect(x, y, width, height, roundness, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, roundness, color: borderCol);

    // 2. Texto del mensaje
    final textY = y + (height ~/ 2) - (fontSize ~/ 2);
    ctx2d.drawText(message, x + 16, textY, fontSize, textCol);

    // 3. Botón de Acción ("DESHACER", "REINTENTAR")
    if (actionLabel != null) {
      final actW = actionLabel!.length * 8 + 16;
      final actX = x + width - actW - 36;
      final actY = y + 8;
      final actH = height - 16;

      final btnBg = _isActionHovered
          ? const ColorRGBA(52, 152, 219, 60)
          : ColorRGBA.transparent;
      ctx2d.drawRoundRect(actX, actY, actW, actH, 0.2, color: btnBg);
      ctx2d.drawText(actionLabel!, actX + 8, textY, fontSize, ColorRGBA.hoverBlue);
    }

    // 4. Ícono de cierre (X)
    final closeX = x + width - 26;
    final closeCol = _isCloseHovered
        ? ColorRGBA.white
        : const ColorRGBA(160, 172, 192);
    ctx2d.drawText(Icons.close.glyph, closeX, y + 14, 16, closeCol);
  }
}

