import 'package:frontend/cortex_engine.dart';
import '../styles/cad_styles.dart';

/// Modelo de datos para una pieza de carpintería / despiece BOM.
class FurniturePart {
  final String id;
  final String name;
  final String material;
  final int count;
  final double length; // Largo en mm
  final double width; // Ancho en mm
  final double thickness; // Espesor en mm
  final String grain;
  final String status;
  bool isVisible;

  // Dimensiones 3D relativas
  final double posX, posY, posZ;
  final double sizeX, sizeY, sizeZ;
  final ColorRGBA color;

  FurniturePart({
    required this.id,
    required this.name,
    required this.material,
    this.count = 1,
    required this.length,
    required this.width,
    required this.thickness,
    this.grain = 'Longitudinal',
    this.status = 'Corte OK',
    this.isVisible = true,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.sizeX,
    required this.sizeY,
    required this.sizeZ,
    required this.color,
  });
}

class CadStudioView extends FluidView {
  CadStudioView()
      : super(
          id: 'cad_studio_view',
          localStyleRules: cadStyleRules,
          localLayoutRules: cadLayoutRules,
        );

  // Lista de piezas del ensamble activo (Gabinete de Cocina)
  final List<FurniturePart> _parts = [
    FurniturePart(
      id: 'lat_izq',
      name: 'Lateral Izquierdo',
      material: 'Melamina Roble 18mm',
      count: 1,
      length: 720,
      width: 580,
      thickness: 18,
      posX: -2.0,
      posY: 2.0,
      posZ: 0.0,
      sizeX: 0.1,
      sizeY: 4.0,
      sizeZ: 3.0,
      color: CadColors.woodCabinet,
    ),
    FurniturePart(
      id: 'lat_der',
      name: 'Lateral Derecho',
      material: 'Melamina Roble 18mm',
      count: 1,
      length: 720,
      width: 580,
      thickness: 18,
      posX: 2.0,
      posY: 2.0,
      posZ: 0.0,
      sizeX: 0.1,
      sizeY: 4.0,
      sizeZ: 3.0,
      color: CadColors.woodCabinet,
    ),
    FurniturePart(
      id: 'piso',
      name: 'Piso / Base Inferior',
      material: 'Melamina Roble 18mm',
      count: 1,
      length: 764,
      width: 580,
      thickness: 18,
      posX: 0.0,
      posY: 0.05,
      posZ: 0.0,
      sizeX: 3.9,
      sizeY: 0.1,
      sizeZ: 3.0,
      color: CadColors.woodCabinet,
    ),
    FurniturePart(
      id: 'techo',
      name: 'Techo / Tapa Superior',
      material: 'Melamina Roble 18mm',
      count: 1,
      length: 764,
      width: 580,
      thickness: 18,
      posX: 0.0,
      posY: 3.95,
      posZ: 0.0,
      sizeX: 3.9,
      sizeY: 0.1,
      sizeZ: 3.0,
      color: CadColors.woodCabinet,
    ),
    FurniturePart(
      id: 'estante_medio',
      name: 'Estante Fijo Medio',
      material: 'Melamina Roble 18mm',
      count: 1,
      length: 764,
      width: 560,
      thickness: 18,
      posX: 0.0,
      posY: 2.0,
      posZ: 0.0,
      sizeX: 3.9,
      sizeY: 0.08,
      sizeZ: 2.8,
      color: CadColors.woodShelves,
    ),
    FurniturePart(
      id: 'fondo',
      name: 'Fondo Trasero',
      material: 'MDF 3mm Blanco',
      count: 1,
      length: 710,
      width: 780,
      thickness: 3,
      posX: 0.0,
      posY: 2.0,
      posZ: -1.45,
      sizeX: 3.9,
      sizeY: 3.8,
      sizeZ: 0.05,
      color: const ColorRGBA(245, 245, 250, 255),
    ),
    FurniturePart(
      id: 'puerta_izq',
      name: 'Puerta Izquierda',
      material: 'MDF Laqueado Blanco 18mm',
      count: 1,
      length: 714,
      width: 395,
      thickness: 18,
      posX: -0.98,
      posY: 2.0,
      posZ: 1.55,
      sizeX: 1.9,
      sizeY: 3.8,
      sizeZ: 0.08,
      color: CadColors.doorFront,
    ),
    FurniturePart(
      id: 'puerta_der',
      name: 'Puerta Derecha',
      material: 'MDF Laqueado Blanco 18mm',
      count: 1,
      length: 714,
      width: 395,
      thickness: 18,
      posX: 0.98,
      posY: 2.0,
      posZ: 1.55,
      sizeX: 1.9,
      sizeY: 3.8,
      sizeZ: 0.08,
      color: CadColors.doorFront,
    ),
    FurniturePart(
      id: 'tiradores',
      name: 'Tiradores de Aluminio',
      material: 'Aluminio Anodizado',
      count: 2,
      length: 160,
      width: 25,
      thickness: 15,
      posX: 0.0,
      posY: 2.0,
      posZ: 1.65,
      sizeX: 0.1,
      sizeY: 0.8,
      sizeZ: 0.05,
      color: CadColors.metallic,
    ),
  ];

