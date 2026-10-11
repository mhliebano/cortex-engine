import 'package:frontend/core/ui/edge_insets.dart';
import 'package:frontend/core/ui/layout_alignment.dart';

/// Maneja estrictamente la matemática espacial, dimensiones y comportamiento de layout.
class LayoutRules {
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final int? spacing;
  final bool? scroll;
  final Alignment2D? align;

  const LayoutRules({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.spacing,
    this.scroll,
    this.align,
  });

  static final Map<String, LayoutRules> _registry = {};

  /// Registra una regla de layout en el registro global.
  static void register(String className, LayoutRules layout) {
    _registry[className] = layout;
  }

  /// Elimina una regla de layout del registro global.
  static void unregister(String className) {
    _registry.remove(className);
  }

  /// Obtiene una regla de layout por su identificador.
  static LayoutRules? get(String className) {
    return _registry[className];
  }

  /// Combina múltiples clases de layout separadas por espacios.
  static LayoutRules merge(String classNames) {
    double? w;
    double? h;
    double? minW;
    double? minH;
    double? maxW;
    double? maxH;
    EdgeInsets? pad;
    EdgeInsets? marg;
    int? space;
    bool? scr;
    Alignment2D? al;

    final names = classNames.split(' ');
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final l = _registry[name];
      if (l != null) {
        if (l.width != null) w = l.width;
        if (l.height != null) h = l.height;
        if (l.minWidth != null) minW = l.minWidth;
        if (l.minHeight != null) minH = l.minHeight;
        if (l.maxWidth != null) maxW = l.maxWidth;
        if (l.maxHeight != null) maxH = l.maxHeight;
        if (l.padding != null) pad = l.padding;
        if (l.margin != null) marg = l.margin;
        if (l.spacing != null) space = l.spacing;
        if (l.scroll != null) scr = l.scroll;
        if (l.align != null) al = l.align;
      }
    }

    return LayoutRules(
      width: w,
      height: h,
      minWidth: minW,
      minHeight: minH,
      maxWidth: maxW,
      maxHeight: maxH,
      padding: pad,
      margin: marg,
      spacing: space,
      scroll: scr,
      align: al,
    );
  }
}
