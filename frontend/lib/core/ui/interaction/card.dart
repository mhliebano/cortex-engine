import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/icons.dart';
import 'package:cortex/core/ui/style.dart';

enum CardVariant { filled, outlined, elevated }

/// Componente de Tarjeta Premium e Interactiva (`Card`).
///
/// Ofrece una identidad visual distintiva frente al `Panel` básico:
/// - Bordes redondeados elegantes (Radius 12px).
/// - Franja o línea de acento superior.
/// - Elevación con sombra suave en estado `elevated`.
/// - Animación de brillo y borde reactivo en estado Hover/Press.
/// - Encabezado estructurado (`title`, `subtitle`, `icon`), insignia integrada (`badgeText`) y acciones (`actions`).
class Card extends Element {
  final Element? child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String? badgeText;
  final List<Element>? actions;
  final CardVariant variant;
  final int padding;
  final void Function()? onTap;

  late ColorRGBA bgColor;
  late ColorRGBA borderColor;
  late ColorRGBA hoverBorderColor;

  bool _isHovered = false;
  bool _isPressed = false;
  final bool _isHeightFixed;

  ColorRGBA? accentColor;

  Card({
    String? className,
    int width = 0,
    int height = 0,
    int? padding,
    this.variant = CardVariant.filled,
    this.title,
    this.subtitle,
    this.icon,
    this.badgeText,
    this.actions,
    this.child,
    this.onTap,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) : padding =
           padding ??
           (className != null ? Style.merge(className).padding ?? 16 : 16),
       _isHeightFixed =
           height != 0 ||
           (className != null && Style.merge(className).height != null) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 280);
    this.height = height != 0 ? height : (style?.height ?? 0);
    accentColor = style?.accentColor;