  String? _selectedPartId;
  bool _wireframeMode = false;
  bool _showAxes = true;
  bool _showGrid = true;

  @override
  List<Panel> build() {
    // 1. Construir Árbol de Jerarquía (TreeView)
    final rootNode = TreeNode<FurniturePart>(
      id: 'root_cabinet',
      label: 'Gabinete Cocina 800x600',
      icon: Icons.folder,
      isExpanded: true,
      children: [
        TreeNode<FurniturePart>(
          id: 'grp_structure',
          label: 'Estructura Principal',
          icon: Icons.folder,
          isExpanded: true,
          children: _parts
              .where((p) => p.id.startsWith('lat_') || p.id == 'piso' || p.id == 'techo' || p.id == 'fondo')
              .map((p) => TreeNode<FurniturePart>(
                    id: p.id,
                    label: p.name,
                    icon: Icons.dashboard,
                    data: p,
                    isVisible: p.isVisible,
                    isSelected: p.id == _selectedPartId,
                  ))
              .toList(),
        ),
        TreeNode<FurniturePart>(
          id: 'grp_shelves',
          label: 'Estantes Interiores',
          icon: Icons.folder,
          isExpanded: true,
          children: _parts
              .where((p) => p.id.contains('estante'))
              .map((p) => TreeNode<FurniturePart>(
                    id: p.id,
                    label: p.name,
                    icon: Icons.menu,
                    data: p,
                    isVisible: p.isVisible,
                    isSelected: p.id == _selectedPartId,
                  ))
              .toList(),
        ),
        TreeNode<FurniturePart>(
          id: 'grp_doors',
          label: 'Frentes y Herrajes',
          icon: Icons.folder,
          isExpanded: true,
          children: _parts
              .where((p) => p.id.contains('puerta') || p.id.contains('tirador'))
              .map((p) => TreeNode<FurniturePart>(
                    id: p.id,
                    label: p.name,
                    icon: Icons.check,
                    data: p,
                    isVisible: p.isVisible,
                    isSelected: p.id == _selectedPartId,
                  ))
              .toList(),
        ),
      ],
    );

    final treeView = TreeView<FurniturePart>(
      roots: [rootNode],
      showVisibilityToggles: true,
      showGuides: true,
      itemHeight: 26,
      onNodeSelected: (node) {
        if (node.data != null) {
          _selectedPartId = node.data!.id;
        }
      },
      onVisibilityChanged: (node, isVisible) {
        if (node.data != null) {
          node.data!.isVisible = isVisible;
        }
      },
    );

    // 2. Construir DataGrid de Despiece y Lista de Corte (BOM)
    final dataGrid = DataGrid<FurniturePart>(
      columns: [
        DataGridColumn<FurniturePart>(
          id: 'name',
          title: 'Pieza / Descripción',
          width: 170,
          cellValue: (row) => row.name,
          cellTextColor: (row) => row.id == _selectedPartId ? CadColors.accentHover : CadColors.textPrimary,
        ),
        DataGridColumn<FurniturePart>(
          id: 'material',
          title: 'Material',
          width: 160,
          cellValue: (row) => row.material,
          cellTextColor: (row) => CadColors.textSecondary,
        ),
        DataGridColumn<FurniturePart>(
          id: 'count',
          title: 'Cant.',
          width: 60,
          alignment: Alignment2D.center,
          cellValue: (row) => '${row.count}',
        ),
        DataGridColumn<FurniturePart>(
          id: 'length',
          title: 'Largo (mm)',
          width: 95,
          alignment: Alignment2D.centerRight,
          cellValue: (row) => row.length.toStringAsFixed(0),
          comparator: (a, b) => a.length.compareTo(b.length),
        ),
        DataGridColumn<FurniturePart>(
          id: 'width',
          title: 'Ancho (mm)',
          width: 95,
          alignment: Alignment2D.centerRight,
          cellValue: (row) => row.width.toStringAsFixed(0),
          comparator: (a, b) => a.width.compareTo(b.width),
        ),
        DataGridColumn<FurniturePart>(
          id: 'thickness',
          title: 'Esp. (mm)',
          width: 75,
          alignment: Alignment2D.center,
          cellValue: (row) => row.thickness.toStringAsFixed(0),
        ),
        DataGridColumn<FurniturePart>(
          id: 'grain',
          title: 'Veta',
          width: 100,
          cellValue: (row) => row.grain,
          cellTextColor: (row) => CadColors.textMuted,
        ),
        DataGridColumn<FurniturePart>(
          id: 'status',
          title: 'Estado',
          width: 90,
          alignment: Alignment2D.center,
          cellValue: (row) => row.status,
          cellTextColor: (row) => const ColorRGBA(34, 197, 94, 255),
        ),
      ],
      rows: _parts,
      rowHeight: 28,
      headerHeight: 30,
      zebraStriping: true,
      onRowSelected: (part, index) {
        _selectedPartId = part.id;
      },
    );

    // 3. Viewport3D para previsualización interactiva con GPU
    final viewport3d = Viewport3D(
      showAxes: _showAxes,
      showGrid: _showGrid,
      enableControls: true,
      onRender3D: (ctx3d) {
        // Renderizar cada pieza visible del mueble
        for (final part in _parts) {
          if (!part.isVisible) continue;

          final isSelected = part.id == _selectedPartId;
          final color = isSelected ? CadColors.accentHover : part.color;

          if (_wireframeMode) {
            ctx3d.drawBoxWires(
              part.posX,
              part.posY,
              part.posZ,
              part.sizeX,
              part.sizeY,
              part.sizeZ,
              color,
            );
          } else {
            ctx3d.drawBox(
              part.posX,
              part.posY,
              part.posZ,
              part.sizeX,
              part.sizeY,
              part.sizeZ,
              color,
            );
            // Dibujar wireframe sutil para resaltar bordes del modelo
            ctx3d.drawBoxWires(
              part.posX,
              part.posY,
              part.posZ,
              part.sizeX,
              part.sizeY,
              part.sizeZ,
              isSelected ? const ColorRGBA(255, 255, 255, 255) : const ColorRGBA(40, 44, 52, 160),
            );
          }
        }
      },
      onRender2D: (ctx2d) {
        // HUD 2D en esquina superior derecha
        final selName = _parts.firstWhere((p) => p.id == _selectedPartId, orElse: () => _parts.first).name;
        ctx2d.drawRectangle(12, 12, 280, 52, const ColorRGBA(20, 24, 33, 200));
        ctx2d.drawText('Cortex 3D Orbital Engine', 20, 20, 13, CadColors.accentHover);
        ctx2d.drawText('Pieza: $selName', 20, 38, 12, CadColors.textPrimary);
      },
    );

    // 4. TabView central para alternar vistas
    final tabView = TabView(
      tabs: [
        TabItem(
          id: 'tab_3d',
          title: 'Diseño 3D (Perspectiva)',
          icon: Icons.visibility,
          isClosable: false,
          content: viewport3d,
        ),
        TabItem(
          id: 'tab_tech',
          title: 'Plano Técnico 2D',
          icon: Icons.code,
          isClosable: false,
          content: Col(
            crossAlign: CrossAlign.center,
            mainAlign: MainAlign.center,
            children: [
              Label(text: 'Vista Técnica Acotada (Escala 1:10)'),
              Spacer(12),
              Label(text: 'Dimensiones totales del módulo: 800 mm x 600 mm x 720 mm'),
            ],
          ),
        ),
      ],
    );

    // 5. División Vertical: TabView (Arriba 68%) + DataGrid BOM (Abajo 32%)
    final centerSplitter = Splitter(
      axis: SplitterAxis.vertical,
      split: 0.68,
      minFirst: 150,
      minSecond: 100,
      first: tabView,
      second: dataGrid,
    );

    // 6. División Horizontal: TreeView (Izquierda 260px ~ 24%) + Centro Splitter (76%)
    final mainSplitter = Splitter(
      axis: SplitterAxis.horizontal,
      split: 0.24,
      minFirst: 180,
      minSecond: 300,
      first: treeView,
      second: centerSplitter,
    );

    // 7. DesktopLayout armazón completo
    return [
      Panel(
        width: double.infinity,
        height: double.infinity,
        children: [
          DesktopLayout(
            menuBar: MenuBar(
              items: [
                MenuItem(label: 'Archivo', subItems: [
                  MenuItem(label: 'Nuevo Proyecto', shortcut: 'Ctrl+N'),
                  MenuItem(label: 'Abrir...', shortcut: 'Ctrl+O'),
                  MenuItem(label: 'Guardar', shortcut: 'Ctrl+S'),
                  MenuItem(label: 'Exportar Lista de Corte (CSV)'),
                  MenuItem(label: 'Salir', shortcut: 'Alt+F4'),
                ]),
                MenuItem(label: 'Editar', subItems: [
                  MenuItem(label: 'Deshacer', shortcut: 'Ctrl+Z'),
                  MenuItem(label: 'Rehacer', shortcut: 'Ctrl+Y'),
                  MenuItem(label: 'Cortar', shortcut: 'Ctrl+X'),
                  MenuItem(label: 'Copiar', shortcut: 'Ctrl+C'),
                  MenuItem(label: 'Pegar', shortcut: 'Ctrl+V'),
                ]),
                MenuItem(label: 'Ver', subItems: [
                  MenuItem(label: 'Alternar Rejilla (Grid)', onTap: () => _showGrid = !_showGrid),
                  MenuItem(label: 'Alternar Ejes Cartesianos', onTap: () => _showAxes = !_showAxes),
                  MenuItem(label: 'Modo Wireframe', onTap: () => _wireframeMode = !_wireframeMode),
                ]),
                MenuItem(label: 'Herramientas', subItems: [
                  MenuItem(label: 'Optimizador de Corte de Placas'),
                  MenuItem(label: 'Cálculo de Costo y Material'),
                ]),
                MenuItem(label: 'Ayuda', subItems: [
                  MenuItem(label: 'Acerca de Cortex Studio'),
                ]),
              ],
            ),
            toolBar: ToolBar(
              tools: [
                ToolItem(id: 'add', icon: Icons.add, label: 'Pieza'),
                ToolItem(id: 'save', icon: Icons.save, label: 'Guardar'),
                ToolItem(
                  id: 'grid',
                  icon: Icons.visibility,
                  label: 'Rejilla',
                  onTap: () => _showGrid = !_showGrid,
                ),
                ToolItem(
                  id: 'wire',
                  icon: Icons.code,
                  label: 'Wireframe',
                  onTap: () => _wireframeMode = !_wireframeMode,
                ),
              ],
            ),
            sideBar: SideBar(
              items: [
                SideBarItem(id: 'folder', icon: Icons.folder, label: 'Proyecto'),
                SideBarItem(id: 'parts', icon: Icons.dashboard, label: 'Piezas'),
                SideBarItem(id: 'settings', icon: Icons.settings, label: 'Ajustes'),
              ],
            ),
            statusBar: StatusBar(
              items: [
                'Cortex CAD Studio v1.0.1',
                'Unidades: Milímetros (mm)',
                'Cámara: Orbital 3D',
                'FPS: 60 (Reposo 0% CPU)',
              ],
            ),
            body: mainSplitter,
          ),
        ],
      ),
    ];
  }
}
