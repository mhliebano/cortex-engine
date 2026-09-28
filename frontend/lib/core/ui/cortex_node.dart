import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/utils.dart';
import 'package:frontend/core/ui/layouts/column.dart';
import 'package:frontend/core/ui/layouts/panel.dart';
import 'package:frontend/core/ui/layouts/row.dart';

/// Nodo base fundamental del motor Cortex UI.
abstract class CortexNode {
  /// Flag global del motor para detectar instanciación indebida de componentes durante el renderizado.
  static bool isRenderingPhase = false;

  /// Clave declarativa opcional para identificar el nodo entre reconstrucciones.
  final String? key;

  int x;
  int y;
  int width;
  int height;
  bool isVisible;

  CortexNode({
    this.key,
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
    this.isVisible = true,
  }) {
    if (isRenderingPhase) {
      throw StateError(
        '❌ ERROR ARQUITECTÓNICO DEL MOTOR: Se intentó instanciar "$runtimeType" dentro del método onRender().\n'
        '👉 Los componentes UI NO deben crearse durante la fase de dibujado.\n'
        '👉 Decláralos en el método build() de la Vista o agrégalos durante init/onInit().',
      );
    }
  }

  /// Indica si el elemento es flexible en ancho.
  bool get isFlexWidth => false;

  /// Indica si el elemento es flexible en alto.
  bool get isFlexHeight => false;

  void onUpdate(double dt, InputEngine input) {}
  void onRender(Context2D ctx2d, Context3D ctx3d);

  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    renderDebugWireframe(ctx2d);
  }

  /// Dibuja el Wireframe Debugger visual cuando [Debugger.showLayout] está activo.
  void renderDebugWireframe(Context2D ctx2d) {
    if (!Debugger.showLayout || width <= 0 || height <= 0) return;

    final String typeName = runtimeType.toString();
    final ColorRGBA borderColor;

    if (this is Panel) {
      borderColor = const ColorRGBA(255, 50, 50, 255); // Rojo para Panel
    } else if (this is Col) {
      borderColor = const ColorRGBA(50, 255, 50, 255); // Verde para Col
    } else if (this is Row) {
      borderColor = const ColorRGBA(50, 150, 255, 255); // Azul para Row
    } else {
      borderColor = const ColorRGBA(180, 180, 180, 255); // Gris para otros componentes
    }

    // Dibujar borde rectangular estricto del nodo
    ctx2d.drawRect(x, y, width, 1, borderColor);
    ctx2d.drawRect(x, y + height - 1, width, 1, borderColor);
    ctx2d.drawRect(x, y, 1, height, borderColor);
    ctx2d.drawRect(x + width - 1, y, 1, height, borderColor);

    // Etiqueta flotante superior izquierda con el runtimeType
    final labelWidth = typeName.length * 7 + 8;
    ctx2d.drawRect(x, y, labelWidth, 14, const ColorRGBA(0, 0, 0, 180));
    ctx2d.drawText(typeName, x + 4, y + 1, 10, borderColor);
  }

  void onResize(int allocatedWidth, int allocatedHeight) {
    width = allocatedWidth;
    height = allocatedHeight;
  }

  bool containsPoint(double px, double py) {
    return px >= x && px <= x + width && py >= y && py <= y + height;
  }

  List<CortexNode> get childrenElements => const [];

  Map<String, dynamic>? exportState() => null;
  void importState(Map<String, dynamic> state) {}
}
