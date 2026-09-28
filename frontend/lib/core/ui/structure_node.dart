import 'package:frontend/core/ui/cortex_node.dart';

/// Nodo estructural de disposición espacial (`Row`, `Col`).
///
/// Hereda directamente de [CortexNode], libre de propiedades visuales o reactivas de Element.
abstract class StructureNode extends CortexNode {
  StructureNode({
    super.key,
    super.x,
    super.y,
    super.width,
    super.height,
    super.isVisible,
  });
}
