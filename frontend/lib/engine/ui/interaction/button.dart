import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';
import 'package:cortex/engine/ui/style.dart';

/// Estilos y variantes visuales del Botón (`Button`).
enum ButtonVariant {
  /// Alto contraste. Fondo sólido redondeado.
  filled,

  /// Fondo elevado con relieve/borde sutil.
  elevated,

  /// Fondo tonal suave secundario.
  tonal,

  /// Sin fondo relleno; borde vectorial contorneado.
  outlined,

  /// Sin borde ni fondo relleno; resalta al pasar el cursor.
  text,
}

/// Componente interactivo de Botón (`Button`).
///
/// Soporta 5 variantes visuales, íconos de acompañamiento, estado deshabilitado 
/// y cálculo automático o explícito de dimensiones.
class Button extends Element {
  String label;
  IconData? icon;
  ButtonVariant variant;
  bool enabled;
  void Function()? onPressed;

  ColorRGBA? customBgColor;
  ColorRGBA? customHoverColor;
  ColorRGBA? customTextColor;
  late int fontSize;

  bool _isHovered = false;
  bool _isPressed = false;

  Button({
    super.key,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.enabled = true,
    this.onPressed,
    String? className,
    int width = 0,
    int height = 0,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : super() {
    final style = className != null ? Style.merge(className) : null;
    customBgColor = style?.bgColor;
    customHoverColor = style?.accentColor;
    customTextColor = style?.textColor;
    fontSize = style?.fontSize ?? 14;

    final int textLen = label.length;
    final int iconPad = icon != null ? 24 : 0;
    final int autoWidth = (textLen * (fontSize * 0.55) + 32 + iconPad).toInt().clamp(80, 500);

    this.width = width != 0 ? width : (style?.width ?? autoWidth);
    this.height = height != 0 ? height : (style?.height ?? 40);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) {
      _isHovered = false;
      _isPressed = false;
      return;
    }

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
        onPressed?.call();
      } else if (input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = true;
      } else {
        _isPressed = false;
      }
    } else {
      _isPressed = false;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    ColorRGBA bg;
    ColorRGBA fg;
    ColorRGBA border = ColorRGBA.transparent;
    const double roundness = 0.5;

    if (!enabled) {
      bg = const ColorRGBA(60, 64, 72, 100);
      fg = const ColorRGBA(140, 145, 155, 180);
    } else {
      switch (variant) {
        case ButtonVariant.filled:
          bg = _isPressed
              ? const ColorRGBA(31, 105, 155)
              : _isHovered
                  ? (customHoverColor ?? const ColorRGBA(52, 152, 219))
                  : (customBgColor ?? const ColorRGBA(41, 128, 185));
          fg = customTextColor ?? ColorRGBA.white;
          break;

        case ButtonVariant.elevated:
          bg = _isPressed
              ? const ColorRGBA(45, 50, 60)
              : _isHovered
                  ? const ColorRGBA(55, 60, 72)
                  : (customBgColor ?? const ColorRGBA(40, 44, 54));
          fg = customTextColor ?? const ColorRGBA(100, 180, 240);
          border = const ColorRGBA(70, 75, 90);
          break;

        case ButtonVariant.tonal:
          bg = _isPressed
              ? const ColorRGBA(40, 70, 95)
              : _isHovered
                  ? const ColorRGBA(50, 90, 120)
                  : (customBgColor ?? const ColorRGBA(35, 60, 85));
          fg = customTextColor ?? const ColorRGBA(130, 200, 255);
          break;

        case ButtonVariant.outlined:
          bg = _isPressed
              ? const ColorRGBA(41, 128, 185, 40)
              : _isHovered
                  ? const ColorRGBA(52, 152, 219, 25)
                  : ColorRGBA.transparent;
          fg = customTextColor ?? const ColorRGBA(100, 180, 240);
          border = _isHovered ? const ColorRGBA(52, 152, 219) : const ColorRGBA(70, 80, 100);
          break;

        case ButtonVariant.text:
          bg = _isPressed
              ? const ColorRGBA(255, 255, 255, 30)
              : _isHovered
                  ? const ColorRGBA(255, 255, 255, 15)
                  : ColorRGBA.transparent;
          fg = customTextColor ?? const ColorRGBA(100, 180, 240);
          break;
      }
    }

    // 1. Fondo relleno
    if (bg.a > 0) {
      ctx2d.drawRoundRect(x, y, width, height, roundness, color: bg);
    }

    // 2. Borde contorno (si está definido)
    if (border.a > 0) {
      ctx2d.drawRoundRectLines(x, y, width, height, roundness, lineThick: 1.2, color: border);
    }

    // 3. Contenido (Icono + Texto centrado)
    final int iconWidth = icon != null ? (fontSize + 2) : 0;
    final int textWidth = label.isNotEmpty ? (label.length * (fontSize * 0.55)).toInt() : 0;
    final int totalContentWidth = iconWidth + (icon != null && label.isNotEmpty ? 8 : 0) + textWidth;

    int contentX = x + (width - totalContentWidth) ~/ 2;
    final int contentY = y + (height - fontSize) ~/ 2;

    if (icon != null) {
      ctx2d.drawText(icon!.glyph, contentX, contentY, fontSize + 2, fg);
      contentX += iconWidth + 8;
    }

    if (label.isNotEmpty) {
      ctx2d.drawText(label, contentX, contentY, fontSize, fg);
    }
  }
}
