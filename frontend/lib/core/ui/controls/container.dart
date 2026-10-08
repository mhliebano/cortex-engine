import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/control_node.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/edge_insets.dart';

/// Control visual Container bajo la arquitectura Cortex.
/// Cero parámetros espaciales en constructor. La geometría se gobierna por [layoutClass]
/// y la pintura cosmética por [styleClass].
class Container extends ControlNode {
  final CortexNode? child;

  Container({
    super.key,
    super.isVisible,
    super.styleClass,
    super.layoutClass,
    super.isEnabled,
    this.child,
  }) {
    _updateDimensions();
  }

  @override
  List<CortexNode> get childrenElements => child == null ? const [] : [child!];

  static int _inner(int total, double a, double b) {
    final v = total - (a + b).round();
    return v > 0 ? v : 0;
  }

  void _updateDimensions() {
    final layout = currentLayout;
    final pad = layout.padding ?? const EdgeInsets.all(0.0);
    final c = child;

    final wRule = layout.width;
    if (wRule != null && wRule > 1.0 && wRule != double.infinity) {
      width = wRule.round();
    } else {
      final minW = ((c?.width ?? 0) + pad.left + pad.right).round();
      if (width < minW) width = minW;
    }

    final hRule = layout.height;
    if (hRule != null && hRule > 1.0 && hRule != double.infinity) {
      height = hRule.round();
    } else {
      final minH = ((c?.height ?? 0) + pad.top + pad.bottom).round();
      if (height < minH) height = minH;
    }
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    final layout = currentLayout;
    final pad = layout.padding ?? const EdgeInsets.all(0.0);
    final c = child;

    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        width = allocatedWidth;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        width = (allocatedWidth * wRule).round();
      } else {
        width = wRule.round();
      }
    } else {
      final minW = ((c?.width ?? 0) + pad.left + pad.right).round();
      width = allocatedWidth > 0 ? allocatedWidth : minW;
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        height = allocatedHeight;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        height = (allocatedHeight * hRule).round();
      } else {
        height = hRule.round();
      }
    } else {
      final minH = ((c?.height ?? 0) + pad.top + pad.bottom).round();
      height = allocatedHeight > 0 ? allocatedHeight : minH;
    }

    if (c == null) return;

    c.x = x + pad.left.round();
    c.y = y + pad.top.round();
    c.onResize(
      _inner(width, pad.left, pad.right),
      _inner(height, pad.top, pad.bottom),
    );
  }

  @override
  void onUpdate(double dt, InputEngine input) {
    super.onUpdate(dt, input);
    if (!isVisible) return;

    if (isEnabled) {
      isHovered = input.isHovering(x, y, width, height);
    } else {
      isHovered = false;
    }

    _updateDimensions();

    final c = child;
    if (c == null) return;

    final pad = currentLayout.padding ?? const EdgeInsets.all(0.0);
    final childX = x + pad.left.round();
    final childY = y + pad.top.round();

    if (c.x != childX || c.y != childY) {
      c.x = childX;
      c.y = childY;
      c.onResize(
        _inner(width, pad.left, pad.right),
        _inner(height, pad.top, pad.bottom),
      );
    }

    if (c.isVisible) c.onUpdate(dt, input);
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final style = currentStyle;
    final bgColor = style.bgColor;
    final borderColor = style.borderColor;
    final borderRadius = style.borderRadius ?? 0.0;

    final roundness =
        (borderRadius > 1.0
                ? borderRadius / (height > 0 ? height : 1)
                : borderRadius)
            .clamp(0.0, 1.0);

    if (bgColor != null && bgColor.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRect(x, y, width, height, roundness, color: bgColor);
      } else {
        ctx2d.drawRect(x, y, width, height, bgColor);
      }
    }

    if (borderColor != null && borderColor.a > 0) {
      if (roundness > 0) {
        ctx2d.drawRoundRectLines(
          x,
          y,
          width,
          height,
          roundness,
          color: borderColor,
        );
      } else {
        ctx2d.drawRect(x, y, width, 1, borderColor);
        ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
        ctx2d.drawRect(x, y, 1, height, borderColor);
        ctx2d.drawRect(x + width - 1, y, 1, height, borderColor);
      }
    }

    final c = child;
    if (c != null && c.isVisible && width > 2 && height > 2) {
      ctx2d.beginScissor(x + 1, y + 1, width - 2, height - 2);
      c.onRender(ctx2d, ctx3d);
      ctx2d.endScissor();
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    final c = child;
    if (c != null && c.isVisible) c.onRenderOverlay(ctx2d, ctx3d);

    super.onRenderOverlay(ctx2d, ctx3d);
  }
}
