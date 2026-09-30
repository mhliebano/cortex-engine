import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/style.dart';

typedef VoidCallback = void Function();

/// Nodo base abstracto para componentes interactivos de control.
abstract class ControlNode extends CortexNode {
  final String? className;
  bool isEnabled;
  bool isHovered;
  bool isFocused;

  ControlNode({
    super.key,
    super.isVisible,
    this.className,
    this.isEnabled = true,
    this.isHovered = false,
    this.isFocused = false,
  });

  /// Getter dinámico que resuelve el estilo concatenando pseudoclases CSS según el estado.
  /// Jerarquía de precedencia en Style.merge: disabled > focus > hover > normal.
  Style get currentStyle {
    if (className == null || className!.trim().isEmpty) {
      return const Style();
    }

    final classes = className!.trim().split(RegExp(r'\s+'));
    final buffer = <String>[];

    for (final cls in classes) {
      buffer.add(cls);
      if (isHovered) buffer.add('$cls:hover');
      if (isFocused) buffer.add('$cls:focus');
      if (!isEnabled) buffer.add('$cls:disabled');
    }

    return Style.merge(buffer.join(' '));
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
