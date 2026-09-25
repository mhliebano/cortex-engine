import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/interaction/button.dart';

/// Componente de Ventana Modal Emergente (`Dialog` / `AlertDialog`).
///
/// Presenta una caja de diálogo centrada con telón de fondo oscurecido (`backdrop`),
/// encabezado estructurado (`icon`, `title`), cuerpo informativo o contenedor personalizado (`child`)
/// y botones de acción principal y secundaria (`onConfirm`, `onCancel`).
class Dialog extends Element {
  static Dialog? _activeDialog;

  final String title;
  final String? message;
  final Element? child;
  final IconData? icon;
  final String confirmLabel;
  final String? cancelLabel;
  final ButtonVariant confirmVariant;
  final void Function()? onConfirm;
  final void Function()? onCancel;
  final bool dismissibleOutsideClick;

  late Button _confirmBtn;
  late Button? _cancelBtn;

  bool _dismissed = false;
  bool _wasJustOpened = true;
  final int _dialogWidth;
  final int _dialogHeight;

  Dialog({
    required this.title,
    this.message,
    this.child,
    this.icon,
    this.confirmLabel = "Aceptar",
    this.cancelLabel = "Cancelar",
    this.confirmVariant = ButtonVariant.filled,
    this.onConfirm,
    this.onCancel,
    this.dismissibleOutsideClick = true,
    int width = 440,
    int height = 0,
  }) : _dialogWidth = width,
       _dialogHeight = height != 0
           ? height
           : (child != null ? 160 + child.height : 210),
       super(
         width: width,
         height: height != 0
             ? height
             : (child != null ? 160 + child.height : 210),
       ) {
    _confirmBtn = Button(
      label: confirmLabel,
      variant: confirmVariant,
      onPressed: () {
        _dismissed = true;
        _activeDialog = null;
        if (onConfirm != null) onConfirm!();
      },
    );

    if (cancelLabel != null) {
      _cancelBtn = Button(
        label: cancelLabel!,
        variant: ButtonVariant.outlined,
        onPressed: () {
          _dismissed = true;
          _activeDialog = null;
          if (onCancel != null) onCancel!();
        },
      );
    } else {
      _cancelBtn = null;
    }
  }

  /// Muestra un Diálogo Modal en pantalla.
  static void show(
    String title, {
    String? message,
    Element? child,
    IconData? icon,
    String confirmLabel = "Aceptar",
    String? cancelLabel = "Cancelar",
    ButtonVariant confirmVariant = ButtonVariant.filled,
    void Function()? onConfirm,
    void Function()? onCancel,
    bool dismissibleOutsideClick = true,
    int width = 440,
  }) {
    _activeDialog = Dialog(
      title: title,
      message: message,
      child: child,
      icon: icon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmVariant: confirmVariant,
      onConfirm: onConfirm,
      onCancel: onCancel,
      dismissibleOutsideClick: dismissibleOutsideClick,
      width: width,
    );
  }

  /// Oculta el Diálogo activo.
  static void dismiss() {
    _activeDialog?._dismissed = true;
    _activeDialog = null;
  }

  /// Devuelve si hay un diálogo modal bloqueando la pantalla.
  static bool get isModalActive =>
      _activeDialog != null && !_activeDialog!._dismissed;

