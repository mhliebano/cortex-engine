import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/element.dart';
import 'package:frontend/core/ui/icons.dart';

/// Ítem individual para un grupo de botones segmentados (`SegmentItem`).
class SegmentItem {
  final String id;
  final String label;
  final IconData? icon;

  const SegmentItem({required this.id, required this.label, this.icon});
}

/// Componente de Grupo de Botones Conectados / Segmentados (`SegmentedButton`).
///
/// Permite alternar selecciones en un grupo continuo de botones donde
/// los segmentos exteriores redondean sus esquinas correspondientes.
class SegmentedButton extends Element {
  final List<SegmentItem> items;
  String? selectedId;
  final bool multiSelect;
  final Set<String> selectedIds;
  final void Function(String id)? onSelected;

  int _hoveredIndex = -1;

  SegmentedButton({
    required this.items,
    this.selectedId,
    Set<String>? selectedIds,
    this.multiSelect = false,
    this.onSelected,
    int height = 40,
    int itemWidth = 110,
  }) : selectedIds = selectedIds ?? {},
       super(width: items.length * itemWidth, height: height) {
    if (selectedId != null && !this.selectedIds.contains(selectedId)) {
      this.selectedIds.add(selectedId!);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || items.isEmpty) return;

    final int itemW = width ~/ items.length;
    _hoveredIndex = -1;

    for (int i = 0; i < items.length; i++) {
      final int ix = x + (i * itemW);
      if (input.isHovering(ix, y, itemW, height)) {
        _hoveredIndex = i;
        if (input.isMouseButtonPressed(MouseButtons.left)) {
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

    final int count = items.length;
    final int itemW = width ~/ count;

    // 1. Dibujar contenedor base general
    ctx2d.drawRoundRect(
      x,
      y,
      width,
      height,
      0.4,
      color: const ColorRGBA(30, 35, 45),
    );
    ctx2d.drawRoundRectLines(
      x,
      y,
      width,
      height,
      0.4,
      lineThick: 1.0,
      color: const ColorRGBA(65, 72, 85),
    );

    for (int i = 0; i < count; i++) {
      final item = items[i];
      final int ix = x + (i * itemW);
      final bool isSelected = selectedIds.contains(item.id);
      final bool isHovered = _hoveredIndex == i;

      // Colores de estado
      ColorRGBA bg = ColorRGBA.transparent;
      ColorRGBA fg = const ColorRGBA(180, 190, 205);

      if (isSelected) {
        bg = const ColorRGBA(41, 128, 185);
        fg = ColorRGBA.white;
      } else if (isHovered) {
        bg = const ColorRGBA(255, 255, 255, 20);
        fg = ColorRGBA.white;
      }

      // Dibujar fondo de segmento (si está seleccionado o hovered)
      if (bg.a > 0) {
        if (i == 0) {
          // Primer ítem: esquinas izquierdas redondeadas
          ctx2d.drawRoundRect(ix, y, itemW, height, 0.4, color: bg);
        } else if (i == count - 1) {
          // Último ítem: esquinas derechas redondeadas
          ctx2d.drawRoundRect(ix, y, itemW, height, 0.4, color: bg);
        } else {
          // Ítems intermedios
          ctx2d.drawRect(ix, y, itemW, height, bg);
        }
      }

      // Línea divisora entre segmentos adyacentes
      if (i > 0) {
        ctx2d.drawRect(ix, y + 6, 1, height - 12, const ColorRGBA(65, 72, 85));
      }

      // Contenido (Ícono + Texto)
      final int iconW = item.icon != null ? 18 : 0;
      final int textW = item.label.isNotEmpty ? (item.label.length * 7) : 0;
      final int totalW =
          iconW + (item.icon != null && item.label.isNotEmpty ? 6 : 0) + textW;

      int cx = ix + (itemW - totalW) ~/ 2;
      final int cy = y + (height - 14) ~/ 2;

      if (item.icon != null) {
        ctx2d.drawText(item.icon!.glyph, cx, cy - 1, 16, fg);
        cx += iconW + 6;
      }

      if (item.label.isNotEmpty) {
        ctx2d.drawText(item.label, cx, cy, 13, fg);
      }
    }
  }
}