    _setupColors(style);
    _updateLayout();
  }

  void _setupColors(Style? style) {
    switch (variant) {
      case CardVariant.filled:
        bgColor = style?.bgColor ?? const ColorRGBA(30, 36, 48);
        borderColor = style?.borderColor ?? const ColorRGBA(55, 65, 82);
        hoverBorderColor = style?.hoverColor ?? const ColorRGBA(41, 128, 185);
        break;
      case CardVariant.outlined:
        bgColor = style?.bgColor ?? const ColorRGBA(22, 26, 36);
        borderColor = style?.borderColor ?? const ColorRGBA(75, 88, 110);
        hoverBorderColor = style?.hoverColor ?? const ColorRGBA(52, 152, 219);
        break;
      case CardVariant.elevated:
        bgColor = style?.bgColor ?? const ColorRGBA(38, 45, 58);
        borderColor = style?.borderColor ?? const ColorRGBA(62, 72, 92);
        hoverBorderColor = style?.hoverColor ?? const ColorRGBA(41, 128, 185);
        break;
    }
  }

  void _updateLayout() {
    int contentH = padding * 2;

    // Espacio para la franja de acento superior
    if (accentColor != null) {
      contentH += 4;
    }

    // Espacio para título e ícono
    if (title != null || icon != null) {
      contentH += 24;
    }
    if (subtitle != null) {
      contentH += 18;
    }

    if (child != null) {
      child!.x = x + padding;
      child!.y = y + contentH;
      if (child!.width == 0 || child!.fillWidth) {
        child!.width = width > (padding * 2) ? width - (padding * 2) : 0;
      }
      child!.onResize(child!.width, child!.height);
      contentH += child!.height + 10;
    }

    if (actions != null && actions!.isNotEmpty) {
      contentH += 42;
    }

    if (!_isHeightFixed && !fillHeight && contentH > 0) {
      height = contentH;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _updateLayout();

    _isHovered = input.isHovering(x, y, width, height);

    if (_isHovered) {
      if (input.isMouseButtonPressed(MouseButtons.left)) {
        _isPressed = true;
      }
      if (_isPressed && !input.isMouseButtonDown(MouseButtons.left)) {
        _isPressed = false;
        if (onTap != null) {
          onTap!();
        }
      }
    } else {
      _isPressed = false;
    }

    if (child != null && child!.isVisible) {
      child!.onUpdate(dt, input);
    }

    if (actions != null) {
      for (final act in actions!) {
        if (act.isVisible) act.onUpdate(dt, input);
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    _updateLayout();

    // 1. Sombra de elevación para variante elevated
    if (variant == CardVariant.elevated) {
      final shadowColor = _isHovered
          ? const ColorRGBA(0, 0, 0, 140)
          : const ColorRGBA(0, 0, 0, 90);
      final shadowOffsetY = _isHovered ? 6 : 3;
      ctx2d.drawRoundRect(
        x + 2,
        y + shadowOffsetY,
        width,
        height,
        0.12,
        color: shadowColor,
      );
    }

    // 2. Fondo de la tarjeta con esquinas redondeadas
    final activeBg = _isPressed
        ? const ColorRGBA(24, 28, 38)
        : (_isHovered
              ? ColorRGBA(
                  bgColor.r + 8,
                  bgColor.g + 10,
                  bgColor.b + 12,
                  bgColor.a,
                )
              : bgColor);

    ctx2d.drawRoundRect(x, y, width, height, 0.12, color: activeBg);

    // 3. Franja o línea de acento superior si se especifica
    if (accentColor != null) {
      ctx2d.drawRoundRect(x, y, width, 5, 0.12, color: accentColor!);
    }

    // 4. Borde sutil o brillo de selección en hover
    final currentBorder = _isHovered ? hoverBorderColor : borderColor;
    ctx2d.drawRoundRectLines(x, y, width, height, 0.12, color: currentBorder);

    int currentY = y + padding + (accentColor != null ? 4 : 0);

    // 5. Encabezado: Ícono, Título e Insignia
    if (title != null || icon != null) {
      int textX = x + padding;
      if (icon != null) {
        ctx2d.drawText(
          icon!.glyph,
          textX,
          currentY,
          18,
          accentColor ?? const ColorRGBA(41, 128, 185),
        );
        textX += 26;
      }
      if (title != null) {
        ctx2d.drawText(title!, textX, currentY, 15, ColorRGBA.white);
      }

      // Insignia integrada (badgeText) en la esquina superior derecha
      if (badgeText != null) {
        final badgeW = (badgeText!.length * 8) + 12;
        final badgeX = x + width - padding - badgeW;
        ctx2d.drawRoundRect(
          badgeX,
          currentY - 2,
          badgeW,
          18,
          0.5,
          color: const ColorRGBA(228, 77, 61),
        );
        ctx2d.drawText(
          badgeText!,
          badgeX + 6,
          currentY + 1,
          11,
          ColorRGBA.white,
        );
      }

      currentY += 22;
    }

    if (subtitle != null) {
      ctx2d.drawText(
        subtitle!,
        x + padding,
        currentY,
        12,
        const ColorRGBA(160, 172, 192),
      );
      currentY += 18;
    }

    // 6. Elemento Hijo Contenido
    if (child != null && child!.isVisible) {
      child!.x = x + padding;
      child!.y = currentY;
      child!.onRender(ctx2d, ctx3d);
      currentY += child!.height + 10;
    }

    // 7. Fila de Acciones / Botones en el pie de la tarjeta
    if (actions != null && actions!.isNotEmpty) {
      int actX = x + padding;
      final actY = y + height - padding - 32;
      for (final act in actions!) {
        if (act.isVisible) {
          act.x = actX;
          act.y = actY;
          act.onRender(ctx2d, ctx3d);
          actX += act.width + 10;
        }
      }
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    if (child != null && child!.isVisible) {
      child!.onRenderOverlay(ctx2d, ctx3d);
    }
    if (actions != null) {
      for (final act in actions!) {
        if (act.isVisible) act.onRenderOverlay(ctx2d, ctx3d);
      }
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _updateLayout();
  }
}
