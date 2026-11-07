import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Ítem individual para un grupo de botones segmentados (`SegmentItem`).
class SegmentItem {
  final String id;
  final String label;
  final IconData? icon;

  const SegmentItem({required this.id, required this.label, this.icon});
}

/// Componente de Grupo de Botones Conectados / Segmentados (`SegmentedButton`) bajo la arquitectura `ControlNode`.
///
/// Permite alternar selecciones en un grupo continuo de botones donde
/// los segmentos exteriores redondean sus esquinas correspondientes.
class SegmentedButton extends ControlNode {
  final List<SegmentItem> items;
  String? selectedId;
  final bool multiSelect;
  final Set<String> selectedIds;
  final void Function(String id)? onSelected;

  int _hoveredIndex = -1;

  SegmentedButton({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.items,
    this.selectedId,
    Set<String>? selectedIds,
    this.multiSelect = false,
    this.onSelected,
    int? defaultHeight,
    int? defaultItemWidth,
  }) : selectedIds = selectedIds ?? {} {
    if (selectedId != null && !this.selectedIds.contains(selectedId)) {
      this.selectedIds.add(selectedId!);
    }
    _updateDimensions(defaultHeight ?? 38, defaultItemWidth ?? 110);
  }

  void _updateDimensions([int defH = 38, int defItemW = 110]) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (width <= 0) {
      width = items.length * defItemW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (height <= 0) {
      height = defH;
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    } else if (isFlexWidth) {
      width = maxWidth;
    }

    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled || items.isEmpty) return;

    final mx = input.mouseX.round();
    final my = input.mouseY.round();
    final int itemW = width ~/ items.length;
    _hoveredIndex = -1;

    for (int i = 0; i < items.length; i++) {
      final int ix = x + (i * itemW);
      if (mx >= ix && mx < ix + itemW && my >= y && my < y + height) {
        _hoveredIndex = i;
        if (input.isMouseButtonPressed(0)) {
          final String item = items[i].id;
          if (multiSelect) {
            if (selectedIds.contains(item)) {
              selectedIds.remove(item);
            } else {
              selectedIds.add(item);
            }
          } else {
            selectedId = item;
            selectedIds.clear();
            selectedIds.add(item);
          }
          onSelected?.call(item);
        }
        break;
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || items.isEmpty) return;

    final style = currentStyle;
    final int count = items.length;
    final int itemW = width ~/ count;

    final bgColor = style.bgColor ?? const ColorRGBA(30, 35, 45, 255);
    final borderColor = style.borderColor ?? const ColorRGBA(65, 72, 85, 255);
    final activeBg = const ColorRGBA(37, 99, 235, 255);
    final hoverBg = const ColorRGBA(255, 255, 255, 25);
    final activeText = const ColorRGBA(255, 255, 255, 255);
    final defaultText = style.textColor ?? const ColorRGBA(180, 190, 205, 255);

    // 1. Dibujar contenedor base general
    ctx2d.drawRoundRect(x, y, width, height, 0.4, color: bgColor);
    ctx2d.drawRoundRectLines(x, y, width, height, 0.4, lineThick: 1.0, color: borderColor);

    for (int i = 0; i < count; i++) {
      final item = items[i];
      final int ix = x + (i * itemW);
      final bool isSelected = selectedIds.contains(item.id);
      final bool isHovered = _hoveredIndex == i;

      ColorRGBA segmentBg = const ColorRGBA(0, 0, 0, 0);
      ColorRGBA segmentFg = defaultText;

      if (isSelected) {
        segmentBg = activeBg;
        segmentFg = activeText;
      } else if (isHovered) {
        segmentBg = hoverBg;
        segmentFg = activeText;
      }

      // Dibujar fondo del segmento
      if (segmentBg.a > 0) {
        if (i == 0) {
          ctx2d.drawRoundRect(ix, y, itemW, height, 0.4, color: segmentBg);
        } else if (i == count - 1) {
          ctx2d.drawRoundRect(ix, y, itemW, height, 0.4, color: segmentBg);
        } else {
          ctx2d.drawRect(ix, y, itemW, height, segmentBg);
        }
      }

      // Línea divisora entre segmentos adyacentes
      if (i > 0) {
        ctx2d.drawRect(ix, y + 6, 1, height - 12, borderColor);
      }

      // Contenido (Ícono + Texto)
      final int iconW = item.icon != null ? 18 : 0;
      final int textW = item.label.isNotEmpty ? (item.label.length * 8) : 0;
      final int totalW = iconW + (item.icon != null && item.label.isNotEmpty ? 6 : 0) + textW;

      int cx = ix + (itemW - totalW) ~/ 2;
      final int cy = y + (height - 14) ~/ 2;

      if (item.icon != null) {
        ctx2d.drawIcon(item.icon!, cx, cy - 1, 14, segmentFg);
        cx += iconW + 6;
      }

      if (item.label.isNotEmpty) {
        ctx2d.drawText(item.label, cx, cy, 13, segmentFg);
      }
    }
  }
}
