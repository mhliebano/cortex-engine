import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/icons.dart';

/// Nodo individual dentro de un árbol jerárquico `TreeView`.
class TreeNode<T> {
  final String id;
  String label;
  IconData? icon;
  T? data;
  final List<TreeNode<T>> children;
  bool isExpanded;
  bool isSelected;
  bool isVisible;
  TreeNode<T>? parent;

  TreeNode({
    required this.id,
    required this.label,
    this.icon,
    this.data,
    List<TreeNode<T>>? children,
    this.isExpanded = false,
    this.isSelected = false,
    this.isVisible = true,
  }) : children = children ?? [] {
    for (final child in this.children) {
      child.parent = this;
    }
  }

  bool get hasChildren => children.isNotEmpty;

  void addChild(TreeNode<T> child) {
    child.parent = this;
    children.add(child);
  }

  void removeChild(TreeNode<T> child) {
    if (children.remove(child)) {
      child.parent = null;
    }
  }
}

/// Registro interno para aplanar la jerarquía visible del árbol.
class _FlattenedNode<T> {
  final TreeNode<T> node;
  final int depth;
  _FlattenedNode(this.node, this.depth);
}

/// Explorador en Árbol Jerárquico (`TreeView`) bajo la arquitectura `ControlNode`.
///
/// Diseñado para gestión de proyectos, ensambles de muebles, capas y piezas en entornos CAD:
/// - Expansión y colapso de nodos con flechas animadas o iconos chevron.
/// - Líneas guía de jerarquía visual vertical y horizontal (`showGuides`).
/// - Conmutador visual de visibilidad 3D por pieza/capa (ojo `Icons.visibility`).
/// - Desplazamiento vertical fluido con rueda de ratón y barra de scroll integrada.
/// - Selección simple y callbacks para selección, doble clic y menú contextual.
class TreeView<T> extends ControlNode {
  final List<TreeNode<T>> roots;
  final int itemHeight;
  final int indentWidth;
  final bool showGuides;
  final bool showVisibilityToggles;

  final void Function(TreeNode<T> node)? onNodeSelected;
  final void Function(TreeNode<T> node)? onNodeDoubleClicked;
  final void Function(TreeNode<T> node, bool isExpanded)? onNodeExpandedChanged;
  final void Function(TreeNode<T> node, bool isVisible)? onVisibilityChanged;
  final void Function(TreeNode<T> node, int mouseX, int mouseY)? onNodeContextMenu;

  int _scrollY = 0;
  int _hoveredIndex = -1;
  bool _hoveredChevron = false;
  bool _hoveredEye = false;

  double _lastClickTime = 0.0;
  String? _lastClickedNodeId;

