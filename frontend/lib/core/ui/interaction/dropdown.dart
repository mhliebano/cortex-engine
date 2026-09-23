import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/element.dart';
import 'package:cortex/core/ui/icons.dart';
import 'package:cortex/core/ui/style.dart';

/// Opción individual para un componente `Dropdown<T>`.
class DropdownOption<T> {
  final T value;
  final String label;
  final String? icon;

  const DropdownOption({required this.value, required this.label, this.icon});
}

/// Selector Desplegable (`Dropdown<T>`).
/// Muestra la opción seleccionada y abre un menú flotante en `onRenderOverlay` para elegir entre las opciones disponibles.
/// Soporta desplazamiento interactivo (rueda del mouse / barra de scroll), altura máxima configurable (`maxMenuHeight`)
/// y aislamiento de eventos ante múltiples instancias superpuestas (`_activeOpenDropdown`).
class Dropdown<T> extends Element {
  /// Instancia estática global del Dropdown activo con menú desplegado sobre la interfaz.
  static Dropdown? _activeOpenDropdown;

  T? selectedValue;
  final List<DropdownOption<T>> options;
  final String placeholder;
  final bool enabled;
  final int maxMenuHeight;
  final void Function(T value)? onChanged;

  late ColorRGBA bgColor;
  late ColorRGBA borderColor;
  late ColorRGBA hoverBorderColor;
  late ColorRGBA textColor;
  late ColorRGBA dropdownBgColor;
  late ColorRGBA hoverItemColor;

  bool _isOpen = false;
  bool _isHovered = false;
  int _hoveredOptionIndex = -1;
  int _openAnchorY = 0;

  double _scrollOffset = 0.0;
  bool _isDraggingScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  Dropdown({
    super.key,
    String? className,
    this.selectedValue,
    required this.options,
    this.placeholder = 'Seleccionar opción...',
    this.enabled = true,
    this.maxMenuHeight = 220,
    this.onChanged,
    int width = 0,
    int height = 0,
    super.expand,
    super.fillWidth,
    super.fillHeight,
    super.marginRight,
    super.marginBottom,
  }) {
    final style = className != null ? Style.merge(className) : null;
    this.width = width != 0 ? width : (style?.width ?? 220);
    this.height = height != 0 ? height : (style?.height ?? 38);

    bgColor = style?.bgColor ?? const ColorRGBA(24, 30, 40);
    borderColor = style?.borderColor ?? const ColorRGBA(60, 70, 85);
    hoverBorderColor = style?.accentColor ?? const ColorRGBA(52, 152, 219);
    textColor = style?.textColor ?? ColorRGBA.white;
    dropdownBgColor = const ColorRGBA(28, 34, 46);
    hoverItemColor = const ColorRGBA(42, 52, 70);
  }

  /// Retorna la opción actualmente seleccionada.
  DropdownOption<T>? get selectedOption {
    if (selectedValue == null) return null;
    for (final opt in options) {
      if (opt.value == selectedValue) return opt;
    }
    return null;
  }

  /// Cierra de forma segura el menú flotante y libera el foco.
  void closeMenu() {
    _isOpen = false;
    _isDraggingScrollbar = false;
    if (_activeOpenDropdown == this) {
      _activeOpenDropdown = null;
    }
  }

  /// Abre el menú flotante y desactiva otros desplegables activos.
  void openMenu(int visibleMenuHeight) {
    if (_activeOpenDropdown != null && _activeOpenDropdown != this) {
      _activeOpenDropdown!.closeMenu();
    }
    _isOpen = true;
    _openAnchorY = y;
    _activeOpenDropdown = this;
    _scrollToSelected(visibleMenuHeight);
  }

