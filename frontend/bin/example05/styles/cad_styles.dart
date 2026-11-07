import 'package:frontend/core/context2d.dart';
import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/layout_rules.dart';
import 'package:frontend/core/ui/style_rules.dart';

/// Paleta de color estilo CAD Dark Studio (inspirada en Fusion 360 / Blender).
class CadColors {
  static const bgDark = ColorRGBA(24, 26, 31, 255);
  static const panelDark = ColorRGBA(32, 35, 42, 255);
  static const panelHeader = ColorRGBA(38, 42, 51, 255);
  static const border = ColorRGBA(52, 58, 70, 255);
  static const borderLight = ColorRGBA(70, 78, 92, 255);

  static const accentBlue = ColorRGBA(14, 165, 233, 255);
  static const accentHover = ColorRGBA(56, 189, 248, 255);

  static const textPrimary = ColorRGBA(243, 244, 246, 255);
  static const textSecondary = ColorRGBA(156, 163, 175, 255);
  static const textMuted = ColorRGBA(107, 114, 128, 255);

  // Colores para madera / materiales 3D
  static const woodCabinet = ColorRGBA(217, 185, 143, 255);
  static const woodShelves = ColorRGBA(198, 163, 118, 255);
  static const doorFront = ColorRGBA(240, 240, 245, 230);
  static const metallic = ColorRGBA(160, 165, 175, 255);
}

final Map<String, StyleRules> cadStyleRules = {
  'cad_root': const StyleRules(
    bgColor: CadColors.bgDark,
  ),
  'cad_panel': const StyleRules(
    bgColor: CadColors.panelDark,
    borderColor: CadColors.border,
  ),
  'cad_panel_header': const StyleRules(
    bgColor: CadColors.panelHeader,
    textColor: CadColors.textPrimary,
    fontSize: 13,
  ),
  'cad_title': const StyleRules(
    textColor: CadColors.textPrimary,
    fontSize: 16,
  ),
  'cad_subtitle': const StyleRules(
    textColor: CadColors.textSecondary,
    fontSize: 12,
  ),
  'cad_splitter': const StyleRules(
    bgColor: CadColors.border,
  ),
};

final Map<String, LayoutRules> cadLayoutRules = {
  'full_space': const LayoutRules(
    width: double.infinity,
    height: double.infinity,
  ),
  'sidebar_tree': const LayoutRules(
    width: double.infinity,
    height: double.infinity,
    padding: EdgeInsets.all(6),
  ),
  'viewport_container': const LayoutRules(
    width: double.infinity,
    height: double.infinity,
  ),
  'datagrid_container': const LayoutRules(
    width: double.infinity,
    height: double.infinity,
    padding: EdgeInsets.all(4),
  ),
};
