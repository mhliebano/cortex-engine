// ignore_for_file: prefer_initializing_formals

import 'package:cortex/core/context2d.dart';
import 'package:cortex/core/context3d.dart';
import 'package:cortex/core/input.dart';
import 'package:cortex/core/ui/desktop/menu_bar.dart';
import 'package:cortex/core/ui/desktop/side_bar.dart';
import 'package:cortex/core/ui/desktop/status_bar.dart';
import 'package:cortex/core/ui/desktop/tool_bar.dart';
import 'package:cortex/core/ui/element.dart';

/// Contenedor de Disposición de Escritorio (`DesktopLayout`).
/// Organiza automáticamente los componentes principales del entorno MDI:
/// - `menuBar`: Barra de menú superior (anclada a y: 0)
/// - `toolBar`: Barra de accesos directos (anclada debajo del menú)
/// - `sideBar`: Panel lateral de herramientas o navegación (anclada a la izquierda)
/// - `statusBar`: Barra informativa inferior (anclada al borde inferior de la ventana)
/// - `body`: Zona central asignada al contenido activo / RouterView / MDI
class DesktopLayout extends Element {
  static DesktopLayout? activeLayout;

  MenuBar? menuBar;
  ToolBar? toolBar;
  SideBar? sideBar;
  StatusBar? statusBar;
  Element? _body;

  DesktopLayout({
    this.menuBar,
    this.toolBar,
    this.sideBar,
    this.statusBar,
    Element? body,
    super.expand = Expand.all,
  }) : _body = body {
    activeLayout = this;
    _performLayout();
  }

  Element? get body => _body;
  set body(Element? newBody) {
    _body = newBody;
    _performLayout();
  }

  void _performLayout() {
    int currentTopY = y;

    // 1. Posicionar MenuBar superior
    if (menuBar != null && menuBar!.isVisible) {
      menuBar!.x = x;
      menuBar!.y = currentTopY;
      menuBar!.width = width;
      menuBar!.onResize(menuBar!.width, menuBar!.height);
      currentTopY += menuBar!.height;
    }

    // 2. Posicionar ToolBar debajo de MenuBar
    if (toolBar != null && toolBar!.isVisible) {
      toolBar!.x = x;
      toolBar!.y = currentTopY;
      toolBar!.width = width;
      toolBar!.onResize(toolBar!.width, toolBar!.height);
      currentTopY += toolBar!.height;
    }

    // 3. Posicionar StatusBar anclada estrictamente al borde inferior
    int currentBottomY = y + height;
    if (statusBar != null && statusBar!.isVisible) {
      statusBar!.x = x;
      statusBar!.height = statusBar!.height > 0 ? statusBar!.height : 24;
      statusBar!.y = y + height - statusBar!.height;
      statusBar!.width = width;
      statusBar!.onResize(statusBar!.width, statusBar!.height);
      currentBottomY = statusBar!.y;
    }

    // 4. Calcular zona libre central libre entre barras superiores e inferiores
    final availableCenterHeight = currentBottomY > currentTopY
        ? currentBottomY - currentTopY
        : 0;
    int currentLeftX = x;

    // 5. Posicionar SideBar a la izquierda
    if (sideBar != null && sideBar!.isVisible) {
      sideBar!.x = currentLeftX;
      sideBar!.y = currentTopY;
      sideBar!.height = availableCenterHeight;
      sideBar!.onResize(sideBar!.width, sideBar!.height);
      currentLeftX += sideBar!.width;
    }

    // 6. Posicionar la zona principal body en el espacio sobrante
    if (_body != null && _body!.isVisible) {
      _body!.x = currentLeftX;
      _body!.y = currentTopY;
      final availableBodyWidth = (x + width) > currentLeftX
          ? (x + width) - currentLeftX
          : 0;
      _body!.width = availableBodyWidth;
      _body!.height = availableCenterHeight;
      _body!.onResize(_body!.width, _body!.height);
    }
  }

  @override
  List<Element> get childrenElements => [
    if (menuBar != null) menuBar!,
    if (toolBar != null) toolBar!,
    if (sideBar != null) sideBar!,
    if (_body != null) _body!,
    if (statusBar != null) statusBar!,
  ];

  @override
  void onUpdate(double dt, InputEngine input) {
    if (!isVisible) return;

    if (menuBar != null && menuBar!.isVisible) menuBar!.onUpdate(dt, input);
    if (toolBar != null && toolBar!.isVisible) toolBar!.onUpdate(dt, input);
    if (sideBar != null && sideBar!.isVisible) sideBar!.onUpdate(dt, input);
    if (_body != null && _body!.isVisible) _body!.onUpdate(dt, input);
    if (statusBar != null && statusBar!.isVisible)
      statusBar!.onUpdate(dt, input);
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

    if (_body != null && _body!.isVisible) _body!.onRenderOverlay(ctx2d, ctx3d);
    if (sideBar != null && sideBar!.isVisible)
      sideBar!.onRenderOverlay(ctx2d, ctx3d);
    if (toolBar != null && toolBar!.isVisible)
      toolBar!.onRenderOverlay(ctx2d, ctx3d);
    if (statusBar != null && statusBar!.isVisible)
      statusBar!.onRenderOverlay(ctx2d, ctx3d);
    if (menuBar != null && menuBar!.isVisible)
      menuBar!.onRenderOverlay(ctx2d, ctx3d);
  }

  @override
  void onResize(int allocatedWidth, int allocatedHeight) {
    super.onResize(allocatedWidth, allocatedHeight);
    _performLayout();
  }
}