  /// Auto-scroll para centrar la opción seleccionada al abrir el menú.
  void _scrollToSelected(int visibleMenuHeight) {
    if (selectedValue == null) return;
    int index = -1;
    for (int i = 0; i < options.length; i++) {
      if (options[i].value == selectedValue) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      final itemHeight = 36;
      final totalContentHeight = options.length * itemHeight;
      final maxScroll = totalContentHeight > visibleMenuHeight
          ? (totalContentHeight - visibleMenuHeight).toDouble()
          : 0.0;
      final targetOffset =
          (index * itemHeight) - (visibleMenuHeight / 2) + (itemHeight / 2);
      _scrollOffset = targetOffset.clamp(0.0, maxScroll);
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible || !enabled) {
      if (_isOpen) closeMenu();
      return;
    }

    _isHovered = input.isHovering(x, y, width, height);

    final itemHeight = 36;
    final totalContentHeight = options.length * itemHeight;
    final visibleMenuHeight = totalContentHeight > maxMenuHeight
        ? maxMenuHeight
        : totalContentHeight;
    final maxScroll = totalContentHeight > visibleMenuHeight
        ? (totalContentHeight - visibleMenuHeight).toDouble()
        : 0.0;
    final menuY = y + height + 2;

    final mx = input.mouseX;
    final my = input.mouseY;
    final isHoveringMenu =
        _isOpen &&
        mx >= x &&
        mx <= x + width &&
        my >= menuY &&
        my <= menuY + visibleMenuHeight;

    // Detección de clic izquierdo en el gatillo o fuera del área
    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (_isHovered) {
        if (_isOpen) {
          closeMenu();
        } else {
          openMenu(visibleMenuHeight);
        }
      } else if (_isOpen && !isHoveringMenu) {
        closeMenu();
      }
    }

