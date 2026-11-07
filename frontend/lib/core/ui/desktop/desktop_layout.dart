import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/ui/cortex_node.dart';
import 'package:frontend/core/ui/desktop/menu_bar.dart';
import 'package:frontend/core/ui/desktop/side_bar.dart';
import 'package:frontend/core/ui/desktop/status_bar.dart';
import 'package:frontend/core/ui/desktop/tool_bar.dart';
import 'package:frontend/core/ui/structure_node.dart';

/// Contenedor de Disposición de Escritorio (`DesktopLayout`) bajo la arquitectura `StructureNode`.
///
/// Organiza automáticamente los componentes principales del entorno MDI:
/// - `menuBar`: Barra de menú superior (anclada a `y: 0`).
/// - `toolBar`: Barra de accesos directos (anclada debajo del menú).
/// - `sideBar`: Panel lateral de herramientas o navegación (anclada a la izquierda).
/// - `statusBar`: Barra informativa inferior (anclada al borde inferior de la ventana).
/// - `body`: Zona central asignada al contenido activo / RouterView / Viewport3D / MDI.
class DesktopLayout extends StructureNode {
  static DesktopLayout? activeLayout;

  MenuBar? menuBar;
  ToolBar? toolBar;
  SideBar? sideBar;
  StatusBar? statusBar;
  CortexNode? _body;

  DesktopLayout({
    super.key,
    super.isVisible,
    this.menuBar,
    this.toolBar,
    this.sideBar,
    this.statusBar,
    CortexNode? body,
  }) : _body = body {
    activeLayout = this;
    _performLayout();
  }

  CortexNode? get body => _body;
  set body(CortexNode? newBody) {
    _body = newBody;
    _performLayout();
  }

  @override
  bool get isFlexWidth => true;

  @override
  bool get isFlexHeight => true;

  void _performLayout() {
    int currentTopY = y;

    // 1. Posicionar MenuBar superior
    final menu = menuBar;
    if (menu != null && menu.isVisible) {
      menu.x = x;
      menu.y = currentTopY;
      menu.width = width;
      menu.onResize(menu.width, menu.height);
      currentTopY += menu.height;
    }

    // 2. Posicionar ToolBar debajo de MenuBar
    final tools = toolBar;
    if (tools != null && tools.isVisible) {
      tools.x = x;
      tools.y = currentTopY;
      tools.width = width;
      tools.onResize(tools.width, tools.height);
      currentTopY += tools.height;
    }

    // 3. Posicionar StatusBar anclada estrictamente al borde inferior
    int currentBottomY = y + height;
    final status = statusBar;
    if (status != null && status.isVisible) {
      status.x = x;
      status.height = status.height > 0 ? status.height : 24;
      status.y = y + height - status.height;
      status.width = width;
      status.onResize(status.width, status.height);
      currentBottomY = status.y;
    }

    // 4. Calcular zona libre central entre barras superiores e inferiores
    final availableCenterHeight = currentBottomY > currentTopY
        ? currentBottomY - currentTopY
        : 0;
    int currentLeftX = x;

    // 5. Posicionar SideBar a la izquierda
    final side = sideBar;
    if (side != null && side.isVisible) {
      side.x = currentLeftX;
      side.y = currentTopY;
      side.height = availableCenterHeight;
      side.onResize(side.width, side.height);
      currentLeftX += side.width;
    }

    // 6. Posicionar la zona principal body en el espacio sobrante
    final b = _body;
    if (b != null && b.isVisible) {
      b.x = currentLeftX;
      b.y = currentTopY;
      final availableBodyWidth = (x + width) > currentLeftX
          ? (x + width) - currentLeftX
          : 0;
      b.width = availableBodyWidth;
      b.height = availableCenterHeight;
      b.onResize(b.width, b.height);
    }
  }

  @override
  List<CortexNode> get childrenElements => [
    if (menuBar != null) menuBar!,
    if (toolBar != null) toolBar!,
    if (sideBar != null) sideBar!,
    if (_body != null) _body!,
    if (statusBar != null) statusBar!,
  ];

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    if (menuBar != null && menuBar!.isVisible) {
      menuBar!.onUpdate(dt, input);
    }
    if (toolBar != null && toolBar!.isVisible) {
      toolBar!.onUpdate(dt, input);
    }
    if (sideBar != null && sideBar!.isVisible) {
      sideBar!.onUpdate(dt, input);
    }
    if (_body != null && _body!.isVisible) {
      _body!.onUpdate(dt, input);
    }
    if (statusBar != null && statusBar!.isVisible) {
      statusBar!.onUpdate(dt, input);
    }
  }

  @override
  void onRender(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    // 1. Dibujar zona principal (body)
    if (_body != null && _body!.isVisible) {
      _body!.onRender(ctx2d, ctx3d);
    }

    // 2. Dibujar SideBar lateral
    if (sideBar != null && sideBar!.isVisible) {
      sideBar!.onRender(ctx2d, ctx3d);
    }

    // 3. Dibujar ToolBar
    if (toolBar != null && toolBar!.isVisible) {
      toolBar!.onRender(ctx2d, ctx3d);
    }

    // 4. Dibujar StatusBar inferior
    if (statusBar != null && statusBar!.isVisible) {
      statusBar!.onRender(ctx2d, ctx3d);
    }

    // 5. Dibujar MenuBar superior
    if (menuBar != null && menuBar!.isVisible) {
      menuBar!.onRender(ctx2d, ctx3d);
    }
  }

  @override
  void onRenderOverlay(Context2D ctx2d, Context3D ctx3d) {
    if (!isVisible) return;

    if (_body != null && _body!.isVisible) {
      _body!.onRenderOverlay(ctx2d, ctx3d);
    }
    if (sideBar != null && sideBar!.isVisible) {
      sideBar!.onRenderOverlay(ctx2d, ctx3d);
    }
    if (toolBar != null && toolBar!.isVisible) {
      toolBar!.onRenderOverlay(ctx2d, ctx3d);
    }
    if (statusBar != null && statusBar!.isVisible) {
      statusBar!.onRenderOverlay(ctx2d, ctx3d);
    }
    if (menuBar != null && menuBar!.isVisible) {
      menuBar!.onRenderOverlay(ctx2d, ctx3d);
    }
  }

  @override
  void onResize(int maxWidth, int maxHeight) {
    width = maxWidth;
    height = maxHeight;
    _performLayout();
  }
}
