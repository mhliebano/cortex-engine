import 'dart:math';
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
  late final List<StructureNode> children;

  Panel({
    super.key,
    super.localLayoutRules,
    super.localStyleRules,
    required double width,
    required double height,
    this.padding = const EdgeInsets.all(0.0),
    this.layout = PanelLayout.stack,
    List<StructureNode>? children,
  })  : rawWidth = width,
        rawHeight = height {
    this.width = resolveDimension(rawWidth, 0);
    this.height = resolveDimension(rawHeight, 0);
    this.children = children ?? build();
    _updateChildBounds();
  }

  /// Hook sobreescribible para declarar los nodos estructurales hijos del Panel.
  List<StructureNode> build() => [];

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

    final availableWidth = max(
      0,
      width > (padding.left + padding.right)
          ? (width - (padding.left + padding.right)).toInt()
          : 0,
    );
    final availableHeight = max(
      0,
      height > (padding.top + padding.bottom)
          ? (height - (padding.top + padding.bottom)).toInt()
          : 0,
    );

    if (layout == PanelLayout.stack) {
      for (final child in children) {
        child.x = childX;
        child.y = childY;
        child.onResize(availableWidth, availableHeight);
      }
    } else if (layout == PanelLayout.vertical) {
      int rigidSum = 0;
      final flexibleChildren = <StructureNode>[];

      for (final child in children) {
        if (child is Spacer) {
          if (child.size != null) {
            final sz = child.size!.round();
            rigidSum += sz;
            child.height = sz;
          } else {
            flexibleChildren.add(child);
          }
        } else {
          child.onResize(availableWidth, availableHeight);
          if (child.height < availableHeight) {
            rigidSum += child.height;
          } else {
            flexibleChildren.add(child);
          }
        }
      }

      final remainingSpace = max(0, availableHeight - rigidSum);
      final childQuota = flexibleChildren.isNotEmpty
          ? (remainingSpace / flexibleChildren.length).floor()
          : 0;

      for (final child in flexibleChildren) {
        if (child is Spacer) {
          child.height = childQuota;
          child.width = availableWidth;
        } else {
          child.onResize(availableWidth, childQuota);
        }
      }

      int currentY = childY;
      for (final child in children) {
        child.x = childX;
        child.y = currentY;
        currentY += child.height;
      }
    } else if (layout == PanelLayout.horizontal) {
      int rigidSum = 0;
      final flexibleChildren = <StructureNode>[];

      for (final child in children) {
        if (child is Spacer) {
          if (child.size != null) {
            final sz = child.size!.round();
            rigidSum += sz;
            child.width = sz;
          } else {
            flexibleChildren.add(child);
          }
        } else {
          child.onResize(availableWidth, availableHeight);
          if (child.width < availableWidth) {
            rigidSum += child.width;
          } else {
            flexibleChildren.add(child);
          }
        }
      }

      final remainingSpace = max(0, availableWidth - rigidSum);
      final childQuota = flexibleChildren.isNotEmpty
          ? (remainingSpace / flexibleChildren.length).floor()
          : 0;

      for (final child in flexibleChildren) {
        if (child is Spacer) {
          child.width = childQuota;
          child.height = availableHeight;
        } else {
          child.onResize(childQuota, availableHeight);
        }
      }

      int currentX = childX;
      for (final child in children) {
        child.x = currentX;
        child.y = childY;
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
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = maxHeight;
    _updateChildBounds();
  }
}
