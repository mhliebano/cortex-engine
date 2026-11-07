import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/navigator.dart';

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

/// Barra Lateral Vertical de Navegación (`SideBar`) bajo la arquitectura `ControlNode`.
class SideBar extends ControlNode {
  final List<SideBarItem> items;
  String? activeItemId;
  final void Function(String itemId)? onItemTap;

  int? _hoveredIndex;

  SideBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.items,
    this.activeItemId,
    this.onItemTap,
  }) {
    if (items.isNotEmpty && activeItemId == null) {
      activeItemId = items.first.id;
    }
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (!isFlexWidth && width <= 0) {
      width = 160;
    }
  }

  @override
  bool get isFlexHeight => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    height = maxHeight;
    final wRule = currentLayout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else {
      width = 160;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible) return;

    _hoveredIndex = null;
    int currentY = y + 8;

    for (int i = 0; i < items.length; i++) {
      const itemHeight = 40;

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
    _updateDimensions();

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(20, 23, 30);
    final activeColor = style.activeColor ?? style.accentColor ?? ColorRGBA.accentBlue;
    final hoverColor = style.hoverColor ?? const ColorRGBA(35, 40, 52);
    final textColor = style.textColor ?? ColorRGBA.white;
    final fontSize = style.fontSize ?? 14;
    final borderColor = style.borderColor ?? const ColorRGBA(36, 40, 52);

    // 1. Fondo de la barra lateral
    ctx2d.drawRect(x, y, width, height, bgColor);

    // 2. Separador vertical derecho
    ctx2d.drawRect(x + width - 1, y, 1, height, borderColor);

    // 3. Renderizado de ítems
    int currentY = y + 8;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = activeItemId == item.id;
      final isHovered = _hoveredIndex == i;
      const itemHeight = 40;

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

  @override
  Map<String, dynamic>? exportState() {
    return {'activeItemId': activeItemId};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('activeItemId')) {
      activeItemId = state['activeItemId'] as String?;
    }
  }
}
