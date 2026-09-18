import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
import 'package:cortex/engine/ui/element.dart';
import 'package:cortex/engine/ui/icons.dart';
import 'package:cortex/engine/ui/style.dart';

/// Componente de ítem de lista (`ListTile`).
/// Estructura estándar con leading (ícono/widget), título, subtítulo y trailing (ícono/widget).
class ListTile extends Element {
  final String title;
  final String? subtitle;
  final dynamic leadingIcon;
  final Element? leading;
  final dynamic trailingIcon;
  final Element? trailing;
  bool selected;
  bool enabled;
  void Function()? onTap;

  late ColorRGBA bgColor;
  late ColorRGBA hoverBgColor;
  late ColorRGBA selectedBgColor;
  late ColorRGBA titleColor;
  late ColorRGBA subtitleColor;
  late ColorRGBA iconColor;

  bool _isHovered = false;
  bool _isPressed = false;

  ListTile({
    String? className,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailingIcon,
    this.trailing,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    int width = 0,
    int height = 0,
    bool fillWidth = true,
    super.expand,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : super(fillWidth: fillWidth) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 0);
    this.height = height != 0 ? height : (style?.height ?? (subtitle != null ? 52 : 42));

    bgColor = style?.bgColor ?? const ColorRGBA(28, 34, 44);
    hoverBgColor = const ColorRGBA(45, 55, 72);
    selectedBgColor = style?.accentColor ?? const ColorRGBA(36, 80, 130);
    titleColor = style?.textColor ?? ColorRGBA.white;
    subtitleColor = const ColorRGBA(140, 155, 175);
    iconColor = ColorRGBA.accentBlue;
  }

  String? _resolveGlyph(dynamic iconData) {
    if (iconData == null) return null;
    if (iconData is IconData) return iconData.glyph;
    if (iconData is String) return iconData;
    return iconData.toString();
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) return;

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
      }
      if (_isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = false;
        onTap?.call();
      }
    } else {
      _isPressed = false;
    }

    // Actualizar hijos leading y trailing si son Elements
    if (leading != null) {
      leading!.x = x + 12;
      leading!.y = y + (height - leading!.height) ~/ 2;
      leading!.onUpdate(dt, input);
    }
    if (trailing != null) {
      trailing!.x = x + width - trailing!.width - 12;
      trailing!.y = y + (height - trailing!.height) ~/ 2;
      trailing!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final currentBg = selected
        ? selectedBgColor
        : (_isHovered ? hoverBgColor : bgColor);

    // 1. Dibujar fondo redondeado del ítem de lista
    if (currentBg.a > 0) {
      ctx2d.drawRoundRect(x, y, width, height, 0.15, color: currentBg);
    }

    int leftX = x + 12;
    final leadGlyph = _resolveGlyph(leadingIcon);

    // 2. Renderizar Leading (Widget o Ícono)
    if (leading != null) {
      leading!.onRender(ctx2d, ctx3d);
      leftX += leading!.width + 12;
    } else if (leadGlyph != null && leadGlyph.isNotEmpty) {
      ctx2d.drawText(leadGlyph, leftX, y + (height ~/ 2) - 9, 18, enabled ? iconColor : const ColorRGBA(100, 110, 125));
      leftX += 28;
    }

    // 3. Renderizar Título y Subtítulo
    final currentTitleColor = enabled ? titleColor : const ColorRGBA(120, 130, 145);

    if (subtitle != null && subtitle!.isNotEmpty) {
      ctx2d.drawText(title, leftX, y + 8, 14, currentTitleColor);
      ctx2d.drawText(subtitle!, leftX, y + 28, 12, subtitleColor);
    } else {
      ctx2d.drawText(title, leftX, y + (height ~/ 2) - 7, 14, currentTitleColor);
    }

    // 4. Renderizar Trailing (Widget o Ícono)
    final trailGlyph = _resolveGlyph(trailingIcon);
    if (trailing != null) {
      trailing!.onRender(ctx2d, ctx3d);
    } else if (trailGlyph != null && trailGlyph.isNotEmpty) {
      final rightX = x + width - 24;
      ctx2d.drawText(trailGlyph, rightX, y + (height ~/ 2) - 8, 16, const ColorRGBA(130, 145, 165));
    }
  }
}

/// Alias para `ListTile` (compatibilidad y semántica alternativa de listas)
typedef ListItem = ListTile;
