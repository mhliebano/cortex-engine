import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/structure_node.dart';
import 'package:frontend/core/ui/layouts/spacer.dart';

/// Modos de disposición interna para Panel.
enum PanelLayout { stack, vertical, horizontal }

/// Contenedor Maestro Rígido (`Panel`).
class Panel extends CortexNode {
  final double rawWidth;
  final double rawHeight;
  final EdgeInsets padding;
  final PanelLayout layout;
  final List<StructureNode>? _explicitChildren;
  late final List<StructureNode> children;

  Panel({
    super.key,
    required double width,
    required double height,
    this.padding = const EdgeInsets.all(0.0),
    this.layout = PanelLayout.stack,
    List<StructureNode>? children,
  })  : rawWidth = width,
        rawHeight = height,
        _explicitChildren = children {
    this.width = resolveDimension(rawWidth, 0);
    this.height = resolveDimension(rawHeight, 0);
    this.children = build();
    _updateChildBounds();
  }

  /// Hook sobreescribible para declarar los nodos estructurales hijos del Panel.
  List<StructureNode> build() {
    return _explicitChildren ?? const [];
  }

  /// Resuelve un valor dimensional numérico (`double`) al tamaño final en píxeles (`int`).
  static int resolveDimension(double spec, int parentTotal, [int? freeSpace]) {
    if (spec == double.infinity || spec <= 0.0) {
      return freeSpace ?? parentTotal;
    }
    if (spec > 0.0 && spec <= 1.0) {
      return (parentTotal * spec).round();
    }
    if (spec > 1.0) {
      return spec.toInt();
    }
    return 0;
  }

  @override
  List<CortexNode> get childrenElements => children;

  @override
  bool get isFlexWidth =>
      rawWidth == double.infinity || (rawWidth >= 0.0 && rawWidth <= 1.0);

  @override
  bool get isFlexHeight =>
      rawHeight == double.infinity || (rawHeight >= 0.0 && rawHeight <= 1.0);

  void _updateChildBounds() {
    if (children.isEmpty) return;

    final childX = x + padding.left.toInt();
    final childY = y + padding.top.toInt();

    final availableWidth = width > (padding.left + padding.right)
        ? (width - (padding.left + padding.right)).toInt()
        : 0;
    final availableHeight = height > (padding.top + padding.bottom)
        ? (height - (padding.top + padding.bottom)).toInt()
        : 0;

    if (layout == PanelLayout.stack) {
      for (final child in children) {
        child.x = childX;
        child.y = childY;

        if (availableWidth > 0) child.width = availableWidth;
        if (availableHeight > 0) child.height = availableHeight;

        child.onResize(
          availableWidth > 0 ? availableWidth : child.width,
          availableHeight > 0 ? availableHeight : child.height,
        );
      }
    } else if (layout == PanelLayout.vertical) {
      // Paso 1 (Lo Rígido)
      int rigidSum = 0;
      int flexibleSpacerCount = 0;
      for (final child in children) {
        if (child is Spacer) {
          if (child.size != null) {
            final sz = child.size!.round();
            rigidSum += sz;
            child.height = sz;
          } else {
            flexibleSpacerCount++;
          }
        } else if (child.isFlexHeight) {
          flexibleSpacerCount++;
        } else {
          rigidSum += child.height;
        }
      }

      // Paso 2 (Los Resortes) & Paso 3 (Repartición)
      if (flexibleSpacerCount > 0) {
        final remainingSpace = availableHeight - rigidSum;
        final spacerHeight =
            remainingSpace > 0 ? (remainingSpace / flexibleSpacerCount).floor() : 0;
        for (final child in children) {
          if ((child is Spacer && child.size == null) || child.isFlexHeight) {
            child.height = spacerHeight;
          }
        }
      }

      int currentY = childY;
      for (final child in children) {
        child.x = childX;
        child.y = currentY;
        if (availableWidth > 0) child.width = availableWidth;
        child.onResize(child.width, child.height);
        currentY += child.height;
      }
    } else if (layout == PanelLayout.horizontal) {
      // Paso 1 (Lo Rígido)
      int rigidSum = 0;
      int flexibleSpacerCount = 0;
      for (final child in children) {
        if (child is Spacer) {
          if (child.size != null) {
            final sz = child.size!.round();
            rigidSum += sz;
            child.width = sz;
          } else {
            flexibleSpacerCount++;
          }
        } else if (child.isFlexWidth) {
          flexibleSpacerCount++;
        } else {
          rigidSum += child.width;
        }
      }

      // Paso 2 (Los Resortes) & Paso 3 (Repartición)
      if (flexibleSpacerCount > 0) {
        final remainingSpace = availableWidth - rigidSum;
        final spacerWidth =
            remainingSpace > 0 ? (remainingSpace / flexibleSpacerCount).floor() : 0;
        for (final child in children) {
          if ((child is Spacer && child.size == null) || child.isFlexWidth) {
            child.width = spacerWidth;
          }
        }
      }

      int currentX = childX;
      for (final child in children) {
        child.x = currentX;
        child.y = childY;
        if (availableHeight > 0) child.height = availableHeight;
        child.onResize(child.width, child.height);
        currentX += child.width;
      }
    }
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    for (final child in children) {
      if (child.isVisible) child.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    if (children.isNotEmpty && width > 0 && height > 0) {
      ctx2d.beginScissor(x, y, width, height);

      for (final child in children) {
        if (child.isVisible) {
          child.onRender(ctx2d, ctx3d);
        }
      }
      ctx2d.endScissor();
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;
    for (final child in children) {
      if (child.isVisible) child.onRenderOverlay(ctx2d, ctx3d);
    }
    super.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    width = allocatedWidth;
    height = allocatedHeight;
    _updateChildBounds();
  }
}
