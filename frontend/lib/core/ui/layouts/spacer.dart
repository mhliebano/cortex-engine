import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/ui/structure_node.dart';

/// Nodo de espaciado para la distribución en layouts lineales (`Col`, `Row`, `Panel`).
///
/// Si [size] es nulo, actúa como resorte flexible llenando el espacio disponible.
/// Si [size] tiene valor, actúa como bloque de espacio rígido de [size] x [size].
class Spacer extends StructureNode {
  final double? size;

  Spacer([this.size])
      : super(
          width: size != null ? size.round() : 0,
          height: size != null ? size.round() : 0,
        );

  @override
  bool get isFlexHeight => size == null;

  @override
  bool get isFlexWidth => size == null;

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {}
}
