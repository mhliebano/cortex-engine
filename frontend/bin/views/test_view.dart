import 'package:cortex/engine/ui/ui.dart';

class TestView extends View {
  bool _isCompleted = false;
  String _activeTool = 'select';
  String _activeTab = 'editor';

  TestView() : super(id: 'test_view') {
    print("Constructor Vista de prueba");
  }

  @override
  void onInit() {
    print("init Vista de prueba");
    backgroundColor = const ColorRGBA(24, 28, 36);
    Future.delayed(const Duration(seconds: 5), () {
      print("5 segundos han pasado");
      _isCompleted = true;
      rebuild();
    });
    super.onInit();
  }

  @override
  List<Element> build() {
    return [
      DesktopLayout(
        // 1. MenuBar Superior
        menuBar: MenuBar(
          items: [
            MenuItem(
              label: "Archivo",
              icon: Icons.folder,
              subItems: [
                MenuItem(
                  label: "Nuevo Proyecto",
                  icon: Icons.file,
                  shortcut: "Ctrl+N",
                  onTap: () => print("Nuevo Proyecto"),
                ),
                MenuItem(
                  label: "Abrir Archivo...",
                  icon: Icons.folder,
                  shortcut: "Ctrl+O",
                  onTap: () => print("Abrir Archivo"),
                ),
                MenuItem(
                  label: "Guardar Cambios",
                  icon: Icons.save,
                  shortcut: "Ctrl+S",
                  onTap: () => print("Guardar Cambios"),
                ),
                MenuItem(
                  label: "Exportar Despiece",
                  shortcut: "Ctrl+E",
                  onTap: () => print("Exportar Despiece"),
                ),
                MenuItem(
                  label: "Salir",
                  icon: Icons.close,
                  shortcut: "Alt+F4",
                  onTap: () => print("Salir"),
                ),
              ],
            ),
            MenuItem(
              label: "Editar",
              icon: Icons.edit,
              subItems: [
                MenuItem(
                  label: "Deshacer",
                  icon: Icons.undo,
                  shortcut: "Ctrl+Z",
                  onTap: () => print("Deshacer"),
                ),
                MenuItem(
                  label: "Rehacer",
                  icon: Icons.redo,
                  shortcut: "Ctrl+Y",
                  onTap: () => print("Rehacer"),
                ),
                MenuItem(
                  label: "Cortar Pieza",
                  icon: Icons.cut,
                  shortcut: "Ctrl+X",
                  onTap: () => print("Cortar"),
                ),
                MenuItem(
                  label: "Copiar",
                  icon: Icons.copy,
                  shortcut: "Ctrl+C",
                  onTap: () => print("Copiar"),
                ),
                MenuItem(
                  label: "Pegar",
                  icon: Icons.paste,
                  shortcut: "Ctrl+V",
                  onTap: () => print("Pegar"),
                ),
              ],
            ),
            MenuItem(
              label: "Vista",
              icon: Icons.view3d,
              subItems: [
                MenuItem(
                  label: "Modelado 3D",
                  onTap: () => print("Toggle Grid"),
                ),
                MenuItem(
                  label: "Modo Ortogonal",
                  onTap: () => print("Toggle Ortho"),
                ),
                MenuItem(
                  label: "Maximizar Viewport",
                  shortcut: "F11",
                  onTap: () => print("Toggle Fullscreen"),
                ),
              ],
            ),
            MenuItem(
              label: "Herramientas",
              icon: Icons.settings,
              subItems: [
                MenuItem(
                  label: "Optimizador de Cortes",
                  icon: Icons.cut,
                  onTap: () => print("Abriendo Optimizador"),
                ),
                MenuItem(
                  label: "Calculadora de Materiales",
                  onTap: () => print("Calculadora"),
                ),
              ],
            ),
            MenuItem(
              label: "Ayuda",
              icon: Icons.help,
              subItems: [
                MenuItem(
                  label: "Documentación Online",
                  onTap: () => print("Docs"),
                ),
                MenuItem(
                  label: "Acerca de Cortex CAD",
                  onTap: () => print("Acerca de"),
                ),
              ],
            ),
          ],
        ),

        // 2. ToolBar de Acciones Rápidas
        toolBar: ToolBar(
          selectedToolId: _activeTool,
          onToolSelected: (id) {
            _activeTool = id;
            rebuild();
          },
          tools: [
            ToolItem(
              id: "select",
              icon: Icons.select,
              label: "Seleccionar",
              tooltip: "Seleccionar (V)",
            ),
            ToolItem(
              id: "move",
              icon: Icons.move,
              label: "Mover",
              tooltip: "Mover objeto (M)",
            ),
            ToolItem(
              id: "rotate",
              icon: Icons.rotate,
              label: "Rotar",
              tooltip: "Rotar en 3D (R)",
            ),
            ToolItem(
              id: "cut",
              icon: Icons.cut,
              label: "Cortar",
              tooltip: "Cortar pieza (C)",
            ),
            ToolItem(
              id: "measure",
              icon: Icons.measure,
              label: "Medir",
              tooltip: "Cinta métrica (D)",
            ),
          ],
        ),

        // 3. SideBar de Navegación Lateral
        sideBar: SideBar(
          activeItemId: _activeTab,

          items: [
            SideBarItem(
              id: "editor",
              icon: Icons.view3d,
              label: "Editor 3D",
              route: "editor3d",
            ),
            SideBarItem(
              id: "editor2d",
              icon: Icons.accessible,
              label: "Editor 2D",
              route: "editor2d",
            ),
            SideBarItem(
              id: "elements_ui_example",
              icon: Icons.cut,
              label: "Elements UI",
              route: "elements_ui_example",
            ),
            SideBarItem(
              id: "settings",
              icon: Icons.settings,
              label: "Ajustes",
              route: "config",
            ),
          ],
        ),

        // 4. Zona Principal ("body" / RouterView / MDI)
        body: Column(
          expand: Expand.all,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Panel(
              className: "test-panel",
              width: 320,
              height: 120,
              padding: 15,
              child: Label(text: "CORTEX ENGINE"),
            ),
          ],
        ),

        // 5. StatusBar Inferior
        statusBar: StatusBar(
          items: [
            "Herramienta: $_activeTool",
            "Vista: $_activeTab",
            "Coordenadas X: 0.0, Y: 0.0, Z: 0.0",
            "Snapping: ON",
            _isCompleted ? "Estado: Listo" : "Estado: Cargando...",
          ],
        ),
      ),
    ];
  }
}
