import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/icons.dart';
import 'package:frontend/core/ui/structure_node.dart';

/// Modelo de datos para una pestaña en `TabBar` y `TabView`.
class TabItem {
  final String id;
  String title;
  IconData? icon;
  bool isClosable;
  bool isModified;
  CortexNode? content;
  Object? data;

  TabItem({
    required this.id,
    required this.title,
    this.icon,
    this.isClosable = true,
    this.isModified = false,
    this.content,
    this.data,
  });
}

/// Barra de Pestañas Horizontal (`TabBar`) bajo la arquitectura `ControlNode`.
///
/// Gestiona la visualización de pestañas para múltiples documentos o vistas de trabajo:
/// - Pestaña activa resaltada con borde de acento e indicación visual clara.
/// - Cierre individual mediante botón `x` por pestaña.
/// - Indicador de documento modificado / no guardado (`isModified` con punto circular).
/// - Botón opcional `+` para añadir pestañas rápidamente.
/// - Desplazamiento horizontal interactivo si las pestañas exceden el ancho visible.
class TabBar extends ControlNode {
  final List<TabItem> tabs;
  int selectedIndex;
  final int tabHeight;
  final bool showNewTabButton;

  final void Function(int index, TabItem tab)? onTabSelected;
  final void Function(int index, TabItem tab)? onTabClosed;
  final void Function()? onNewTab;

  int _hoveredIndex = -1;
  int _hoveredCloseIndex = -1;
  bool _hoveredNewTab = false;
  int _scrollOffset = 0;

