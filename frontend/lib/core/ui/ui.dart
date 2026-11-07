/// Exportador centralizado del Motor UI (`ui.dart`).
/// Permite importar todos los elementos, layouts, componentes de escritorio y controladores con una sola línea:
/// `import 'package:frontend/core/ui/ui.dart';`
library;

import 'dart:math' as math;
import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/context3d.dart';
import 'package:frontend/core/input.dart';
import 'package:frontend/core/navigator.dart';
import 'package:frontend/core/utils.dart';

import 'cortex_node.dart';
import 'element.dart';
import 'layout_rules.dart';
import 'style_rules.dart';
import 'layouts/panel.dart';
import 'controls/toast.dart';
import 'controls/snack_bar.dart';
import 'controls/dialog.dart';

export 'package:frontend/core/context2d.dart';
export 'package:frontend/core/context3d.dart';
export 'package:frontend/core/input.dart';
export 'cortex_node.dart';
export 'element.dart';
export 'icons.dart';
export 'style.dart';
export 'style_rules.dart';
export 'layout_rules.dart';
export 'layout_alignment.dart';
export 'structure_node.dart';
export 'control_node.dart';
export 'edge_insets.dart';
export 'package:frontend/core/navigator.dart';

// Componentes de Maquetación
export 'layouts/column.dart';
export 'layouts/row.dart';
export 'layouts/panel.dart';
export 'layouts/spacer.dart';
export 'layouts/splitter.dart';
export 'controls/container.dart';

// Componentes de Escritorio / CAD
export 'desktop/desktop_layout.dart';
export 'desktop/menu_bar.dart';
export 'desktop/tool_bar.dart';
export 'desktop/side_bar.dart';
export 'desktop/status_bar.dart';
export 'desktop/tab_view.dart';
export 'controls/tree_view.dart';
export 'controls/data_grid.dart';

// Componentes de Interacción y Entradas
export 'controls/badge.dart';
export 'controls/button.dart';
// export 'interaction/card.dart';
export 'controls/carousel.dart';
export 'controls/checkbox.dart';
export 'controls/chip.dart';
export 'controls/icon_button.dart';
export 'controls/radio_button.dart';
export 'controls/segmented_button.dart';
export 'controls/slider.dart';
export 'controls/switch.dart';
export 'controls/fab.dart';
export 'controls/split_button.dart';
export 'controls/icon.dart';
export 'controls/label.dart';
export 'controls/text_field.dart';
export 'controls/dropdown.dart';
export 'controls/list_tile.dart';
export 'controls/divider.dart';
export 'controls/loading_indicator.dart';
export 'controls/progress_bar.dart';
export 'controls/image.dart';
export 'controls/toast.dart';
export 'controls/snack_bar.dart';
export 'controls/dialog.dart';

// Componentes 3D / Viewport
export '3d/viewport_3d.dart';

part 'view.dart';
part 'view_manager.dart';
