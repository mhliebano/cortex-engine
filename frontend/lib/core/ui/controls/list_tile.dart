import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Componente de Ítem de Lista (`ListTile`) bajo la arquitectura `ControlNode`.
///
/// Estructura estándar con leading (ícono/nodo), título, subtítulo y trailing (ícono/nodo).
class ListTile extends ControlNode {
  final String title;
  final String? subtitle;
  final dynamic leadingIcon;
  final CortexNode? leading;
  final dynamic trailingIcon;
  final CortexNode? trailing;
  bool selected;
  final void Function()? onTap;

  bool _isHovered = false;
  bool _isPressed = false;

  ListTile({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailingIcon,
    this.trailing,
    this.selected = false,
    this.onTap,
    int? defaultHeight,
  }) {
    _updateDimensions(defaultHeight ?? (subtitle != null ? 54 : 44));
  }

  void _updateDimensions(int defH) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    }
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (height <= 0) {
      height = defH;
    }
  }

  @override
  bool get isFlexWidth => true;

  @override
  List<CortexNode> get childrenElements => [
        if (leading != null) leading!,
        if (trailing != null) trailing!,
      ];

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    final hRule = currentLayout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    }

    if (leading != null) {
      leading!.onResize(leading!.width, height);
    }
    if (trailing != null) {
      trailing!.onResize(trailing!.width, height);
    }
  }

  String? _resolveGlyph(dynamic iconData) {
    if (iconData == null) return null;
    if (iconData is IconData) return iconData.glyph;
    if (iconData is String) return iconData;
    return iconData.toString();
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled) return;

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

    // Actualizar hijos leading y trailing si existen
    if (leading != null && leading!.isVisible) {
      leading!.x = x + 12;
      leading!.y = y + (height - leading!.height) ~/ 2;
      leading!.onUpdate(dt, input);
    }
    if (trailing != null && trailing!.isVisible) {
      trailing!.x = x + width - trailing!.width - 12;
      trailing!.y = y + (height - trailing!.height) ~/ 2;
      trailing!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final ColorRGBA baseBg = style.bgColor ?? const ColorRGBA(28, 34, 44, 255);
    final ColorRGBA hoverBg = style.hoverColor ?? const ColorRGBA(45, 55, 72, 255);
    final ColorRGBA selectedBg = style.accentColor ?? const ColorRGBA(36, 80, 130, 255);
    final ColorRGBA titleColor = style.textColor ?? ColorRGBA.white;
    const ColorRGBA subtitleColor = ColorRGBA(140, 155, 175, 255);
    final ColorRGBA iconColor = style.accentColor ?? ColorRGBA.accentBlue;

    final currentBg = selected ? selectedBg : (_isHovered ? hoverBg : baseBg);

    // 1. Dibujar fondo redondeado del ítem de lista
    if (currentBg.a > 0) {
      ctx2d.drawRoundRect(x, y, width, height, 0.15, color: currentBg);
    }

    int leftX = x + 12;
    final leadGlyph = _resolveGlyph(leadingIcon);

    // 2. Renderizar Leading (Widget o Ícono)
    if (leading != null && leading!.isVisible) {
      leading!.onRender(ctx2d, ctx3d);
      leftX += leading!.width + 12;
    } else if (leadGlyph != null && leadGlyph.isNotEmpty) {
      ctx2d.drawText(
        leadGlyph,
        leftX,
        y + (height ~/ 2) - 9,
        18,
        isEnabled ? iconColor : const ColorRGBA(100, 110, 125, 255),
      );
      leftX += 28;
    }

    // 3. Renderizar Título y Subtítulo
    final currentTitleColor = isEnabled ? titleColor : const ColorRGBA(120, 130, 145, 255);

    if (subtitle != null && subtitle!.isNotEmpty) {
      ctx2d.drawText(title, leftX, y + 8, 14, currentTitleColor);
      ctx2d.drawText(subtitle!, leftX, y + 28, 12, subtitleColor);
    } else {
      ctx2d.drawText(
        title,
        leftX,
        y + (height ~/ 2) - 7,
        14,
        currentTitleColor,
      );
    }

    // 4. Renderizar Trailing (Widget o Ícono)
    final trailGlyph = _resolveGlyph(trailingIcon);
    if (trailing != null && trailing!.isVisible) {
      trailing!.onRender(ctx2d, ctx3d);
    } else if (trailGlyph != null && trailGlyph.isNotEmpty) {
      final rightX = x + width - 24;
      ctx2d.drawText(
        trailGlyph,
        rightX,
        y + (height ~/ 2) - 8,
        16,
        const ColorRGBA(130, 145, 165, 255),
      );
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    leading?.onRenderOverlay(ctx2d, ctx3d);
    trailing?.onRenderOverlay(ctx2d, ctx3d);
  }
}

/// Alias para `ListTile` (compatibilidad y semántica alternativa de listas).
typedef ListItem = ListTile;

