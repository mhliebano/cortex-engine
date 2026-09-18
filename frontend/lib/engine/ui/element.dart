import 'package:cortex/engine/context2d.dart';
import 'package:cortex/engine/context3d.dart';
import 'package:cortex/engine/input.dart';
export 'package:cortex/engine/ui/layout_alignment.dart';
export 'package:cortex/engine/ui/text_editing_controller.dart';

/// Modalidad de expansión declarativa para componentes de la UI.
enum Expand {
  /// Tamaño propio o ajustado automáticamente al contenido (MainAxisSize.min)
  none,

  /// Estira horizontalmente para ocupar todo el ancho disponible en X
  width,

  /// Estira verticalmente para ocupar todo el alto disponible en Y
  height,

  /// Estira en ambas dimensiones (X e Y)
  all,
}

/// Clase base para componentes gráficos.
/// Soporta anclajes flexibles y estiramiento automático al redimensionar la ventana.
abstract class Element {
  /// Flag global del motor para detectar instanciación indebida de componentes durante el renderizado.
  static bool isRenderingPhase = false;

  /// Clave declarativa opcional para identificar y reconciliar el estado del componente entre reconstrucciones.
  final String? key;

  int x;
  int y;
  int width;
  int height;
  bool isVisible;

  // Propiedad de Expansión Declarativa
  Expand expand;
  int marginRight;
  int marginBottom;

  Element({
    this.key,
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
    this.isVisible = true,
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
                        : Expand.none) {
    if (isRenderingPhase) {
      throw StateError(
        '❌ ERROR ARQUITECTÓNICO DEL MOTOR: Se intentó instanciar "$runtimeType" dentro del método onRender().\n'
        '👉 Los componentes UI (Button, Panel, TextField, etc.) NO deben crearse durante la fase de dibujado.\n'
        '👉 Decláralos en el método build() de la Vista o agrégalos a la lista de hijos durante init/onInit().'
      );
    }
  }

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

  /// Indica si el elemento debe comportarse como flexible en su ancho en contenedores Flex.
  bool get isFlexWidth => fillWidth;

  /// Indica si el elemento debe comportarse como flexible en su alto en contenedores Flex.
  bool get isFlexHeight => fillHeight;

  void onUpdate(double dt, InputEngine input) {}
  void onRender(Context2D ctx2d, Context3D ctx3d);
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {}

  /// Reacción automática al redimensionamiento del contenedor padre.
  /// `allocatedWidth` y `allocatedHeight` representan el espacio asignado disponible para este elemento.
  void onResize(int allocatedWidth, int allocatedHeight) {
    if (isFlexWidth) {
      width = allocatedWidth > marginRight ? allocatedWidth - marginRight : 0;
    }
    if (isFlexHeight) {
      height = allocatedHeight > marginBottom ? allocatedHeight - marginBottom : 0;
    }
  }

  bool containsPoint(double px, double py) {
    return px >= x && px <= x + width && py >= y && py <= y + height;
  }

  /// Devuelve la lista de elementos hijos para navegación recursiva del árbol UI.
  List<Element> get childrenElements => const [];

  /// Devuelve el estado volátil o dinámico del componente para ser preservado durante `rebuild()`.
  /// Retorna `null` si el componente no mantiene estado dinámico.
  Map<String, dynamic>? exportState() => null;

  /// Restaura el estado volátil o dinámico del componente tras un `rebuild()`.
  void importState(Map<String, dynamic> state) {}
}
