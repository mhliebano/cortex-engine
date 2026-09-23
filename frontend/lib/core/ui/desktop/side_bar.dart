import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/icons.dart';
import 'package:cortex/core/ui/style.dart';

import 'package:cortex/core/navigator.dart';

/// Ítem de navegación para `SideBar`.
class SideBarItem {
  final String id;
  final String label;
  final IconData? icon;
  final String? route;
  final void Function()? onTap;

  SideBarItem({
    required this.id,
    required this.label,
    this.icon,
    this.route,
    this.onTap,
  });
}

/// Barra Lateral Vertical de Navegación (`SideBar`) para cambiar entre vistas/secciones.
class SideBar extends Element {
  final List<SideBarItem> items;
  String? activeItemId;
  final void Function(String itemId)? onItemTap;

  late ColorRGBA bgColor;
  late ColorRGBA activeColor;
  late ColorRGBA hoverColor;
  late ColorRGBA textColor;
  late int fontSize;

  int? _hoveredIndex;

  SideBar({
    String? className,
    int width = 0,
    required this.items,
    this.activeItemId,
    this.onItemTap,
    super.expand = Expand.height,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 160);

    bgColor = style?.bgColor ?? const ColorRGBA(20, 23, 30);
    activeColor = style?.accentColor ?? ColorRGBA.accentBlue;
    hoverColor = const ColorRGBA(35, 40, 52);
    textColor = style?.textColor ?? ColorRGBA.white;
    fontSize = style?.fontSize ?? 14;

    if (items.isNotEmpty && activeItemId == null) {
      activeItemId = items.first.id;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    _hoveredIndex = null;
    int currentY = y + 8;

    for (int i = 0; i < items.length; i++) {
      final itemHeight = 40;

      if (input.isHovering(x + 6, currentY, width - 12, itemHeight)) {
        _hoveredIndex = i;
        if (input.isMouseButtonPressed(MouseButtons.left)) {
          final item = items[i];
          activeItemId = item.id;
          onItemTap?.call(item.id);
          item.onTap?.call();
          if (item.route != null) {
            Navigator.to(item.route!);
          }
        }
        break;
      }

      currentY += itemHeight + 6;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // 1. Fondo de la barra lateral
    ctx2d.drawRect(x, y, width, height, bgColor);

    // 2. Separador vertical derecho
    ctx2d.drawRect(x + width - 1, y, 1, height, const ColorRGBA(36, 40, 52));

    // 3. Renderizado de ítems
    int currentY = y + 8;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = activeItemId == item.id;
      final isHovered = _hoveredIndex == i;
      final itemHeight = 40;

      final itemBg = isSelected
          ? activeColor
          : (isHovered ? hoverColor : const ColorRGBA(28, 32, 42));

      ctx2d.drawRect(x + 6, currentY, width - 12, itemHeight, itemBg);

      // Borde o indicador de selección activo
      if (isSelected) {
        ctx2d.drawRect(x + 6, currentY, 4, itemHeight, ColorRGBA.white);
      }

      final textY = currentY + ((itemHeight - fontSize) ~/ 2);
      int drawX = x + 16;

      if (item.icon != null) {
        ctx2d.drawText(item.icon!.glyph, drawX, textY, fontSize + 2, textColor);
        drawX += fontSize + 8;
      }

      ctx2d.drawText(item.label, drawX, textY, fontSize, textColor);

      currentY += itemHeight + 6;
    }
  }
}
