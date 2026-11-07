import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Elemento de menú individual para `MenuBar` y sus submenús desplegables.
class MenuItem {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final void Function()? onTap;
  final List<MenuItem>? subItems;
  final bool isDivider;

  MenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.subItems,
    this.isDivider = false,
  });

  /// Crea un elemento separador/divisor horizontal o vertical.
  factory MenuItem.divider() => MenuItem(label: '', isDivider: true);

  /// Indica si el elemento tiene un submenú desplegable configurado.
  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;
}

/// Barra de Menú Horizontal Superior (`MenuBar`) bajo la arquitectura `ControlNode`.
/// Soporta íconos tipados (`IconData`), atajos de teclado, divisores y menús desplegables (`subItems`).
class MenuBar extends ControlNode {
  final List<MenuItem> items;

  int? _hoveredIndex;
  int? _openMenuIndex;
  int? _hoveredSubIndex;

  MenuBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.items,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight && height <= 0) {
      height = 28;
    }
  }

  int _getItemWidth(MenuItem item, int fontSize) {
    if (item.isDivider) return 10;
    final iconWidth = item.icon != null ? (fontSize + 6) : 0;
    final textWidth = item.label.length * (fontSize ~/ 2);
    return iconWidth + textWidth + 20;
  }

  @override
  bool get isFlexWidth => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    final hRule = currentLayout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else {
      height = 28;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible) return;

    final fontSize = currentStyle.fontSize ?? 13;
    _hoveredIndex = null;
    _hoveredSubIndex = null;
    int currentX = x + 10;

    // 1. Detección de cernido y clic en menú principal superior
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final itemWidth = _getItemWidth(item, fontSize);

      if (item.isDivider) {
        currentX += itemWidth + 4;
        continue;
      }

      if (input.isHovering(currentX, y, itemWidth, height)) {
        _hoveredIndex = i;
        if (_openMenuIndex != null && item.hasSubItems) {
          _openMenuIndex = i;
        }

        if (input.isMouseButtonPressed(MouseButtons.left)) {
          if (item.hasSubItems) {
            _openMenuIndex = (_openMenuIndex == i) ? null : i;
          } else {
            _openMenuIndex = null;
            item.onTap?.call();
          }
        }
        break;
      }

      currentX += itemWidth + 4;
    }

    // 2. Manejo de interacción dentro del submenú desplegable abierto
    if (_openMenuIndex != null && _openMenuIndex! < items.length) {
      final openItem = items[_openMenuIndex!];

      if (openItem.hasSubItems) {
        int openX = x + 10;
        for (int i = 0; i < _openMenuIndex!; i++) {
          openX += _getItemWidth(items[i], fontSize) + 4;
        }

        final subItems = openItem.subItems!;
        final dropdownY = y + height;
        const dropdownWidth = 220;
        const itemHeight = 30;

        int dropdownHeight = 8;
        for (final sub in subItems) {
          dropdownHeight += sub.isDivider ? 8 : itemHeight;
        }

        final isHoveringDropdown = input.isHovering(
          openX,
          dropdownY,
          dropdownWidth,
          dropdownHeight,
        );

        if (isHoveringDropdown) {
          int accumY = dropdownY + 4;
          for (int j = 0; j < subItems.length; j++) {
            final sub = subItems[j];
            final h = sub.isDivider ? 8 : itemHeight;

            if (input.mouseY >= accumY && input.mouseY < accumY + h) {
              if (!sub.isDivider) {
                _hoveredSubIndex = j;
                if (input.isMouseButtonPressed(MouseButtons.left)) {
                  _openMenuIndex = null;
                  sub.onTap?.call();
                }
              }
              break;
            }
            accumY += h;
          }
        } else if (input.isMouseButtonPressed(MouseButtons.left) &&
            _hoveredIndex == null) {
          _openMenuIndex = null;
        }
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(18, 20, 26);
    final hoverColor = style.hoverColor ?? const ColorRGBA(45, 50, 65);
    final textColor = style.textColor ?? ColorRGBA.white;
    final fontSize = style.fontSize ?? 13;
    final borderColor = style.borderColor ?? const ColorRGBA(40, 44, 56);

    // 1. Dibujar barra de fondo principal
    ctx2d.drawRect(x, y, width, height, bgColor);

    int currentX = x + 10;

    // 2. Dibujar ítems de menú principal
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final itemWidth = _getItemWidth(item, fontSize);

      if (item.isDivider) {
        ctx2d.drawRect(
          currentX + (itemWidth ~/ 2),
          y + 4,
          1,
          height - 8,
          const ColorRGBA(50, 56, 70),
        );
        currentX += itemWidth + 4;
        continue;
      }

      final isHovered = _hoveredIndex == i;
      final isOpen = _openMenuIndex == i;

      if (isOpen || isHovered) {
        ctx2d.drawRect(currentX, y + 2, itemWidth, height - 4, hoverColor);
      }

      final textY = y + ((height - fontSize) ~/ 2);
      int drawX = currentX + 10;

      if (item.icon != null) {
        ctx2d.drawText(item.icon!.glyph, drawX, textY, fontSize, textColor);
        drawX += fontSize + 6;
      }

      ctx2d.drawText(item.label, drawX, textY, fontSize, textColor);

      currentX += itemWidth + 4;
    }

    // 3. Línea delgada separadora inferior
    ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final hoverColor = style.hoverColor ?? const ColorRGBA(45, 50, 65);
    final textColor = style.textColor ?? ColorRGBA.white;
    final fontSize = style.fontSize ?? 13;

    // Renderizar submenú desplegable flotante por encima de toda la interfaz
    if (_openMenuIndex != null && _openMenuIndex! < items.length) {
      final openItem = items[_openMenuIndex!];
      if (openItem.hasSubItems) {
        int openX = x + 10;
        for (int i = 0; i < _openMenuIndex!; i++) {
          openX += _getItemWidth(items[i], fontSize) + 4;
        }

        final subItems = openItem.subItems!;
        final dropdownY = y + height;
        const dropdownWidth = 220;
        const itemHeight = 30;

        int dropdownHeight = 8;
        for (final sub in subItems) {
          dropdownHeight += sub.isDivider ? 8 : itemHeight;
        }

        // Fondo y borde del menú desplegable
        ctx2d.drawPanel(
          openX,
          dropdownY,
          dropdownWidth,
          dropdownHeight,
          bgColor: const ColorRGBA(24, 28, 36),
          borderColor: const ColorRGBA(55, 62, 80),
        );

        // Renderizar sub-ítems
        int subY = dropdownY + 4;
        for (int j = 0; j < subItems.length; j++) {
          final subItem = subItems[j];

          if (subItem.isDivider) {
            ctx2d.drawRect(
              openX + 8,
              subY + 3,
              dropdownWidth - 16,
              1,
              const ColorRGBA(50, 58, 75),
            );
            subY += 8;
            continue;
          }

          final isSubHovered = _hoveredSubIndex == j;

          if (isSubHovered) {
            ctx2d.drawRect(
              openX + 4,
              subY,
              dropdownWidth - 8,
              itemHeight,
              hoverColor,
            );
          }

          final textY = subY + ((itemHeight - fontSize) ~/ 2);
          int drawX = openX + 12;

          if (subItem.icon != null) {
            ctx2d.drawText(
              subItem.icon!.glyph,
              drawX,
              textY,
              fontSize,
              textColor,
            );
            drawX += fontSize + 6;
          }

          ctx2d.drawText(subItem.label, drawX, textY, fontSize, textColor);

          if (subItem.shortcut != null) {
            final shortcutWidth = subItem.shortcut!.length * (fontSize ~/ 2);
            ctx2d.drawText(
              subItem.shortcut!,
              openX + dropdownWidth - shortcutWidth - 14,
              textY,
              fontSize - 1,
              ColorRGBA.lightGray,
            );
          }

          subY += itemHeight;
        }
      }
    }
  }
}
