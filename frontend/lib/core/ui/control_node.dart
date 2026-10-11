import 'dart:math';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/layout_rules.dart';
import 'package:frontend/core/ui/style_rules.dart';

typedef VoidCallback = void Function();

/// Nodo base abstracto para componentes interactivos de control bajo la arquitectura Cortex.
abstract class ControlNode extends CortexNode {
  final String? styleClass;
  final String? layoutClass;
  bool isEnabled;
  bool isHovered;
  bool isFocused;

  ControlNode({
    super.key,
    super.isVisible,
    super.localLayoutRules,
    super.localStyleRules,
    this.styleClass,
    this.layoutClass,
    this.isEnabled = true,
    this.isHovered = false,
    this.isFocused = false,
  }) : super();

  /// Resuelve cosmética y pintura contra el registro global [StyleRules],
  /// evaluando pseudoclases según el estado interactivo.
  StyleRules get currentStyle {
    final raw = styleClass;
    if (raw == null || raw.trim().isEmpty) {
      return const StyleRules();
    }

    final classes = raw.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered) buffer.add('$cls:hover');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return StyleRules.merge(buffer.join(' '));
  }

  /// Resuelve matemática espacial, dimensiones y layout contra el registro global [LayoutRules].
  LayoutRules get currentLayout {
    final raw = layoutClass;
    if (raw == null || raw.trim().isEmpty) {
      return const LayoutRules();
    }
    return LayoutRules.merge(raw.trim());
  }

  @override
  bool get isFlexWidth {
    final w = currentLayout.width;
    if (w == null) return false;
    return w == double.infinity || (w > 0.0 && w <= 1.0);
  }

  @override
  bool get isFlexHeight {
    final h = currentLayout.height;
    if (h == null) return false;
    return h == double.infinity || (h > 0.0 && h <= 1.0);
  }

  static const int unconstrained = 1000000;

  @override
  void onResize(int maxWidth, int maxHeight) {
    updateDimensions(maxWidth, maxHeight);
  }

  void updateDimensions(int maxWidth, int maxHeight) {
    final effectiveMaxW = maxWidth == unconstrained ? unconstrained : max(0, maxWidth);
    final effectiveMaxH = maxHeight == unconstrained ? unconstrained : max(0, maxHeight);

    int requestedWidth = width;
    int requestedHeight = height;

    final layout = currentLayout;
    final wRule = layout.width;
    if (wRule != null) {
      if (wRule == double.infinity) {
        requestedWidth = effectiveMaxW;
      } else if (wRule > 0.0 && wRule <= 1.0) {
        requestedWidth = (effectiveMaxW * wRule).round();
      } else if (wRule.isFinite) {
        requestedWidth = wRule.round();
      }
    }

    final hRule = layout.height;
    if (hRule != null) {
      if (hRule == double.infinity) {
        requestedHeight = effectiveMaxH;
      } else if (hRule > 0.0 && hRule <= 1.0) {
        requestedHeight = (effectiveMaxH * hRule).round();
      } else if (hRule.isFinite) {
        requestedHeight = hRule.round();
      }
    }

    width = (maxWidth == unconstrained) ? requestedWidth : min(requestedWidth, effectiveMaxW);
    height = (maxHeight == unconstrained) ? requestedHeight : min(requestedHeight, effectiveMaxH);
  }

  void onMouseEnter() {
    if (!isEnabled) return;
    isHovered = true;
  }

  void onMouseExit() {
    if (!isEnabled) return;
    isHovered = false;
  }

  void onFocus() {
    if (!isEnabled) return;
    isFocused = true;
  }

  void onBlur() {
    if (!isEnabled) return;
    isFocused = false;
  }

  void onMouseDown() {
    if (!isEnabled) return;
  }

  void onMouseUp() {
    if (!isEnabled) return;
  }
}