  TabBar({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.tabs,
    this.selectedIndex = 0,
    this.tabHeight = 34,
    this.showNewTabButton = false,
    this.onTabSelected,
    this.onTabClosed,
    this.onNewTab,
  }) {
    height = tabHeight;
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    }
    height = tabHeight;
  }

  @override
  bool get isFlexWidth => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = tabHeight;
  }

  void selectTab(int index) {
    if (index >= 0 && index < tabs.length && index != selectedIndex) {
      selectedIndex = index;
      onTabSelected?.call(selectedIndex, tabs[selectedIndex]);
    }
  }

  void closeTab(int index) {
    if (index >= 0 && index < tabs.length) {
      final closedTab = tabs[index];
      onTabClosed?.call(index, closedTab);
    }
  }

  int _getTabWidth(TabItem tab) {
    // Cálculo aproximado: padding (24) + icono (20) + texto + cerrar/modificado (24)
    int base = 32;
    if (tab.icon != null) base += 22;
    base += tab.title.length * 8;
    if (tab.isClosable || tab.isModified) base += 22;
    return math.max(80, math.min(base, 220));
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled) return;

    final mx = input.mouseX.round();
    final my = input.mouseY.round();
    final isInsideBar = mx >= x && mx < x + width && my >= y && my < y + height;

    _hoveredIndex = -1;
    _hoveredCloseIndex = -1;
    _hoveredNewTab = false;

    // Soporte para desplazamiento horizontal con rueda de ratón sobre la barra
    if (isInsideBar) {
      final wheel = input.mouseWheelMove;
      if (wheel != 0) {
        _scrollOffset = math.max(0, _scrollOffset - (wheel * 40).round());
      }
    }

    int currentTabX = x + 4 - _scrollOffset;

    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final tabW = _getTabWidth(tab);

      if (mx >= currentTabX && mx < currentTabX + tabW && my >= y && my < y + height) {
        _hoveredIndex = i;

        // Verificar si el cursor está sobre el botón cerrar
        if (tab.isClosable) {
          final closeBtnX = currentTabX + tabW - 22;
          final closeBtnY = y + (height - 18) ~/ 2;
          if (mx >= closeBtnX && mx < closeBtnX + 18 && my >= closeBtnY && my < closeBtnY + 18) {
            _hoveredCloseIndex = i;
          }
        }

        if (input.isMouseButtonPressed(0)) {
          if (_hoveredCloseIndex == i) {
            closeTab(i);
            return;
          } else {
            selectTab(i);
            return;
          }
        }
      }

      currentTabX += tabW + 2;
    }

    // Botón de nueva pestaña '+'
    if (showNewTabButton) {
      final newBtnX = currentTabX + 4;
      final newBtnY = y + (height - 24) ~/ 2;
      if (mx >= newBtnX && mx < newBtnX + 26 && my >= newBtnY && my < newBtnY + 24) {
        _hoveredNewTab = true;
        if (input.isMouseButtonPressed(0)) {
          onNewTab?.call();
        }
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(24, 25, 28, 255);
    final borderColor = style.borderColor ?? const ColorRGBA(45, 47, 54, 255);
    final activeBg = const ColorRGBA(36, 38, 44, 255);
    final hoverBg = const ColorRGBA(32, 34, 38, 255);
    final activeIndicator = const ColorRGBA(96, 165, 250, 255); // Azul suave
    final textColor = style.textColor ?? const ColorRGBA(220, 224, 230, 255);
    final inactiveTextColor = const ColorRGBA(140, 146, 160, 255);

    // Fondo general de la barra de pestañas
    ctx2d.drawRectangle(x, y, width, height, bgColor);
    ctx2d.drawLine(x, y + height - 1, x + width, y + height - 1, borderColor);

    // Recorte de tijera para soportar desplazamiento horizontal de pestañas
    ctx2d.beginScissor(x, y, width, height);

    int currentTabX = x + 4 - _scrollOffset;

    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final tabW = _getTabWidth(tab);
      final isSelected = i == selectedIndex;
      final isHovered = i == _hoveredIndex;

      // Color de fondo de la pestaña
      final currentTabBg = isSelected
          ? activeBg
          : (isHovered ? hoverBg : const ColorRGBA(28, 30, 34, 255));

      // Rectángulo de la pestaña
      ctx2d.drawRectangle(currentTabX, y + 2, tabW, height - 2, currentTabBg);
      ctx2d.drawLine(currentTabX, y + 2, currentTabX + tabW, y + 2, isSelected ? activeIndicator : borderColor);
      ctx2d.drawLine(currentTabX + tabW, y + 2, currentTabX + tabW, y + height - 1, borderColor);

      // Línea de acento superior o inferior para la pestaña activa
      if (isSelected) {
        ctx2d.drawRectangle(currentTabX, y + height - 2, tabW, 2, activeIndicator);
      }

      int contentX = currentTabX + 10;
      final contentY = y + (height - 14) ~/ 2;

      // Icono de la pestaña
      if (tab.icon != null) {
        ctx2d.drawIcon(
          tab.icon!,
          contentX,
          contentY,
          14,
          isSelected ? textColor : inactiveTextColor,
        );
        contentX += 18;
      }

      // Título de la pestaña
      final maxChars = (tabW - (contentX - currentTabX) - (tab.isClosable || tab.isModified ? 24 : 8)) ~/ 8;
      String displayTitle = tab.title;
      if (displayTitle.length > maxChars && maxChars > 3) {
        displayTitle = '${displayTitle.substring(0, maxChars - 2)}..';
      }

      ctx2d.drawText(
        displayTitle,
        contentX,
        contentY,
        13,
        isSelected ? textColor : inactiveTextColor,
      );

      // Indicador de modificado o botón de cerrar
      if (tab.isModified && !isSelected && _hoveredIndex != i) {
        // Punto de documento modificado
        final dotX = currentTabX + tabW - 14;
        final dotY = y + height ~/ 2;
        ctx2d.drawCircle(dotX, dotY, 3.5, activeIndicator);
      } else if (tab.isClosable) {
        final closeBtnX = currentTabX + tabW - 20;
        final closeBtnY = y + (height - 16) ~/ 2;
        final isCloseHovered = _hoveredCloseIndex == i;

        if (isCloseHovered) {
          ctx2d.drawRectangle(closeBtnX, closeBtnY, 16, 16, const ColorRGBA(239, 68, 68, 180));
        }

        ctx2d.drawIcon(
          Icons.close,
          closeBtnX + 2,
          closeBtnY + 2,
          12,
          isCloseHovered ? const ColorRGBA(255, 255, 255, 255) : inactiveTextColor,
        );
      }

      currentTabX += tabW + 2;
    }

    // Botón de nueva pestaña '+'
    if (showNewTabButton) {
      final newBtnX = currentTabX + 4;
      final newBtnY = y + (height - 22) ~/ 2;
      final newBg = _hoveredNewTab ? hoverBg : const ColorRGBA(0, 0, 0, 0);

      if (_hoveredNewTab) {
        ctx2d.drawRectangle(newBtnX, newBtnY, 22, 22, newBg);
      }
      ctx2d.drawText('+', newBtnX + 7, newBtnY + 3, 16, textColor);
    }

    ctx2d.endScissor();
  }
}

