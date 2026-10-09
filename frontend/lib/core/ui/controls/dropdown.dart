import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/style_rules.dart';
import 'package:frontend/wrappers/graphics2d.dart';

/// Opción individual para un componente `Dropdown<T>`.
class DropdownOption<T> {
  final T value;
  final String label;
  final String? icon;

  const DropdownOption({required this.value, required this.label, this.icon});
}

/// Selector Desplegable (`Dropdown<T>`) bajo la arquitectura Cortex.
///
/// Muestra la opción seleccionada y proyecta un menú flotante sobre la capa overlay
/// (`onRenderOverlay`) para elegir entre las opciones disponibles con soporte de scroll y búsqueda interactiva.
class Dropdown<T> extends ControlNode {
  /// Instancia estática global del Dropdown activo con menú desplegado sobre la interfaz.
  static Dropdown? _activeOpenDropdown;

  T? selectedValue;
  final List<DropdownOption<T>> options;
  final String placeholder;
  final int maxMenuHeight;
  final void Function(T value)? onChanged;
  bool isPressed;

  bool _isOpen = false;
  int _hoveredOptionIndex = -1;
  int _openAnchorY = 0;

  double _scrollOffset = 0.0;
  bool _isDraggingScrollbar = false;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;

  Dropdown({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.selectedValue,
    required this.options,
    this.placeholder = 'Seleccionar...',
    this.maxMenuHeight = 220,
    this.onChanged,
    this.isPressed = false,
  }) {
    _updateDimensions();
  }

