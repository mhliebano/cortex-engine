import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Definición de una herramienta para `ToolBar`.
class ToolItem {
  final String id;
  final String label;
  final IconData? icon;
  final String? tooltip;
  final void Function()? onTap;
  final bool isDivider;

  ToolItem({
    required this.id,
    this.label = '',
    this.icon,
    this.tooltip,
    void Function()? onTap,
    void Function()? onPressed,
    this.isDivider = false,
  }) : onTap = onTap ?? onPressed;

  /// Crea una herramienta separadora/divisora vertical.
  factory ToolItem.divider() => ToolItem(id: 'divider', isDivider: true);

  String get tooltipText => tooltip ?? label;
}

/// Barra de Herramientas Rápidas (`ToolBar`) bajo la arquitectura `ControlNode`.
/// Soporta botones cuadrados con íconos, divisores y globos de ayuda flotantes (`tooltip`).
class ToolBar extends ControlNode {
  final List<ToolItem> tools;
  String? selectedToolId;
  final void Function(String toolId)? onToolSelected;

  int? _hoveredIndex;

  ToolBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.tools,
    this.selectedToolId,
    this.onToolSelected,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else if (!isFlexHeight && height <= 0) {
      height = 36;
    }
  }

  int get _buttonSize => height - 8;

  @override
  bool get isFlexWidth => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    final hRule = currentLayout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    } else {
      height = 36;
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible) return;

    _hoveredIndex = null;
    final btnSize = _buttonSize;
    int currentX = x + 8;

    for (int i = 0; i < tools.length; i++) {
      final tool = tools[i];

      if (tool.isDivider) {
        currentX += 10;
        continue;
      }

      if (input.isHovering(currentX, y + 4, btnSize, btnSize)) {
        _hoveredIndex = i;
        if (input.isMouseButtonPressed(MouseButtons.left)) {
          selectedToolId = tool.id;
          tool.onTap?.call();
          onToolSelected?.call(tool.id);
        }
        break;
      }

      currentX += btnSize + 4;
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    _updateDimensions();

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(24, 28, 36);
    final activeColor = style.activeColor ?? style.accentColor ?? ColorRGBA.accentBlue;
    final hoverColor = style.hoverColor ?? const ColorRGBA(45, 52, 68);
    final textColor = style.textColor ?? ColorRGBA.white;
    final iconSize = style.fontSize ?? 18;
    final borderColor = style.borderColor ?? const ColorRGBA(40, 44, 56);

    // 1. Fondo de la barra de herramientas
    ctx2d.drawRect(x, y, width, height, bgColor);

    // 2. Renderizado de botones de herramienta cuadrados con íconos
    final btnSize = _buttonSize;
    int currentX = x + 8;

    for (int i = 0; i < tools.length; i++) {
      final tool = tools[i];

      if (tool.isDivider) {
        ctx2d.drawRect(
          currentX + 4,
          y + 6,
          1,
          height - 12,
          const ColorRGBA(50, 58, 75),
        );
        currentX += 10;
        continue;
      }

      final isSelected = selectedToolId == tool.id;
      final isHovered = _hoveredIndex == i;

      final btnBg = isSelected
          ? activeColor
          : (isHovered ? hoverColor : const ColorRGBA(32, 37, 48));

      // Fondo del botón cuadrado
      ctx2d.drawRect(currentX, y + 4, btnSize, btnSize, btnBg);

      // Borde del botón (resaltado si está seleccionado o en hover)
      final btnBorderColor = isSelected
          ? const ColorRGBA(255, 255, 255, 180)
          : (isHovered
                ? const ColorRGBA(90, 100, 125)
                : const ColorRGBA(50, 56, 72));
      ctx2d.drawPanel(
        currentX,
        y + 4,
        btnSize,
        btnSize,
        bgColor: ColorRGBA.transparent,
        borderColor: btnBorderColor,
      );

      // Renderizar el ícono centrado en el botón cuadrado
      if (tool.icon != null) {
        final iconX = currentX + ((btnSize - iconSize) ~/ 2);
        final iconY = y + ((height - iconSize) ~/ 2);
        ctx2d.drawText(tool.icon!.glyph, iconX, iconY, iconSize, textColor);
      }

      currentX += btnSize + 4;
    }

    // 3. Separador inferior
    ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // Renderizar globo de ayuda flotante (Tooltip) al pasar el cursor
    if (_hoveredIndex != null && _hoveredIndex! < tools.length) {
      final tool = tools[_hoveredIndex!];
      if (tool.isDivider) return;

      final text = tool.tooltipText;
      final btnSize = _buttonSize;

      final textWidth = text.length * 7;
      final tooltipWidth = textWidth + 16;
      const tooltipHeight = 24;

      final btnCenterX =
          (x + 8 + _hoveredIndex! * (btnSize + 4)) + (btnSize ~/ 2);
      int tooltipX = btnCenterX - (tooltipWidth ~/ 2);
      if (tooltipX < x + 4) tooltipX = x + 4;
      if (tooltipX + tooltipWidth > x + width - 4) {
        tooltipX = x + width - tooltipWidth - 4;
      }
      final tooltipY = y + height + 6;

      // Dibujar caja flotante del tooltip
      ctx2d.drawPanel(
        tooltipX,
        tooltipY,
        tooltipWidth,
        tooltipHeight,
        bgColor: const ColorRGBA(18, 22, 30, 245),
        borderColor: const ColorRGBA(65, 75, 95),
      );

      // Dibujar texto del tooltip
      ctx2d.drawText(text, tooltipX + 8, tooltipY + 4, 12, ColorRGBA.white);
    }
  }

  @override
  Map<String, dynamic>? exportState() {
    return {'selectedToolId': selectedToolId};
  }

  @override
  void importState(Map<String, dynamic> state) {
    if (state.containsKey('selectedToolId')) {
      selectedToolId = state['selectedToolId'] as String?;
    }
  }
}