  /// Actualiza la lógica del Diálogo activo.
  static void updateActiveDialog(
    double dt,
    InputEngine input,
    int windowW,
    int windowH,
  ) {
    if (_activeDialog == null || _activeDialog!._dismissed) return;
    final dlg = _activeDialog!;

    dlg.width = dlg._dialogWidth;
    dlg.height = dlg._dialogHeight;
    dlg.x = (windowW ~/ 2) - (dlg.width ~/ 2);
    dlg.y = (windowH ~/ 2) - (dlg.height ~/ 2);

    // Evitar que el clic que abrió el diálogo lo cierre inmediatamente en el mismo fotograma
    if (dlg._wasJustOpened) {
      dlg._wasJustOpened = false;
      dlg.onUpdate(dt, input);
      return;
    }

    // Clic fuera del panel modal para cerrar
    if (dlg.dismissibleOutsideClick &&
        input.isMouseButtonPressed(MouseButtons.left)) {
      final isInside = input.isHovering(dlg.x, dlg.y, dlg.width, dlg.height);
      if (!isInside) {
        dismiss();
        if (dlg.onCancel != null) dlg.onCancel!();
        return;
      }
    }

    dlg.onUpdate(dt, input);
  }

  /// Renderiza el Diálogo activo globalmente en la capa overlay con telón de fondo.
  static void renderActiveDialog(
    Context2D ctx2d,
    Context3D ctx3d,
    int windowW,
    int windowH,
  ) {
    if (_activeDialog == null || _activeDialog!._dismissed) return;
    final dlg = _activeDialog!;

    // 1. Renderizar telón de fondo oscurecido que bloquea la interacción inferior
    ctx2d.drawRect(0, 0, windowW, windowH, const ColorRGBA(0, 0, 0, 165));

    dlg.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (_dismissed) return;

    final btnY = y + height - 52;
    int btnX = x + width - 16;

    _confirmBtn.x = btnX - _confirmBtn.width;
    _confirmBtn.y = btnY;
    _confirmBtn.onUpdate(dt, input);
    btnX -= _confirmBtn.width + 12;

    if (_cancelBtn != null) {
      _cancelBtn!.x = btnX - _cancelBtn!.width;
      _cancelBtn!.y = btnY;
      _cancelBtn!.onUpdate(dt, input);
    }

    if (child != null && child!.isVisible) {
      child!.x = x + 20;
      child!.y = y + 62;
      child!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (_dismissed) return;

    final bgCol = const ColorRGBA(30, 36, 48, 255);
    final borderCol = const ColorRGBA(65, 78, 98);

    // 1. Sombra suave y Panel modal
    ctx2d.drawRoundRect(
      x + 4,
      y + 6,
      width,
      height,
      0.1,
      color: const ColorRGBA(0, 0, 0, 180),
    );
    ctx2d.drawRoundRect(x, y, width, height, 0.1, color: bgCol);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.1, color: borderCol);

    int currentY = y + 20;

    // 2. Encabezado: Ícono y Título
    int titleX = x + 20;
    if (icon != null) {
      ctx2d.drawText(icon!.glyph, titleX, currentY, 20, ColorRGBA.accentBlue);
      titleX += 28;
    }

    ctx2d.drawText(title, titleX, currentY, 16, ColorRGBA.white);
    currentY += 28;

    // Línea divisora de encabezado
    ctx2d.drawRect(
      x + 20,
      currentY,
      width - 40,
      1,
      const ColorRGBA(50, 60, 75),
    );
    currentY += 14;

    // 3. Mensaje descriptivo o Contenido personalizado
    if (message != null) {
      ctx2d.drawText(
        message!,
        x + 20,
        currentY,
        13,
        const ColorRGBA(180, 192, 210),
      );
    }

    if (child != null && child!.isVisible) {
      child!.x = x + 20;
      child!.y = currentY;
      child!.onRender(ctx2d, ctx3d);
    }

    // 4. Botones de acción inferior
    final btnY = y + height - 50;
    int btnX = x + width - 20;

    _confirmBtn.x = btnX - _confirmBtn.width;
    _confirmBtn.y = btnY;
    _confirmBtn.onRender(ctx2d, ctx3d);
    btnX -= _confirmBtn.width + 12;

    if (_cancelBtn != null) {
      _cancelBtn!.x = btnX - _cancelBtn!.width;
      _cancelBtn!.y = btnY;
      _cancelBtn!.onRender(ctx2d, ctx3d);
    }
  }
}
