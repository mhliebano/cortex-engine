import 'package:cortex/core/ui/ui.dart';

class ElementsUiExample extends View {
  ElementsUiExample() : super(id: "elements_ui_example") {
    print("Constructor ElementsUiExample");
  }

  @override
  void onInit() {
    print("init ElementsUiExample");
    super.onInit();
  }

  @override
  List<Element> build() {
    return [
      Panel(
        className: "panel-container",
        expand: Expand.all,
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          isScrollable: true,
          children: [
            Label(
              className: "header-title",
              text: "Catálogo Gradual de Elementos UI",
            ),

            // 1. Texto y Etiquetas (Label)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "1. Texto y Etiquetas (Label)",
                  ),
                  Row(
                    spacing: 25,
                    children: [
                      Label(text: "Texto Normal"),
                      Label(className: "label-muted", text: "Texto Secundario"),
                      Label(
                        className: "header-title",
                        text: "Título Destacado",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Insignias e Indicadores (Badge)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "2. Insignias e Indicadores (Badge sobre Label e Ícono)",
                  ),
                  Row(
                    spacing: 35,
                    children: [
                      Badge(
                        label: "NUEVO",
                        child: Label(text: "Módulo de Diseño"),
                      ),
                      Badge(
                        label: "5",
                        child: Label(text: "Notificaciones"),
                      ),
                      Badge(child: Label(text: "Estado Servidor")),
                      Badge(
                        label: "99+",
                        child: IconButton(
                          icon: Icons.notifications,
                          variant: IconButtonVariant.tonal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Variantes de Botones Estándar (Button)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "3. Botones Estándar (Button Variants)",
                  ),
                  Row(
                    spacing: 15,
                    children: [
                      Button(
                        label: "Filled",
                        variant: ButtonVariant.filled,
                        icon: Icons.add,
                      ),
                      Button(
                        label: "Elevated",
                        variant: ButtonVariant.elevated,
                        icon: Icons.star,
                      ),
                      Button(
                        label: "Tonal",
                        variant: ButtonVariant.tonal,
                        icon: Icons.edit,
                      ),
                      Button(
                        label: "Outlined",
                        variant: ButtonVariant.outlined,
                        icon: Icons.folder,
                      ),
                      Button(
                        label: "Text Only",
                        variant: ButtonVariant.text,
                        icon: Icons.close,
                      ),
                      Button(
                        label: "Deshabilitado",
                        variant: ButtonVariant.filled,
                        enabled: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Botones de Ícono (IconButton & Toggle)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "4. Botones de Ícono e Intercalación (IconButton & Toggle)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      IconButton(
                        icon: Icons.notifications,
                        variant: IconButtonVariant.standard,
                      ),
                      IconButton(
                        icon: Icons.notifications,
                        variant: IconButtonVariant.filled,
                      ),
                      IconButton(
                        icon: Icons.notifications,
                        variant: IconButtonVariant.tonal,
                      ),
                      IconButton(
                        icon: Icons.notifications,
                        variant: IconButtonVariant.outlined,
                      ),
                      IconButton(
                        icon: Icons.favorite,
                        variant: IconButtonVariant.filled,
                        isToggle: true,
                        isSelected: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 5. Botones Conectados / Segmentados (SegmentedButton)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "5. Grupo Conectado / Segmentado (SegmentedButton)",
                  ),
                  Row(
                    spacing: 25,
                    children: [
                      SegmentedButton(
                        selectedId: "v3d",
                        items: const [
                          SegmentItem(
                            id: "v3d",
                            label: "Vista 3D",
                            icon: Icons.view3d,
                          ),
                          SegmentItem(
                            id: "v2d",
                            label: "Vista 2D",
                            icon: Icons.select,
                          ),
                          SegmentItem(
                            id: "cut",
                            label: "Cortes",
                            icon: Icons.cut,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 6. Floating Action Buttons (FAB) & Split Buttons
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "6. Acciones Flotantes y Botones Divididos (FAB & SplitButton)",
                  ),
                  Row(
                    spacing: 25,
                    children: [
                      Fab(icon: Icons.add),
                      Fab.extended(icon: Icons.add, label: "Crear Proyecto"),
                      SplitButton(
                        label: "Guardar",
                        icon: Icons.save,
                        options: [
                          SplitMenuItem(
                            label: "Guardar como...",
                            icon: Icons.save,
                          ),
                          SplitMenuItem(
                            label: "Exportar a CAD",
                            icon: Icons.folder,
                          ),
                          SplitMenuItem(
                            label: "Generar Despiece",
                            icon: Icons.cut,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 7. Tarjetas Contenedoras e Interactivas (Card)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "7. Tarjetas Contenedoras e Interactivas (Card)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Card(
                        variant: CardVariant.filled,
                        className: "card-primary",
                        width: 270,
                        title: "Modulo de Cocina",
                        subtitle: "Mueble bajo mesada 120cm",
                        icon: Icons.view3d,
                        badgeText: "POPULAR",
                        actions: [
                          Button(
                            label: "Editar",
                            variant: ButtonVariant.tonal,
                            icon: Icons.edit,
                          ),
                        ],
                      ),
                      Card(
                        variant: CardVariant.outlined,
                        className: "card-success",
                        width: 270,
                        title: "Placard Ropero",
                        subtitle: "2 Puertas corredizas",
                        icon: Icons.folder,
                        badgeText: "NUEVO",
                        actions: [
                          Button(
                            label: "Ver 3D",
                            variant: ButtonVariant.outlined,
                            icon: Icons.view3d,
                          ),
                        ],
                      ),
                      Card(
                        variant: CardVariant.elevated,
                        className: "card-purple",
                        width: 270,
                        title: "Escritorio L",
                        subtitle: "Cajonera móvil con llave",
                        icon: Icons.star,
                        actions: [
                          Button(
                            label: "Abrir",
                            variant: ButtonVariant.filled,
                            icon: Icons.folder,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 8. Carrusel Paginado (Carousel)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "8. Carrusel Paginado de Diapositivas (Carousel)",
                  ),
                  Carousel(
                    fillWidth: true,
                    height: 180,
                    autoPlay: true,
                    autoPlayIntervalSec: 3.5,
                    children: [
                      Card(
                        variant: CardVariant.filled,
                        className: "card-primary",
                        title: "Plantilla 01: Cocina Integral",
                        subtitle:
                            "Diseño optimizado para optimizador de cortes CAD",
                        icon: Icons.view3d,
                        badgeText: "PLANTILLA",
                      ),
                      Card(
                        variant: CardVariant.outlined,
                        className: "card-success",
                        title: "Plantilla 02: Ropero de Melamina",
                        subtitle: "Módulo con estantes regulables y barrotes",
                        icon: Icons.folder,
                        badgeText: "CORTES",
                      ),
                      Card(
                        variant: CardVariant.elevated,
                        className: "card-purple",
                        title: "Plantilla 03: Centro de Entretenimiento",
                        subtitle: "Panel flotante de TV con iluminación LED",
                        icon: Icons.star,
                        badgeText: "PREMIUM",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 9. Casillas de Verificación (Checkbox)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "9. Casillas de Verificación (Checkbox)",
                  ),
                  Row(
                    spacing: 30,
                    children: [
                      Checkbox(value: true, label: "Canto en 4 Lados"),
                      Checkbox(value: false, label: "Ranura de Fondo"),
                      Checkbox(value: null, label: "Estado Indeterminado"),
                      Checkbox(
                        value: true,
                        enabled: false,
                        label: "Deshabilitado",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 10. Conmutadores Deslizantes (Switch)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "10. Conmutadores Deslizantes (Switch)",
                  ),
                  Row(
                    spacing: 30,
                    children: [
                      Switch(value: true, label: "Vista Renderizada 3D"),
                      Switch(value: false, label: "Modo Oscuro CAD"),
                      Switch(value: true, enabled: false, label: "Bloqueado"),
                    ],
                  ),
                ],
              ),
            ),

            // 11. Botones de Opción Única (RadioButton & RadioGroup)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "11. Botones de Opción Única (RadioButton & RadioGroup)",
                  ),
                  RadioGroup<String>(
                    selectedValue: "mela18",
                    spacing: 30,
                    options: [
                      RadioButton(value: "mela18", label: "Melamina 18mm"),
                      RadioButton(value: "mdf15", label: "MDF 15mm"),
                      RadioButton(value: "enc25", label: "Enchapado 25mm"),
                      RadioButton(
                        value: "pino30",
                        label: "Pino 30mm (Agotado)",
                        enabled: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 12. Deslizadores Numéricos (Slider)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "12. Deslizadores Numéricos (Slider)",
                  ),
                  Row(
                    spacing: 35,
                    children: [
                      Slider(
                        value: 18.0,
                        min: 3.0,
                        max: 36.0,
                        label: "Espesor Placa",
                        valueFormatter: (val) => "${val.toStringAsFixed(0)} mm",
                      ),
                      Slider(
                        value: 45.0,
                        min: 0.0,
                        max: 90.0,
                        divisions: 6,
                        label: "Ángulo de Corte",
                        valueFormatter: (val) => "${val.toStringAsFixed(0)}°",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 13. Fichas y Etiquetas Compactas (Chip)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "13. Fichas y Etiquetas Compactas (Chip)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Chip(
                        label: "Blanco Trik",
                        variant: ChipVariant.input,
                        leadingIcon: Icons.folder,
                        onDeleted: () {},
                      ),
                      Chip(
                        label: "Canto PVC 2mm",
                        variant: ChipVariant.filter,
                        isSelected: true,
                      ),
                      Chip(
                        label: "Optimizar Despiece",
                        variant: ChipVariant.action,
                        leadingIcon: Icons.cut,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 14. Campos de Entrada de Texto (TextField)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "14. Entradas de Texto (TextField: Búsqueda, Parámetros y Contraseñas)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      TextField(
                        width: 240,
                        placeholder: "Buscar pieza o código...",
                        prefixIcon: Icons.search.glyph,
                        clearable: true,
                      ),
                      TextField(
                        width: 220,
                        text: "Largo: 2400 mm",
                        placeholder: "Dimensiones...",
                        clearable: true,
                      ),
                      TextField(
                        width: 200,
                        placeholder: "Clave de taller...",
                        obscureText: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 15. Selectores Desplegables (Dropdown / Select)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "15. Selectores Desplegables (Dropdown / Select)",
                  ),
                  Row(
                    spacing: 25,
                    children: [
                      Dropdown<String>(
                        width: 240,
                        selectedValue: "mela_18",
                        placeholder: "Seleccionar Material...",
                        options: [
                          DropdownOption(
                            value: "mela_18",
                            label: "Melamina Roble 18mm",
                            icon: Icons.folder.glyph,
                          ),
                          DropdownOption(
                            value: "mdf_15",
                            label: "MDF Blanco 15mm",
                            icon: Icons.folder.glyph,
                          ),
                          DropdownOption(
                            value: "enc_25",
                            label: "Enchapado Cedro 25mm",
                            icon: Icons.folder.glyph,
                          ),
                        ],
                      ),
                      Dropdown<String>(
                        width: 220,
                        selectedValue: "canto_2",
                        placeholder: "Tipo de Canto...",
                        options: [
                          DropdownOption(
                            value: "canto_04",
                            label: "Canto PVC 0.4mm",
                            icon: Icons.check_box_outline_blank.glyph,
                          ),
                          DropdownOption(
                            value: "canto_2",
                            label: "Canto PVC 2.0mm",
                            icon: Icons.check_box.glyph,
                          ),
                          DropdownOption(
                            value: "canto_al",
                            label: "Perfil Aluminio J",
                            icon: Icons.star.glyph,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 16. Listas Desplazables y Elementos de Lista (ListView & ListTile)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "16. Listas Desplazables (ListView & ListTile - Despiece de Mueble)",
                  ),
                  ListView(
                    height: 210,
                    fillWidth: true,
                    showDividers: true,
                    children: [
                      ListTile(
                        title: "Lateral Izquierdo",
                        subtitle: "Melamina Roble 18mm • 1800 x 580 mm",
                        leadingIcon: Icons.view_in_ar.glyph,
                        selected: true,
                        trailing: Badge(
                          label: "OK",
                          child: Icon(Icons.check_circle, size: 18),
                        ),
                      ),
                      ListTile(
                        title: "Lateral Derecho",
                        subtitle: "Melamina Roble 18mm • 1800 x 580 mm",
                        leadingIcon: Icons.view_in_ar.glyph,
                        trailingIcon: Icons.chevron_right.glyph,
                      ),
                      ListTile(
                        title: "Base Inferior",
                        subtitle: "Melamina Roble 18mm • 864 x 580 mm",
                        leadingIcon: Icons.table_chart.glyph,
                        trailingIcon: Icons.chevron_right.glyph,
                      ),
                      ListTile(
                        title: "Techo Superior",
                        subtitle: "Melamina Roble 18mm • 864 x 580 mm",
                        leadingIcon: Icons.table_chart.glyph,
                        trailingIcon: Icons.chevron_right.glyph,
                      ),
                      ListTile(
                        title: "Estante Móvil (x3)",
                        subtitle: "MDF Blanco 15mm • 862 x 550 mm",
                        leadingIcon: Icons.layers.glyph,
                        trailingIcon: Icons.chevron_right.glyph,
                      ),
                      ListTile(
                        title: "Fondo Mueble MDF",
                        subtitle: "MDF 3mm Enchapado • 1780 x 880 mm",
                        leadingIcon: Icons.texture.glyph,
                        trailingIcon: Icons.chevron_right.glyph,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 17. Divisores y Separadores (Divider)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "17. Divisores y Separadores (Divider: Horizontal y Vertical)",
                  ),
                  Label(text: "Sección 1: Especificaciones del Mueble"),
                  Divider(thickness: 1, className: "divider-subtle"),
                  Row(
                    spacing: 20,
                    children: [
                      Label(className: "label-muted", text: "Ancho: 1200mm"),
                      Divider(
                        axis: DividerAxis.vertical,
                        height: 20,
                        thickness: 1,
                        className: "divider-subtle",
                      ),
                      Label(className: "label-muted", text: "Alto: 850mm"),
                      Divider(
                        axis: DividerAxis.vertical,
                        height: 20,
                        thickness: 1,
                        className: "divider-subtle",
                      ),
                      Label(
                        className: "label-muted",
                        text: "Profundidad: 600mm",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 18. Indicadores de Carga (LoadingIndicator)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "18. Indicadores de Carga (LoadingIndicator: Circular y Puntos Pulsantes)",
                  ),
                  Row(
                    spacing: 45,
                    children: [
                      LoadingIndicator(
                        variant: LoadingVariant.circular,
                        size: 32,
                        label: "Cargando optimizador...",
                        className: "loading-blue",
                      ),
                      LoadingIndicator(
                        variant: LoadingVariant.spinner,
                        size: 32,
                        label: "Procesando CAD 3D...",
                        className: "loading-green",
                      ),
                      LoadingIndicator(
                        variant: LoadingVariant.dots,
                        size: 24,
                        label: "Sincronizando con servidor...",
                      ),
                      LoadingIndicator(
                        variant: LoadingVariant.pulse,
                        size: 28,
                        label: "Conectando cámara...",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 19. Barras de Progreso (ProgressBar)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 14,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "19. Barras de Progreso (ProgressBar: Determinado e Indeterminado)",
                  ),
                  ProgressBar(
                    fillWidth: true,
                    value: 0.75,
                    label: "Generando Despiece y Lista de Cortes CAD",
                    showPercentage: true,
                    className: "progress-blue",
                  ),
                  ProgressBar(
                    fillWidth: true,
                    value: 0.88,
                    label: "Aprovechamiento Eficiente de Placa Melamina (88%)",
                    showPercentage: true,
                    className: "progress-green",
                  ),
                  ProgressBar(
                    fillWidth: true,
                    value: null,
                    label: "Renderizando Escena 3D Raytracing (Indeterminado)",
                    className: "progress-orange",
                  ),
                ],
              ),
            ),

            // 20. Imágenes e Ilustraciones (ImageElement / Image)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "20. Imágenes e Ilustraciones (ImageElement / Image)",
                  ),
                  Row(
                    spacing: 25,
                    children: [
                      ImageElement(
                        width: 220,
                        height: 120,
                        borderRadius: 0.1,
                        fit: BoxFit.cover,
                        placeholderLabel: "Muestra Melamina Roble",
                        src: "assets/images/1.png",
                      ),
                      ImageElement(
                        width: 220,
                        height: 120,
                        borderRadius: 0.1,
                        fit: BoxFit.cover,
                        placeholderLabel: "Plano CAD 2D Despiece",
                        src: "assets/images/2.png",
                      ),
                      ImageElement(
                        width: 220,
                        height: 120,
                        borderRadius: 0.1,
                        fit: BoxFit.fill,
                        placeholderLabel: "Vista 3D Mueble Armado",
                        src: "assets/images/3.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 21. Notificaciones Emergentes (Toast)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text: "21. Notificaciones Emergentes Flotantes (Toast)",
                  ),
                  Row(
                    spacing: 15,
                    children: [
                      Button(
                        label: "Toast Info",
                        variant: ButtonVariant.tonal,
                        icon: Icons.info,
                        onPressed: () {
                          Toast.show(
                            "Módulo CAD cargado correctamente",
                            type: ToastType.info,
                          );
                        },
                      ),
                      Button(
                        label: "Toast Éxito",
                        variant: ButtonVariant.filled,
                        icon: Icons.check_circle,
                        onPressed: () {
                          Toast.show(
                            "¡Proyecto guardado exitosamente!",
                            type: ToastType.success,
                          );
                        },
                      ),
                      Button(
                        label: "Toast Advertencia",
                        variant: ButtonVariant.outlined,
                        icon: Icons.warning,
                        onPressed: () {
                          Toast.show(
                            "Atención: Espesor límite alcanzado",
                            type: ToastType.warning,
                          );
                        },
                      ),
                      Button(
                        label: "Toast Error",
                        variant: ButtonVariant.outlined,
                        icon: Icons.error,
                        onPressed: () {
                          Toast.show(
                            "Error de conexión con servidor CAD",
                            type: ToastType.error,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 22. Barras de Mensajes Rápido (SnackBar)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "22. Barras de Mensajes Rápido e Interactivo (SnackBar)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Button(
                        label: "SnackBar con Acción",
                        variant: ButtonVariant.filled,
                        icon: Icons.delete,
                        onPressed: () {
                          SnackBar.show(
                            "Pieza 'Lateral Izquierdo' eliminada del despiece",
                            actionLabel: "DESHACER",
                            onAction: () {
                              Toast.show(
                                "Acción deshecha correctamente",
                                type: ToastType.info,
                              );
                            },
                          );
                        },
                      ),
                      Button(
                        label: "SnackBar Simple",
                        variant: ButtonVariant.tonal,
                        icon: Icons.notifications,
                        onPressed: () {
                          SnackBar.show(
                            "Cortes optimizados exportados a PDF en Descargas",
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 23. Diálogos Modales y Confirmaciones (Dialog / AlertDialog)
            Panel(
              className: "panel-section",
              fillWidth: true,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(
                    className: "subsection-title",
                    text:
                        "23. Diálogos Modales y Confirmaciones (Dialog / AlertDialog)",
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Button(
                        label: "Confirmación",
                        variant: ButtonVariant.filled,
                        icon: Icons.save,
                        onPressed: () {
                          Dialog.show(
                            "Confirmar Guardado",
                            message:
                                "¿Desea guardar los cambios en el proyecto de cocina integral?",
                            icon: Icons.save,
                            confirmLabel: "Guardar",
                            onConfirm: () {
                              Toast.show(
                                "Proyecto guardado con éxito",
                                type: ToastType.success,
                              );
                            },
                          );
                        },
                      ),
                      Button(
                        label: "Diálogo de Peligro",
                        variant: ButtonVariant.outlined,
                        icon: Icons.delete,
                        onPressed: () {
                          Dialog.show(
                            "Eliminar Módulo",
                            message:
                                "Esta acción borrará permanentemente el módulo seleccionado.",
                            icon: Icons.delete,
                            confirmLabel: "Eliminar",
                            confirmVariant: ButtonVariant.filled,
                            onConfirm: () {
                              Toast.show(
                                "Módulo eliminado",
                                type: ToastType.error,
                              );
                            },
                          );
                        },
                      ),
                      Button(
                        label: "Diálogo Personalizado",
                        variant: ButtonVariant.tonal,
                        icon: Icons.add,
                        onPressed: () {
                          Dialog.show(
                            "Nuevo Parámetro de Taller",
                            child: Column(
                              spacing: 10,
                              children: [
                                Label(
                                  className: "label-muted",
                                  text: "Nombre del nuevo tipo de canto:",
                                ),
                                TextField(
                                  width: 360,
                                  placeholder: "Ej: Canto Aluminio J...",
                                  clearable: true,
                                ),
                              ],
                            ),
                            confirmLabel: "Crear Parámetro",
                            onConfirm: () {
                              Toast.show(
                                "Nuevo parámetro registrado",
                                type: ToastType.success,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