/// Contenedor de Vistas por Pestañas (`TabView`) bajo la arquitectura `StructureNode`.
///
/// Combina un [`TabBar`] superior anclado con el área central de contenido,
/// renderizando y redimensionando automáticamente el `child` correspondiente
/// a la pestaña activa seleccionada.
class TabView extends StructureNode {
  late final TabBar tabBar;
  final List<TabItem> tabs;
  final void Function(int index, TabItem tab)? onTabChanged;
  final void Function(int index, TabItem tab)? onTabClosed;
  final void Function()? onNewTab;

  TabView({
    super.key,
    super.isVisible,
    required this.tabs,
    int initialIndex = 0,
    int tabHeight = 34,
    bool showNewTabButton = false,
    this.onTabChanged,
    this.onTabClosed,
    this.onNewTab,
  }) {
    tabBar = TabBar(
      tabs: tabs,
      selectedIndex: initialIndex,
      tabHeight: tabHeight,
      showNewTabButton: showNewTabButton,
      onTabSelected: (index, tab) {
        _performLayout();
        onTabChanged?.call(index, tab);
      },
      onTabClosed: (index, tab) {
        closeTab(index);
      },
      onNewTab: onNewTab,
    );
    _performLayout();
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  List<CortexNode> get childrenElements => [
        tabBar,
        if (activeContent != null) activeContent!,
      ];

  TabItem? get activeTab =>
      (tabBar.selectedIndex >= 0 && tabBar.selectedIndex < tabs.length)
          ? tabs[tabBar.selectedIndex]
          : null;

  CortexNode? get activeContent => activeTab?.content;

  void addTab(TabItem tab, {bool selectImmediately = true}) {
    tabs.add(tab);
    if (selectImmediately) {
      tabBar.selectedIndex = tabs.length - 1;
    }
    _performLayout();
  }

  void closeTab(int index) {
    if (index >= 0 && index < tabs.length) {
      final removedTab = tabs[index];
      tabs.removeAt(index);

      if (tabBar.selectedIndex >= tabs.length) {
        tabBar.selectedIndex = math.max(0, tabs.length - 1);
      }
      _performLayout();
      onTabClosed?.call(index, removedTab);
    }
  }

  void _performLayout() {
    tabBar.x = x;
    tabBar.y = y;
    tabBar.width = width;
    tabBar.onResize(width, tabBar.tabHeight);

    final content = activeContent;
    if (content != null) {
      content.x = x;
      content.y = y + tabBar.tabHeight;
      content.width = width;
      content.height = math.max(0, height - tabBar.tabHeight);
      content.onResize(content.width, content.height);
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = maxHeight;
    _performLayout();
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;
    tabBar.onUpdate(dt, input);
    activeContent?.onUpdate(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    tabBar.onRender(ctx2d, ctx3d);
    activeContent?.onRender(ctx2d, ctx3d);
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    tabBar.onRenderOverlay(ctx2d, ctx3d);
    activeContent?.onRenderOverlay(ctx2d, ctx3d);
  }
}