  @override
  StyleRules get currentStyle {
    final raw = styleClass;
    if (raw == null || raw.trim().isEmpty) {
      return const StyleRules();
    }

    final classes = raw.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered || _isOpen) buffer.add('$cls:hover');
      if (isPressed || _isOpen) buffer.add('$cls:active');
      if (isFocused || _isOpen) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return StyleRules.merge(buffer.join(' '));
  }

  /// Retorna la opción actualmente seleccionada.
  DropdownOption<T>? get selectedOption {
    if (selectedValue == null) return null;
    for (final opt in options) {
      if (opt.value == selectedValue) return opt;
    }
    return null;
  }

  int _measureTextWidth(String text, int fontSize) {
    if (text.isEmpty) return 0;
    try {
      final w = Graphics2D().measureText(text, fontSize);
      if (w > 0) return w;
    } catch (_) {}
    double totalWidth = 0.0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune).toLowerCase();
      if ('iljft1!| .,:;-/\\()[]\'`"'.contains(char)) {
        totalWidth += fontSize * 0.30;
      } else if ('mw0@#%&'.contains(char)) {
        totalWidth += fontSize * 0.65;
      } else {
        totalWidth += fontSize * 0.48;
      }
    }
    return totalWidth.round();
  }

  void _updateDimensions() {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final String sampleText = selectedOption?.label ?? placeholder;
    final int textW = _measureTextWidth(sampleText, fontSize);
    final int minW =
        (textW + 36 + pad.left + pad.right).round().clamp(180, 9999);
    final int minH = (fontSize + pad.top + pad.bottom).round().clamp(36, 9999);

    final wRule = layout.width;
    if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
      width = wRule.round();
    } else if (!isFlexWidth) {
      if (width < minW) width = minW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
      height = hRule.round();
    } else if (!isFlexHeight) {
      if (height < minH) height = minH;
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final style = currentStyle;
    final layout = currentLayout;
    final fontSize = style.fontSize ?? 14;
    final pad =
        layout.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final String sampleText = selectedOption?.label ?? placeholder;
    final int textW = _measureTextWidth(sampleText, fontSize);
    final int minW =
        (textW + 36 + pad.left + pad.right).round().clamp(180, 9999);
    final int minH = (fontSize + pad.top + pad.bottom).round().clamp(36, 9999);

    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        width = allocatedWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        width = (allocatedWidth * wRule).round();
      } else if (wRule.isFinite) {
        width = wRule.round();
      }
    } else {
      width = allocatedWidth > 0 ? allocatedWidth : minW;
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        height = allocatedHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        height = (allocatedHeight * hRule).round();
      } else if (hRule.isFinite) {
        height = hRule.round();
      }
    } else {
      height = allocatedHeight > 0 ? allocatedHeight : minH;
    }
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
      const itemHeight = 36;
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
    if (!isVisible || !isEnabled) {
      isHovered = false;
      isPressed = false;
      if (_isOpen) closeMenu();
      return;
    }

    _updateDimensions();

    isHovered = input.isHovering(x, y, width, height);

    const itemHeight = 36;
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
    final isHoveringMenu = _isOpen &&
        mx >= x &&
        mx <= x + width &&
        my >= menuY &&
        my <= menuY + visibleMenuHeight;

    // Detección de clic izquierdo en el gatillo o fuera del área
    if (input.isMouseButtonPressed(MouseButtons.left)) {
      if (isHovered) {
        isPressed = true;
        if (_isOpen) {
          closeMenu();
        } else {
          openMenu(visibleMenuHeight);
        }
      } else if (_isOpen && !isHoveringMenu) {
        closeMenu();
      }
    } else if (!input.isMouseButtonDown(MouseButtons.left)) {
      isPressed = false;
    }

    // Procesar interacción del menú desplegable abierto
    if (_isOpen) {
      if (y != _openAnchorY) {
        closeMenu();
        return;
      }

      if (input.mouseWheelMove != 0 && !isHoveringMenu && !isHovered) {
        closeMenu();
        return;
      }

      _hoveredOptionIndex = -1;

      // Scroll interno con rueda de mouse sobre las opciones
      if (isHoveringMenu && maxScroll > 0) {
        final wheel = input.mouseWheelMove;
        if (wheel != 0) {
          _scrollOffset -= wheel * 36.0;
          _scrollOffset = _scrollOffset.clamp(0.0, maxScroll);
        }
      }

      // Arrastre de la barra de scroll
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

      // Hover y Selección de Opción
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
    _updateDimensions();

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;

    final ColorRGBA bgColor =
        style.bgColor ?? const ColorRGBA(24, 30, 40);
    final ColorRGBA borderColor = _isOpen || isHovered
        ? (style.hoverColor ??
            style.activeColor ??
            style.borderColor ??
            const ColorRGBA(52, 152, 219))
        : (style.borderColor ?? const ColorRGBA(60, 70, 85));
    final ColorRGBA textColor =
        style.textColor ?? ColorRGBA.white;

    final ColorRGBA currentBg = isEnabled
        ? (isPressed
            ? ColorRGBA((bgColor.r * 0.8).round(), (bgColor.g * 0.8).round(),
                (bgColor.b * 0.8).round(), bgColor.a)
            : (isHovered || _isOpen
                ? ColorRGBA(
                    (bgColor.r * 1.15).clamp(0, 255).round(),
                    (bgColor.g * 1.15).clamp(0, 255).round(),
                    (bgColor.b * 1.15).clamp(0, 255).round(),
                    bgColor.a)
                : bgColor))
        : const ColorRGBA(16, 20, 26);

    final borderRadius = style.borderRadius ?? 6.0;
    final roundness = (borderRadius / (height > 0 ? height : 1)).clamp(0.0, 1.0);

    // 1. Dibujar caja gatillo principal
    if (roundness > 0) {
      ctx2d.drawRoundRect(x, y, width, height, roundness, color: currentBg);
      ctx2d.drawRoundRectLines(x, y, width, height, roundness,
          color: borderColor);
    } else {
      ctx2d.drawRect(x, y, width, height, currentBg);
      ctx2d.drawRect(x, y, width, 1, borderColor);
      ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
      ctx2d.drawRect(x, y, 1, height, borderColor);
      ctx2d.drawRect(x + width - 1, y, 1, height, borderColor);
    }

    // 2. Dibujar texto o placeholder activo
    final currentOpt = selectedOption;
    int textX = x + 12;

    if (currentOpt != null &&
        currentOpt.icon != null &&
        currentOpt.icon!.isNotEmpty) {
      ctx2d.drawText(
        currentOpt.icon!,
        textX,
        y + ((height - 16) ~/ 2),
        16,
        borderColor,
      );
      textX += 24;
    }

    if (currentOpt != null) {
      final textColorToUse =
          isEnabled ? textColor : const ColorRGBA(110, 120, 135);
      ctx2d.drawText(
        currentOpt.label,
        textX,
        y + ((height - fontSize) ~/ 2),
        fontSize,
        textColorToUse,
      );
    } else {
      ctx2d.drawText(
        placeholder,
        textX,
        y + ((height - fontSize) ~/ 2),
        fontSize,
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
      y + ((height - 18) ~/ 2),
      18,
      const ColorRGBA(150, 165, 185),
    );
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible || !_isOpen || options.isEmpty) return;

    final style = currentStyle;
    final fontSize = style.fontSize ?? 14;

    const itemHeight = 36;
    final totalContentHeight = options.length * itemHeight;
    final visibleMenuHeight = totalContentHeight > maxMenuHeight
        ? maxMenuHeight
        : totalContentHeight;
    final maxScroll = totalContentHeight > visibleMenuHeight
        ? (totalContentHeight - visibleMenuHeight).toDouble()
        : 0.0;
    final menuY = y + height + 2;

    final ColorRGBA dropdownBgColor =
        style.bgColor ?? const ColorRGBA(28, 34, 46);
    final ColorRGBA menuBorderColor = style.hoverColor ??
        style.activeColor ??
        style.borderColor ??
        const ColorRGBA(52, 152, 219);
    final ColorRGBA hoverItemColor =
        style.hoverColor ?? const ColorRGBA(42, 52, 70);

    // 1. Dibujar panel flotante del menú emergente sobre la capa overlay
    final borderRadius = style.borderRadius ?? 6.0;
    final roundness = (borderRadius / (visibleMenuHeight > 0 ? visibleMenuHeight : 1))
        .clamp(0.0, 0.2);

    if (roundness > 0) {
      ctx2d.drawRoundRect(x, menuY, width, visibleMenuHeight, roundness,
          color: dropdownBgColor);
      ctx2d.drawRoundRectLines(x, menuY, width, visibleMenuHeight, roundness,
          color: menuBorderColor);
    } else {
      ctx2d.drawRect(x, menuY, width, visibleMenuHeight, dropdownBgColor);
      ctx2d.drawRect(x, menuY, width, 1, menuBorderColor);
      ctx2d.drawRect(x, menuY + visibleMenuHeight - 1, width, 1, menuBorderColor);
      ctx2d.drawRect(x, menuY, 1, visibleMenuHeight, menuBorderColor);
      ctx2d.drawRect(x + width - 1, menuY, 1, visibleMenuHeight, menuBorderColor);
    }

    // 2. Recortar área visible del menú desplegable con Scissor
    ctx2d.beginScissor(x, menuY, width, visibleMenuHeight);

    // 3. Dibujar lista de ítems de opción
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final itemY = menuY + (i * itemHeight) - _scrollOffset.toInt();

      if (itemY + itemHeight < menuY || itemY > menuY + visibleMenuHeight) {
        continue;
      }

      final isItemHovered = i == _hoveredOptionIndex;
      final isSelected = option.value == selectedValue;

      if (isItemHovered) {
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
            ? (style.activeColor ?? ColorRGBA.accentBlue)
            : const ColorRGBA(160, 175, 195);
        ctx2d.drawText(option.icon!, optionTextX, itemY + 9, 16, iconColor);
        optionTextX += 24;
      }

      final textColorToUse = isSelected
          ? (style.activeColor ?? ColorRGBA.accentBlue)
          : ColorRGBA.white;
      ctx2d.drawText(
          option.label, optionTextX, itemY + ((itemHeight - fontSize) ~/ 2), fontSize, textColorToUse);

      // Marca de selección si está activo
      if (isSelected) {
        ctx2d.drawText(
          Icons.check.glyph,
          x + width - 24,
          itemY + 9,
          16,
          style.activeColor ?? ColorRGBA.accentBlue,
        );
      }
    }

    // 4. Dibujar barra de scroll si las opciones exceden la altura máxima
    if (maxScroll > 0) {
      final scrollbarHeight =
          ((visibleMenuHeight / totalContentHeight) * visibleMenuHeight)
              .toInt()
              .clamp(20, visibleMenuHeight);
      final scrollbarY = menuY +
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