    // Procesar interacción del menú desplegable abierto
    if (_isOpen) {
      // 0. Si el contenedor padre se movió verticalmente por scroll, cerrar menú
      if (y != _openAnchorY) {
        closeMenu();
        return;
      }

      // 1. Si la rueda del mouse se activa fuera del menú desplegado y gatillo, cerrar menú
      if (input.mouseWheelMove != 0 && !isHoveringMenu && !_isHovered) {
        closeMenu();
        return;
      }

      _hoveredOptionIndex = -1;

      // 2. Scroll interno con rueda de mouse sobre las opciones
      if (isHoveringMenu && maxScroll > 0) {
        final wheel = input.mouseWheelMove;
        if (wheel != 0) {
          _scrollOffset -= wheel * 36.0;
          _scrollOffset = _scrollOffset.clamp(0.0, maxScroll);
        }
      }

      // 3. Arrastre de la barra de scroll
      if (maxScroll > 0) {
        final scrollbarHitX = x + width - 14;
        if (input.isMouseButtonPressed(MouseButtons.left)) {
          if (mx >= scrollbarHitX &&
              mx <= x + width &&
              my >= menuY &&
              my <= menuY + visibleMenuHeight) {
            _isDraggingScrollbar = true;
            _dragStartY = my;
            _dragStartOffset = _scrollOffset;
          }
        }

        if (_isDraggingScrollbar) {
          if (input.isMouseButtonDown(MouseButtons.left)) {
            final deltaY = my - _dragStartY;
            final scrollbarHeight =
                ((visibleMenuHeight / totalContentHeight) * visibleMenuHeight)
                    .toInt()
                    .clamp(20, visibleMenuHeight);
            final trackSpace = (visibleMenuHeight - scrollbarHeight).toDouble();
            if (trackSpace > 0) {
              final offsetDelta = (deltaY / trackSpace) * maxScroll;
              _scrollOffset = (_dragStartOffset + offsetDelta).clamp(
                0.0,
                maxScroll,
              );
            }
          } else {
            _isDraggingScrollbar = false;
          }
        }
      }

      // 4. Hover y Selección de Opción
      if (isHoveringMenu && !_isDraggingScrollbar) {
        for (int i = 0; i < options.length; i++) {
          final optY = menuY + (i * itemHeight) - _scrollOffset.toInt();
          if (my >= optY &&
              my <= optY + itemHeight &&
              my >= menuY &&
              my <= menuY + visibleMenuHeight) {
            _hoveredOptionIndex = i;
            if (input.isMouseButtonPressed(MouseButtons.left)) {
              selectedValue = options[i].value;
              closeMenu();
              onChanged?.call(selectedValue as T);
            }
            break;
          }
        }
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final currentBorder = _isOpen || _isHovered
        ? hoverBorderColor
        : borderColor;
    final currentBg = enabled ? bgColor : const ColorRGBA(16, 20, 26);

    // 1. Dibujar caja gatillo principal
    ctx2d.drawPanel(
      x,
      y,
      width,
      height,
      bgColor: currentBg,
      borderColor: currentBorder,
    );

    // 2. Dibujar texto o placeholder activo
    final currentOpt = selectedOption;
    int textX = x + 12;

    if (currentOpt != null &&
        currentOpt.icon != null &&
        currentOpt.icon!.isNotEmpty) {
      ctx2d.drawText(
        currentOpt.icon!,
        textX,
        y + (height ~/ 4),
        16,
        hoverBorderColor,
      );
      textX += 24;
    }

    if (currentOpt != null) {
      final textColorToUse = enabled
          ? textColor
          : const ColorRGBA(110, 120, 135);
      ctx2d.drawText(
        currentOpt.label,
        textX,
        y + (height ~/ 4),
        14,
        textColorToUse,
      );
    } else {
      ctx2d.drawText(
        placeholder,
        textX,
        y + (height ~/ 4),
        14,
        const ColorRGBA(110, 125, 140),
      );
    }

    // 3. Dibujar ícono de flecha desplegable
    final arrowIcon = _isOpen
        ? Icons.expand_less.glyph
        : Icons.arrow_drop_down.glyph;
    ctx2d.drawText(
      arrowIcon,
      x + width - 26,
      y + (height ~/ 4),
      18,
      const ColorRGBA(150, 165, 185),
    );
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || !_isOpen || options.isEmpty) return;

    final itemHeight = 36;
    final totalContentHeight = options.length * itemHeight;
    final visibleMenuHeight = totalContentHeight > maxMenuHeight
        ? maxMenuHeight
        : totalContentHeight;
    final maxScroll = totalContentHeight > visibleMenuHeight
        ? (totalContentHeight - visibleMenuHeight).toDouble()
        : 0.0;
    final menuY = y + height + 2;

    // 1. Dibujar panel flotante del menú emergente sobre la capa overlay
    ctx2d.drawPanel(
      x,
      menuY,
      width,
      visibleMenuHeight,
      bgColor: dropdownBgColor,
      borderColor: hoverBorderColor,
    );

    // 2. Recortar área visible del menú desplegable con Scissor
    ctx2d.beginScissor(x, menuY, width, visibleMenuHeight);

    // 3. Dibujar lista de ítems de opción
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final itemY = menuY + (i * itemHeight) - _scrollOffset.toInt();

      // Optimización: Omitir dibujado si el ítem está completamente fuera de la vista
      if (itemY + itemHeight < menuY || itemY > menuY + visibleMenuHeight) {
        continue;
      }

      final isHovered = i == _hoveredOptionIndex;
      final isSelected = option.value == selectedValue;

      if (isHovered) {
        ctx2d.drawRect(
          x + 2,
          itemY + 2,
          width - 4,
          itemHeight - 4,
          hoverItemColor,
        );
      } else if (isSelected) {
        ctx2d.drawRect(
          x + 2,
          itemY + 2,
          width - 4,
          itemHeight - 4,
          const ColorRGBA(36, 45, 62),
        );
      }

      int optionTextX = x + 12;
      if (option.icon != null && option.icon!.isNotEmpty) {
        final iconColor = isSelected
            ? ColorRGBA.accentBlue
            : const ColorRGBA(160, 175, 195);
        ctx2d.drawText(option.icon!, optionTextX, itemY + 9, 16, iconColor);
        optionTextX += 24;
      }

      final textColorToUse = isSelected
          ? ColorRGBA.accentBlue
          : ColorRGBA.white;
      ctx2d.drawText(option.label, optionTextX, itemY + 9, 14, textColorToUse);

      // Marca de selección si está activo
      if (isSelected) {
        ctx2d.drawText(
          Icons.check.glyph,
          x + width - 24,
          itemY + 9,
          16,
          ColorRGBA.accentBlue,
        );
      }
    }

    // 4. Dibujar barra de scroll si las opciones exceden la altura máxima
    if (maxScroll > 0) {
      final scrollbarHeight =
          ((visibleMenuHeight / totalContentHeight) * visibleMenuHeight)
              .toInt()
              .clamp(20, visibleMenuHeight);
      final scrollbarY =
          menuY +
          ((_scrollOffset / maxScroll) * (visibleMenuHeight - scrollbarHeight))
              .toInt();
      final isHighlighted = _isDraggingScrollbar;
      final barWidth = isHighlighted ? 6 : 4;
      final color = isHighlighted
          ? const ColorRGBA(255, 255, 255, 220)
          : const ColorRGBA(255, 255, 255, 120);

      ctx2d.drawRect(
        x + width - (barWidth + 2),
        scrollbarY,
        barWidth,
        scrollbarHeight,
        color,
      );
    }

    ctx2d.endScissor();
  }
}
