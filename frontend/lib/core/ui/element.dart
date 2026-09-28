import 'package:frontend/core/ui/cortex_node.dart';
export 'package:frontend/core/ui/layout_alignment.dart';
export 'package:frontend/core/ui/text_editing_controller.dart';

/// Modalidad de expansión declarativa para componentes de la UI.
enum Expand {
  none,
  width,
  height,
  all,
}

/// Clase base para componentes gráficos visuales y reactivos.
abstract class Element extends CortexNode {
  static bool get isRenderingPhase => CortexNode.isRenderingPhase;
  static set isRenderingPhase(bool val) => CortexNode.isRenderingPhase = val;

  Expand expand;
  int marginRight;
  int marginBottom;

  Element({
    super.key,
    super.x,
    super.y,
    super.width,
    super.height,
    super.isVisible,
    Expand? expand,
    bool? fillWidth,
    bool? fillHeight,
    this.marginRight = 0,
    this.marginBottom = 0,
  }) : expand = expand ??
            (fillWidth == true && fillHeight == true
                ? Expand.all
                : fillWidth == true
                    ? Expand.width
                    : fillHeight == true
                        ? Expand.height
                        : Expand.none);

  bool get fillWidth => expand == Expand.width || expand == Expand.all;
  set fillWidth(bool val) {
    if (val) {
      expand = fillHeight ? Expand.all : Expand.width;
    } else {
      expand = fillHeight ? Expand.height : Expand.none;
    }
  }

  bool get fillHeight => expand == Expand.height || expand == Expand.all;
  set fillHeight(bool val) {
    if (val) {
      expand = fillWidth ? Expand.all : Expand.height;
    } else {
      expand = fillWidth ? Expand.width : Expand.none;
    }
  }

  @override
  bool get isFlexWidth => fillWidth;

  @override
  bool get isFlexHeight => fillHeight;

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    if (isFlexWidth) {
      width = allocatedWidth > marginRight ? allocatedWidth - marginRight : 0;
    } else {
      width = allocatedWidth;
    }
    if (isFlexHeight) {
      height = allocatedHeight > marginBottom
          ? allocatedHeight - marginBottom
          : 0;
    } else {
      height = allocatedHeight;
    }
  }
}