  TreeView({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled = true,
    required this.roots,
    this.itemHeight = 26,
    this.indentWidth = 18,
    this.showGuides = true,
    this.showVisibilityToggles = false,
    this.onNodeSelected,
    this.onNodeDoubleClicked,
    this.onNodeExpandedChanged,
    this.onVisibilityChanged,
    this.onNodeContextMenu,
  }) {
    _updateDimensions();
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null && wRule.isFinite && wRule > 1.0) {
      width = wRule.round();
    }
    final hRule = layout.height;
    if (hRule != null && hRule.isFinite && hRule > 1.0) {
      height = hRule.round();
    }
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = maxHeight;
  }

  List<_FlattenedNode<T>> _getVisibleNodes() {
    final list = <_FlattenedNode<T>>[];
    void traverse(List<TreeNode<T>> nodes, int depth) {
      for (final n in nodes) {
        list.add(_FlattenedNode<T>(n, depth));
        if (n.hasChildren && n.isExpanded) {
          traverse(n.children, depth + 1);
        }
      }
    }
    traverse(roots, 0);
    return list;
  }

  int get _maxScrollY {
    final totalHeight = _getVisibleNodes().length * itemHeight;
    return math.max(0, totalHeight - height);
  }

  TreeNode<T>? get selectedNode {
    TreeNode<T>? found;
    void search(List<TreeNode<T>> list) {
      for (final n in list) {
        if (n.isSelected) {
          found = n;
          return;
        }
        if (n.hasChildren) search(n.children);
      }
    }
    search(roots);
    return found;
  }

  void selectNode(TreeNode<T> targetNode) {
    void deselectAll(List<TreeNode<T>> list) {
      for (final n in list) {
        n.isSelected = (n == targetNode);
        if (n.hasChildren) deselectAll(n.children);
      }
    }
    deselectAll(roots);
    onNodeSelected?.call(targetNode);
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible || !isEnabled) return;

    final mx = input.mouseX.round();
    final my = input.mouseY.round();
    final isInside = mx >= x && mx < x + width && my >= y && my < y + height;

    _hoveredIndex = -1;
    _hoveredChevron = false;
    _hoveredEye = false;

    if (!isInside) return;

    // Desplazamiento con rueda de ratón
    final wheel = input.mouseWheelMove;
    if (wheel != 0) {
      _scrollY = math.max(0, math.min(_maxScrollY, _scrollY - (wheel * 30).round()));
    }

    final visibleNodes = _getVisibleNodes();
    final relativeY = my - y + _scrollY;
    final clickedIndex = relativeY ~/ itemHeight;

    if (clickedIndex >= 0 && clickedIndex < visibleNodes.length) {
      _hoveredIndex = clickedIndex;
      final flat = visibleNodes[clickedIndex];
      final node = flat.node;

      final nodeX = x + (flat.depth * indentWidth) + 8;
      final chevronX = nodeX;
      final eyeX = x + width - 26;

      // Detectar si el cursor está sobre el chevron
      if (node.hasChildren && mx >= chevronX && mx < chevronX + 16) {
        _hoveredChevron = true;
      }

      // Detectar si el cursor está sobre el conmutador de visibilidad
      if (showVisibilityToggles && mx >= eyeX && mx < eyeX + 20) {
        _hoveredEye = true;
      }

      // Clic izquierdo
      if (input.isMouseButtonPressed(0)) {
        if (_hoveredChevron) {
          node.isExpanded = !node.isExpanded;
          onNodeExpandedChanged?.call(node, node.isExpanded);
        } else if (_hoveredEye) {
          node.isVisible = !node.isVisible;
          onVisibilityChanged?.call(node, node.isVisible);
        } else {
          // Clic en la fila
          final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final isDoubleClick = (_lastClickedNodeId == node.id) && (now - _lastClickTime < 0.35);

          selectNode(node);

          if (isDoubleClick) {
            if (node.hasChildren) {
              node.isExpanded = !node.isExpanded;
              onNodeExpandedChanged?.call(node, node.isExpanded);
            }
            onNodeDoubleClicked?.call(node);
          }

          _lastClickTime = now;
          _lastClickedNodeId = node.id;
        }
      }

      // Clic derecho (menú contextual)
      if (input.isMouseButtonPressed(1)) {
        selectNode(node);
        onNodeContextMenu?.call(node, mx, my);
      }
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final bgColor = style.bgColor ?? const ColorRGBA(22, 23, 27, 255);
    final borderColor = style.borderColor ?? const ColorRGBA(40, 42, 48, 255);
    final textColor = style.textColor ?? const ColorRGBA(220, 225, 230, 255);
    final secondaryText = const ColorRGBA(130, 136, 150, 255);
    final selectedBg = const ColorRGBA(37, 99, 235, 90);
    final selectedBorder = const ColorRGBA(59, 130, 246, 255);
    final hoverBg = const ColorRGBA(34, 36, 42, 255);
    final guideColor = const ColorRGBA(55, 58, 68, 255);

    // Fondo del TreeView
    ctx2d.drawRectangle(x, y, width, height, bgColor);
    ctx2d.drawLine(x, y, x + width, y, borderColor);
    ctx2d.drawLine(x, y + height - 1, x + width, y + height - 1, borderColor);

    final visibleNodes = _getVisibleNodes();
    final totalHeight = visibleNodes.length * itemHeight;

    ctx2d.beginScissor(x, y, width, height);

    for (int i = 0; i < visibleNodes.length; i++) {
      final itemY = y + (i * itemHeight) - _scrollY;
      if (itemY + itemHeight < y || itemY > y + height) continue;

      final flat = visibleNodes[i];
      final node = flat.node;
      final isHovered = i == _hoveredIndex;
      final isSelected = node.isSelected;

      // Resaltado de fondo
      if (isSelected) {
        ctx2d.drawRectangle(x + 2, itemY, width - 4, itemHeight, selectedBg);
        ctx2d.drawRectangle(x + 2, itemY, 3, itemHeight, selectedBorder);
      } else if (isHovered) {
        ctx2d.drawRectangle(x + 2, itemY, width - 4, itemHeight, hoverBg);
      }

      int currentX = x + (flat.depth * indentWidth) + 8;
      final centerY = itemY + itemHeight ~/ 2;

      // Líneas guía de jerarquía vertical y horizontal
      if (showGuides && flat.depth > 0) {
        for (int d = 1; d <= flat.depth; d++) {
          final guideX = x + (d * indentWidth) - (indentWidth ~/ 2);
          ctx2d.drawLine(guideX, itemY, guideX, itemY + itemHeight, guideColor);
        }
        // Conector horizontal a la fila actual
        final connectorX = x + (flat.depth * indentWidth) - (indentWidth ~/ 2);
        ctx2d.drawLine(connectorX, centerY, currentX - 2, centerY, guideColor);
      }

      // Flecha / Chevron de expansión para padres
      if (node.hasChildren) {
        final chevronIcon = node.isExpanded ? Icons.expandMore : Icons.chevronRight;
        final chevronColor = (_hoveredChevron && isHovered) ? textColor : secondaryText;
        ctx2d.drawIcon(chevronIcon, currentX, centerY - 7, 14, chevronColor);
      }
      currentX += 16;

      // Icono del nodo
      final nodeIcon = node.icon ??
          (node.hasChildren
              ? (node.isExpanded ? Icons.folder_open : Icons.folder)
              : Icons.file);
      final iconColor = isSelected ? const ColorRGBA(96, 165, 250, 255) : secondaryText;
      ctx2d.drawIcon(nodeIcon, currentX, centerY - 7, 14, iconColor);
      currentX += 18;

      // Etiqueta del nodo
      final labelColor = isSelected
          ? const ColorRGBA(255, 255, 255, 255)
          : (node.isVisible ? textColor : const ColorRGBA(100, 105, 115, 255));
      ctx2d.drawText(node.label, currentX, centerY - 6, 13, labelColor);

      // Conmutador de visibilidad CAD (ojo)
      if (showVisibilityToggles) {
        final eyeX = x + width - 24;
        final eyeColor = node.isVisible
            ? ((_hoveredEye && isHovered) ? const ColorRGBA(255, 255, 255, 255) : secondaryText)
            : const ColorRGBA(239, 68, 68, 200);
        final eyeIcon = node.isVisible ? Icons.visibility : Icons.visibility_off;
        ctx2d.drawIcon(eyeIcon, eyeX, centerY - 6, 13, eyeColor);
      }
    }

    ctx2d.endScissor();

    // Barra de scroll vertical si el contenido excede el alto
    if (totalHeight > height) {
      final scrollbarW = 6;
      final scrollbarX = x + width - scrollbarW - 2;
      final thumbH = math.max(20, (height * height) ~/ totalHeight);
      final thumbY = y + ((height - thumbH) * _scrollY) ~/ (totalHeight - height);

      ctx2d.drawRectangle(scrollbarX, y, scrollbarW, height, const ColorRGBA(0, 0, 0, 30));
      ctx2d.drawRectangle(scrollbarX, thumbY, scrollbarW, thumbH, const ColorRGBA(120, 125, 140, 150));
    }
  }
}

