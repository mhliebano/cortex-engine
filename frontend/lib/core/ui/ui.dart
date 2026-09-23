/// Exportador centralizado del Motor UI (`ui.dart`).
/// Permite importar todos los elementos, layouts, componentes de escritorio y controladores con una sola línea:
/// `import 'package:cortex/core/ui/ui.dart';`
library;

export 'package:cortex/core/context2d.dart';
export 'package:cortex/core/context3d.dart';
export 'package:cortex/core/input.dart';
export 'element.dart';
export 'icons.dart';
export 'layout_alignment.dart';
export 'style.dart';
export 'text_editing_controller.dart';
export 'scroll_controller.dart';
export 'view.dart';
export 'view_manager.dart';
export 'package:cortex/core/navigator.dart';

// Componentes de Maquetación
export 'layouts/column.dart';
export 'layouts/row.dart';
export 'layouts/panel.dart';

// Componentes de Escritorio / CAD
export 'desktop/desktop_layout.dart';
export 'desktop/menu_bar.dart';
export 'desktop/tool_bar.dart';
export 'desktop/side_bar.dart';
export 'desktop/status_bar.dart';

// Componentes de Interacción y Entradas
export 'interaction/badge.dart';
export 'interaction/button.dart';
export 'interaction/card.dart';
export 'interaction/carousel.dart';
export 'interaction/checkbox.dart';
export 'interaction/chip.dart';
export 'interaction/icon_button.dart';
export 'interaction/radio_button.dart';
export 'interaction/segmented_button.dart';
export 'interaction/slider.dart';
export 'interaction/switch.dart';
export 'interaction/fab.dart';
export 'interaction/split_button.dart';
export 'interaction/icon.dart';
export 'interaction/label.dart';
export 'interaction/text_field.dart';
export 'interaction/dropdown.dart';
export 'interaction/list_tile.dart';
export 'interaction/list_view.dart';
export 'interaction/divider.dart';
export 'interaction/loading_indicator.dart';
export 'interaction/progress_bar.dart';
export 'interaction/image.dart';
export 'interaction/toast.dart';
export 'interaction/snack_bar.dart';
export 'interaction/dialog.dart';

// Componentes 3D / Viewport
export '3d/viewport_3d.dart';
